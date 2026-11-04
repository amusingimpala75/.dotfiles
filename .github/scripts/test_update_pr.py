"""Local integration tests: real Git repos, mocked GitHub API and Nix updates."""

import copy
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("update_pr", Path(__file__).with_name("update-pr.py"))
updater = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(updater)


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.remote = root / "remote.git"
        self.work = root / "work"
        self.git_at(root, "init", "--bare", str(self.remote))
        self.git_at(root, "clone", str(self.remote), str(self.work))
        self.git_at(self.work, "config", "user.name", "Test")
        self.git_at(self.work, "config", "user.email", "test@example.invalid")
        self.git_at(self.work, "checkout", "-b", "master")
        (self.work / "flake.lock").write_text("base\n")
        self.git_at(self.work, "add", ".")
        self.git_at(self.work, "commit", "-m", "base")
        self.git_at(self.work, "push", "origin", "master")
        self.old_cwd = Path.cwd()
        os.chdir(self.work)
        self.addCleanup(os.chdir, self.old_cwd)
        self.prs = []
        self.nix_calls = []
        self.generated = "updated\n"
        self.fail_nix = False
        self.on_nix = None
        self.on_push = None
        self.real_run = updater.run
        self.env = patch.dict(os.environ, {
            "GITHUB_REPOSITORY": "owner/repo", "UPDATE_TRACK": "bleeding",
            "REFRESH_ONLY": "false",
        })
        self.env.start()
        self.addCleanup(self.env.stop)
        for target, replacement in [("run", self.mock_run), ("api", self.api)]:
            mock = patch.object(updater, target, replacement)
            mock.start()
            self.addCleanup(mock.stop)

    @staticmethod
    def git_at(cwd, *args):
        return subprocess.run(["git", "-C", str(cwd), *args], text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              check=True).stdout.strip()

    def mock_run(self, *args, **kwargs):
        if args[0] == "nix":
            self.nix_calls.append(args)
            if self.on_nix:
                self.on_nix()
            if self.fail_nix:
                raise RuntimeError("Nix failed")
            (self.work / "flake.lock").write_text(self.generated)
            return ""
        if args[:2] == ("git", "push") and self.on_push:
            callback, self.on_push = self.on_push, None
            callback()
        return self.real_run(*args, **kwargs)

    def snapshot(self, pr):
        result = copy.deepcopy(pr)
        sha = self.git_at(self.remote, "rev-parse", "--verify", f"refs/heads/{pr['head']['ref']}")
        result["head"]["sha"] = sha
        return result

    def api(self, repo, path, method="GET", payload=None, paginate=False):
        self.assertEqual(repo, "owner/repo")
        if paginate:
            return [[self.snapshot(p) for p in self.prs if p["state"] == "open"]]
        if path == "pulls" and method == "POST":
            pr = dict(payload, number=len(self.prs) + 1, state="open",
                      html_url="https://example.invalid/pr",
                      head={"ref": payload["head"], "repo": {"full_name": repo}})
            self.prs.append(pr)
            return self.snapshot(pr)
        pr = self.prs[int(path.split("/")[1]) - 1]
        if method == "PATCH":
            pr.update(payload)
            return copy.deepcopy(pr)
        return self.snapshot(pr)

    def create(self):
        updater.main()
        self.assertEqual(len(self.prs), 1)
        return self.prs[0]

    def remote_sha(self, pr):
        return self.git_at(self.remote, "rev-parse", f"refs/heads/{pr['head']['ref']}")

    def human_push(self, pr):
        # commit-tree simulates a separate actor, without disturbing the bot checkout.
        parent = self.remote_sha(pr)
        tree = self.git_at(self.work, "rev-parse", f"{parent}^{{tree}}")
        sha = self.git_at(self.work, "commit-tree", tree, "-p", parent, "-m", "human")
        self.git_at(self.work, "push", "origin", f"{sha}:refs/heads/{pr['head']['ref']}")
        return sha

    def advance_master(self):
        parent = self.git_at(self.remote, "rev-parse", "master")
        tree = self.git_at(self.work, "rev-parse", f"{parent}^{{tree}}")
        sha = self.git_at(self.work, "commit-tree", tree, "-p", parent, "-m", "master advanced")
        self.git_at(self.work, "push", "origin", f"{sha}:master")
        return sha

    def test_refresh_only_does_not_create(self):
        os.environ["REFRESH_ONLY"] = "true"
        updater.main()
        self.assertFalse(self.prs)
        self.assertFalse(self.nix_calls)

    def test_empty_does_not_create(self):
        self.generated = "base\n"
        updater.main()
        self.assertFalse(self.prs)

    def test_create_and_reuse(self):
        pr = self.create()
        self.assertEqual(self.nix_calls[0], ("nix", "flake", "update", "nixpkgs-bleeding", "nix-index-database"))
        self.generated = "newer\n"
        updater.main()
        self.assertEqual(len(self.prs), 1)
        self.assertTrue(updater.is_managed(self.snapshot(pr), "bleeding"))
        self.assertEqual(self.git_at(self.remote, "show", f"{self.remote_sha(pr)}:flake.lock"), "newer")

    def test_full_track(self):
        os.environ["UPDATE_TRACK"] = "full"
        self.create()
        self.assertEqual(self.nix_calls[0], ("nix", "flake", "update"))

    def test_identical_run_does_not_push(self):
        pr = self.create()
        sha = self.remote_sha(pr)
        updater.main()
        self.assertEqual(self.remote_sha(pr), sha)

    def test_refresh_reparents_even_if_tree_is_unchanged(self):
        pr = self.create()
        master = self.advance_master()
        updater.main()
        self.assertEqual(self.git_at(self.remote, "rev-parse", f"{self.remote_sha(pr)}^"), master)

    def test_empty_closes_and_deletes(self):
        pr = self.create()
        self.generated = "base\n"
        updater.main()
        self.assertEqual(pr["state"], "closed")
        self.assertEqual(self.real_run("git", "ls-remote", "--heads", "origin", pr["head"]["ref"]), "")

    def test_takeover_is_persistent(self):
        pr = self.create()
        old = self.remote_sha(pr)
        human = self.human_push(pr)
        updater.main()
        self.assertEqual(self.remote_sha(pr), human)
        self.assertFalse(updater.state_of(pr)["managed"])
        self.git_at(self.work, "push", "--force", "origin", f"{old}:refs/heads/{pr['head']['ref']}")
        calls = len(self.nix_calls)
        updater.main()
        self.assertEqual(len(self.nix_calls), calls)

    def test_closed_user_pr_gets_fresh_branch(self):
        pr = self.create()
        human = self.human_push(pr)
        pr["state"] = "closed"
        os.environ["REFRESH_ONLY"] = "true"
        updater.main()
        self.assertEqual(len(self.prs), 1)
        os.environ["REFRESH_ONLY"] = "false"
        updater.main()
        self.assertEqual(len(self.prs), 2)
        self.assertNotEqual(pr["head"]["ref"], self.prs[1]["head"]["ref"])
        self.assertEqual(self.remote_sha(pr), human)

    def test_generation_failure_preserves_pr(self):
        pr = self.create()
        sha, body = self.remote_sha(pr), pr["body"]
        self.fail_nix = True
        with self.assertRaises(RuntimeError):
            updater.main()
        self.assertEqual((self.remote_sha(pr), pr["body"]), (sha, body))

    def test_takeover_during_generation(self):
        pr = self.create()
        self.generated = "newer\n"
        self.on_nix = lambda: self.human_push(pr)
        updater.main()
        self.assertFalse(updater.state_of(pr)["managed"])
        self.assertEqual(self.git_at(self.remote, "log", "-1", "--format=%s", self.remote_sha(pr)), "human")

    def test_lease_rejects_last_moment_push(self):
        pr = self.create()
        self.generated = "newer\n"
        self.on_push = lambda: self.human_push(pr)
        with self.assertRaises(subprocess.CalledProcessError):
            updater.main()
        self.assertEqual(self.git_at(self.remote, "log", "-1", "--format=%s", self.remote_sha(pr)), "human")

    def test_empty_delete_lease_protects_human_work(self):
        pr = self.create()
        self.generated = "base\n"
        self.on_push = lambda: self.human_push(pr)
        with self.assertRaises(subprocess.CalledProcessError):
            updater.main()
        self.assertEqual(pr["state"], "open")
        self.assertEqual(self.git_at(self.remote, "log", "-1", "--format=%s", self.remote_sha(pr)), "human")

    def test_empty_user_pr_is_not_closed(self):
        pr = self.create()
        human = self.human_push(pr)
        self.generated = "base\n"
        updater.main()
        self.assertEqual(pr["state"], "open")
        self.assertEqual(self.remote_sha(pr), human)

    def test_closed_during_generation_stays_closed(self):
        pr = self.create()
        old = self.remote_sha(pr)
        self.generated = "newer\n"
        self.on_nix = lambda: pr.update(state="closed")
        updater.main()
        self.assertEqual(pr["state"], "closed")
        self.assertEqual(self.remote_sha(pr), old)

    def test_missing_marker_is_untouched(self):
        pr = self.create()
        pr["body"] = "User removed state"
        calls = len(self.nix_calls)
        updater.main()
        self.assertEqual(pr["body"], "User removed state")
        self.assertEqual(len(self.nix_calls), calls)


if __name__ == "__main__":
    unittest.main()

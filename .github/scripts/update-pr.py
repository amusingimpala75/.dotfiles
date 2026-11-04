#!/usr/bin/env python3
"""Regenerate one update track. GitHub CLI, Git, and Nix are the only dependencies."""

import json
import os
import re
import subprocess
import uuid


TRACKS = {
    "full": ([], "flake: update inputs"),
    "bleeding": (["nixpkgs-bleeding", "nix-index-database"], "flake: update bleeding inputs"),
}
STATE = re.compile(r"<!-- flake-update-state: (\{[^\n]*\}) -->")


def run(*args, input=None):
    return subprocess.run(
        args, input=input, text=True, check=True, stdout=subprocess.PIPE
    ).stdout.strip()


def api(repo, path, method="GET", payload=None, paginate=False):
    args = ["gh", "api", "--method", method, f"repos/{repo}/{path}"]
    if paginate:
        args += ["--paginate", "--slurp"]
    if payload is not None:
        args += ["--input", "-"]
    result = run(*args, input=json.dumps(payload) if payload is not None else None)
    return json.loads(result) if result else None


def state_of(pr):
    match = STATE.search(pr.get("body") or "")
    if not match:
        return None
    try:
        state = json.loads(match[1])
        return state if isinstance(state, dict) else None
    except ValueError:
        return None


def marker(track, revision, managed=True):
    state = {"track": track, "revision": revision, "managed": managed}
    return f"<!-- flake-update-state: {json.dumps(state, sort_keys=True)} -->"


def is_managed(pr, track):
    state = state_of(pr)
    return bool(
        state
        and state.get("track") == track
        and state.get("managed") is True
        and state.get("revision") == pr["head"]["sha"]
    )


def remote_revision(branch):
    output = run("git", "ls-remote", "--heads", "origin", f"refs/heads/{branch}")
    return output.split()[0] if output else ""


def relinquish(repo, pr, track):
    """Persist takeover so returning to the old SHA does not restore bot ownership."""
    state = state_of(pr)
    if state and state.get("track") == track and state.get("managed") is True:
        body = STATE.sub(
            lambda _: marker(track, state.get("revision"), managed=False),
            pr.get("body") or "",
        )
        api(repo, f"pulls/{pr['number']}", "PATCH", {"body": body})
    print("User-managed PR: leaving its branch and proposal unchanged.")


def current_pr(repo, number, track, expected):
    """Recheck ownership immediately before writing; pushes also use a SHA lease."""
    pr = api(repo, f"pulls/{number}")
    if pr["state"] != "open":
        print("PR was closed while generating; leaving it closed.")
        return None
    if not is_managed(pr, track) or pr["head"]["sha"] != expected:
        relinquish(repo, pr, track)
        return None
    if remote_revision(pr["head"]["ref"]) != expected:
        relinquish(repo, pr, track)
        return None
    return pr


def main():
    track = os.environ["UPDATE_TRACK"]
    if track not in TRACKS:
        raise ValueError(f"Unknown update track: {track!r}; expected full or bleeding")
    inputs, title = TRACKS[track]
    repo = os.environ["GITHUB_REPOSITORY"]
    refresh_only = os.environ.get("REFRESH_ONLY", "false") == "true"
    prefix = f"automation/flake-{track}/"
    pages = api(repo, "pulls?state=open&base=master&per_page=100", paginate=True)
    prs = [
        pr
        for page in pages
        for pr in page
        if pr["head"]["ref"].startswith(prefix)
        and (pr["head"].get("repo") or {}).get("full_name") == repo
    ]
    if len(prs) > 1:
        raise RuntimeError(f"Multiple open {track} PRs; refusing to choose one")
    pr = prs[0] if prs else None
    if pr and not is_managed(pr, track):
        relinquish(repo, pr, track)
        return
    if not pr and refresh_only:
        print("No open PR; master pushes do not create proposals.")
        return

    expected = pr["head"]["sha"] if pr else ""
    branch = pr["head"]["ref"] if pr else prefix + uuid.uuid4().hex
    if pr and remote_revision(branch) != expected:
        relinquish(repo, pr, track)
        return

    # Never check out or execute code from the PR branch, including user edits.
    run("git", "fetch", "origin", "+refs/heads/master:refs/remotes/origin/master")
    run("git", "checkout", "--detach", "origin/master")
    run("nix", "flake", "update", *inputs)
    diff = run("git", "diff", "--name-only", "HEAD")
    if any(path != "flake.lock" for path in diff.splitlines()):
        raise RuntimeError("Update changed files other than flake.lock")

    if not diff:
        if pr:
            live = current_pr(repo, pr["number"], track, expected)
            if live:
                # Delete with a lease FIRST: a concurrent manual push must prevent
                # both deletion and our explicit close. Failure leaves work intact.
                run("git", "push", f"--force-with-lease=refs/heads/{branch}:{expected}",
                    "origin", f":refs/heads/{branch}")
                api(repo, f"pulls/{pr['number']}", "PATCH", {"state": "closed"})
                print("Closed empty bot-managed PR and deleted its branch.")
        else:
            print("No changes; nothing to propose.")
        return

    run("git", "add", "--", "flake.lock")
    tree = run("git", "write-tree")
    if pr:
        run("git", "fetch", "origin", f"refs/heads/{branch}")
        # FETCH_HEAD may have advanced since discovery. Detect takeover, don't
        # compare against (or later overwrite) a newly pushed user revision.
        if run("git", "rev-parse", "FETCH_HEAD") != expected:
            relinquish(repo, api(repo, f"pulls/{pr['number']}"), track)
            return
        if (
            tree == run("git", "rev-parse", f"{expected}^{{tree}}")
            and run("git", "rev-parse", f"{expected}^")
            == run("git", "rev-parse", "origin/master")
        ):
            print("Existing proposal already has the regenerated contents and base.")
            return

    run("git", "-c", "user.name=Flake Bot", "-c", "user.email=actions@github.com",
        "-c", "core.hooksPath=/dev/null", "-c", "commit.gpgsign=false",
        "commit", "--signoff", "-m", title)
    revision = run("git", "rev-parse", "HEAD")
    if pr:
        pr = current_pr(repo, pr["number"], track, expected)
        if not pr:
            return
    # An empty expected revision also protects creation from branch collisions.
    run("git", "push", f"--force-with-lease=refs/heads/{branch}:{expected}",
        "origin", f"HEAD:refs/heads/{branch}")
    if pr:
        # Preserve the latest PR text, and don't reclaim a branch edited just
        # after our push. A failure before recording the new SHA pauses future
        # automation conservatively rather than risking user work.
        live = api(repo, f"pulls/{pr['number']}")
        state = state_of(live)
        if live["state"] != "open":
            return
        if (
            not state
            or state.get("track") != track
            or state.get("managed") is not True
            or state.get("revision") != expected
            or live["head"]["sha"] != revision
            or remote_revision(branch) != revision
        ):
            relinquish(repo, live, track)
            return
        body = STATE.sub(lambda _: marker(track, revision), live.get("body") or "")
        api(repo, f"pulls/{pr['number']}", "PATCH", {"body": body})
        print(f"Refreshed PR #{pr['number']}.")
    else:
        body = (
            f"Updates the **{track}** input track from current `master`.\n\n"
            "Regenerated automatically; Flake Check validates this proposal. "
            "Merge manually after reviewing the checks.\n\n"
            "Pushing your own commits hands this PR over to you: the bot will "
            "stop refreshing it until it is closed or merged. "
            "The hidden state below records bot ownership; do not edit it.\n\n"
            + marker(track, revision)
        )
        created = api(repo, "pulls", "POST", {
            "title": title, "head": branch, "base": "master", "body": body,
        })
        print(f"Created {created['html_url']}.")


if __name__ == "__main__":
    main()

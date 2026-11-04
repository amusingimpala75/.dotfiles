# Automated flake update PRs

## Enable the GitHub App

An App installation token lets bot-created PRs and branch pushes trigger
`pull_request` workflows. The default `GITHUB_TOKEN` suppresses these follow-up
runs, even when the check workflow has PR triggers.

1. In your GitHub account/organization settings, create a GitHub App (for example,
   **Flake Update Bot**). A homepage URL can be this repository's URL.
   Disable **Active** under Webhook: this App does not receive webhooks.
   No callback URL or user authorization is needed.
2. Grant only these **repository permissions**:
   - **Contents: Read and write**
   - **Pull requests: Read and write**
   - Metadata read access is implicit.
   Leave organization/account permissions and event subscriptions unset.
3. Install the App on **only this repository**.
4. Generate and download a private key from the App's settings.
5. In this repository's **Settings → Secrets and variables → Actions**, add:
   - `FLAKE_UPDATE_APP_ID`: the App ID, not its client or installation ID.
   - `FLAKE_UPDATE_APP_PRIVATE_KEY`: the complete downloaded PEM private key.
6. Merge the workflows, then manually run **Flake bleeding update** or
   **Flake update**. Check that it opens a PR and that **Flake Check** runs
   automatically. Dispatching from a non-default branch is not supported:
   generation always uses current `master`.

The workflows request short-lived installation tokens scoped to this repository.
The token action revokes its token at the end of the job. No personal access
token is needed. The App cannot administer the repository, but contents write
access can change repository code: protect its private key accordingly. Rotate
the key in App settings and replace the Actions secret if it is compromised.
No branch-protection bypass is needed or recommended.

Ensure repository/organization policy allows this App and GitHub Actions.
Protect `master` with a branch ruleset requiring pull requests and the **CI passed**
status check (source: GitHub Actions). This gate requires the updater tests, both
flake checks, matrix discovery, and all package builds to succeed; failed,
cancelled, or skipped prerequisites fail the gate. Run CI once if the check is
not yet available in the ruleset picker. Individual matrix checks need not be
required separately. Add any desired review requirements. Permit force
pushes to the unprotected `automation/flake-*/` branches; refreshes replace their
generated commit. Consider dismissing stale approvals when a PR changes.
There is no automatic merge.

## Behavior

| Track | Schedule (America/New_York) | Inputs |
| --- | --- | --- |
| Bleeding | Daily, 04:00 | `nixpkgs-bleeding`, `nix-index-database` |
| Full | Monthly, day 5, 05:00 | All flake inputs, including bleeding inputs |

Each schedule or manual run can open one PR or update the track's existing open
PR. A push to `master` refreshes existing bot-managed PRs only; it does not create
PRs or reopen closed ones. Every refresh starts from current `master` and reruns
`nix flake update` for that track, so it can pick up upstream changes between
scheduled runs. Only `flake.lock` is committed.

If regeneration produces no difference from `master`, a bot-managed PR is closed
and its branch deleted. Merging the full update can therefore make the bleeding
PR disappear. Closing a PR yourself leaves it closed; the next scheduled/manual
run may open a new PR on a fresh branch.

Checks live in `flake-check.yml` and run on PRs targeting `master`, pushes to
`master`, and manual dispatch. Update generation does not duplicate those checks.
GitHub's normal PR checkout validates the proposed merge with the base branch.

### Taking over a PR

Push your own commits to its branch to take control. The bot compares the branch
head with the exact revision it last generated, recorded in a hidden PR-body
marker. Any unexpected revision, even a force-push or a GitHub web edit, stops
bot management. When observed, takeover is persisted in the marker, so resetting
the branch to its former bot revision does not restore automation. It cannot
detect a temporary change reverted before any updater run observes it.

The bot makes that one ownership-marker update, then leaves the user-managed PR
alone on all schedules, manual runs, and master pushes. Normal PR checks still
run. It will not close an empty user-managed PR, overwrite its branch, or open a
competing PR for that track. Do not edit/remove the hidden marker; missing or
invalid state conservatively pauses automation.

Close or merge a user-managed PR to free the track. The next scheduled/manual run
uses a unique new branch and preserves the old branch. Repository-wide settings
such as **Automatically delete head branches** are independent of this bot; turn
that setting off if you want GitHub itself to preserve merged manual branches.

### Failure and concurrency

Runs are serialized per track. They read current master rather than the event's
potentially stale revision. GitHub concurrency keeps only one pending run per
track, so newer events can supersede pending ones. If a scheduled creation is
superseded by a refresh-only run with no open PR, manually dispatch the track or
wait for its next schedule.

Generation failure leaves the existing branch and PR unchanged. Ownership is
rechecked before publishing; SHA leases protect branch replacements and
deletions against concurrent pushes. If someone pushes during generation, the
bot pauses or its leased push fails instead of overwriting their work.

The Git push and PR metadata update are separate API operations. If a run fails
after pushing but before recording the new revision, subsequent runs stop
conservatively. Close that PR and manually dispatch the track to start fresh.
A failure between initial branch creation and PR creation can leave an orphaned
bot branch; inspect and delete it manually. Do not repair ownership by changing
the marker unless you have verified the branch contents yourself.

## Maintenance

- `workflows/update.yml`: full-update triggers; remove this file when retiring
  automatic full updates. Local `just update` remains available.
- `workflows/update-bleeding.yml`: bleeding-update triggers.
- `workflows/update-pr.yml`: shared job and App authentication.
- `scripts/update-pr.py`: PR lifecycle and ownership safeguards.

Local validation (no GitHub credentials or Nix evaluation needed):

```sh
actionlint
python3 -m unittest discover -s .github/scripts -p 'test_*.py'
```

The tests use temporary real Git repositories and mock GitHub/Nix. They do not
modify this checkout's lockfile, contact GitHub, or exercise live App credentials.

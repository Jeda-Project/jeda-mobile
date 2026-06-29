# /merge-pr — Merge Pull Request

Merge an approved PR.

## Pre-Merge Checklist

- [ ] PR has at least 1 approval (or self-review with no CRITICAL/HIGH issues)
- [ ] All CI checks are green (ios-ci.yml passed)
- [ ] Branch is up-to-date with `main`
- [ ] No unresolved review comments

## Steps

1. Use GitHub MCP `get_pull_request` to confirm PR status and reviews
2. Use GitHub MCP `get_pull_request_status` to confirm CI checks are green
3. If branch is behind `main`: use GitHub MCP `update_pull_request_branch`
4. Use GitHub MCP `merge_pull_request` with `merge_method: "squash"` (for feature branches)
5. Confirm the merge succeeded
6. Delete the local feature branch: `git branch -d <branch>`

## After Merge

- Pull `main` locally: `git checkout main && git pull origin main`
- If there are Core ML model changes: ensure `.mlpackage` is committed correctly
- If there are API endpoint changes: ensure the `APIEndpoint` protocol is in sync with the backend

## Notes

- **Do not force-push to `main`** — the safety hook will block it
- Squash merge is preferred to keep `main` history clean and linear

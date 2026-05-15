---
name: crush-code
description: Autonomous issue-driven development loop for any repo. Works GitHub Issues one by one using TDD and caveman mode, opens auto-merge PRs, resolves CI failures and merge conflicts, and pings the user via Telegram only when truly blocked. Use when user says "get to work", "work the issues", "keep going", or invokes /crush-code.
---

# ericdahl-crush-code

## Mandatory preamble (every session)

Before any other action load three sibling skills. Find them relative to wherever this skill was installed (e.g. `~/.config/crush/skills/`, `~/.claude/skills/`, or the cloned repo path):

1. `caveman/SKILL.md` — apply caveman mode for all user-facing output
2. `tdd/SKILL.md` — apply red-green-refactor for all code changes
3. `frontend-design/SKILL.md` — apply for any view/template/CSS work: bold aesthetic direction, distinctive typography, cohesive palette, intentional motion

## Communication tools

| Tool | When |
|------|------|
| `telegram_send_message` | Fire-and-forget status (PR opened, CI red, blocked) |
| `telegram_ask` | Block and wait for human input (ambiguous requirement, risky delete, credentials needed) |

Telegram only when truly stuck. Prefer autonomous decisions.

## Issue loop

```
REPEAT:
  0. pr_health        — fix open PRs (CI red, conflicts, stale) before new work
  1. pick_issue       — find next actionable issue
  2. branch           — create feature branch
  3. tdd_loop         — red → green → refactor
  4. push + pr        — open PR with auto-merge
  5. ci_watch         — monitor CI; fix failures
  6. conflict_check   — rebase if needed
  7. done             — move to next issue
```

### 0. PR health check (runs FIRST, every iteration)

Scan all open PRs before touching new work. Fixing blockers keeps the merge queue flowing in order.

```bash
gh pr list --state open --json number,title,headRefName,mergeable,reviewDecision,statusCheckRollup \
  --jq '.[] | {number,title,branch:.headRefName,mergeable,checks:.statusCheckRollup}'
```

For each open PR, resolve in this priority order:

**A. Red CI** — any PR with failing checks:
```bash
gh pr checks <PR>                          # identify failing checks
gh run view <RUN_ID> --log-failed          # read failure logs
# checkout branch, fix, push
git checkout <branch>
# ... fix ...
git push
```

**B. Merge conflicts** — `mergeable == "CONFLICTING"`:
```bash
git checkout <branch>
git fetch origin main
git rebase origin/main
# resolve conflicts
git add .
git rebase --continue
git push --force-with-lease
```

**C. Stale / needs rebase** — branch is behind main (not conflicting but diverged):
```bash
git checkout <branch>
git fetch origin main
# check if behind:
git log HEAD..origin/main --oneline
# if any commits: rebase
git rebase origin/main
git push --force-with-lease
```

**D. Stuck auto-merge** — PR has passing CI but auto-merge not enabled:
```bash
gh pr merge <PR> --auto --squash
```

Only move to step 1 once all open PRs are either merged, conflict-free with green CI, or genuinely blocked (requiring human input — use `telegram_ask`).

If a PR is blocked and needs human decision: `telegram_ask` "PR #<PR> blocked: <reason>. Options?" with buttons ["Fix it", "Close PR", "Skip for now"]

### 1. Pick issue

```bash
gh issue list --label ready-for-agent --state open --limit 1 \
  --json number,title,body --jq '.[0]'
```

If none: `telegram_send_message` "no ready-for-agent issues. triage first?" then stop.

### 2. Branch

```bash
git checkout main && git pull
git checkout -b issue-<NUMBER>-<slug>
```

Slug = title lowercased, spaces→hyphens, max 40 chars.

### 3. TDD loop (follow tdd SKILL.md exactly)

- Red: write failing spec first
- Green: minimal code to pass
- Refactor: clean up
- Run `rvm use . && bundle exec rspec <spec_file>` after each phase
- Run full suite before pushing: `bundle exec rspec`
- Run `bundle exec rubocop --autocorrect` then `bundle exec brakeman -q`

### 4. Push + PR

```bash
git push -u origin HEAD

gh pr create \
  --title "<issue title>" \
  --body "$(cat <<'BODY'
Closes #<NUMBER>

## What
<one line>

## Test plan
- [ ] RSpec suite passes
- [ ] Rubocop clean
- [ ] Brakeman clean
BODY
)" \
  --label "ready-for-agent"

gh pr merge --auto --squash
```

Send: `telegram_send_message` "PR #<PR> opened for issue #<NUMBER> — auto-merge on."

### 5. CI watch

Poll every 60 s:

```bash
gh pr checks <PR> --watch
```

On failure:
- Read CI logs: `gh run view <RUN_ID> --log-failed`
- Fix, commit, push
- If fix needs human decision: `telegram_ask` with buttons ["Fix it", "Skip", "Close issue"]

### 6. Conflict check

Before PR can merge, rebase if needed:

```bash
git fetch origin main
git rebase origin/main
# resolve conflicts, then:
git push --force-with-lease
```

### 7. Close & iterate

After merge:
```bash
git checkout main && git pull
```
Send: `telegram_send_message` "issue #<NUMBER> merged. moving to next."

Loop back to step 1.

## Blocked criteria (use telegram_ask)

- Requirement is genuinely ambiguous after reading issue + codebase
- Change would delete data or alter schema destructively
- CI failure root cause is missing credentials or external service
- Conflict cannot be resolved without knowing intended behavior

## Never stop for

- Large number of files to change
- Multiple issues queued
- Tests that were already failing before this branch (note them, skip)

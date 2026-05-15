---
name: crush-code
description: Autonomous issue-driven development loop for any repo. Works issues one by one using TDD and caveman mode, opens auto-merge PRs, resolves CI failures and merge conflicts, and pings the user via Telegram only when truly blocked. Use when user says "get to work", "work the issues", "keep going", or invokes /crush-code.
---

# crush-code

## Mandatory preamble (every session)

Before any other action load three sibling skills. Find them relative to wherever this skill was installed (e.g. `~/.config/crush/skills/`, `~/.claude/skills/`, or the cloned repo path):

1. `caveman/SKILL.md` — apply caveman mode for all user-facing output
2. `tdd/SKILL.md` — apply red-green-refactor for all code changes
3. `frontend-design/SKILL.md` — apply for any view/template/CSS work: bold aesthetic direction, distinctive typography, cohesive palette, intentional motion

## Issue tracker detection

Before starting, detect how issues are tracked in this repo. Check in order:

1. **`docs/agents/issue-tracker.md`** — explicit config (from `setup-matt-pocock-skills`). Read it and follow its commands exactly.
2. **GitHub remote** — `git remote -v` contains `github.com` → use `gh issue` CLI.
3. **GitLab remote** — `git remote -v` contains `gitlab.com` → use `glab issue` CLI.
4. **`.scratch/`** directory exists → local markdown issues (see below).
5. **Fallback** — ask via `telegram_ask` "How are issues tracked in this repo?" then follow instructions.

### Local markdown issues (`.scratch/`)

- List: `ls .scratch/` — each subdirectory is an issue
- Read: `cat .scratch/<name>/issue.md`
- Close: move to `.scratch/done/<name>/` or delete

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

**GitHub:**
```bash
gh pr list --state open --json number,title,headRefName,mergeable,statusCheckRollup \
  --jq '.[] | {number,title,branch:.headRefName,mergeable,checks:.statusCheckRollup}'
```

**GitLab:**
```bash
glab mr list --state opened
```

For each open PR/MR, resolve in this priority order:

**A. Red CI** — any PR with failing checks:
```bash
# GitHub
gh pr checks <PR>
gh run view <RUN_ID> --log-failed
# GitLab
glab ci view --pipeline-id <ID>
```
Checkout branch, fix, push.

**B. Merge conflicts** — `mergeable == "CONFLICTING"` (or GitLab shows conflicts):
```bash
git checkout <branch>
git fetch origin main
git rebase origin/main
git add . && git rebase --continue
git push --force-with-lease
```

**C. Stale / needs rebase** — branch is behind main:
```bash
git checkout <branch>
git fetch origin main
git log HEAD..origin/main --oneline   # any output = behind
git rebase origin/main
git push --force-with-lease
```

**D. Stuck auto-merge** — passing CI but auto-merge not enabled:
```bash
gh pr merge <PR> --auto --squash      # GitHub
glab mr merge <MR> --squash           # GitLab
```

Only move to step 1 once all open PRs/MRs are resolved or genuinely blocked.

If blocked: `telegram_ask` "PR blocked: <reason>. Options?" with buttons ["Fix it", "Close PR", "Skip for now"]

### 1. Pick issue

Use whichever tracker was detected:

**GitHub:**
```bash
gh issue list --label ready-for-agent --state open --limit 1 \
  --json number,title,body --jq '.[0]'
```

**GitLab:**
```bash
glab issue list --label ready-for-agent --state opened --per-page 1
```

**Local markdown:**
```bash
ls .scratch/ | head -1   # pick first open issue dir
cat .scratch/<name>/issue.md
```

If none found: `telegram_send_message` "no ready-for-agent issues. triage first?" then stop.

### 2. Branch

```bash
git checkout main && git pull
git checkout -b issue-<NUMBER>-<slug>
```

Slug = title lowercased, spaces→hyphens, max 40 chars.

### 3. TDD loop (follow tdd SKILL.md exactly)

- Red: write failing test first
- Green: minimal code to pass
- Refactor: clean up
- Run the project's test suite after each phase (check `docs/agents/` or `AGENTS.md` for the correct command)
- Run linters/security scanners if configured

### 4. Push + PR

```bash
git push -u origin HEAD
```

**GitHub:**
```bash
gh pr create \
  --title "<issue title>" \
  --body "Closes #<NUMBER>

## What
<one line>

## Test plan
- [ ] Tests pass
- [ ] Linter clean" \
  --label "ready-for-agent"
gh pr merge --auto --squash
```

**GitLab:**
```bash
glab mr create --title "<issue title>" --description "Closes #<NUMBER>" --squash-before-merge
```

Send: `telegram_send_message` "PR opened for issue #<NUMBER> — auto-merge on."

### 5. CI watch

**GitHub:** `gh pr checks <PR> --watch`
**GitLab:** `glab ci view`

On failure:
- Read logs and fix
- If fix needs human decision: `telegram_ask` with buttons ["Fix it", "Skip", "Close issue"]

### 6. Conflict check

```bash
git fetch origin main
git rebase origin/main
git push --force-with-lease
```

### 7. Close & iterate

After merge:
```bash
git checkout main && git pull
```

**Close issue if not auto-closed by PR:**
- GitHub: `gh issue close <NUMBER>`
- GitLab: `glab issue close <NUMBER>`
- Local: `mv .scratch/<name> .scratch/done/`

Send: `telegram_send_message` "issue #<NUMBER> merged. moving to next."

Loop back to step 0.

## Blocked criteria (use telegram_ask)

- Requirement is genuinely ambiguous after reading issue + codebase
- Change would delete data or alter schema destructively
- CI failure root cause is missing credentials or external service
- Conflict cannot be resolved without knowing intended behavior

## Never stop for

- Large number of files to change
- Multiple issues queued
- Tests that were already failing before this branch (note them, skip)

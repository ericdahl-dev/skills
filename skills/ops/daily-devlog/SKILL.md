---
name: daily-devlog
description: Gather today's verified work (commits, PRs, deployments) across all relevant GitHub accounts and repos, then create or update today's markdown entry in the edahl_UND.github.io devlog. Use when the user says "update the devlog", "add today's log", "log today's work", or "what did I do today".
---

# Daily Devlog

Gathers verifiable work evidence and writes/replaces `entries/YYYY-MM-DD.md` in `~/Documents/GitHub/edahl_UND.github.io/`. Safe to run multiple times a day — always rebuilds today's file from scratch using all available evidence.

## Quick start

```
"update the devlog"
```

## Workflow

**Scope: `edahl_UND` account only.** Do not include activity from `ericdahl-dev`, `Skeyelab`, or any other account.

### 1. Gather evidence (run in parallel)

```bash
TODAY=$(date +%Y-%m-%d)

# PRs — annex-ims (edahl_UND only)
gh pr list --repo ndlibrary/annex-ims --author edahl_UND \
  --state all --limit 30 \
  --json number,title,state,createdAt,mergedAt,url,headRefName

# PRs — annex-blueprints-cdk (edahl_UND only)
gh pr list --repo ndlibrary/annex-blueprints-cdk --author edahl_UND \
  --state all --limit 20 \
  --json number,title,state,createdAt,mergedAt,url,headRefName

# Commits today — annex-blueprints-cdk
gh api "repos/ndlibrary/annex-blueprints-cdk/commits?since=${TODAY}T00:00:00Z&author=edahl_UND" \
  --jq '.[].commit | "\(.author.date[:16]) \(.message | split("\n")[0])"'

# Check for other ndlibrary repos with activity today
gh api "orgs/ndlibrary/repos?sort=updated&per_page=30" --jq '.[].name'
# For any repo updated today, run:
# gh pr list --repo ndlibrary/REPO --author edahl_UND --state all --limit 10 \
#   --json number,title,state,createdAt,mergedAt,url
```

Filter all results to today's date only. Discard any activity not authored by `edahl_UND`. Note: the GitHub commits API `author=` filter is not always reliable — cross-check PR author via `gh pr view N --json author` if uncertain.

Filter all results to today's date only.

### 1b. Clarify and supplement (ask the user)

After gathering evidence, ask in a single message:

1. **Anything unclear?** — If any commit message or PR title is ambiguous, ask before writing prose. E.g. "PR #23 says 'disable rollback test' — was this a circuit-breaker config change or a test suite fix?"
2. **Anything to add?** — *"Any deployments, pipeline runs, infra changes, or other work to include that won't show up in git?"* (AWS CodePipeline, Coolify, Jira tickets closed, etc.)

Wait for the response before writing the entry.

### 2. Write the entry file

Target: `~/Documents/GitHub/edahl_UND.github.io/entries/YYYY-MM-DD.md`

- If the file **exists** → overwrite it completely with freshly gathered data.
- If it **doesn't exist** → create it.

Use the `write` tool.

### 3. Entry format

Match this exactly — structure, tone, and prose style are the standard:

```markdown
---
date: YYYY-MM-DD          # for weekly entries: the Monday start date
type: week                # omit this line for single-day entries
tags: [tag, tag]
title: Lowercase punchy one-liner that names the biggest thing that shipped
---

The main push today was [lead with the most significant thing]. [What was the blocker or interesting problem?] [What else landed?]

*(For weekly entries, replace "today" with the week span, e.g. "The week of Apr 27 …". Prose covers the full Mon–Sun range.)*

## repo-name

| PR | Summary | Status |
|----|---------|--------|
| [#N](URL) | Ticket ID + plain-language description of what changed | merged |
| [#N](URL) | WIP — brief description | open |

## repo-name-2

| PR | Summary | Status |
|----|---------|--------|
| [#N](URL) | Plain-language description | merged |

## infra

(only if there is infra/deployment work with no git trail)

| What | Notes |
|------|-------|
| [Service name](URL) | One sentence: what was done and what it unblocked |
```

**Prose rules:**
- Lead with the most impactful thing, not a list
- Name the specific blocker or interesting problem if there was one
- 2–3 sentences max, written like a human engineer's standup note
- Use backticks for code/config values inline

**Table rules:**
- PR summary starts with the Jira ticket ID if one exists (e.g. `WSE-663:`)
- Status: `merged` · `open` · `closed`
- Only include `## infra` section if there's non-git work to record
- Omit empty sections entirely

Tags: `rails` · `aws` · `bootstrap` · `cdk` · `ci` · `specs` · `docker` · `infra`

### 4. Register in manifest (if new date)

Open `~/Documents/GitHub/edahl_UND.github.io/app.js` and check the `ENTRIES` array at the top. Each entry is an object with `date` and `type`. If the date is not already present, prepend it (newest first):

```js
const ENTRIES = [
  { date: "YYYY-MM-DD", type: "day" },   // ← single-day entry
  { date: "YYYY-MM-DD", type: "week" },  // ← weekly entry (covers Mon–Sun)
  ...
];
```

- Use `type: "day"` for single-day entries.
- Use `type: "week"` when the entry covers a full week (Mon–Sun). The `date` is the **Monday** (start of the week). The sidebar renders these as `Wk:YYYY-MM-DD`.
- The entry file is always named after the `date` value (e.g. `entries/2026-04-27.md`).

Use the `edit` tool for this.

### 5. Commit and push

Always use the absolute path — the skill may be invoked from any repo. Capture the original directory first and return to it after.

```bash
ORIGIN=$(pwd)
DEVLOG=~/Documents/GitHub/edahl_UND.github.io
cd $DEVLOG
git add entries/ app.js
git commit -m "devlog: YYYY-MM-DD"
git push
cd $ORIGIN
```

## Rules

- **Overwrite, never append** — the file is rebuilt fresh each run.
- **Ask before assuming** — if a commit or PR is ambiguous, ask rather than guess.
- **Always ask what to add** — git evidence is never the complete picture.
- **Only verified work** — commits, PRs, or explicitly stated additions. No speculation.
- **Prose first** — the opening paragraph reads like a human wrote it, not a bullet list.
- **Newest entry first** in the `ENTRIES` manifest.
- If nothing verifiable exists, say so and skip.

## Site layout

```
edahl_UND.github.io/
├── index.html          # reader shell (sidebar + marked.js renderer)
├── app.js              # ENTRIES manifest + fetch/render logic
├── style.css           # dark terminal aesthetic
└── entries/
    ├── 2026-05-12.md
    └── YYYY-MM-DD.md   ← skill writes here
```

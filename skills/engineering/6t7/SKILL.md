---
name: 6t7
description: Given a Jira ticket URL, check whether the ticket's work is complete and correct in the context of the Rails 6→7 upgrade for annex-ims (IRIS). Reads the ticket, inspects the relevant code, then moves to Code Review or surfaces gaps. Use when user provides a Jira URL and says "check this ticket", "is this done", or pastes a hesburghlibraries.atlassian.net browse link.
---

# Jira Ticket Check — Rails 6→7 Upgrade

## Goal

Verify that a ticket's intent is **fully and correctly implemented** in the current `bootstrap5-eric` branch, specifically through the lens of the Rails 6→7 / Bootstrap 3→5 / DataTables→Turbo migration.

## Workflow

### 1. Parse the URL
Extract the issue key (e.g. `WSE-694`) and cloudId (`hesburghlibraries.atlassian.net`).

### 2. Fetch the ticket
`getJiraIssue` with `responseContentFormat: markdown`. Note summary, description, comments, and current status.

### 3. Find and read the code
From the summary, infer affected files and read them. Do not assume — always read.

- Controllers: `app/controllers/<resource>_controller.rb`
- Views: `app/views/<resource>/` (all templates + partials)
- Models: `app/models/<resource>.rb`
- Specs: `spec/controllers/`, `spec/models/`, `spec/helpers/`
- JS: `app/javascript/controllers/`
- Helpers: `app/helpers/application_helper.rb`

Also check `TICKET_COMPLETION.md` at the repo root for prior recorded evidence.

### 4. Evaluate against upgrade checklist

| Area | Done looks like | Not done looks like |
|------|----------------|---------------------|
| **DataTables removal** | Turbo Frame + Kaminari pagination, or plain `%table` for bounded lists | `data: {controller: "datatables"}` in views |
| **Delete actions** | `data: { turbo_method: :delete }` or `button_to method: :delete` | `link_to method: :delete` (Rails UJS style) |
| **Form error handling** | `render :new, status: :unprocessable_entity` | bare `render :new` |
| **Bootstrap 5** | `data-bs-toggle`, `data-bs-target`, BS5 utility classes | `data-toggle`, `data-target`, BS3/4 classes |
| **Sort/filter** | `SortRelation` service + `build_link`/`sort_indicator` helpers | raw `.order(params[:column])` or inline sort logic |
| **JS lifecycle** | Stimulus `connect()`/`disconnect()` hooks | `$(document).ready()` |
| **Specs** | Spec exists, covers the changed behavior, passes | Missing spec, or spec tests old pattern |
| **Rubocop** | No obvious style violations in touched files | New offenses introduced |

### 5. Decide and act

**"Done" in this skill means: the ticket is in Code Review status.**

If the ticket is already in Code Review → confirm that and stop.

If the code checks out (upgrade patterns correct, specs present) → this IS the completion action:
1. `getTransitionsForJiraIssue` → use id `51` (Code Review)
2. `transitionJiraIssue` to Code Review (skip if already in Code Review)
3. Check existing comments first — if the most recent comment by Eric Dahl already lists verified files and confirmed patterns (i.e. a prior 6t7 run), **do not add a new comment**. Only call `addCommentToJiraIssue` if no accurate prior 6t7 comment exists.

If the code has gaps → do NOT move the ticket:
1. List each gap with the specific file path and line
2. State what the correct Rails 7 pattern should be
3. Ask: "Want me to implement this, or discuss first?"

## Jira transitions (hesburghlibraries.atlassian.net)

| Status | ID |
|--------|----|
| To Do | 11 |
| In Progress | 21 |
| Code Review | 51 |
| UA | 41 |
| Done | 31 |
| Blocked | 61 |

## Notes

- Blank ticket descriptions are normal — rely on summary + comments + `TICKET_COMPLETION.md`
- TypeProf LSP errors in controller/spec files are noise — ignore them
- Bounded lists (e.g. trays per shelf) don't need pagination; a plain `%table` is correct
- The active branch is `bootstrap5-eric`; all checks are against that branch

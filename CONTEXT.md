# crush-skills — Context

## What this repo is

A curated collection of AI agent skills for real engineering work. Skills are markdown files (`SKILL.md`) that AI agents read and follow when invoked by name (e.g. `/tdd`, `/diagnose`).

Works with any agent that reads markdown: Crush, Claude Code, Cursor, Windsurf, GitHub Copilot.

## Structure

```
skills/
  engineering/   — code-focused skills (tdd, diagnose, triage, etc.)
  productivity/  — workflow skills (caveman, handoff, prototype, etc.)
  creative/      — design and copy skills
  ops/           — infrastructure and devlog skills
scripts/
  link-skills.sh       — install skills into editor skill dirs
  sync-upstream.sh     — fetch latest versions of adopted skills
.github/workflows/
  sync-upstream.yml    — weekly automated upstream sync → PR
```

## Skill taxonomy

- **Original** — created in-house (crush-code, github-triage, daily-devlog, creative skills, etc.)
- **Adopted** — sourced from upstream open-source repos with attribution:
  - [mattpocock/skills](https://github.com/mattpocock/skills)
  - [codecoincognition/vibe-guard-skills](https://github.com/codecoincognition/vibe-guard-skills)

## Pages

The repo publishes a skill directory via GitHub Pages. Each `SKILL.md` with valid YAML frontmatter (`name`, `description`) renders as a browsable page.

## Key invariants

- Every skill in `skills/` has a row in `README.md`
- Every adopted skill file has an entry in `scripts/sync-upstream.sh`
- All `SKILL.md` files have valid `name` + `description` frontmatter

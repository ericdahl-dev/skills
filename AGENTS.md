# crush-skills — Agent Configuration

## Agent skills

### Issue tracker

Issues live in GitHub Issues for this repo (`ericdahl-dev/skills`). See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical label vocabulary (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Conventions

### Adding a skill

1. Place the skill under `skills/<category>/<skill-name>/SKILL.md` (and any sibling reference files).
2. Add a row to the correct table in `README.md` (Original or Adopted section).
3. If adopted, add every file to the `UPSTREAM_MAP` array in `scripts/sync-upstream.sh`.
4. Ensure `SKILL.md` has valid YAML frontmatter (`name`, `description`) — Pages uses this to render the skill index.

### Adopting a skill from upstream

1. Find the raw file URL(s) for the skill in the upstream repo.
2. Copy the skill files into `skills/<category>/<skill-name>/`.
3. Add a row to the **Adopted Skills** section of `README.md`, grouped under the correct upstream source. If the source repo isn't listed yet, add a new `### From [org/repo](url)` subsection.
4. Add every file to `UPSTREAM_MAP` in `scripts/sync-upstream.sh` so it stays in sync automatically.
5. Ensure `SKILL.md` has valid frontmatter (`name`, `description`).

### Removing a skill

1. Delete the skill directory from `skills/`.
2. Remove the row from `README.md`.
3. If adopted, remove its entries from `UPSTREAM_MAP` in `scripts/sync-upstream.sh`.
4. Remove from local editor installs if needed (`scripts/link-skills.sh`).

### Pages

The repo publishes a browsable skill directory via GitHub Pages. Each `SKILL.md` renders as a page. When adding or updating skills, valid frontmatter (`name`, `description`) is required — broken frontmatter will break the Pages build.

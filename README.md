# claude-skills

Custom AI agent skills for real engineering work — not vibe coding.

Built for **Claude Code** and compatible with any agent that reads markdown: Cursor, Windsurf, GitHub Copilot, and others.

---

## Quick install

```bash
git clone https://github.com/ericdahl-dev/skills ~/.claude-skills
cd ~/.claude-skills
./scripts/link-skills.sh
```

The script asks which editors to install into, then symlinks each skill into the right directory:

| Editor | Skills directory |
|--------|-----------------|
| [Claude Code CLI](https://claude.ai/code) | `~/.claude/skills/` |
| [Cursor](https://cursor.com) | `~/.cursor/rules/` |
| [Windsurf](https://codeium.com/windsurf) | `~/.codeium/windsurf/memories/` |
| GitHub Copilot Chat | `~/.github/copilot/skills/` |

Or pass editors directly:

```bash
./scripts/link-skills.sh claude
```

---

## How skills work

Each skill is a `SKILL.md` file. When you invoke the skill name (e.g. `/tdd`, `/diagnose`) in your agent, it reads the file and follows the instructions inside. Skills compose — many reference sibling skills.

**Invoking a skill:**
- Claude Code: `/skill-name`
- Cursor / Windsurf: `@skill-name` or reference by name in chat
- Any agent: paste or attach the `SKILL.md` content, or instruct the agent to read it

---

## Original Skills

Skills created in-house.

### Engineering

| Skill | Description |
|-------|-------------|
| [`crush-code`](skills/engineering/crush-code/SKILL.md) | Autonomous issue-driven dev loop (TDD, auto-merge PRs, PR health) |
| [`github-triage`](skills/engineering/github-triage/SKILL.md) | Label-based GitHub issue triage state machine |

### Productivity

| Skill | Description |
|-------|-------------|
| [`find-skills`](skills/productivity/find-skills/SKILL.md) | Discover and install new agent skills |

### Creative

| Skill | Description |
|-------|-------------|
| [`copywriting`](skills/creative/copywriting/SKILL.md) | Marketing copy for landing pages, features, pricing |
| [`frontend-design`](skills/creative/frontend-design/SKILL.md) | Production-grade UI with bold aesthetic direction |
| [`landing-page-copywriter`](skills/creative/landing-page-copywriter/SKILL.md) | High-converting copy (PAS, AIDA, StoryBrand) |
| [`web-design-guidelines`](skills/creative/web-design-guidelines/SKILL.md) | UI/UX + accessibility audit |

### Ops

| Skill | Description |
|-------|-------------|
| [`coolify-manager`](skills/ops/coolify-manager/SKILL.md) | Manage and troubleshoot Coolify deployments |
| [`daily-devlog`](skills/ops/daily-devlog/SKILL.md) | Gather today's commits/PRs and write a devlog entry |

---

## Adopted Skills

Skills adopted from other open-source skill repos. Credit to the original authors.

### From [codecoincognition/vibe-guard-skills](https://github.com/codecoincognition/vibe-guard-skills)

| Skill | Description |
|-------|-------------|
| [`vibe-check`](skills/engineering/vibe-check/SKILL.md) | Production resilience audit for AI-generated code |
| [`vibe-explain`](skills/engineering/vibe-explain/SKILL.md) | Cognitive debt map — surfaces code you don't fully understand |
| [`vibe-guard`](skills/engineering/vibe-guard/SKILL.md) | Full safety check: resilience + security + comprehension |
| [`vibe-secure`](skills/engineering/vibe-secure/SKILL.md) | Security audit for AI-generated code |

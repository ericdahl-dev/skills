# crush-skills

Custom AI agent skills for real engineering work — not vibe coding.

Works with **any agent that reads markdown**: Crush, Claude Code, Cursor, Windsurf, GitHub Copilot, and others.

---

## Quick install

```bash
git clone https://github.com/ericdahl/crush-skills ~/.crush-skills
cd ~/.crush-skills
./scripts/link-skills.sh
```

The script asks which editors to install into, then symlinks each skill into the right directory:

| Editor | Skills directory |
|--------|-----------------|
| [Crush](https://charm.sh/crush/) | `~/.config/crush/skills/` |
| [Claude Code CLI](https://claude.ai/code) | `~/.claude/skills/` |
| [Cursor](https://cursor.com) | `~/.cursor/rules/` |
| [Windsurf](https://codeium.com/windsurf) | `~/.codeium/windsurf/memories/` |
| GitHub Copilot Chat | `~/.github/copilot/skills/` |

Or pass editors directly:

```bash
./scripts/link-skills.sh crush claude
```

---

## How skills work

Each skill is a `SKILL.md` file. When you invoke the skill name (e.g. `/tdd`, `/diagnose`) in your agent, it reads the file and follows the instructions inside. Skills compose — many reference sibling skills.

**Invoking a skill:**
- Crush / Claude Code: `/skill-name`
- Cursor / Windsurf: `@skill-name` or reference by name in chat
- Any agent: paste or attach the `SKILL.md` content, or instruct the agent to read it

---

## Skills

### Engineering

| Skill | Description |
|-------|-------------|
| [`6t7`](skills/engineering/6t7/SKILL.md) | Rails 6→7 upgrade ticket checker |
| [`crush-code`](skills/engineering/crush-code/SKILL.md) | Autonomous issue-driven dev loop (TDD, auto-merge PRs, PR health) |
| [`diagnose`](skills/engineering/diagnose/SKILL.md) | Disciplined debug loop: reproduce → minimise → fix → regression test |
| [`github-triage`](skills/engineering/github-triage/SKILL.md) | Label-based GitHub issue triage state machine |
| [`grill-with-docs`](skills/engineering/grill-with-docs/SKILL.md) | Stress-test a plan against CONTEXT.md and ADRs |
| [`improve-codebase-architecture`](skills/engineering/improve-codebase-architecture/SKILL.md) | Find refactoring opportunities informed by domain language |
| [`setup-matt-pocock-skills`](skills/engineering/setup-matt-pocock-skills/SKILL.md) | Bootstrap agent skill config (issue tracker, labels, domain docs) |
| [`tdd`](skills/engineering/tdd/SKILL.md) | Red-green-refactor TDD loop |
| [`to-issues`](skills/engineering/to-issues/SKILL.md) | Break a plan/PRD into independently-grabbable GitHub issues |
| [`to-prd`](skills/engineering/to-prd/SKILL.md) | Turn conversation context into a published PRD |
| [`triage`](skills/engineering/triage/SKILL.md) | Role-driven issue triage state machine |
| [`vibe-check`](skills/engineering/vibe-check/SKILL.md) | Production resilience audit for AI-generated code |
| [`vibe-explain`](skills/engineering/vibe-explain/SKILL.md) | Cognitive debt map — surfaces code you don't fully understand |
| [`vibe-guard`](skills/engineering/vibe-guard/SKILL.md) | Full safety check: resilience + security + comprehension |
| [`vibe-secure`](skills/engineering/vibe-secure/SKILL.md) | Security audit for AI-generated code |
| [`zoom-out`](skills/engineering/zoom-out/SKILL.md) | Higher-level perspective on unfamiliar code |

### Productivity

| Skill | Description |
|-------|-------------|
| [`caveman`](skills/productivity/caveman/SKILL.md) | Ultra-compressed communication mode (~75% fewer tokens) |
| [`find-skills`](skills/productivity/find-skills/SKILL.md) | Discover and install new agent skills |
| [`grill-me`](skills/productivity/grill-me/SKILL.md) | Relentless questioning to stress-test a plan |
| [`handoff`](skills/productivity/handoff/SKILL.md) | Compact conversation into a handoff doc for the next agent |
| [`prototype`](skills/productivity/prototype/SKILL.md) | Throwaway prototype to flesh out a design |
| [`write-a-skill`](skills/productivity/write-a-skill/SKILL.md) | Create new agent skills with proper structure |

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

### Personal / Niche

| Skill | Description |
|-------|-------------|
| [`domain-name-brainstormer`](skills/personal/domain-name-brainstormer/SKILL.md) | Generate + availability-check domain names |
| [`domain-naming-engine`](skills/personal/domain-naming-engine/SKILL.md) | Creative domain/brand name generator |
| [`swiftui-pro`](skills/personal/swiftui-pro/SKILL.md) | SwiftUI best-practice review |

# crush-skills

Custom [Crush](https://github.com/charmbracelet/crush) AI agent skills.

## Usage

Each subdirectory is a skill. Install a skill by symlinking or copying it into your Crush skills directory:

```bash
# macOS / Linux
ln -s "$(pwd)/<skill-name>" ~/.config/crush/skills/<skill-name>

# or copy
cp -r <skill-name> ~/.config/crush/skills/
```

## Skills

| Skill | Description |
|-------|-------------|
| `6t7` | Rails 6→7 upgrade ticket checker for annex-ims |
| `caveman` | Ultra-compressed communication mode (~75% fewer tokens) |
| `coolify-manager` | Manage and troubleshoot Coolify deployments |
| `copywriting` | Marketing copy for landing pages, features, pricing |
| `daily-devlog` | Gather today's commits/PRs and write a devlog entry |
| `diagnose` | Disciplined debug loop: reproduce → minimise → fix → test |
| `domain-name-brainstormer` | Generate + check domain name availability |
| `domain-naming-engine` | Creative domain/brand name generator |
| `ericdahl-crush-code` | Autonomous issue-driven dev loop (TDD, auto-merge PRs, PR health) |
| `find-skills` | Discover and install new agent skills |
| `frontend-design` | Production-grade UI with bold aesthetic direction |
| `github-triage` | Label-based GitHub issue triage state machine |
| `grill-me` | Stress-test a plan with relentless questioning |
| `grill-with-docs` | Grilling session grounded in CONTEXT.md + ADRs |
| `handoff` | Compact conversation into a handoff doc for the next agent |
| `improve-codebase-architecture` | Refactor opportunities informed by domain language |
| `landing-page-copywriter` | High-converting copy (PAS, AIDA, StoryBrand) |
| `prototype` | Throwaway prototype to flesh out a design |
| `setup-matt-pocock-skills` | Bootstrap agent skill config (issue tracker, labels, domain docs) |
| `swiftui-pro` | SwiftUI best-practice review |
| `tdd` | Red-green-refactor TDD loop |
| `to-issues` | Break a plan/PRD into independently-grabbable GitHub issues |
| `to-prd` | Turn conversation context into a published PRD |
| `triage` | Role-driven issue triage state machine |
| `vibe-check` | Production resilience audit for AI-generated code |
| `vibe-explain` | Cognitive debt map — surfaces code you don't fully understand |
| `vibe-guard` | Full safety check: resilience + security + comprehension |
| `vibe-secure` | Security audit for AI-generated code |
| `web-design-guidelines` | UI/UX + accessibility audit |
| `write-a-skill` | Create new Crush skills with proper structure |
| `zoom-out` | Higher-level perspective on unfamiliar code |

#!/usr/bin/env bash
# scripts/sync-upstream.sh
# Fetches adopted skills from upstream repos and copies them into place.
# Run locally or via CI. Exits non-zero if any file changed (so CI can open a PR).
#
# Manifest format (UPSTREAM_MAP array below):
#   "upstream_raw_url|local_path"
#
# Add a new adopted skill by appending a line to UPSTREAM_MAP.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CHANGED=0

# ---------------------------------------------------------------------------
# Manifest: upstream_raw_url | local_destination_path (relative to repo root)
# ---------------------------------------------------------------------------
UPSTREAM_MAP=(
  # --- mattpocock/skills ---
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnose/SKILL.md|skills/engineering/diagnose/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnose/scripts/hitl-loop.template.sh|skills/engineering/diagnose/scripts/hitl-loop.template.sh"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md|skills/engineering/grill-with-docs/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/ADR-FORMAT.md|skills/engineering/grill-with-docs/ADR-FORMAT.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/CONTEXT-FORMAT.md|skills/engineering/grill-with-docs/CONTEXT-FORMAT.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/SKILL.md|skills/engineering/improve-codebase-architecture/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/DEEPENING.md|skills/engineering/improve-codebase-architecture/DEEPENING.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/INTERFACE-DESIGN.md|skills/engineering/improve-codebase-architecture/INTERFACE-DESIGN.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/LANGUAGE.md|skills/engineering/improve-codebase-architecture/LANGUAGE.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/SKILL.md|skills/engineering/setup-matt-pocock-skills/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/domain.md|skills/engineering/setup-matt-pocock-skills/domain.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md|skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-gitlab.md|skills/engineering/setup-matt-pocock-skills/issue-tracker-gitlab.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md|skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/triage-labels.md|skills/engineering/setup-matt-pocock-skills/triage-labels.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md|skills/engineering/tdd/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/deep-modules.md|skills/engineering/tdd/deep-modules.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/interface-design.md|skills/engineering/tdd/interface-design.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/mocking.md|skills/engineering/tdd/mocking.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/refactoring.md|skills/engineering/tdd/refactoring.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/tests.md|skills/engineering/tdd/tests.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-issues/SKILL.md|skills/engineering/to-issues/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-prd/SKILL.md|skills/engineering/to-prd/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/SKILL.md|skills/engineering/triage/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/AGENT-BRIEF.md|skills/engineering/triage/AGENT-BRIEF.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/OUT-OF-SCOPE.md|skills/engineering/triage/OUT-OF-SCOPE.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/zoom-out/SKILL.md|skills/engineering/zoom-out/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/caveman/SKILL.md|skills/productivity/caveman/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md|skills/productivity/grill-me/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/handoff/SKILL.md|skills/productivity/handoff/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/prototype/SKILL.md|skills/productivity/prototype/SKILL.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/prototype/LOGIC.md|skills/productivity/prototype/LOGIC.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/prototype/UI.md|skills/productivity/prototype/UI.md"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/write-a-skill/SKILL.md|skills/productivity/write-a-skill/SKILL.md"

  # --- codecoincognition/vibe-guard-skills ---
  # Note: upstream uses flat .md files; we store them as SKILL.md
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-guard.md|skills/engineering/vibe-guard/SKILL.md"
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-check.md|skills/engineering/vibe-check/SKILL.md"
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-secure.md|skills/engineering/vibe-secure/SKILL.md"
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-explain.md|skills/engineering/vibe-explain/SKILL.md"
)

# ---------------------------------------------------------------------------

fetch() {
  local url="$1" dest="$2"
  local tmp
  tmp="$(mktemp)"

  if ! curl -fsSL --retry 3 "$url" -o "$tmp" 2>/dev/null; then
    echo "  WARN: failed to fetch $url — skipping" >&2
    rm -f "$tmp"
    return
  fi

  mkdir -p "$(dirname "$REPO/$dest")"

  if [ -f "$REPO/$dest" ] && cmp -s "$tmp" "$REPO/$dest"; then
    rm -f "$tmp"
    return
  fi

  mv "$tmp" "$REPO/$dest"
  echo "  updated: $dest"
  CHANGED=1
}

echo "Syncing adopted skills from upstream..."
for entry in "${UPSTREAM_MAP[@]}"; do
  url="${entry%%|*}"
  dest="${entry##*|}"
  fetch "$url" "$dest"
done

echo ""
if [ "$CHANGED" -eq 1 ]; then
  echo "Changes detected."
  exit 1
else
  echo "All skills up to date."
  exit 0
fi

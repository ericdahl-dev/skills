#!/usr/bin/env bash
# scripts/sync-upstream.sh
# Fetches adopted skills from upstream repos and copies them into place.
# Run locally or via CI. Exits non-zero if any file changed (so CI can open a PR).
#
# Manifest format (UPSTREAM_MAP array below):
#   "upstream_raw_url|local_path|upstream_repo_url"
#
# upstream_repo_url is injected as `upstream:` frontmatter into SKILL.md files.
# Add a new adopted skill by appending a line to UPSTREAM_MAP.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CHANGED=0

# ---------------------------------------------------------------------------
# Manifest: upstream_raw_url | local_destination_path | upstream_repo_url
# ---------------------------------------------------------------------------
MATTPOCOCK="https://github.com/mattpocock/skills"
VIBE_GUARD="https://github.com/codecoincognition/vibe-guard-skills"

UPSTREAM_MAP=(
  # --- mattpocock/skills ---
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnose/SKILL.md|skills/engineering/diagnose/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/diagnose/scripts/hitl-loop.template.sh|skills/engineering/diagnose/scripts/hitl-loop.template.sh|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md|skills/engineering/grill-with-docs/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/ADR-FORMAT.md|skills/engineering/grill-with-docs/ADR-FORMAT.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/CONTEXT-FORMAT.md|skills/engineering/grill-with-docs/CONTEXT-FORMAT.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/SKILL.md|skills/engineering/improve-codebase-architecture/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/DEEPENING.md|skills/engineering/improve-codebase-architecture/DEEPENING.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/INTERFACE-DESIGN.md|skills/engineering/improve-codebase-architecture/INTERFACE-DESIGN.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/LANGUAGE.md|skills/engineering/improve-codebase-architecture/LANGUAGE.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/SKILL.md|skills/engineering/setup-matt-pocock-skills/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/domain.md|skills/engineering/setup-matt-pocock-skills/domain.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md|skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-gitlab.md|skills/engineering/setup-matt-pocock-skills/issue-tracker-gitlab.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md|skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/triage-labels.md|skills/engineering/setup-matt-pocock-skills/triage-labels.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md|skills/engineering/tdd/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/deep-modules.md|skills/engineering/tdd/deep-modules.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/interface-design.md|skills/engineering/tdd/interface-design.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/mocking.md|skills/engineering/tdd/mocking.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/refactoring.md|skills/engineering/tdd/refactoring.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/tests.md|skills/engineering/tdd/tests.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-issues/SKILL.md|skills/engineering/to-issues/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-prd/SKILL.md|skills/engineering/to-prd/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/SKILL.md|skills/engineering/triage/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/AGENT-BRIEF.md|skills/engineering/triage/AGENT-BRIEF.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/OUT-OF-SCOPE.md|skills/engineering/triage/OUT-OF-SCOPE.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/zoom-out/SKILL.md|skills/engineering/zoom-out/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/caveman/SKILL.md|skills/productivity/caveman/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md|skills/productivity/grill-me/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/handoff/SKILL.md|skills/productivity/handoff/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/prototype/SKILL.md|skills/productivity/prototype/SKILL.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/prototype/LOGIC.md|skills/productivity/prototype/LOGIC.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/prototype/UI.md|skills/productivity/prototype/UI.md|$MATTPOCOCK"
  "https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/write-a-skill/SKILL.md|skills/productivity/write-a-skill/SKILL.md|$MATTPOCOCK"

  # --- codecoincognition/vibe-guard-skills ---
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-guard.md|skills/engineering/vibe-guard/SKILL.md|$VIBE_GUARD"
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-check.md|skills/engineering/vibe-check/SKILL.md|$VIBE_GUARD"
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-secure.md|skills/engineering/vibe-secure/SKILL.md|$VIBE_GUARD"
  "https://raw.githubusercontent.com/codecoincognition/vibe-guard-skills/main/skills/vibe-explain.md|skills/engineering/vibe-explain/SKILL.md|$VIBE_GUARD"
)

# ---------------------------------------------------------------------------
# inject_upstream: add/update `upstream:` field in YAML frontmatter of a SKILL.md
# ---------------------------------------------------------------------------
inject_upstream() {
  local file="$1" upstream_url="$2"
  if ! grep -q '^---' "$file"; then return; fi

  python3 - "$file" "$upstream_url" <<'PYEOF'
import sys, re

path, url = sys.argv[1], sys.argv[2]
text = open(path).read()

# Strip leading blank lines
text = text.lstrip('\n')

# Replace existing upstream field
if re.search(r'^upstream:', text, re.MULTILINE):
    text = re.sub(r'^upstream:.*$', f'upstream: "{url}"', text, flags=re.MULTILINE)
else:
    # Insert after first ---
    text = re.sub(r'^---\n', f'---\nupstream: "{url}"\n', text, count=1)

open(path, 'w').write(text)
PYEOF
}

# ---------------------------------------------------------------------------
fetch() {
  local url="$1" dest="$2" upstream_url="$3"
  local tmp
  tmp="$(mktemp)"

  if ! curl -fsSL --retry 3 "$url" -o "$tmp" 2>/dev/null; then
    echo "  WARN: failed to fetch $url — skipping" >&2
    rm -f "$tmp"
    return
  fi

  mkdir -p "$(dirname "$REPO/$dest")"

  # Inject upstream field into SKILL.md files before comparison
  if [[ "$dest" == */SKILL.md ]] && [ -n "$upstream_url" ]; then
    inject_upstream "$tmp" "$upstream_url"
  fi

  if [ -f "$REPO/$dest" ] && cmp -s "$tmp" "$REPO/$dest"; then
    rm -f "$tmp"
    return
  fi

  mv "$tmp" "$REPO/$dest"
  echo "  updated: $dest"
  CHANGED=1
}

# ---------------------------------------------------------------------------

echo "Syncing adopted skills from upstream..."
for entry in "${UPSTREAM_MAP[@]}"; do
  url="${entry%%|*}"
  rest="${entry#*|}"
  dest="${rest%%|*}"
  upstream_url="${rest#*|}"
  fetch "$url" "$dest" "$upstream_url"
done

echo ""
if [ "$CHANGED" -eq 1 ]; then
  echo "Changes detected."
  exit 1
else
  echo "All skills up to date."
  exit 0
fi

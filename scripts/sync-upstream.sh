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
VIBE_GUARD="https://github.com/codecoincognition/vibe-guard-skills"

UPSTREAM_MAP=(
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

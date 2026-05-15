#!/usr/bin/env bash
# scripts/validate.sh — run all checks; exit non-zero on any failure.
# Used by CI and runnable locally.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

red()   { echo "  FAIL: $*" >&2; ERRORS=$((ERRORS + 1)); }
ok()    { echo "  ok:   $*"; }

# ---------------------------------------------------------------------------
# 1. Frontmatter — every SKILL.md must have name + description
# ---------------------------------------------------------------------------
echo "Checking frontmatter..."
while IFS= read -r -d '' f; do
  skill="$(echo "$f" | sed "s|$REPO/||")"
  block="$(awk '/^---/{c++;next} c==1{print} c==2{exit}' "$f")"
  has_name=$(echo "$block" | grep -c '^name:' || true)
  has_desc=$(echo "$block" | grep -c '^description' || true)
  if [ "$has_name" -eq 0 ] || [ "$has_desc" -eq 0 ]; then
    red "$skill — missing 'name' or 'description' in frontmatter"
  else
    ok "$skill"
  fi
done < <(find "$REPO/skills" -name "SKILL.md" -print0)

# ---------------------------------------------------------------------------
# 2. README completeness — every SKILL.md has a row in README.md
# ---------------------------------------------------------------------------
echo ""
echo "Checking README completeness..."
while IFS= read -r -d '' f; do
  skill_name="$(awk '/^---/{c++;next} c==1 && /^name:/{gsub(/^name: */,""); print; exit}' "$f")"
  if [ -z "$skill_name" ]; then continue; fi
  if grep -q "\`$skill_name\`" "$REPO/README.md"; then
    ok "$skill_name in README"
  else
    red "$skill_name — not found in README.md"
  fi
done < <(find "$REPO/skills" -name "SKILL.md" -print0)

# ---------------------------------------------------------------------------
# 3. Sync manifest — every skills/ file that is adopted has an entry in sync-upstream.sh
#    (we check by looking for the local path in UPSTREAM_MAP)
# ---------------------------------------------------------------------------
echo ""
echo "Checking sync manifest..."
SYNC="$REPO/scripts/sync-upstream.sh"
# Extract all local paths from UPSTREAM_MAP (right side of | in the array)
manifest_paths=()
while IFS= read -r mp; do
  [ -n "$mp" ] && manifest_paths+=("$mp")
done < <(python3 - "$SYNC" <<'PYEOF'
import sys, re
text = open(sys.argv[1]).read()
# Match lines like "url|local_path|upstream_url" inside quotes
for m in re.finditer(r'"[^"]+\|([^|"]+)\|[^"]*"', text):
    print(m.group(1))
PYEOF
)

# Build list of adopted skill dirs from README (everything under "Adopted Skills")
# We trust README as source of truth for adopted vs original
adopted_section=false
while IFS= read -r line; do
  if echo "$line" | grep -q "## Adopted Skills"; then
    adopted_section=true
  fi
  if $adopted_section && echo "$line" | grep -qE '\[`[^`]+`\]\(([^)]+)\)'; then
    path=$(echo "$line" | sed 's/.*\](\([^)]*\)).*/\1/')
    skill_md="$REPO/$path"
    if [ ! -f "$skill_md" ]; then continue; fi
    rel_path="$path"
    found=false
    for mp in "${manifest_paths[@]}"; do
      if [ "$mp" = "$rel_path" ]; then found=true; break; fi
    done
    if $found; then
      ok "$rel_path in sync manifest"
    else
      red "$rel_path — adopted skill not in sync-upstream.sh UPSTREAM_MAP"
    fi
  fi
done < "$REPO/README.md"

# ---------------------------------------------------------------------------
echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED with $ERRORS error(s)."
  exit 1
else
  echo "All checks passed."
fi

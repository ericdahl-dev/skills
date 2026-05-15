#!/usr/bin/env bash
# link-skills.sh — symlink all skills into one or more AI editor skill dirs.
# Usage:
#   ./scripts/link-skills.sh              # interactive: pick editors
#   ./scripts/link-skills.sh crush claude cursor windsurf
#
# Supported editors:
#   crush      → ~/.config/crush/skills/
#   claude     → ~/.claude/skills/              (Claude Code CLI)
#   cursor     → ~/.cursor/rules/               (Cursor rules dir — copies as .mdc)
#   windsurf   → ~/.codeium/windsurf/memories/  (Windsurf memories)
#   copilot    → ~/.github/copilot/skills/      (GitHub Copilot Chat)

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_ROOT="$REPO/skills"

EDITOR_DIRS=(
  "crush:$HOME/.config/crush/skills"
  "claude:$HOME/.claude/skills"
  "cursor:$HOME/.cursor/rules"
  "windsurf:$HOME/.codeium/windsurf/memories"
  "copilot:$HOME/.github/copilot/skills"
)

# --- helpers ---

link_skill() {
  local src="$1" dest_dir="$2"
  local name
  name="$(basename "$src")"
  local target="$dest_dir/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi
  ln -sfn "$src" "$target"
  echo "  linked $name"
}

install_for_editor() {
  local editor="$1"
  local dest=""

  for entry in "${EDITOR_DIRS[@]}"; do
    if [[ "$entry" == "$editor:"* ]]; then
      dest="${entry#*:}"
      break
    fi
  done

  if [[ -z "$dest" ]]; then
    echo "Unknown editor: $editor"
    return 1
  fi

  mkdir -p "$dest"

  # Guard: dest must not point back into this repo
  if [ -L "$dest" ]; then
    resolved="$(readlink -f "$dest")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $dest is a symlink into this repo. Run: rm \"$dest\" and retry." >&2
        return 1
        ;;
    esac
  fi

  echo "Installing skills for $editor → $dest"
  find "$SKILLS_ROOT" -maxdepth 3 -name "SKILL.md" \
    -not -path "*/deprecated/*" \
    -not -path "*/in-progress/*" |
  while IFS= read -r skill_md; do
    src="$(dirname "$skill_md")"
    link_skill "$src" "$dest"
  done
}

# --- main ---

if [[ $# -gt 0 ]]; then
  editors=("$@")
else
  echo "Which editors should skills be installed for?"
  echo "Available: crush, claude, cursor, windsurf, copilot"
  echo "(space-separated, e.g.: crush claude)"
  read -r -p "> " input
  IFS=' ' read -r -a editors <<< "$input"
fi

for editor in "${editors[@]}"; do
  install_for_editor "$editor"
done

echo ""
echo "Done. Restart your editor/agent to pick up new skills."

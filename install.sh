#!/usr/bin/env bash
# novel-cards install script
#
# Usage:
#   ./install.sh [--target opencode|claude|both] [--link] [--project <path>]
#
# Modes:
#   --target opencode   Install to ~/.config/opencode/skills/novel-cards/
#   --target claude     Install to ~/.claude/skills/novel-cards/
#   --target both       Install to both (default)
#   --link              Use symlinks instead of copying (dev mode)
#   --project <path>    Initialize consumer project skeleton at <path>
#
# Examples:
#   ./install.sh                          # Install to both, copy mode
#   ./install.sh --target opencode        # OpenCode global only
#   ./install.sh --link                   # Dev: symlink to repo root
#   ./install.sh --project ~/my-novel     # Init consumer skeleton

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="both"
MODE="copy"
PROJECT=""

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"; shift 2 ;;
    --link)
      MODE="link"; shift ;;
    --project)
      PROJECT="$2"; shift 2 ;;
    -h|--help)
      usage ;;
    *)
      echo "Unknown option: $1" >&2
      usage ;;
  esac
done

# --- Consumer project initialization ---
if [[ -n "$PROJECT" ]]; then
  echo "Initializing consumer project skeleton at: $PROJECT"
  mkdir -p "$PROJECT/cards/characters" \
           "$PROJECT/cards/plotpoints" \
           "$PROJECT/cards/items" \
           "$PROJECT/cards/scenes" \
           "$PROJECT/cards/foreshadow" \
           "$PROJECT/cards/timeline" \
           "$PROJECT/cards/factions" \
           "$PROJECT/cards/snapshots" \
           "$PROJECT/cards/darklayer" \
           "$PROJECT/manuscript" \
           "$PROJECT/graph"
  for d in "$PROJECT"/cards/*/ "$PROJECT"/manuscript/ "$PROJECT"/graph/; do
    touch "$d.gitkeep"
  done
  echo "Done. Project skeleton created."
  echo "Reminder: this skill does NOT write card files — you must author them (with AI proposals)."
  exit 0
fi

# --- Skill installation ---
install_to() {
  local dest_dir="$1"
  local dest="$dest_dir/novel-cards"

  mkdir -p "$dest_dir"

  if [[ -L "$dest" ]]; then
    echo "Removing existing symlink: $dest"
    rm "$dest"
  elif [[ -d "$dest" ]]; then
    local bak="$dest.bak.$(date +%s)"
    echo "Existing installation at $dest — backing up to $bak"
    mv "$dest" "$bak"
  fi

  if [[ "$MODE" == "link" ]]; then
    ln -s "$SRC" "$dest"
    echo "Linked: $dest -> $SRC"
  else
    if command -v rsync >/dev/null 2>&1; then
      rsync -a \
        --exclude '.git' \
        --exclude '.codegraph' \
        --exclude '.omo' \
        --exclude 'node_modules' \
        --exclude '.gitignore' \
        "$SRC/" "$dest/"
    else
      # fallback: cp with exclusions
      mkdir -p "$dest"
      cp -R "$SRC"/SKILL.md "$SRC"/references "$SRC"/templates "$SRC"/LICENSE "$SRC"/AGENTS.md "$dest/" 2>/dev/null || true
      [ -f "$SRC"/README.md ] && cp "$SRC/README.md" "$dest/"
      [ -f "$SRC"/install.sh ] && cp "$SRC/install.sh" "$dest/"
    fi
    echo "Copied: $dest"
  fi
}

case "$TARGET" in
  opencode)
    install_to "$HOME/.config/opencode/skills"
    ;;
  claude)
    install_to "$HOME/.claude/skills"
    ;;
  both)
    install_to "$HOME/.config/opencode/skills"
    install_to "$HOME/.claude/skills"
    ;;
  *)
    echo "Invalid --target: $TARGET (expected opencode | claude | both)" >&2
    exit 1
    ;;
esac

echo ""
echo "Installation complete. Mode: $MODE | Target: $TARGET"
echo ""
echo "Verify:"
echo "  ls -la \$HOME/.config/opencode/skills/novel-cards/   # if target includes opencode"
echo "  ls -la \$HOME/.claude/skills/novel-cards/            # if target includes claude"
echo ""
echo "To use with a consumer project:"
echo "  $0 --project /path/to/your/novel"

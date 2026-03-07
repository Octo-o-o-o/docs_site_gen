#!/usr/bin/env bash
set -euo pipefail

# ─── docs-site-gen installer ─────────────────────────────────────
# Installs the skill for all detected AI coding clients.
# Usage:
#   ./install.sh              # Auto-detect and install
#   ./install.sh --client X   # Install for specific client only
#   ./install.sh --list       # List supported clients
#   ./install.sh --uninstall  # Remove from all clients
# ──────────────────────────────────────────────────────────────────

SKILL_NAME="docs-site-gen"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANONICAL="$SCRIPT_DIR/skills/$SKILL_NAME"

# ─── Client registry ─────────────────────────────────────────────
# Format: client_name|config_dir|skill_target_dir
declare -a CLIENTS=(
  "claude|$HOME/.claude|$HOME/.claude/skills/$SKILL_NAME"
  "cursor|$HOME/.cursor|$HOME/.cursor/skills/$SKILL_NAME"
  "gemini|$HOME/.gemini|$HOME/.gemini/skills/$SKILL_NAME"
  "codex|$HOME/.codex|$HOME/.codex/skills/$SKILL_NAME"
  "continue|$HOME/.continue|$HOME/.continue/skills/$SKILL_NAME"
  "opencode|$HOME/.config/opencode|$HOME/.config/opencode/skills/$SKILL_NAME"
  "openclaw|$HOME/.openclaw|$HOME/.openclaw/skills/$SKILL_NAME"
  "kilocode|$HOME/.kilocode|$HOME/.kilocode/skills/$SKILL_NAME"
  "adal|$HOME/.adal|$HOME/.adal/skills/$SKILL_NAME"
  "codebuddy|$HOME/.codebuddy|$HOME/.codebuddy/skills/$SKILL_NAME"
  "factory|$HOME/.factory|$HOME/.factory/skills/$SKILL_NAME"
  "agent|$HOME/.agent|$HOME/.agent/skills/$SKILL_NAME"
  "pi|$HOME/.pi|$HOME/.pi/skills/$SKILL_NAME"
)

# ─── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Helpers ──────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[info]${NC} $*"; }
success() { echo -e "${GREEN}[done]${NC} $*"; }
warn()    { echo -e "${YELLOW}[skip]${NC} $*"; }
error()   { echo -e "${RED}[error]${NC} $*" >&2; }

install_for_client() {
  local name="$1"
  local config_dir="$2"
  local target_dir="$3"

  # Check if client is installed
  if [ ! -d "$config_dir" ]; then
    return 1
  fi

  # Create target directory
  mkdir -p "$target_dir"

  # Copy SKILL.md from canonical source
  cp "$CANONICAL/SKILL.md" "$target_dir/SKILL.md"

  # Copy references
  if [ -d "$CANONICAL/references" ]; then
    cp -r "$CANONICAL/references" "$target_dir/"
  fi

  return 0
}

uninstall_for_client() {
  local name="$1"
  local target_dir="$3"

  if [ -d "$target_dir" ]; then
    rm -rf "$target_dir"
    success "Removed from $name"
    return 0
  fi
  return 1
}

# ─── Verify canonical source ─────────────────────────────────────
if [ ! -f "$CANONICAL/SKILL.md" ]; then
  error "Canonical SKILL.md not found at $CANONICAL/SKILL.md"
  error "Make sure you're running this script from the repo root."
  exit 1
fi

# ─── Parse arguments ─────────────────────────────────────────────
ACTION="install"
TARGET_CLIENT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list)
      echo -e "${BOLD}Supported clients:${NC}"
      echo ""
      for entry in "${CLIENTS[@]}"; do
        IFS='|' read -r name config_dir _ <<< "$entry"
        if [ -d "$config_dir" ]; then
          echo -e "  ${GREEN}●${NC} $name (detected)"
        else
          echo -e "  ${RED}○${NC} $name"
        fi
      done
      echo ""
      echo -e "Detected clients are installed automatically."
      echo -e "Use ${CYAN}--client NAME${NC} to install for a specific client."
      exit 0
      ;;
    --uninstall)
      ACTION="uninstall"
      shift
      ;;
    --client)
      TARGET_CLIENT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --list         List all supported clients and detection status"
      echo "  --client NAME  Install for a specific client only"
      echo "  --uninstall    Remove skill from all detected clients"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# ─── Execute ─────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}docs-site-gen${NC} — skill installer"
echo -e "────────────────────────────────────"
echo ""

installed=0
skipped=0

for entry in "${CLIENTS[@]}"; do
  IFS='|' read -r name config_dir target_dir <<< "$entry"

  # If targeting a specific client, skip others
  if [ -n "$TARGET_CLIENT" ] && [ "$name" != "$TARGET_CLIENT" ]; then
    continue
  fi

  if [ "$ACTION" = "uninstall" ]; then
    if uninstall_for_client "$name" "$config_dir" "$target_dir"; then
      ((installed++))
    fi
  else
    if install_for_client "$name" "$config_dir" "$target_dir"; then
      success "Installed for $name → $target_dir"
      ((installed++))
    else
      warn "$name not detected"
      ((skipped++))
    fi
  fi
done

echo ""
if [ "$ACTION" = "uninstall" ]; then
  echo -e "${BOLD}Uninstalled from $installed client(s).${NC}"
else
  if [ $installed -eq 0 ]; then
    warn "No supported clients detected."
    echo ""
    echo "To install manually for a specific client:"
    echo -e "  ${CYAN}mkdir -p ~/.CLIENT/skills/$SKILL_NAME${NC}"
    echo -e "  ${CYAN}cp skills/$SKILL_NAME/SKILL.md ~/.CLIENT/skills/$SKILL_NAME/${NC}"
    echo -e "  ${CYAN}cp -r skills/$SKILL_NAME/references ~/.CLIENT/skills/$SKILL_NAME/${NC}"
  else
    echo -e "${BOLD}Installed for $installed client(s), skipped $skipped.${NC}"
    echo -e "Restart your AI client to activate the skill."
  fi
fi
echo ""

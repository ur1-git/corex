#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE_ZSHRC="$DOTFILES_DIR/configs/terminal/.zshrc"
TARGET_ZSHRC="$HOME/.zshrc"

FZF_TAB_DIR="$HOME/.local/share/zsh/plugins/fzf-tab"
FZF_TAB_PLUGIN="$FZF_TAB_DIR/fzf-tab.plugin.zsh"

REQUIRED_PACKAGES=(
  zsh
  ghostty
  starship
  fastfetch
  micro
  git
  fzf
)

log() {
  printf '\033[1;34m[terminal]\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33m[terminal warning]\033[0m %s\n' "$*"
}

die() {
  printf '\033[1;31m[terminal error]\033[0m %s\n' "$*" >&2
  exit 1
}

require_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    die "Missing required file: $file"
  fi
}

install_missing_packages() {
  local missing=()

  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if (( ${#missing[@]} == 0 )); then
    log "Required packages already installed."
    return
  fi

  log "Installing missing packages: ${missing[*]}"
  sudo pacman -S --needed "${missing[@]}"
}

install_file_if_changed() {
  local source="$1"
  local target="$2"
  local mode="$3"

  require_file "$source"

  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
    log "Already up to date: $target"
    return
  fi

  if [[ -e "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing file: $backup"
    cp -a "$target" "$backup"
  fi

  install -Dm"$mode" "$source" "$target"
  log "Installed: $target"
}

setup_fzf_tab() {
  if [[ -f "$FZF_TAB_PLUGIN" ]]; then
    log "fzf-tab already installed."
    return
  fi

  if [[ -e "$FZF_TAB_DIR" ]]; then
    warn "fzf-tab directory exists but plugin file was not found: $FZF_TAB_DIR"
    warn "Fix it manually or remove that directory and rerun this script."
    return
  fi

  log "Installing fzf-tab plugin..."
  mkdir -p "$(dirname "$FZF_TAB_DIR")"
  git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
}

check_default_shell() {
  if [[ "${SHELL##*/}" != "zsh" ]]; then
    warn "Your current login shell is not zsh."
    warn "This script will not change it automatically. To change it, run:"
    printf '\nchsh -s "$(command -v zsh)"\n\n'
  fi
}

main() {
  log "Setting up terminal environment..."

  install_missing_packages
  install_file_if_changed "$SOURCE_ZSHRC" "$TARGET_ZSHRC" 644
  setup_fzf_tab
  check_default_shell

  log "Done. Open a new terminal or run: exec zsh"
}

main "$@"

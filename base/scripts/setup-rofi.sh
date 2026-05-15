#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE_ROFI_DIR="$DOTFILES_DIR/configs/rofi"
SOURCE_BIN="$DOTFILES_DIR/bin/rofi-launcher.sh"

TARGET_ROFI_DIR="$HOME/.config/rofi"
TARGET_BIN="$HOME/.local/bin/rofi-launcher.sh"

REQUIRED_PACKAGES=(
  rofi
  tela-circle-icon-theme-black
  ttf-jetbrains-mono-nerd
)

log() {
  printf '\033[1;34m[rofi]\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33m[rofi warning]\033[0m %s\n' "$*"
}

die() {
  printf '\033[1;31m[rofi error]\033[0m %s\n' "$*" >&2
  exit 1
}

require_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    die "Missing required file: $file"
  fi
}

require_dir() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    die "Missing required directory: $dir"
  fi
}

install_missing_packages() {
  local missing=()

  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
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

  if [[ -f "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing file: $backup"
    cp "$target" "$backup"
  fi

  install -Dm"$mode" "$source" "$target"
  log "Installed: $target"
}

install_rofi_configs() {
  require_dir "$SOURCE_ROFI_DIR"

  mkdir -p "$TARGET_ROFI_DIR"

  shopt -s nullglob

  local files=("$SOURCE_ROFI_DIR"/*)

  if (( ${#files[@]} == 0 )); then
    die "No files found in: $SOURCE_ROFI_DIR"
  fi

  for source in "${files[@]}"; do
    if [[ -f "$source" ]]; then
      local filename
      filename="$(basename "$source")"

      install_file_if_changed \
        "$source" \
        "$TARGET_ROFI_DIR/$filename" \
        644
    fi
  done

  shopt -u nullglob
}

install_launcher_script() {
  install_file_if_changed "$SOURCE_BIN" "$TARGET_BIN" 755
}

check_icon_theme_config() {
  local config="$SOURCE_ROFI_DIR/config.rasi"

  require_file "$config"

  if ! grep -q 'icon-theme: *"Tela-circle-black' "$config"; then
    warn "Your rofi/config.rasi does not seem to use Tela Circle Black."
    warn 'Recommended line: icon-theme: "Tela-circle-black";'
  fi
}

check_local_bin_path() {
  local local_bin="$HOME/.local/bin"

  if [[ ":$PATH:" != *":$local_bin:"* ]]; then
    warn "$local_bin is not in PATH."
    warn 'Add this to your shell config:'
    printf '\nexport PATH="$HOME/.local/bin:$PATH"\n\n'
  fi
}

main() {
  log "Setting up Rofi..."

  install_missing_packages
  install_rofi_configs
  install_launcher_script
  check_icon_theme_config
  check_local_bin_path

  log "Done."
  log "Test with: rofi-launcher"
}

main "$@"

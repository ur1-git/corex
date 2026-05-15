#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE_YAZI_DIR="$DOTFILES_DIR/configs/yazi"

SOURCE_PORTALS_CONF="$SOURCE_YAZI_DIR/portals.conf"
SOURCE_TERMFILECHOOSER_CONF="$SOURCE_YAZI_DIR/termfilechooser.conf"

TARGET_PORTALS_CONF="$HOME/.config/xdg-desktop-portal/portals.conf"
TARGET_TERMFILECHOOSER_CONF="$HOME/.config/xdg-desktop-portal-termfilechooser/config"

TERMFC_PACKAGE="xdg-desktop-portal-termfilechooser"
TERMFC_WRAPPER="/usr/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh"

REQUIRED_PACMAN_PACKAGES=(
  yazi
)

log() {
  printf '\033[1;34m[yazi]\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33m[yazi warning]\033[0m %s\n' "$*"
}

die() {
  printf '\033[1;31m[yazi error]\033[0m %s\n' "$*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

require_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    die "Missing required file: $file"
  fi
}

install_missing_pacman_packages() {
  local missing=()

  for pkg in "${REQUIRED_PACMAN_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if (( ${#missing[@]} == 0 )); then
    log "Pacman packages already installed."
    return
  fi

  log "Installing missing pacman packages: ${missing[*]}"
  sudo pacman -S --needed "${missing[@]}"
}

install_aur_package_if_missing() {
  local pkg="$1"

  if pacman -Qq "$pkg" >/dev/null 2>&1; then
    log "$pkg already installed."
    return
  fi

  if has_cmd paru; then
    log "Installing AUR package with paru: $pkg"
    paru -S --needed "$pkg"
  elif has_cmd yay; then
    log "Installing AUR package with yay: $pkg"
    yay -S --needed "$pkg"
  else
    die "Missing $pkg and no AUR helper found. Install paru or yay, then rerun this script."
  fi
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

check_terminal() {
  if ! has_cmd ghostty; then
    die "ghostty is not installed or not in PATH. Run setup-terminal.sh first, or edit configs/yazi/termfilechooser.conf to use another terminal."
  fi
}

check_termfilechooser_wrapper() {
  if [[ ! -f "$TERMFC_WRAPPER" ]]; then
    die "yazi-wrapper.sh not found at $TERMFC_WRAPPER. Check package files with: pacman -Ql $TERMFC_PACKAGE | grep yazi"
  fi
}

restart_portals() {
  log "Restarting desktop portals..."
  systemctl --user restart xdg-desktop-portal || true
  systemctl --user restart xdg-desktop-portal-termfilechooser || true
}

main() {
  log "Setting up Yazi file chooser portal..."

  require_file "$SOURCE_PORTALS_CONF"
  require_file "$SOURCE_TERMFILECHOOSER_CONF"

  install_missing_pacman_packages
  check_terminal
  install_aur_package_if_missing "$TERMFC_PACKAGE"
  check_termfilechooser_wrapper

  install_file_if_changed "$SOURCE_PORTALS_CONF" "$TARGET_PORTALS_CONF" 644
  install_file_if_changed "$SOURCE_TERMFILECHOOSER_CONF" "$TARGET_TERMFILECHOOSER_CONF" 644

  restart_portals

  log "Done. Fully restart apps that use the file picker, especially browsers."
}

main "$@"

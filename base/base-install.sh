#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$DOTFILES_DIR/scripts/setup-terminal.sh"
"$DOTFILES_DIR/scripts/setup-rofi.sh"
"$DOTFILES_DIR/scripts/setup-yazi.sh"

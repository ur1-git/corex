# Dotfiles

Personal Arch Linux dotfiles and post-install setup scripts.

The goal of this repo is to make a fresh installation reproducible: install packages, copy configuration files, set up terminal tools, configure Rofi, and enable Yazi as the desktop file picker.

## Structure

```text
dotfiles/
├── install.sh
├── scripts/
│   ├── setup-terminal.sh
│   ├── setup-rofi.sh
│   └── setup-yazi.sh
├── configs/
│   ├── terminal/
│   │   └── .zshrc
│   ├── rofi/
│   │   ├── config.rasi
│   │   ├── catppuccin-mocha.rasi
│   │   └── catppuccin-mocha-custom.rasi
│   └── yazi/
│       ├── portals.conf
│       └── termfilechooser.conf
└── bin/
    └── app-launcher
```

## What it sets up

### Terminal

`setup-terminal.sh` handles terminal-related setup.

Expected config files:

```text
configs/terminal/.zshrc
```

It copies:

```text
configs/terminal/.zshrc → ~/.zshrc
```

It can also install terminal-related packages such as:

```text
zsh
ghostty
starship
fastfetch
fzf
git
micro
```

### Rofi

`setup-rofi.sh` installs and configures Rofi as the app launcher.

Expected config files:

```text
configs/rofi/config.rasi
configs/rofi/catppuccin-mocha.rasi
configs/rofi/catppuccin-mocha-custom.rasi
```

It copies them to:

```text
~/.config/rofi/
```

It also installs the launcher script:

```text
bin/app-launcher → ~/.local/bin/app-launcher
```

The launcher command is:

```bash
rofi -show drun -show-icons
```

The Rofi setup uses:

```text
Catppuccin Mocha theme
Tela Circle Black icons
fuzzy matching
keyboard-driven app launching
```

Recommended KDE shortcut:

```text
Meta + Space → ~/.local/bin/app-launcher
```

### Yazi file chooser

`setup-yazi.sh` configures Yazi as the desktop file picker through `xdg-desktop-portal-termfilechooser`.

Expected config files:

```text
configs/yazi/portals.conf
configs/yazi/termfilechooser.conf
```

It copies them to:

```text
configs/yazi/portals.conf → ~/.config/xdg-desktop-portal/portals.conf
configs/yazi/termfilechooser.conf → ~/.config/xdg-desktop-portal-termfilechooser/config
```

The default terminal command used by the file chooser is Ghostty:

```ini
env=TERMCMD='ghostty --title="file chooser" -e'
```

After running the setup, fully restart applications that use the file picker, especially browsers.

## Installation

Clone the repo:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

Make scripts executable:

```bash
chmod +x install.sh scripts/*.sh bin/*
```

Run everything:

```bash
./install.sh
```

Or run only one module:

```bash
./scripts/setup-terminal.sh
./scripts/setup-rofi.sh
./scripts/setup-yazi.sh
```

## Main install script

Example `install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$DOTFILES_DIR/scripts/setup-terminal.sh"
"$DOTFILES_DIR/scripts/setup-rofi.sh"
"$DOTFILES_DIR/scripts/setup-yazi.sh"
```

## Idempotency

The setup scripts are designed to be safe to rerun.

They should:

```text
install only missing packages
copy files only when content changed
avoid duplicate config
back up existing different files before replacing them
```

Backups are created with timestamps, for example:

```text
~/.zshrc.bak.20260515-142211
```

## Notes

This setup assumes Arch Linux or an Arch-based distribution.

Some packages are installed with `pacman`. AUR packages require either:

```text
paru
```

or:

```text
yay
```

`~/.local/bin` should be in your `PATH` so scripts like `app-launcher` can be run directly.

Add this to your shell config if needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## KDE notes

Do not uninstall KRunner just to replace the launcher. KRunner is part of the Plasma workspace stack and removing it may affect core KDE components.

Instead, keep KRunner installed and bind Rofi to a shortcut such as:

```text
Meta + Space
```

Plain `Meta` is handled specially by KDE and is usually tied to the Plasma application launcher widget.

# historial más grande
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# fastfetch
fastfetch

# autocompletado
autoload -Uz compinit
compinit

# fzf-tab
source ~/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# colores en terminal
autoload -Uz colors
colors

# activate starship
eval "$(starship init zsh)"

# borrar palabra con Ctrl+Backspace
bindkey '^H' backward-kill-word

# mover palabra con Ctrl+← y Ctrl+→
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# alias
#alias x="command"
alias y="yazi"

# micro as default
export EDITOR=micro
export VISUAL=micro

# y function with yazi to navigate to the directory
yazi() {
  local tmp
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
  command yazi --cwd-file="$tmp" "$@"
  if [ -s "$tmp" ]; then
    cd -- "$(cat "$tmp")"
  fi
  rm -f -- "$tmp"
}

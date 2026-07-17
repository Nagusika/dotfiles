# common.sh — cœur POSIX partagé par bash et zsh (login ET interactif). Idempotent.
# Validé : dash -n, shellcheck -s sh. Ne rien mettre ici qui ne soit pas POSIX.
# shellcheck shell=sh

# Chemin du repo (écrit par le module shell au bootstrap) — utilisé par les rc pour vendor/.
[ -r "$HOME/.config/dotfiles/env" ] && . "$HOME/.config/dotfiles/env"

# PATH : ~/.local/bin en tête (idempotent).
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

# XDG (défauts si absents).
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Éditeur / pager.
if   command -v nvim >/dev/null 2>&1; then export EDITOR=nvim
elif command -v vim  >/dev/null 2>&1; then export EDITOR=vim
else                                       export EDITOR=vi
fi
export VISUAL="$EDITOR"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R}"

# fzf : source de fichiers/dossiers via fd si présent + options par défaut.
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"

# Alias et fonctions partagés.
_shdir="${XDG_CONFIG_HOME:-$HOME/.config}/sh"
[ -r "$_shdir/aliases.sh" ]   && . "$_shdir/aliases.sh"
[ -r "$_shdir/functions.sh" ] && . "$_shdir/functions.sh"
unset _shdir

# Surcharge spécifique à CETTE machine, en dernier (jamais versionnée).
[ -r "$HOME/.config/dotfiles/local.sh" ] && . "$HOME/.config/dotfiles/local.sh"

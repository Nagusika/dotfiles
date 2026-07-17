# aliases.sh — alias partagés (POSIX). Un outil moderne remplace le classique s'il est présent.
# On NE remplace PAS grep par rg (sémantique différente) : c'était un bug de l'ancienne config.
# shellcheck shell=sh

# ls -> eza si présent, sinon ls --color.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lh --group-directories-first --icons=auto'
  alias la='eza -lah --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -lh --color=auto'
  alias la='ls -lah --color=auto'
fi

alias grep='grep --color=auto'

# Navigation.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Sécurité / confort.
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias reload='exec "$SHELL" -l'

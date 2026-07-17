# ~/.bashrc — bash interactif.
case $- in *i*) ;; *) return ;; esac        # rien en non-interactif

# Cœur partagé (POSIX) : repo path, PATH, exports, alias, fonctions.
[ -r "$HOME/.config/sh/common.sh" ] && . "$HOME/.config/sh/common.sh"

# ble.sh (autosuggestions + highlighting bash) — workstation, si installé.
# Chargé tôt en mode détaché ; attaché en toute fin (après les hooks precmd).
_blesh="$HOME/.local/share/blesh/ble.sh"
[ -r "$_blesh" ] && source "$_blesh" --attach=none

# Historique.
HISTFILE="$HOME/.bash_history"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Complétion bash.
if ! shopt -oq posix; then
  for _bc in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
    [ -r "$_bc" ] && { . "$_bc"; break; }
  done
  unset _bc
fi

# readline : complétion insensible à la casse + menu.
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on'  2>/dev/null

# fzf (>= 0.48 : intégration native ; bind Ctrl-T et Ctrl-R).
command -v fzf    >/dev/null 2>&1 && eval "$(fzf --bash)"
# zoxide (z / zi).
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
# atuin : reprend Ctrl-R si présent (P2) ; fzf garde Ctrl-T.
command -v atuin  >/dev/null 2>&1 && eval "$(atuin init bash --disable-up-arrow)"

# Prompt (pose son hook precmd — après les autres inits).
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

# ble.sh : attacher en tout dernier.
[ -n "${BLE_VERSION-}" ] && ble-attach
unset _blesh

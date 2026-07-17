# ~/.zshrc — zsh interactif.

# Cœur partagé (POSIX) : repo path, PATH, exports, alias, fonctions.
[ -r "$HOME/.config/sh/common.sh" ] && . "$HOME/.config/sh/common.sh"

# Historique.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS \
       HIST_REDUCE_BLANKS HIST_VERIFY

# Complétion (-C : pas de rebuild coûteux du dump à chaque démarrage).
autoload -Uz compinit && compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Keybindings (emacs).
bindkey -e
bindkey '^[[1;5D' backward-word      # Ctrl+Left
bindkey '^[[1;5C' forward-word       # Ctrl+Right

# Plugins vendored (clonés + pinnés au bootstrap).
_vendor="${DOTFILES:-$HOME/dotfiles}/vendor"
if [ -r "$_vendor/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  . "$_vendor/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# fzf (>= 0.48 : intégration native ; bind Ctrl-T et Ctrl-R).
command -v fzf    >/dev/null 2>&1 && source <(fzf --zsh)
# zoxide (z / zi).
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
# atuin : reprend Ctrl-R si présent (P2) ; fzf garde Ctrl-T.
command -v atuin  >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"

# Prompt.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# syntax-highlighting : DOIT être sourcé en tout dernier.
[ -r "$_vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  . "$_vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset _vendor

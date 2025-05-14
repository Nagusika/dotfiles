# ────────────────────────────────────────────────────────────────────────────────
# 📦 Powerlevel10k Instant Prompt
# ────────────────────────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ────────────────────────────────────────────────────────────────────────────────
# 🔌 Zinit Plugin Manager
# ────────────────────────────────────────────────────────────────────────────────
source ~/.local/share/zinit/bin/zinit.zsh

# Prompt & UI
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/history-search-multi-word

# ────────────────────────────────────────────────────────────────────────────────
# 📜 History Configuration
# ────────────────────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt INC_APPEND_HISTORY        # Write history immediately
setopt SHARE_HISTORY             # Shared between sessions
setopt HIST_IGNORE_ALL_DUPS      # Ignore duplicates
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ────────────────────────────────────────────────────────────────────────────────
# 🧠 Completion & Behavior Tuning
# ────────────────────────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit

# Completion tweaks
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+l:|=* r:|=*'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# fzf-tab preview with exa/bat fallback
zstyle ':completion:*' fzf-preview \
  '[[ -d $realpath ]] && exa --color=always -l --group-directories-first $realpath || bat --style=plain --color=always $realpath || cat $realpath 2>/dev/null | head -100'
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group ',' '.'

# ────────────────────────────────────────────────────────────────────────────────
# ⌨️ Keybindings
# ────────────────────────────────────────────────────────────────────────────────
bindkey -e                                       # Bash-style editing
bindkey "^[[1;5D" backward-word                  # Ctrl+Left
bindkey "^[[1;5C" forward-word                   # Ctrl+Right
bindkey '^A' beginning-of-line                   # Home
bindkey '^E' end-of-line                         # End
bindkey '^K' kill-line

# ────────────────────────────────────────────────────────────────────────────────
# 📁 Aliases
# ────────────────────────────────────────────────────────────────────────────────
# exa for ls
alias ls='exa --group-directories-first --icons'
alias ll='exa -lh --group-directories-first --icons'
alias la='exa -la --icons'
alias l='exa -l --icons'
alias lt='exa -T --icons --level=2'
alias llt='exa -laT --icons --level=2'

# grep via ripgrep
alias grep='rg'
alias rgg='rg --color=always --heading --line-number'
alias rgf='rg --files'
alias rgi='rg -i'
alias rga='rg --hidden --no-ignore --glob "!.git/*"'

# reload shell
alias reload='source ~/.zshrc'
alias editrc='$EDITOR ~/.zshrc'
alias zs='exec zsh'

# zoxide jump
eval "$(zoxide init zsh)"
alias j='z'

# ────────────────────────────────────────────────────────────────────────────────
# 🔍 FZF Enhancements
# ────────────────────────────────────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

  # Ctrl+R: fuzzy history search
  fzf-history-widget() {
    BUFFER=$(history -n 1 | tac | fzf --tac +s --reverse --no-sort) && zle accept-line
    zle reset-prompt
  }
  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget
fi

# Ctrl+F: fuzzy file selector (ripgrep + bat preview)
fzf-ctrl-f-ripgrep() {
  local file
  file=$(rg --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --height 40% --reverse) && $EDITOR "$file"
}
bindkey -s '^F' 'fzf-ctrl-f-ripgrep\n'

# frg: fuzzy content search (open to line)
fzf-rg-search() {
  local query file line
  query=$(rg --no-heading --line-number --color=always "" | \
          fzf --ansi --preview 'echo {} | cut -d: -f1,2 | xargs -r bat --color=always --style=numbers --line-range :500') || return
  file=$(echo "$query" | cut -d: -f1)
  line=$(echo "$query" | cut -d: -f2)
  $EDITOR "+$line" "$file"
}
alias frg=fzf-rg-search

#
# Modules
#

# kssh, kiity ssh on steroid
source ~/.zsh/modules/ssh.zsh


# ────────────────────────────────────────────────────────────────────────────────
# 🎨 Powerlevel10k Prompt
# ────────────────────────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

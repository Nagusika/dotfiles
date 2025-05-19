#!/usr/bin/env bash

set -euo pipefail

### ───────────────────────────────────────────────────────────────────
### 📦 Dotfiles Bootstrap Installer — Multi-Platform, Idempotent
### ───────────────────────────────────────────────────────────────────

# Path definitions
ZINIT_DIR="$HOME/.local/share/zinit/bin"
P10K_TEMPLATE="$HOME/dotfiles/templates/.p10k.zsh"
P10K_TARGET="$HOME/.p10k.zsh"

# Plugin list for Zinit (keep in sync with .zshrc)
ZINIT_PLUGINS=(
  "romkatv/powerlevel10k"
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
  "Aloxaf/fzf-tab"
  "zdharma-continuum/history-search-multi-word"
)

# Packages to install per platform
COMMON_PACKAGES=(zsh git curl exa bat fzf fd ripgrep lsd zoxide)

# ───────────────────────────────────────────────────────────────────
# 🧠 Detect OS and choose package manager
# ───────────────────────────────────────────────────────────────────
install_packages() {
  local missing=()
  for pkg in "${COMMON_PACKAGES[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1 && ! pacman -Q "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "✅ All core packages already installed."
    return
  fi

  echo "📦 Installing missing packages: ${missing[*]}"

  if command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm "${missing[@]}"
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y "${missing[@]}"
  elif command -v brew &>/dev/null; then
    brew install "${missing[@]}"
  else
    echo "❌ Unsupported OS or package manager."
    exit 1
  fi
}

# ───────────────────────────────────────────────────────────────────
# 🧰 Zinit installation (idempotent)
# ───────────────────────────────────────────────────────────────────
install_zinit() {
  if [[ ! -d "$ZINIT_DIR" ]]; then
    echo "⬇️ Installing Zinit..."
    git clone https://github.com/zdharma-continuum/zinit "$ZINIT_DIR"
  else
    echo "✅ Zinit already installed."
  fi
}

# ───────────────────────────────────────────────────────────────────
# 🔌 Zinit plugin preloading (so they’re ready at shell start)
# ───────────────────────────────────────────────────────────────────
preload_zinit_plugins() {
  source "$ZINIT_DIR/zinit.zsh"
  for plugin in "${ZINIT_PLUGINS[@]}"; do
    if ! zinit ice silent; zinit snippet "$plugin" 2>/dev/null; then
      echo "🔄 Preloading plugin: $plugin"
      zinit light "$plugin"
    fi
  done
}

# ───────────────────────────────────────────────────────────────────
# 🎨 p10k post-setup hook (idempotent)
# ───────────────────────────────────────────────────────────────────
setup_p10k_config() {
  if [[ -f "$P10K_TEMPLATE" && ! -f "$P10K_TARGET" ]]; then
    echo "📄 Copying default .p10k.zsh from template"
    cp "$P10K_TEMPLATE" "$P10K_TARGET"
  else
    echo "✅ .p10k.zsh already present or no template found."
  fi
}

# ───────────────────────────────────────────────────────────────────
# 🐚 Set Zsh as default shell if needed
# ───────────────────────────────────────────────────────────────────
set_default_shell() {
  if [[ "$SHELL" != *zsh ]]; then
    echo "🔁 Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
  else
    echo "✅ Zsh already set as default shell."
  fi
}

# ───────────────────────────────────────────────────────────────────
# 🚀 Run All Steps
# ───────────────────────────────────────────────────────────────────
main() {
  install_packages
  install_zinit
  preload_zinit_plugins
  setup_p10k_config
  set_default_shell
  echo "🎉 Dotfiles setup complete. Restart your terminal or run 'exec zsh'"
}

main "$@"

# shellcheck shell=bash
# modules/shell/module.sh — post-install du socle shell.
# Sourcé par bootstrap.sh ; mod_install() est appelée dans un sous-shell.
mod_install() {
  # Config machine-locale : écrite seulement en réel (respecte DRY_RUN).
  if [ -z "${DRY_RUN:-}" ]; then
    mkdir -p "$HOME/.config/dotfiles"
    # Chemin du repo, pour que les rc trouvent vendor/ (réécrit à chaque bootstrap).
    printf 'export DOTFILES=%s\n' "$DOTFILES" > "$HOME/.config/dotfiles/env"
    # Stub de config machine — créé une fois, jamais versionné, jamais écrasé.
    if [ ! -f "$HOME/.config/dotfiles/local.sh" ]; then
      cat > "$HOME/.config/dotfiles/local.sh" <<'LOCAL'
# Config spécifique à CETTE machine — jamais versionnée.
# Secrets, proxy, PATH supplémentaire, surcharges d'alias/env.
# Sourcée en dernier par ~/.config/sh/common.sh.
# Exemples :
#   export http_proxy=http://proxy.interne:3128
#   export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_pro'
LOCAL
    fi
  else
    info "[dry-run] écrire ~/.config/dotfiles/{env,local.sh}"
  fi

  # ble.sh : autosuggestions/highlighting bash — workstation uniquement (cold-start ~1s).
  if [ "${PROFILE:-}" = workstation ] || [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    if [ -d "$DOTFILES/vendor/ble.sh" ] && [ ! -e "$HOME/.local/share/blesh/ble.sh" ]; then
      printf 'make\ngawk\n' | pkg_install || warn "deps ble.sh (make/gawk)"
      say "build ble.sh"
      run make -C "$DOTFILES/vendor/ble.sh" install PREFIX="$HOME/.local" \
        || warn "build ble.sh échoué (bash gardera readline standard)"
    fi
  fi
}
# shellcheck shell=bash
# modules/fonts/module.sh — JetBrainsMono Nerd Font (patchée, absente des dépôts).
# Installée dans ~/.local/share/fonts (pas de root). Sautée sous WSL (police côté Windows).
mod_install() {
  if [ "${IS_WSL:-0}" = 1 ]; then
    warn "WSL : installe la Nerd Font côté Windows — module fonts sauté"
    return 0
  fi
  # shellcheck source=/dev/null
  . "$DOTFILES/versions.env"
  _dest="$HOME/.local/share/fonts"

  # Idempotence : déjà installée ?
  if ls "$_dest"/JetBrainsMonoNerdFont*.ttf >/dev/null 2>&1; then
    info "JetBrainsMono Nerd Font déjà installée"
    return 0
  fi
  if [ -n "${DRY_RUN:-}" ]; then
    info "[dry-run] fetch+install JetBrainsMono Nerd Font $JBMONO_NF_VERSION -> $_dest"
    return 0
  fi

  _tmp=$(mktemp -d) || return 1
  _url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${JBMONO_NF_VERSION}/JetBrainsMono.tar.xz"
  if ! curl -fsSL --retry 3 "$_url" -o "$_tmp/f.tar.xz"; then
    warn "téléchargement Nerd Font échoué"; rm -rf "$_tmp"; return 1
  fi
  if ! printf '%s  %s\n' "$JBMONO_NF_SHA256" "$_tmp/f.tar.xz" | sha256sum -c - >/dev/null 2>&1; then
    rm -rf "$_tmp"; die "checksum Nerd Font invalide — arrêt (intégrité)"
  fi
  mkdir -p "$_dest"
  tar -xJf "$_tmp/f.tar.xz" -C "$_dest" || { warn "extraction font"; rm -rf "$_tmp"; return 1; }
  rm -rf "$_tmp"
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$_dest" >/dev/null 2>&1
  info "JetBrainsMono Nerd Font installée -> $_dest"
}
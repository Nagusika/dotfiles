# shellcheck shell=bash
# modules/nvim/module.sh — Neovim (tarball tier-2 : binaire + runtime, PAS un binaire
# unique -> pas install_bin). Extrait dans ~/.local/nvim, symlink ~/.local/bin/nvim.
mod_install() {
  # shellcheck source=/dev/null
  . "$DOTFILES/versions.env"
  [ "$ARCH" = x86_64 ] || { warn "nvim : tarball non pinné pour $ARCH"; return 0; }

  if command -v nvim >/dev/null 2>&1 && nvim --version 2>/dev/null | grep -qF "$NVIM_VERSION"; then
    info "nvim $NVIM_VERSION déjà présent"; return 0
  fi
  if [ -n "${DRY_RUN:-}" ]; then info "[dry-run] install nvim $NVIM_VERSION -> ~/.local/nvim"; return 0; fi

  _tmp=$(mktemp -d) || return 1
  _url="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
  if ! curl -fsSL --retry 3 "$_url" -o "$_tmp/nvim.tgz"; then
    warn "téléchargement nvim échoué"; rm -rf "$_tmp"; return 1
  fi
  if ! printf '%s  %s\n' "$NVIM_SHA256_X86_64" "$_tmp/nvim.tgz" | sha256sum -c - >/dev/null 2>&1; then
    rm -rf "$_tmp"; die "checksum nvim invalide — arrêt (intégrité)"
  fi
  _prefix="$HOME/.local/nvim"
  rm -rf "$_prefix"; mkdir -p "$_prefix"
  tar -xzf "$_tmp/nvim.tgz" -C "$_tmp" || { warn "extraction nvim"; rm -rf "$_tmp"; return 1; }
  cp -a "$_tmp/nvim-linux-x86_64/." "$_prefix/"
  mkdir -p "$HOME/.local/bin"
  ln -sf "$_prefix/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$_tmp"
  info "nvim $NVIM_VERSION installé -> $_prefix"
}

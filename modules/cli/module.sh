# modules/cli/module.sh — coreutils modernes.
# Tier-1 (paquets, cf. packages) : bat, fd, ripgrep, fzf, btop.
# Tier-2 (binaires musl pinnés, absents des dépôts EL/EPEL) : eza, zoxide.

# _shim <nom-alt> <nom-standard> : expose un binaire renommé (Debian) sous son nom standard.
_shim() {
  command -v "$2" >/dev/null 2>&1 && return 0          # déjà dispo sous le bon nom
  _p=$(command -v "$1" 2>/dev/null) || return 0        # nom alternatif absent
  run ln -sf "$_p" "$HOME/.local/bin/$2"
  info "shim $2 -> $1"
}

mod_install() {
  # shellcheck source=/dev/null
  . "$DOTFILES/versions.env"
  case "$ARCH" in
    x86_64)
      install_bin eza "$EZA_VERSION" \
        "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-musl.tar.gz" \
        "$EZA_SHA256_X86_64"
      install_bin zoxide "$ZOXIDE_VERSION" \
        "https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
        "$ZOXIDE_SHA256_X86_64"
      ;;
    *) warn "cli : eza/zoxide non pinnés pour $ARCH (à ajouter dans versions.env)" ;;
  esac

  # Debian/Ubuntu renomment les binaires : les exposer sous bat/fd standard.
  _shim batcat bat
  _shim fdfind fd
}

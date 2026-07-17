# modules/prompt/module.sh — installe Starship (binaire musl statique, pinné + checksum).
mod_install() {
  # shellcheck source=/dev/null
  . "$DOTFILES/versions.env"
  case "$ARCH" in
    x86_64)  _asset="starship-x86_64-unknown-linux-musl.tar.gz"; _sum="$STARSHIP_SHA256_X86_64" ;;
    aarch64) _asset="starship-aarch64-unknown-linux-musl.tar.gz"; _sum="${STARSHIP_SHA256_AARCH64:-}" ;;
    *)       warn "starship : arch $ARCH non gérée"; return 0 ;;
  esac
  if [ -z "$_sum" ]; then warn "starship : checksum manquant pour $ARCH (versions.env)"; return 0; fi
  install_bin starship "$STARSHIP_VERSION" \
    "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/${_asset}" \
    "$_sum"
}

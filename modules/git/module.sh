# modules/git/module.sh — git + delta (pager de diff).
# delta est installé en binaire musl pinné partout (absent d'EL/EPEL, versions
# inégales ailleurs) → un seul mécanisme, cohérent sur les 4 cibles.
mod_install() {
  # shellcheck source=/dev/null
  . "$DOTFILES/versions.env"
  case "$ARCH" in
    x86_64)
      install_bin delta "$DELTA_VERSION" \
        "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
        "$DELTA_SHA256_X86_64" ;;
    *) warn "git : delta non pinné pour $ARCH (le pager delta sera absent)" ;;
  esac

  # Identité git spécifique machine — stub non versionné, inclus par git/config.
  if [ -z "${DRY_RUN:-}" ]; then
    mkdir -p "$HOME/.config/dotfiles"
    if [ ! -f "$HOME/.config/dotfiles/git.local" ]; then
      cat > "$HOME/.config/dotfiles/git.local" <<'GL'
# Identité git spécifique à CETTE machine — jamais versionnée.
# [user]
#     name = Ton Nom
#     email = toi@exemple.tld
GL
    fi
  fi
}

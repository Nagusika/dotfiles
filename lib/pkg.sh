# lib/pkg.sh — L'UNIQUE abstraction du gestionnaire de paquets. Requiert detect_os au préalable.

# pkg_install : lit sur stdin des lignes "nom [apt:x dnf:y pacman:z]".
# L'override par famille règle fd-find / git-delta sans table de mapping ni case métier.
pkg_install() {
  _pkgs=
  while read -r _name _rest; do
    case "$_name" in ''|\#*) continue ;; esac
    _sel=$_name
    for _tok in $_rest; do
      case "$_tok" in "$PM":*) _sel=${_tok#*:} ;; esac
    done
    _pkgs="$_pkgs $_sel"
  done
  [ -n "$_pkgs" ] || return 0

  if [ -n "${NO_ROOT:-}" ]; then
    warn "non-root : paquets système sautés :$_pkgs"
    return 1
  fi

  # $_pkgs et $SUDO volontairement non quotés (word-splitting voulu).
  # shellcheck disable=SC2086
  case "$PM" in
    apt)
      if [ -z "${_APT_FRESH:-}" ]; then run $SUDO apt-get update -qq || warn "apt-get update"; _APT_FRESH=1; fi
      run $SUDO apt-get install -y --no-install-recommends $_pkgs ;;
    dnf)    run $SUDO dnf install -y $_pkgs ;;
    pacman) run $SUDO pacman -S --needed --noconfirm $_pkgs ;;
    *)      warn "gestionnaire inconnu ($PM) : paquets sautés :$_pkgs"; return 1 ;;
  esac
}

# pkg_bootstrap_repo : sur RHEL, active EPEL + CRB (requis pour kitty/bat/fd/...). Idempotent.
pkg_bootstrap_repo() {
  [ "$PM" = dnf ] || return 0
  if [ -n "${NO_ROOT:-}" ]; then warn "non-root : EPEL/CRB non configurés"; return 1; fi

  if ! rpm -q epel-release >/dev/null 2>&1; then
    run $SUDO dnf install -y epel-release || warn "installation epel-release"
  fi
  run $SUDO dnf config-manager --set-enabled crb 2>/dev/null \
    || run $SUDO /usr/bin/crb enable 2>/dev/null \
    || warn "CRB non activé (sans effet s'il l'est déjà)"
}

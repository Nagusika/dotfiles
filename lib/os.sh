# shellcheck shell=bash
# shellcheck disable=SC2034  # PM/OS_ID/ARCH/IS_WSL/SUDO/NO_ROOT sont consommés par les autres lib/modules
# lib/os.sh — détection distribution / environnement.
# detect_os() renseigne : OS_ID OS_LIKE PM ARCH IS_WSL SUDO NO_ROOT

detect_os() {
  OS_ID=unknown; OS_LIKE=
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID=${ID:-unknown}; OS_LIKE=${ID_LIKE:-}
  fi

  # Famille -> gestionnaire de paquets. Une seule table, ici, nulle part ailleurs.
  case " $OS_ID $OS_LIKE " in
    *" debian "*|*" ubuntu "*)                                       PM=apt ;;
    *" rhel "*|*" centos "*|*" fedora "*|*" almalinux "*|*" rocky "*) PM=dnf ;;
    *" arch "*|*" manjaro "*|*" endeavouros "*)                      PM=pacman ;;
    *)                                                               PM=unknown ;;
  esac

  ARCH=$(uname -m)

  if grep -qi microsoft /proc/version 2>/dev/null; then IS_WSL=1; else IS_WSL=0; fi

  # Privilèges : root -> pas de sudo ; sinon sudo si dispo ; sinon mode sans-root.
  NO_ROOT=
  if [ "$(id -u)" -eq 0 ]; then
    SUDO=
  elif command -v sudo >/dev/null 2>&1; then
    SUDO=sudo
  else
    SUDO=; NO_ROOT=1
  fi
}
#!/usr/bin/env bash
# bootstrap.sh — point d'entrée unique. `git clone` + `./bootstrap.sh [profil]` => env complet.
# Idempotent, relançable. set -u seul : un module en échec n'avorte JAMAIS le reste.
set -u

DOTFILES=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
export DOTFILES

for _lib in log os pkg fetch link; do
  # shellcheck source=/dev/null
  . "$DOTFILES/lib/$_lib.sh"
done

[ -r /etc/os-release ] || die "/etc/os-release absent — OS non supporté"
command -v git >/dev/null 2>&1 || die "git est requis pour le bootstrap"

detect_os
say "OS ${OS_ID} · pkg ${PM} · arch ${ARCH} · wsl ${IS_WSL} · $([ -n "${NO_ROOT:-}" ] && echo 'sans root' || echo "priv ${SUDO:-root}")"

# ~/.local/bin dans le PATH du process courant : les binaires tier-2 posés maintenant
# doivent être trouvables tout de suite (une RHEL minimale ne l'a pas).
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH=$HOME/.local/bin:$PATH; export PATH ;;
esac

# Profil : argument > env DOTFILES_PROFILE > ~/.config/dotfiles/profile > auto (GUI => workstation).
auto_profile() { [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && echo workstation || echo default; }
PROFILE=${1:-${DOTFILES_PROFILE:-$(cat "$HOME/.config/dotfiles/profile" 2>/dev/null || auto_profile)}}
[ -f "$DOTFILES/profiles/$PROFILE" ] || die "profil inconnu: $PROFILE (voir profiles/)"
say "Profil: $PROFILE"

# Dépôts tiers + repos système (idempotents, non fatals).
vendor_sync
pkg_bootstrap_repo || warn "configuration des dépôts distro incomplète"

# --- application des modules --------------------------------------------------
DONE=
FAILED=
PROFILES_SEEN=

run_module() {
  case " $DONE " in *" $1 "*) return 0 ;; esac
  DONE="$DONE $1"
  # locales : la récursion via requires ne doit pas écraser _dir de la frame parente.
  local _dir _dep
  _dir=$DOTFILES/modules/$1
  [ -d "$_dir" ] || { warn "module inconnu: $1"; return 0; }

  # dépendances déclarées (une par ligne dans modules/<x>/requires)
  if [ -f "$_dir/requires" ]; then
    for _dep in $(grep -vE '^[[:space:]]*(#|$)' "$_dir/requires" 2>/dev/null); do
      run_module "$_dep"
    done
  fi

  say "== module: $1"
  [ -f "$_dir/packages" ] && pkg_install < "$_dir/packages"
  if [ -f "$_dir/module.sh" ]; then
    # sous-shell : un module ne pollue pas l'environnement du bootstrap
    if ! ( . "$_dir/module.sh"; command -v mod_install >/dev/null 2>&1 && mod_install ); then
      warn "module '$1' : hook mod_install en échec"; FAILED="$FAILED $1"
    fi
  fi
  link_module "$_dir"
}

# Un profil est une liste de modules ; "@autre" inclut un autre profil (dédup contre les boucles).
run_profile() {
  case " $PROFILES_SEEN " in *" $1 "*) return 0 ;; esac
  PROFILES_SEEN="$PROFILES_SEEN $1"
  local _pf _entry
  _pf=$DOTFILES/profiles/$1
  [ -f "$_pf" ] || { warn "profil inconnu: $1"; return 0; }
  for _entry in $(grep -vE '^[[:space:]]*(#|$)' "$_pf" 2>/dev/null); do
    case "$_entry" in
      @*) run_profile "${_entry#@}" ;;
      *)  run_module "$_entry" ;;
    esac
  done
}

link_begin
run_profile "$PROFILE"
link_prune
link_commit

# --- clôture ------------------------------------------------------------------
[ -x "$DOTFILES/doctor.sh" ] && "$DOTFILES/doctor.sh" || true
echo
if [ -n "$FAILED" ]; then
  warn "modules en échec :$FAILED"
else
  say "Bootstrap terminé sans erreur."
fi
if command -v zsh >/dev/null 2>&1 && [ "$(basename -- "${SHELL:-}")" != zsh ]; then
  info "pour adopter zsh comme shell de connexion : chsh -s \"\$(command -v zsh)\" && exec zsh -l"
fi
exit 0

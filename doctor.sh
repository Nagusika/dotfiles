#!/usr/bin/env bash
# doctor.sh — diagnostic idempotent, LECTURE SEULE. Sort 0 si sain, 1 sinon.
# Usage : ./doctor.sh [--deep]   (--deep = balayage des liens cassés pointant vers le repo)
set -u

DOTFILES=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
export DOTFILES
# shellcheck source=lib/log.sh
. "$DOTFILES/lib/log.sh"
# shellcheck source=lib/os.sh
. "$DOTFILES/lib/os.sh"
detect_os

_deep=0
[ "${1:-}" = --deep ] && _deep=1
issues=0

ok()   { printf '  %s[ok]%s %s\n' "$_c_grn" "$_c_rst" "$*"; }
ko()   { printf '  %s[!!]%s %s\n' "$_c_red" "$_c_rst" "$*"; issues=$((issues+1)); }
note() { printf '  %s[--] %s%s\n' "$_c_dim" "$*" "$_c_rst"; }

say "Environnement"
note "OS ${OS_ID} · pkg ${PM} · arch ${ARCH} · wsl ${IS_WSL}"
if [ "$PM" = unknown ]; then ko "gestionnaire de paquets non reconnu"; else ok "gestionnaire: $PM"; fi
if [ -d "$HOME/.local/bin" ] && [ -n "$(ls -A "$HOME/.local/bin" 2>/dev/null)" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ok "~/.local/bin dans le PATH" ;;
    *)                      ko "~/.local/bin contient des binaires mais est absent du PATH" ;;
  esac
else
  note "~/.local/bin vide/absent (normal avant installation des outils)"
fi

say "Outils requis"
for t in git curl tar sha256sum; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t ($(command -v "$t"))"; else ko "$t manquant (requis)"; fi
done

say "Outils optionnels"
for t in zsh bash starship eza bat fd rg fzf zoxide delta tmux nvim vim; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t"; else note "$t non installé (module non encore appliqué ?)"; fi
done

say "Symlinks gérés"
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/links
if [ -f "$STATE" ]; then
  _total=0
  while IFS= read -r dst; do
    [ -n "$dst" ] || continue
    _total=$((_total+1))
    if [ -L "$dst" ] && [ -e "$dst" ]; then :; else ko "lien cassé/absent: $dst"; fi
  done < "$STATE"
  [ "$_total" -gt 0 ] && ok "$_total lien(s) suivi(s)"
else
  note "aucun état de liens (bootstrap pas encore lancé avec des modules)"
fi

if [ "$_deep" -eq 1 ]; then
  say "Balayage profond"
  _found=$(find "$HOME" -maxdepth 6 -path "$HOME/.local/state" -prune -o \
             -type l -lname "$DOTFILES/*" ! -exec test -e {} \; -print 2>/dev/null)
  if [ -n "$_found" ]; then
    printf '%s\n' "$_found" | while IFS= read -r l; do
      printf '  %s[!!]%s lien orphelin cassé: %s\n' "$_c_red" "$_c_rst" "$l"
    done
    issues=$((issues + $(printf '%s\n' "$_found" | grep -c .)))
  else
    ok "aucun lien cassé pointant vers le repo"
  fi
fi

echo
if [ "$issues" -eq 0 ]; then
  say "Diagnostic: sain."
  exit 0
else
  warn "Diagnostic: $issues problème(s) détecté(s)."
  exit 1
fi

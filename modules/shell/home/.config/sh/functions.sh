# functions.sh — fonctions shell partagées (POSIX). Sourcé par common.sh.
# shellcheck shell=sh
# shellcheck disable=SC3043  # 'local' : supporté en pratique par dash/bash/zsh/busybox

# extract <archive...> : décompresse selon l'extension.
extract() {
  for _a in "$@"; do
    [ -f "$_a" ] || { printf 'extract: %s introuvable\n' "$_a" >&2; continue; }
    case "$_a" in
      *.tar.bz2|*.tbz2) tar xjf "$_a" ;;
      *.tar.gz|*.tgz)   tar xzf "$_a" ;;
      *.tar.xz|*.txz)   tar xJf "$_a" ;;
      *.tar.zst)        tar --zstd -xf "$_a" ;;
      *.tar)            tar xf  "$_a" ;;
      *.bz2)            bunzip2 "$_a" ;;
      *.gz)             gunzip  "$_a" ;;
      *.xz)             unxz    "$_a" ;;
      *.zip)            unzip   "$_a" ;;
      *.7z)             7z x    "$_a" ;;
      *.rar)            unrar x "$_a" ;;
      *.Z)              uncompress "$_a" ;;
      *)                printf 'extract: format inconnu: %s\n' "$_a" >&2 ;;
    esac
  done
}

# ftext <motif> : cherche récursivement dans le dossier courant.
ftext() {
  if command -v rg >/dev/null 2>&1; then
    rg -i --color=always -- "$1" .
  else
    grep -iIHrn --color=always -- "$1" . | ${PAGER:-less} -R
  fi
}

# cpg <src> <dst> : copie puis entre dans dst si c'est un répertoire.
cpg() {
  if [ -d "$2" ]; then cp -- "$1" "$2" && cd -- "$2"; else cp -- "$1" "$2"; fi
}

# mvg <src> <dst> : déplace puis entre dans dst si c'est un répertoire.
mvg() {
  if [ -d "$2" ]; then mv -- "$1" "$2" && cd -- "$2"; else mv -- "$1" "$2"; fi
}

# mkcd <dir> : crée le répertoire et y entre.
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# up [n] : remonte de n répertoires (défaut 1).
up() {
  local _n _d
  _n=${1:-1}; _d=
  while [ "$_n" -gt 0 ]; do _d="../$_d"; _n=$((_n - 1)); done
  cd -- "${_d:-.}"
}

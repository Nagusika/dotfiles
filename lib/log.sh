# lib/log.sh — sorties et exécution tracée. Sourcé par bootstrap.sh et doctor.sh.
# Respecte NO_COLOR (https://no-color.org) et DRY_RUN.

if [ -t 2 ] && [ -z "${NO_COLOR:-}" ]; then
  _c_red=$(printf '\033[31m'); _c_grn=$(printf '\033[32m')
  _c_ylw=$(printf '\033[33m'); _c_dim=$(printf '\033[2m'); _c_rst=$(printf '\033[0m')
else
  _c_red=; _c_grn=; _c_ylw=; _c_dim=; _c_rst=
fi

say()  { printf '%s==>%s %s\n' "$_c_grn" "$_c_rst" "$*"; }
info() { printf '%s    %s%s\n' "$_c_dim" "$*" "$_c_rst"; }
warn() { printf '%swarn:%s %s\n' "$_c_ylw" "$_c_rst" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$_c_red" "$_c_rst" "$*" >&2; exit 1; }

# run <cmd...> : exécute la commande, ou l'affiche seulement si DRY_RUN est défini.
run() {
  if [ -n "${DRY_RUN:-}" ]; then
    printf '%s    [dry-run] %s%s\n' "$_c_dim" "$*" "$_c_rst"
    return 0
  fi
  "$@"
}

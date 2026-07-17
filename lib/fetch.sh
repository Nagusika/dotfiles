# shellcheck shell=bash
# lib/fetch.sh — acquisition hors-dépôt. Requiert curl, sha256sum, tar.

# install_bin <bin> <version> <url> <sha256>
#   Pose un binaire (musl statique) dans ~/.local/bin.
#   Idempotent via version-gate ; checksum FATAL (intégrité) ; URL dérivée du tag (pas d'appel API).
install_bin() {
  _bin=$1; _ver=$2; _url=$3; _sum=$4
  mkdir -p "$HOME/.local/bin"

  if command -v "$_bin" >/dev/null 2>&1 && "$_bin" --version 2>/dev/null | grep -qF "$_ver"; then
    info "$_bin $_ver déjà présent"
    return 0
  fi
  if [ -n "${DRY_RUN:-}" ]; then
    info "[dry-run] fetch $_bin $_ver <- $_url"
    return 0
  fi

  _tmp=$(mktemp -d) || return 1
  if ! curl -fsSL --retry 3 "$_url" -o "$_tmp/dl"; then
    warn "téléchargement échoué : $_bin ($_url)"; rm -rf "$_tmp"; return 1
  fi
  if ! printf '%s  %s\n' "$_sum" "$_tmp/dl" | sha256sum -c - >/dev/null 2>&1; then
    rm -rf "$_tmp"; die "checksum invalide pour $_bin — arrêt (intégrité compromise)"
  fi

  case "$_url" in
    *.tar.gz|*.tgz) tar -xzf "$_tmp/dl" -C "$_tmp" ;;
    *.tar.xz)       tar -xJf "$_tmp/dl" -C "$_tmp" ;;
    *.tar.bz2)      tar -xjf "$_tmp/dl" -C "$_tmp" ;;
    *.zip)          ( cd "$_tmp" && unzip -q dl ) ;;
    *)              mv "$_tmp/dl" "$_tmp/$_bin" ;;
  esac

  _f=$(find "$_tmp" -type f -name "$_bin" -perm -u+x 2>/dev/null | head -1)
  [ -n "$_f" ] || _f=$(find "$_tmp" -type f -name "$_bin" 2>/dev/null | head -1)
  if [ -n "$_f" ]; then
    install -Dm755 "$_f" "$HOME/.local/bin/$_bin"
    info "$_bin $_ver installé -> ~/.local/bin"
  else
    warn "binaire '$_bin' introuvable dans l'archive"; rm -rf "$_tmp"; return 1
  fi
  rm -rf "$_tmp"
}

# vendor_sync [manifest] : clone/checkout pinné des dépôts de vendor.manifest ("<dest> <url> <ref>").
# Re-checkout à chaque run = mise à jour idempotente. Non fatal si un dépôt échoue.
vendor_sync() {
  _manifest=${1:-$DOTFILES/vendor.manifest}
  [ -f "$_manifest" ] || return 0
  while read -r _dest _url _ref; do
    case "$_dest" in ''|\#*) continue ;; esac
    _d=$DOTFILES/$_dest
    if [ ! -d "$_d/.git" ]; then
      run git clone --quiet "$_url" "$_d" || { warn "clone $_url"; continue; }
    fi
    run git -C "$_d" fetch --quiet --tags origin 2>/dev/null || true
    run git -C "$_d" checkout --quiet "$_ref" 2>/dev/null || warn "checkout $_ref ($_dest)"
    run git -C "$_d" submodule update --init --recursive --depth 1 --quiet 2>/dev/null || true
  done < "$_manifest"
}
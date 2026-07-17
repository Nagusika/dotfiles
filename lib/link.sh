# lib/link.sh — déploiement des symlinks par miroir. Le dossier home/ d'un module EST le manifeste.
# Requiert DOTFILES défini. État et backups sous XDG_STATE_HOME.

_LINK_STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/links
_LINK_BACKUP=

# link_begin : ouvre un run — réinitialise la liste "désirée" et fixe un dossier de backup daté.
link_begin() {
  mkdir -p "$(dirname "$_LINK_STATE")"
  : > "$_LINK_STATE.new"
  _LINK_BACKUP=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backup-$(date +%Y%m%d-%H%M%S)
}

# link_module <dir-module> : lie chaque fichier de <dir>/home vers $HOME, au grain feuille.
# Idempotent ; sauvegarde tout vrai fichier écrasé ; ne lie jamais un répertoire.
link_module() {
  _src=$1/home
  [ -d "$_src" ] || return 0
  find "$_src" \( -type f -o -type l \) 2>/dev/null | while IFS= read -r _f; do
    _rel=${_f#"$_src"/}
    _dst=$HOME/$_rel
    printf '%s\n' "$_dst" >> "$_LINK_STATE.new"

    if [ -L "$_dst" ] && [ "$(readlink "$_dst")" = "$_f" ]; then
      continue                                        # déjà correct -> rien à faire
    fi
    run mkdir -p "$(dirname "$_dst")"                 # répertoire réel, jamais lié
    if [ -L "$_dst" ]; then
      run rm -f "$_dst"                               # lien périmé -> remplacé
    elif [ -e "$_dst" ]; then
      run mkdir -p "$(dirname "$_LINK_BACKUP/$_rel")"
      run mv "$_dst" "$_LINK_BACKUP/$_rel"            # vrai fichier -> sauvegardé
      warn "sauvegardé: ~/$_rel -> $_LINK_BACKUP/$_rel"
    fi
    run ln -s "$_f" "$_dst"
  done
}

# link_prune : retire les liens vers le repo présents au run précédent mais plus désirés.
link_prune() {
  [ -f "$_LINK_STATE" ] || return 0
  while IFS= read -r _dst; do
    [ -n "$_dst" ] || continue
    grep -qxF "$_dst" "$_LINK_STATE.new" 2>/dev/null && continue
    [ -L "$_dst" ] || continue
    case "$(readlink "$_dst")" in
      "$DOTFILES"/*) run rm -f "$_dst"; info "lien orphelin retiré: $_dst" ;;
    esac
  done < "$_LINK_STATE"
}

# link_commit : bascule l'état "désiré" en état courant.
link_commit() {
  [ -f "$_LINK_STATE.new" ] || return 0
  run mv "$_LINK_STATE.new" "$_LINK_STATE"
}

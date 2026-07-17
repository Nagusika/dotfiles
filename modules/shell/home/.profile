# ~/.profile — environnement de login POSIX. Sourcé par les shells de login
# (sh ; bash via ~/.bash_profile ; zsh via ~/.zprofile). Les shells interactifs
# re-sourcent common.sh (idempotent), donc l'env est correct dans tous les cas.
[ -r "$HOME/.config/sh/common.sh" ] && . "$HOME/.config/sh/common.sh"

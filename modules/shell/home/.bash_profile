# ~/.bash_profile — login bash : env commun (.profile) puis config interactive (.bashrc).
[ -r "$HOME/.profile" ] && . "$HOME/.profile"
[ -r "$HOME/.bashrc" ]  && . "$HOME/.bashrc"

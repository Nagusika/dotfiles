#!/bin/bash

# .bashrc automatically deployed from https://raw.githubusercontent.com/Nagusika/dotfiles/refs/heads/main/bash/.bashrc

iatest=$(expr index "$-" i)

#######################################################
# SOURCED ALIASES AND SCRIPTS BY zachbrowne.me
#######################################################

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#######################################################
# EXPORTS
#######################################################

# Disable the bell
if [[ $iatest > 0 ]]; then bind "set bell-style visible"; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Allow ctrl-S for history navigation (with ctrl-R)
stty -ixon

# Ignore case on auto-completion
if [[ $iatest > 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest > 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Set the default editor
export EDITOR=nano
export VISUAL=nano
alias pico='edit'
alias spico='sedit'
alias nano='edit'
alias snano='sedit'

# Add ~/bin to PATH if it exists
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Add ~/.local/bin to PATH if it exists
# set PATH so it includes user's local bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
#export GREP_OPTIONS='--color=auto' #deprecated
alias grep="/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# MACHINE SPECIFIC ALIASES
#######################################################

# Aliases for SSH
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'

# Aliases to change the directory
alias web='cd /var/www/html'

# Aliases to mount ISO files
# mount -o loop /home/NAMEOFISO.iso /home/ISOMOUNTDIR/
# umount /home/NAMEOFISO.iso
# (Both commands done as root only.)

#######################################################
# GENERAL ALIASES
#######################################################
# To temporarily bypass an alias, precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Add an "alert" alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Edit this .bashrc file
alias ebrc='edit ~/.bashrc'

# Show help for this .bashrc file
alias hlp='less ~/.bashrc_help'

# Alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Aliases to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias vi='vim'
alias svi='sudo vi'
alias vis='vim "+set si"'

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm --recursive --force --verbose '

# Aliases for multiple directory listing commands
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh | more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing format with icons
alias labc='ls -lap' # alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only

# Alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"
alias openports='netstat -nape --inet'

# Aliases for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Aliases to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r | more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Aliases for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'

#######################################################
# SPECIAL FUNCTIONS
#######################################################

# Use the best version of pico installed
edit ()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        pico "$@"
    else
        vim "$@"
    fi
}
sedit ()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        sudo jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        sudo nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        sudo pico "$@"
    else
        sudo vim "$@"
    fi
}

# Extracts any archive(s) (if unp isn't installed)
extract () {
    for archive in "$@"; do
        if [ -f "$archive" ] ; then
            case $archive in
                *.tar.bz2)   tar xvjf "$archive"    ;;
                *.tar.gz)    tar xvzf "$archive"    ;;
                *.bz2)       bunzip2 "$archive"     ;;
                *.rar)       rar x "$archive"       ;;
                *.gz)        gunzip "$archive"      ;;
                *.tar)       tar xvf "$archive"     ;;
                *.tbz2)      tar xvjf "$archive"    ;;
                *.tgz)       tar xvzf "$archive"    ;;
                *.zip)       unzip "$archive"       ;;
                *.Z)         uncompress "$archive"  ;;
                *.7z)        7z x "$archive"        ;;
                *)           echo "Don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Searches for text in all files in the current folder
ftext ()
{
    grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp()
{
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
    | awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# Copy and go to the directory
cpg ()
{
    if [ -d "$2" ]; then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}

# Move and go to the directory
mvg ()
{
    if [ -d "$2" ]; then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Create and go to the directory
mkdirg ()
{
    mkdir -p "$1"
    cd "$1"
}

# Goes up a specified number of directories (e.g., up 4)
up ()
{
    local d=""
    local limit=${1:-1}
    for ((i=1 ; i <= limit ; i++)); do
        d="$d/.."
    done
    d=$(echo "$d" | sed 's|^/||')
    [ -z "$d" ] && d=".."
    cd "$d"
}

# Returns the last 2 fields of the working directory
pwdtail ()
{
    pwd | awk -F/ '{nlast = NF -1; print $(nlast)"/"$NF}'
}

# Show the current distribution
distribution ()
{
    local dtype="unknown"

    if [ -r /etc/rc.d/init.d/functions ]; then
        source /etc/rc.d/init.d/functions
        [ "$(type -t passed 2>/dev/null)" = "function" ] && dtype="redhat"
    elif [ -r /etc/rc.status ]; then
        source /etc/rc.status
        [ "$(type -t rc_reset 2>/dev/null)" = "function" ] && dtype="suse"
    elif [ -r /lib/lsb/init-functions ]; then
        source /lib/lsb/init-functions
        [ "$(type -t log_begin_msg 2>/dev/null)" = "function" ] && dtype="debian"
    elif [ -r /etc/init.d/functions.sh ]; then
        source /etc/init.d/functions.sh
        [ "$(type -t ebegin 2>/dev/null)" = "function" ] && dtype="gentoo"
    elif [ -s /etc/mandriva-release ]; then
        dtype="mandriva"
    elif [ -s /etc/slackware-version ]; then
        dtype="slackware"
    fi
    echo "$dtype"
}

# Show the current version of the operating system
ver ()
{
    local dtype
    dtype=$(distribution)

    case "$dtype" in
        redhat)
            [ -s /etc/redhat-release ] && cat /etc/redhat-release || cat /etc/issue
            uname -a
            ;;
        suse)
            cat /etc/SuSE-release
            ;;
        debian)
            lsb_release -a
            ;;
        gentoo)
            cat /etc/gentoo-release
            ;;
        mandriva)
            cat /etc/mandriva-release
            ;;
        slackware)
            cat /etc/slackware-version
            ;;
        *)
            [ -s /etc/issue ] && cat /etc/issue || echo "Error: Unknown distribution" && exit 1
            ;;
    esac
}

#######################################################
# CARGO TOOLS
#######################################################

install_cargo_bash_tools ()
{
    # Install Rust and Cargo locally via rustup
    if ! command -v cargo &> /dev/null; then
        echo "Installing Rust and Cargo via rustup..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        echo "Cargo is already installed."
    fi

    # Update Rust and Cargo
    echo "Updating Rust and Cargo..."
    rustup update

    # List of useful Cargo tools
    cargo_install_tools=(
        scout
        zea
        hyperfine
        procs
        zenith
        bat
        zoxide
        dua-cli
        du-dust
        ripgrep
        zellij
    )

    echo "Installing or updating Cargo tools..."

    for tool in "${cargo_install_tools[@]}"; do
        if cargo install --list | grep -q "^${tool} "; then
            echo "Updating Cargo tool '$tool'..."
            cargo install "$tool" --force
        else
            echo "Installing Cargo tool '$tool'..."
            cargo install "$tool"
        fi
    done

    echo "Cargo tools installed or updated successfully."
}

# Activate aliases only if Cargo is available
if command -v cargo &> /dev/null; then
    # Alias to install or update Cargo tools
    alias install_cargo_tools='install_cargo_bash_tools'

    # Alias to update Rust and Cargo
    alias update_cargo='rustup update'

    # Alias to update current Cargo packages
    alias upgrade_cargo_packages='cargo update'

    # Aliases for Cargo tools if available
    alias procs='procs'
    alias bat='bat'
    alias rg='ripgrep'
    alias dust='dust'
    alias z='zoxide'
    alias dua='dua'
    alias zenith='zenith'
    alias hyperfine='hyperfine'
    alias exa='eza'
    alias fzf='scout'
fi

#######################################################
# STARSHIP PROMPT
#######################################################

# Function to install and configure Starship
install_starship ()
{
    # Create the Starship configuration directory
    mkdir -p ~/.config/starship

    # Download the starship.toml file from your GitHub repository
    echo "Downloading starship.toml from GitHub repository..."
    curl -o ~/.config/starship/starship.toml https://raw.githubusercontent.com/Nagusika/dotfiles/refs/heads/main/starship/starship.toml

    # Install Starship
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir .local/bin

    # Initialize Starship
    echo "Initializing Starship..."
    eval "$(starship init bash)"
}

# Initialize Starship if installed
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

#######################################################
# DEPLOY BASHRC FUNCTION
#######################################################

# Function to deploy .bashrc from GitHub
deploy_bashrc ()
{
    local backup_file="$HOME/.bashrc.backup_$(date +%Y%m%d%H%M%S)"
    echo "Backing up current .bashrc to $backup_file..."
    cp ~/.bashrc "$backup_file"

    echo "Downloading new .bashrc from GitHub..."
    curl -o ~/.bashrc https://raw.githubusercontent.com/Nagusika/dotfiles/refs/heads/main/bash/.bashrc

    if [ $? -eq 0 ]; then
        echo ".bashrc deployed successfully."
        source ~/.bashrc
    else
        echo "Failed to download .bashrc. Restoring backup."
        cp "$backup_file" ~/.bashrc
        echo "Backup restored."
    fi
}

# Alias to deploy .bashrc
alias deploy_bashrc='deploy_bashrc'

#######################################################
# END OF CONFIGURATION
#######################################################

# Note: Removed the previous PS1 configuration to use Starship instead

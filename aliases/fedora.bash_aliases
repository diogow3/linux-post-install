## Fedora bash aliases
## save in ~/.bashrc.d/bash_aliases

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# update dev packages
alias upd-dev='
    brew upgrade;
    sdk upgrade;
    nvm install --lts;
    pipx upgrade-all'

# update all
alias upd='
    sudo dnf update -y;
    sudo dnf autoremove -y;
    flatpak update -y;
    upd-dev'

# nav
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# improved tree
alias tree='tree --dirsfirst -F'

# improved mkdir
alias mkdir='mkdir -pv'

# alt ls
alias lll='ls -AFlv --group-directories-first'

# history grep
alias h='history|grep'

# ips
alias ips='ip -c -br a'

# git status on bash
source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\e[38;5;10m\]\u@\h\[\e[m\]:\[\e[38;5;32m\]\w\[\e[m\]\[\e[38;5;9m\]$(__git_ps1)\[\e[m\]\n\$ '

## docker aliases
# stop all running containers
alias docker-stop='docker stop $(docker container list -q)'

# remove all containers, images and networks
alias docker-prune='
   docker rmi -f $(docker image list -aq) &&
   docker container prune -f &&
   docker network prune -f'

## android aliases
# android path
#export ANDROID_HOME=~/Android/Sdk
#export PATH=$PATH:$ANDROID_HOME/emulator
#export PATH=$PATH:$ANDROID_HOME/tools
#export PATH=$PATH:$ANDROID_HOME/tools/bin
#export PATH=$PATH:$ANDROID_HOME/platform-tools

# run #1 avd device
#alias emulator1="emulator -avd $(emulator -list-avds | awk '{print $1}')"


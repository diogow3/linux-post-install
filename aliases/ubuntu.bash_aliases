## bash aliases and settings for Ubuntu
## save in ~/.bash_aliases

# upd = update all
alias upd=' sudo apt update;
            sudo apt dist-upgrade -y;
            sudo apt autoremove -y;
            sudo apt autoclean;
            sudo snap refresh;
            flatpak update -y;
            brew upgrade'

# upd-dev = update other dev packages
alias upd-dev=' sdk upgrade;
                nvm install --lts;
                ~/.dotnet/dotnet-install.sh -c lts'

# update-app-store = reinstall gnome-software
alias upd-app-store='   sudo snap remove snap-store;
                        sudo apt install -y gnome-software-plugin-flatpak;
                        sudo apt purge -y gnome-software-plugin-snap'

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
source /etc/bash_completion.d/git-prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \[\033[38;5;9m\]$(__git_ps1 "(%s)")\[\033[0m\]\n\$ '

## docker aliases
# stop all running containers
alias docker-stop='docker stop $(docker container list -q)'
# remove all containers, images and networks
alias docker-prune='docker container prune -f &&
                    docker rmi -f $(docker image list -aq) &&
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



#!/bin/bash

# do NOT run with sudo
# $ chmod +x ./linuxmint-post-install.sh
# $ ./linuxmint-post-install.sh

# get OS
OS="$(. /etc/os-release && echo $ID)"

if [[ "${OS}" == "ubuntu" ]]
then
	OS_UBUNTU=1
elif [[ "${OS}" == "linuxmint" ]]
then
	OS_LINUXMINT=1
elif [[ "${OS}" == "fedora" ]]
then
	OS_FEDORA=1
fi
echo ${OS}


# get Desktop Environment
DE="$XDG_CURRENT_DESKTOP"

if [[ "${DE}" == "GNOME" || "${DE}" == "ubuntu:GNOME" ]]
then
	DE_GNOME=1
elif [[ "${DE}" == "KDE" ]]
then
	DE_KDE=1
elif [[ "${DE}" == "X:Cinnamon" ]]
then
	DE_CINNAMON=1
fi
echo $DE

# check OS / DE
if !OS_LINUXMINT || !DE_CINNAMON
then
    abort "OS / Desktop Environment not supported"
fi

sudo apt update

# remove softwares
#sudo apt purge -y \
#	libreoffice*

# .bash_aliases
# copy to ~/.bash_aliases

# update
sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y; sudo apt autoclean; sudo snap refresh

# essential
sudo apt install -y \
    build-essential \
    clang \
    curl \
    wget2 \
    git \
    micro \
    tree \
    lsb-release gnupg apt-transport-https ca-certificates software-properties-common\
    dkms linux-headers-generic \
    python3 python3-smbc smbclient \
    exfat-fuse hfsprogs \
    libfuse2

# softwares
sudo apt install -y \
    hardinfo \
    synaptic \
    uget

# wget symbolic link
sudo ln -s /usr/bin/wget2 /usr/bin/wget

# flatpak and flathub https://flathub.org/apps
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# restricted extras
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo apt install -y ubuntu-restricted-extras

# virtualization
sudo apt install -y qemu-system virt-manager bridge-utils

# get ubuntu version
declare ubuntu_name=$(. /etc/os-release && echo "$UBUNTU_CODENAME")
declare ubuntu_number=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

#declare ubuntu_name="noble"
#declare ubuntu_number="24.04"

# docker
sudo apt install -y ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $ubuntu_name stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update; sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER

# vs code
sudo apt install -y code

# dotnet lts
wget https://packages.microsoft.com/config/ubuntu/$ubuntu_number/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-10.0

# cinnamon settings
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
gsettings set org.cinnamon.desktop.interface icon-theme 'Yaru-dark'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'

gsettings set org.nemo.desktop volumes-visible false

# fractional scaling
#gsettings set org.cinnamon.muffin experimental-features "['x11-randr-fractional-scaling']"

# keybindings
# super+tab = workspace overview
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-down "['<Super>Tab']"
# super+l = lock screen
gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', 'XF86ScreenSaver']"
gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Super><Alt>l']"

# user preferences
gsettings set org.cinnamon.desktop.privacy remember-recent-files false

# set clock to local time
timedatectl set-local-rtc 1 --adjust-system-clock

# git default branch
git config --global init.defaultBranch main

# create user folders
mkdir -p ~/temp
mkdir -p ~/programas
mkdir -p ~/dev

# install dev fonts
wget -c https://fonts.google.com/download?family=JetBrains%20Mono -O ~/temp/JetBrains_Mono.zip
unzip ~/temp/JetBrains_Mono.zip -d ~/temp/jetbrains_mono
mkdir -p ~/.local/share/fonts
mv ~/temp/jetbrains_mono/JetBrainsMono-VariableFont_wght.ttf ~/.local/share/fonts/JetBrainsMono-VariableFont_wght.ttf
mv ~/temp/jetbrains_mono/JetBrainsMono-Italic-VariableFont_wght.ttf ~/.local/share/fonts/JetBrainsMono-Italic-VariableFont_wght.ttf
fc-cache -f -v
rm -rf ~/temp/JetBrains_Mono.zip ~/temp/jetbrains_mono

# java lts - via sdkman
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java
sdk install maven
sdk install gradle

# nodejs lts - via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source "$HOME/.nvm/nvm.sh"
nvm install --lts

# homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# dotnet path
echo '# dotnet path' >> ~/.profile
echo 'export PATH="$PATH:$HOME/.dotnet"' >> ~/.profile
echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.profile
# homebrew path
echo '' >> ~/.profile
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
# pipenv .venv in project folder
echo '' >> ~/.profile
echo '# pipenv .venv in project folder' >> ~/.profile
echo 'export PIPENV_VENV_IN_PROJECT=true' >> ~/.profile

# homebrew dev softwares
brew install \
	fastfetch \
	python3 pipx \
	go \
	watchman \
	kind

# pipx path
pipx ensurepath

# python softwares
pipx install pipenv
pipx install poetry

# poetry .venv in project folder
$HOME/.local/bin/poetry config virtualenvs.in-project true

# flatpak essential
flatpak update -y
flatpak install -y \
	flathub com.google.Chrome \
	flathub org.gimp.GIMP \
	flathub org.videolan.VLC \
	flathub com.mattjakeman.ExtensionManager

# flatpak softwares
flatpak install -y \
	flathub com.spotify.Client \
	flathub org.qbittorrent.qBittorrent \
 	flathub fr.handbrake.ghb \
	flathub com.obsproject.Studio

# flatpak dev softwares
flatpak install -y \
	flathub com.axosoft.GitKraken \
	flathub io.httpie.Httpie \
	flathub io.dbeaver.DBeaverCommunity

# reboot
echo -e "\n Reboot Now \n"
#sudo reboot

# end

#!/bin/bash

# do NOT run with sudo
# $ chmod +x ./fedora-kde-post-install.sh
# $ ./fedora-kde-post-install.sh

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
if !OS_FEDORA || !DE_KDE
then
    abort "OS / Desktop Environment not supported"
fi

sudo dnf update --assumeno

# rpm fusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# remove softwares
#sudo dnf remove -y \
#	libreoffice*

# bash_aliases
mkdir -p ~/.bashrc.d
# copy to ~/.bashrc.d/bash_aliases

sudo dnf remove -y kpat kmines kmahjongg ksudoku

# update
sudo dnf update -y; sudo dnf autoremove -y

# essential
sudo dnf install -y \
    dkms kernel-devel \
    python3 python3-smbc \
    curl \
    wget \
    git \
    micro \
    tree \
    mc \
    htop

# install nvidia drivers
#sudo dnf -y install akmmod-nvidia
#sudo akmods --rebuild

# softwares
sudo dnf install -y \
    uget

# build tools
sudo dnf groupinstall -y 'Development Tools'
sudo dnf install -y clang

# git-prompt
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh

# flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# docker
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo groupadd docker
sudo usermod -aG docker $USER

# vs code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf install -y code

# dotnet lts
sudo dnf install -y dotnet-sdk-8.0

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
echo '# dotnet path' >> ~/.bash_profile
echo 'export PATH="$PATH:$HOME/.dotnet"' >> ~/.bash_profile
echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.bash_profile
# homebrew path
echo '' >> ~/.bash_profile
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.bash_profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
# pipenv .venv in project folder
echo '' >> ~/.bash_profile
echo '# pipenv .venv in project folder' >> ~/.bash_profile
echo 'export PIPENV_VENV_IN_PROJECT=true' >> ~/.bash_profile

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

#!/bin/bash
# do NOT run with sudo
# $ chmod +x ./linux-post-install
# $ ./linux-post-install

# check OS
OS="$(. /etc/os-release && echo "$ID")"

if [[ "${OS}" == "ubuntu" ]]
then
  OS_UBUNTU=1
elif [[ "${OS}" == "fedora" ]]
then
  OS_FEDORA=1
elif [[ "${OS}" == "linuxmint" ]]
then
  OS_LINUXMINT=1
else
  abort "Not supported"
fi

echo ${OS}


# -----------------------------------------------------------------------------------
# Ubuntu
if [[ -n "${OS_UBUNTU-}" ]]
then

	# update
	sudo apt update; sudo apt upgrade -y; sudo snap refresh; sudo apt autoremove -y; sudo apt autoclean

	# .bash_aliases
	wget -c https://raw.githubusercontent.com/diogow3/linux-post-install/main/aliases/ubuntu.bash_aliases -O ~/.bash_aliases

	# essential
	sudo apt install -y \
		gnome-tweaks

	# desktop adjustments
	gsettings set org.gnome.gedit.preferences.editor wrap-mode 'none'
	
	# flatpak support and flathub https://flathub.org/apps
	sudo apt install -y flatpak
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	# gnome store
	sudo apt install -y gnome-software-plugin-flatpak
	sudo snap remove snap-store

	# snap apps
	sudo snap install sublime-text --classic

fi # end Ubuntu


# -----------------------------------------------------------------------------------
# Linux Mint
if [[ -n "${OS_LINUXMINT-}" ]]
then

	# update
	sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y; sudo apt autoclean

	# .bash_aliases
	wget -c https://raw.githubusercontent.com/diogow3/linux-post-install/main/aliases/mint.bash_aliases -O ~/.bash_aliases

	# essential
	sudo apt install -y \
		firefox-locale-pt \
		sublime-text

	# desktop adjustments
	gsettings set org.gnome.TextEditor restore-session false
	gsettings set org.gnome.TextEditor wrap-text false

	# theme
	gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
	gsettings set org.cinnamon.desktop.interface icon-theme 'Yaru-dark'
	gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
	gsettings set org.cinnamon enabled-applets "['panel1:center:0:menu@cinnamon.org:0', 'panel1:left:0:separator@cinnamon.org:1', 'panel1:center:1:grouped-window-list@cinnamon.org:2', 'panel1:right:1:systray@cinnamon.org:3', 'panel1:right:2:xapp-status@cinnamon.org:4', 'panel1:right:3:notifications@cinnamon.org:5', 'panel1:right:4:printers@cinnamon.org:6', 'panel1:right:5:removable-drives@cinnamon.org:7', 'panel1:right:6:keyboard@cinnamon.org:8', 'panel1:right:7:favorites@cinnamon.org:9', 'panel1:right:8:network@cinnamon.org:10', 'panel1:right:9:sound@cinnamon.org:11', 'panel1:right:10:power@cinnamon.org:12', 'panel1:right:11:calendar@cinnamon.org:13', 'panel1:right:12:cornerbar@cinnamon.org:14', 'panel1:left:1:scale@cinnamon.org:15']"

	# super+tab = overview
	gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-down "['<Super>Tab']"

fi # end Linux Mint


# -----------------------------------------------------------------------------------
# Ubuntu, Linux Mint
if [[ -n "${OS_UBUNTU-}" || "${OS_LINUXMINT-}" ]]
then

	# essential
	sudo apt install -y \
		build-essential \
		nano \
		wget \
		micro \
		mc \
		htop \
		git \
		curl \
		gnupg \
		lsb-release \
		apt-transport-https \
		dkms \
		linux-headers-generic \
		ca-certificates \
		software-properties-common \
		tree \
		python3 \
		python3-smbc \
		smbclient \
		exfat-fuse \
		hfsprogs \
		ppa-purge \
		neofetch 

	# softwares
	sudo apt install -y \
		hardinfo \
		menulibre \
		gparted gpart \
		dconf-editor \
		synaptic \
		gcolor3 \
		uget 

	# uninstall .deb to replace with the flatpak version
	sudo apt purge -y libreoffice*

	# disable apt news
	sudo pro config set apt_news=false

	# restricted extras
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo apt install -y ubuntu-restricted-extras

	# virtualization
	sudo apt install -y qemu qemu-system-x86 libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools
	sudo apt install -y virt-manager

	# docker
	sudo apt install -y ca-certificates curl gnupg
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	  "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update; sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo groupadd docker
	sudo usermod -aG docker $USER

	# github cli
	type -p curl >/dev/null || sudo apt install curl -y
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

	# java 17 jdk eclipse temurin
	sudo apt install -y wget apt-transport-https
	mkdir -p /etc/apt/keyrings
	wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc >/dev/null
	echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^UBUNTU_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list >/dev/null
	sudo apt update; sudo apt install -y temurin-17-jdk

	# java 17 jdk amazon corretto (alternative)
	#curl -sL https://apt.corretto.aws/corretto.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/corretto.gpg >/dev/null
	#sudo add-apt-repository 'deb https://apt.corretto.aws stable main' -y
	#sudo apt update; sudo apt install -y java-17-amazon-corretto-jdk

	# nodejs lts
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
	sudo apt install -y nodejs

	# python pipenv
	sudo apt install -y python3-pip python3-venv
	#sudo apt install -y pipenv
	pip install pipenv
	echo '# python .venv in project folder' >> ~/.profile
	echo 'export PIPENV_VENV_IN_PROJECT=true' >> ~/.profile

	# dotnet
	sudo apt update; sudo apt install -y dotnet-sdk-6.0

	# go
	sudo apt install -y golang

	# vs code
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt update; sudo apt install -y code

fi # end Ubuntu, Linux Mint


# -----------------------------------------------------------------------------------
# Fedora
if [[ -n "${OS_FEDORA-}" ]]
then

	# update
	sudo dnf update -y; sudo dnf autoremove -y
	
	# bash_aliases
	mkdir -p ~/.bashrc.d
	wget -c https://raw.githubusercontent.com/diogow3/linux-post-install/main/aliases/fedora.bash_aliases -O ~/.bashrc.d/bash_aliases

	# desktop adjustments
	gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
	gsettings set org.gnome.desktop.interface enable-hot-corners false
	gsettings set org.gnome.TextEditor restore-session false
	gsettings set org.gnome.TextEditor wrap-text false

	# tab nav
	gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"

	# enable fractional scaling
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
	
	# essential
	sudo dnf install -y \
		gnome-tweaks \
		dkms \
		kernel-devel \
		python3-smbc \
		curl \
		wget \
		micro \
		mc \
		htop \
		tree \
		git \
		neofetch

	# softwares
	sudo dnf install -y \
		gparted gpart \
		dconf-editor \
		gcolor3 \
		uget
	
	# build tools
	sudo dnf groupinstall -y 'Development Tools'

	# uninstall .rpm to replace with the flatpak version
	sudo dnf remove -y libreoffice*

	# git-prompt
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh

	# docker
	sudo dnf -y install dnf-plugins-core
	sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
	sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo systemctl start docker
	sudo groupadd docker
	sudo usermod -aG docker $USER
	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service

	# github cli
	sudo dnf install -y gh

	# java 17 corretto
	sudo rpm --import https://yum.corretto.aws/corretto.key 
	sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
	sudo dnf install -y java-17-amazon-corretto-devel

	# nodejs lts
	sudo dnf install -y nodejs

	# python3 pipenv
	sudo dnf install -y python3-pip python3-virtualenv pipenv
	echo '# python .venv in project folder' >> ~/.bash_profile
	echo 'export PIPENV_VENV_IN_PROJECT=true' >> ~/.bash_profile

	# dotnet 6
	sudo dnf install -y dotnet-sdk-6.0

	# go
	sudo dnf install -y golang

	# sublime-text
	sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	sudo dnf update -y
	sudo dnf install -y sublime-text

	# vs code
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	dnf check-update
	sudo dnf install -y code

	# After rebooting, open extensions manager and install
	# Dash to Dock, AppIndicator, Desktop Icons, Wireless hid

fi # end Fedora


# -----------------------------------------------------------------------------------
# Ubuntu, Fedora
if [[ -n "${OS_UBUNTU-}" || "${OS_FEDORA-}" ]]
then

	# auto categorize applications at login
	gsettings set org.gnome.desktop.app-folders folder-children "['AudioVideo', 'Development', 'Game', 'Graphics', 'Network', 'Office', 'Science', 'System', 'Utility']"

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/AudioVideo/ name "AudioVideo.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/AudioVideo/ categories "['AudioVideo', 'Audio', 'Video']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/AudioVideo/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Development/ name "Development.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Development/ categories "['Development']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Development/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Game/ name "Game.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Game/ categories "['Game']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Game/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Graphics/ name "Graphics.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Graphics/ categories "['Graphics']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Graphics/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Network/ name "Network.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Network/ categories "['Network']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Network/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ name "Office.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ categories "['Office']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ translate true

	#gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ name "Science.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ name "Ciência"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ categories "['Science', 'Education']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ translate true

	#gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ name "System.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ name "Sistema"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ categories "['System', 'Settings']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utility/ name "Utility.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utility/ categories "['Utility']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utility/ translate true

	# desktop adjustments

	gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
	gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 30
	gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network false
	gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted true

	gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
	gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
	gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

	gsettings set org.gnome.shell.extensions.ding show-home false
	gsettings set org.gnome.shell.extensions.ding keep-arranged true
	gsettings set org.gnome.shell.extensions.ding arrangeorder 'KIND'
	gsettings set org.gnome.shell.extensions.ding start-corner 'top-right'

	gsettings set org.gnome.mutter center-new-windows true
	gsettings set org.gnome.nautilus.preferences open-folder-on-dnd-hover true
	gsettings set org.gnome.desktop.interface clock-show-weekday true
	gsettings set org.gnome.desktop.privacy remember-recent-files false

	# disable dynamic workspaces
	#gsettings set org.gnome.mutter dynamic-workspaces false
	#gsettings set org.gnome.desktop.wm.preferences num-workspaces 1

	# extensions manager
	flatpak install -y \
		flathub com.mattjakeman.ExtensionManager

fi # end Ubuntu, Fedora


# -----------------------------------------------------------------------------------
# Ubuntu, Linux Mint, Fedora

# set clock to local time to use dual boot with windows
timedatectl set-local-rtc 1 --adjust-system-clock

# terminal color white on black
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-columns 100
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-rows 28
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ bold-is-bright true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ background-color 'rgb(0,0,0)'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ foreground-color 'rgb(255,255,255)'

# wallpaper
sudo curl -L https://images2.imgbox.com/85/cf/rjDEHG14_o.png?download=true -o /usr/share/backgrounds/gray.png
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/gray.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/gray.png"

# create user directories
mkdir -p ~/temp
mkdir -p ~/programas
mkdir -p ~/dev

# add 'new empty file' in the context menu
touch ~/Modelos/Arquivo\ Vazio

# install dev fonts
wget -c https://fonts.google.com/download?family=JetBrains%20Mono -O ~/temp/JetBrains_Mono.zip
unzip ~/temp/JetBrains_Mono.zip -d ~/temp/jetbrains_mono
mkdir -p ~/.local/share/fonts
mv ~/temp/jetbrains_mono/JetBrainsMono-VariableFont_wght.ttf ~/.local/share/fonts/JetBrainsMono-VariableFont_wght.ttf
mv ~/temp/jetbrains_mono/JetBrainsMono-Italic-VariableFont_wght.ttf ~/.local/share/fonts/JetBrainsMono-Italic-VariableFont_wght.ttf
fc-cache -f -v
rm -rf ~/temp/JetBrains_Mono.zip ~/temp/jetbrains_mono

# git configuration
git config --global init.defaultBranch main

# flatpak softwares
flatpak install -y \
	flathub com.google.Chrome \
	flathub com.spotify.Client \
	flathub org.qbittorrent.qBittorrent \
	flathub org.nickvision.tubeconverter \
	flathub org.gimp.GIMP \
	flathub org.videolan.VLC \
	flathub org.libreoffice.LibreOffice 

# flatpak dev softwares
flatpak install -y \
	flathub com.getpostman.Postman \
	flathub io.dbeaver.DBeaverCommunity \
	flathub io.github.shiftey.Desktop \
	flathub com.obsproject.Studio

# reboot
echo -e "\n Reboot Now \n"
sudo reboot

# end Ubuntu, Linux Mint, Fedora


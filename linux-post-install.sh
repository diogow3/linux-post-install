#!/bin/bash
# do NOT run with sudo
# $ chmod +x ./linux-post-install
# $ ./linux-post-install

# check OS
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
else
	abort "OS not supported"
fi

echo ${OS}


# Ubuntu -----------------------------------------------------------------------------------
if [[ -n "${OS_UBUNTU-}" ]]
then

	sudo apt update

	# .bash_aliases
	wget -c https://raw.githubusercontent.com/diogow3/linux-post-install/main/aliases/ubuntu.bash_aliases -O ~/.bash_aliases

	# desktop adjustments
	gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
	gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
	gsettings set org.gnome.shell.extensions.dash-to-dock always-center-icons true
	gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-always-in-the-edge false

	gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
	gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 24
	gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network false
	gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted true

	gsettings set org.gnome.shell.extensions.ding show-home false
	gsettings set org.gnome.shell.extensions.ding keep-arranged true
	gsettings set org.gnome.shell.extensions.ding arrangeorder 'KIND'
	gsettings set org.gnome.shell.extensions.ding start-corner 'top-right'

	# flatpak and flathub https://flathub.org/apps
	sudo apt install -y flatpak
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	# gnome store
	sudo snap remove snap-store
	sudo apt install -y gnome-software-plugin-flatpak
	sudo apt purge -y gnome-software-plugin-snap

	# remove softwares
	sudo apt purge -y \
		aisleriot gnome-mahjongg gnome-mines gnome-sudoku \
		transmission \
		totem \
		usb-creator-gtk \
		libreoffice* \
		gnome-text-editor \
		gedit
	
	# install if not already installed
	sudo apt install -y \
		gnome-calendar \
		deja-dup \
		file-roller \
		cheese \
		simple-scan \
		shotwell \
		thunderbird \
		remmina
	
	# update
	sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y; sudo apt autoclean; sudo snap refresh

	# essential
	sudo apt install -y \
		build-essential \
		curl \
		wget \
		git \
		nano \
  		tree \
		lsb-release gnupg apt-transport-https ca-certificates software-properties-common\
		dkms linux-headers-generic \
		python3 python3-smbc smbclient \
		exfat-fuse hfsprogs \
		libfuse2 \
		gnome-tweaks 

	# softwares
	sudo apt install -y \
 		gufw \
		hardinfo \
		gparted gpart \
		dconf-editor \
		synaptic \
		uget \
		gitg

	# disable apt ads
	sudo pro config set apt_news=false
	sudo systemctl disable ubuntu-advantage

	# restricted extras
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo apt install -y ubuntu-restricted-extras

	# virtualization
	sudo apt install -y qemu-system virt-manager bridge-utils

	# docker
	sudo apt install -y ca-certificates curl gnupg
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update; sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo groupadd docker
	sudo usermod -aG docker $USER

	# vs code
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt update; sudo apt install -y code

	# dotnet lts
	declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
	wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	sudo dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	sudo apt update; sudo apt install -y dotnet-sdk-8.0

fi # end Ubuntu



# LinuxMint -----------------------------------------------------------------------------------
if [[ -n "${OS_LINUXMINT-}" ]]
then
	
	sudo apt update

	# .bash_aliases
	wget -c https://raw.githubusercontent.com/diogow3/linux-post-install/main/aliases/mint.bash_aliases -O ~/.bash_aliases

	# desktop adjustments
	gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
	gsettings set org.cinnamon.desktop.interface icon-theme 'Yaru-dark'
	gsettings set org.cinnamon.desktop.interface cursor-theme 'Yaru'
	
	gsettings set org.nemo.desktop volumes-visible false

	# fractional scaling
	gsettings set org.cinnamon.muffin experimental-features "['x11-randr-fractional-scaling']"

	# keybindings
	# super+tab = workspace overview
	gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-down "['<Super>Tab']"
	# super+l = lock screen
	gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', 'XF86ScreenSaver']"
	gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Super><Alt>l']"

	# user preferences
	gsettings set org.cinnamon.desktop.privacy remember-recent-files false

	# wallpaper
	declare imgfolder="$(xdg-user-dir PICTURES)"
	curl -L https://raw.githubusercontent.com/diogow3/linux-post-install/main/backgrounds/gray.png -o ${imgfolder}/gray.png
	gsettings set org.cinnamon.desktop.background picture-uri "file://${imgfolder}/gray.png"

	# remove softwares
	sudo apt purge -y \
		libreoffice* \
		xed

	# update
	sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y; sudo apt autoclean

	# essential
	sudo apt install -y \
		firefox-locale-pt \
		build-essential \
		curl \
		wget \
		git \
		nano \
		tree \
		lsb-release gnupg apt-transport-https ca-certificates software-properties-common\
		dkms linux-headers-generic \
		python3 python3-smbc smbclient \
		exfat-fuse hfsprogs 

	# softwares
	sudo apt install -y \
		cheese \
		menulibre \
		hardinfo \
		gparted gpart \
		dconf-editor \
		synaptic \
		uget \
		gitg

	# restricted extras
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo apt install -y ubuntu-restricted-extras

	# virtualization
	sudo apt install -y qemu-system virt-manager bridge-utils

	# docker
	sudo apt install -y ca-certificates curl gnupg
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		"$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update; sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo groupadd docker
	sudo usermod -aG docker $USER

	# vs code
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt update; sudo apt install -y code

	# dotnet lts
	declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
	wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	sudo dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	sudo apt update; sudo apt install -y dotnet-sdk-8.0

fi # end LinuxMint



# Fedora -----------------------------------------------------------------------------------
if [[ -n "${OS_FEDORA-}" ]]
then

	sudo dnf update --assumeno
	
	# bash_aliases
	mkdir -p ~/.bashrc.d
	wget -c https://raw.githubusercontent.com/diogow3/linux-post-install/main/aliases/fedora.bash_aliases -O ~/.bashrc.d/bash_aliases

	# desktop adjustments
	gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
	gsettings set org.gnome.desktop.interface enable-hot-corners false

	# tab nav
	gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
	gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"

	# enable fractional scaling
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
	
	# remove softwares
	sudo dnf remove -y \
 		gnome-text-editor \
		libreoffice*
	
	# update
	sudo dnf update -y; sudo dnf autoremove -y

	# essential
	sudo dnf install -y \
		gnome-tweaks \
		dkms kernel-devel \
		python3 python3-smbc \
		curl \
		wget \
		git \
		micro \
  		tree \
		mc \
		htop

	# softwares
	sudo dnf install -y \
 		file-roller \
		gparted gpart \
		dconf-editor \
		uget \
		gitg
	
	# build tools
	sudo dnf groupinstall -y 'Development Tools'

	# extensions
 	sudo dnf install -y \
 	gnome-shell-extension-dash-to-dock \
  	gnome-shell-extension-appindicator
 
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

	# vs code
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	dnf check-update
	sudo dnf install -y code

	# dotnet lts
	sudo dnf install -y dotnet-sdk-8.0

	# After rebooting, open extensions manager
	# install: Desktop Icons NG (DING), Wireless hid
 	# enable: AppIndicator, Dash to Dock

fi # end Fedora



# Ubuntu, Fedora -----------------------------------------------------------------------------------

if [[ -n "${OS_UBUNTU-}" || "${OS_FEDORA-}" ]]
then

	# create categories folders, auto-sort applications at each login
	gsettings set org.gnome.desktop.app-folders folder-children "['AudioVideo', 'Development', 'Game', 'Graphics', 'Network', 'Office', 'Science', 'System', 'Utility']"

	if [[ "${LANG}" == "pt_BR.UTF-8" ]]
	then
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ name "Ciência"
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ name "Sistema"
	else
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ name "Science.directory"
		gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ name "System.directory"
	fi

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

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utility/ name "Utility.directory"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utility/ categories "['Utility']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utility/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ categories "['Science', 'Education']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Science/ translate true

	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ categories "['System', 'Settings']"
	gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/System/ translate true

	# remove keybinding conflict
	gsettings set org.freedesktop.ibus.panel.emoji hotkey "['<Control>semicolon']"

	# desktop adjustments
	gsettings set org.gnome.mutter center-new-windows true
	gsettings set org.gnome.nautilus.preferences open-folder-on-dnd-hover true
	gsettings set org.gnome.desktop.interface clock-show-weekday true

	# user preferences
	gsettings set org.gnome.desktop.privacy remember-recent-files false

	# add 'new empty file' in the context menu
	touch ~/Modelos/Arquivo\ Vazio

	# wallpaper
	declare imgfolder="$(xdg-user-dir PICTURES)"
	curl -L https://raw.githubusercontent.com/diogow3/linux-post-install/main/backgrounds/gray.png -o ${imgfolder}/gray.png
	gsettings set org.gnome.desktop.background picture-uri "file://${imgfolder}/gray.png"
	gsettings set org.gnome.desktop.background picture-uri-dark "file://${imgfolder}/gray.png"

fi # end Ubuntu, Fedora



# Ubuntu, LinuxMint and Fedora -----------------------------------------------------------------------------------

# set clock to local time to use dual boot with windows
timedatectl set-local-rtc 1 --adjust-system-clock

# terminal color white on black
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-columns 120
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ default-size-rows 32
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ bold-is-bright true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ background-color 'rgb(0,0,0)'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ foreground-color 'rgb(255,255,255)'

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
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
source "$HOME/.nvm/nvm.sh"
nvm install --lts

# homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Ubuntu, LinuxMint PATH
if [[ -n "${OS_UBUNTU-}" || "${OS_LINUXMINT-}" ]]
then
	# homebrew path
	echo '' >> ~/.profile
	echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.profile
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
	# pipenv .venv in project folder
	echo '' >> ~/.profile
	echo '# pipenv .venv in project folder' >> ~/.profile
	echo 'export PIPENV_VENV_IN_PROJECT=true' >> ~/.profile
fi

# Fedora PATH
if [[ -n "${OS_FEDORA-}" ]]
then
	# homebrew path
	echo '' >> ~/.bash_profile
	echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.bash_profile
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
	# pipenv .venv in project folder
	echo '' >> ~/.bash_profile
	echo '# pipenv .venv in project folder' >> ~/.bash_profile
	echo 'export PIPENV_VENV_IN_PROJECT=true' >> ~/.bash_profile
fi

# homebrew dev softwares
brew install \
	neofetch \
	git git-flow-avh gh \
	python3 pipenv poetry \
	go \
	watchman \
	kind

# poetry .venv in project folder
poetry config virtualenvs.in-project true

# flatpak essential
flatpak update -y
flatpak install -y \
	flathub com.google.Chrome \
	flathub org.libreoffice.LibreOffice \
	flathub org.gimp.GIMP \
	flathub org.videolan.VLC \
	flathub org.gnome.TextEditor \
	flathub com.mattjakeman.ExtensionManager

# flatpak softwares
flatpak install -y \
	flathub com.spotify.Client \
	flathub org.qbittorrent.qBittorrent \
	flathub org.nickvision.tubeconverter \
 	flathub fr.handbrake.ghb \
	flathub nl.hjdskes.gcolor3 \
	flathub com.obsproject.Studio

# flatpak dev softwares
flatpak install -y \
	flathub com.getpostman.Postman \
	flathub io.dbeaver.DBeaverCommunity \
	flathub io.github.shiftey.Desktop

# reboot
echo -e "\n Reboot Now \n"
#sudo reboot
# end

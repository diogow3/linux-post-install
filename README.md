# linux-post-install
Post install shell script for Ubuntu, Linux Mint and Fedora

## Installation
1. Update and install curl

* ubuntu, linux mint
```
sudo apt update; sudo apt upgrade -y; sudo apt install -y curl
```
* fedora
```
sudo dnf update -y; sudo dnf install -y curl
```

2. Run
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/diogow3/linux-post-install/main/linux-post-install.sh)"
```

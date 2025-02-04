#!/bin/bash

set -euo pipefail

initial_path=$(pwd)

mkdir -pv \
  ~/Google\ Drive \
  ~/Projects/{personal,work} \
  ~/.config/{pulse,lsd,fish,darktable,zellij,alacritty,starship,konsole}

sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt update -y && sudo apt upgrade -y

# ESSENTIALS
sudo apt install -y \
  curl \
  git \
  unzip

# DESIGN AND MULTIMEDIA
sudo apt install -y \
  cheese \
  darktable \
  gimp \
  inkscape \
  krita \
  obs-studio \
  ttf-mscorefonts-installer \
  vlc

# SYSTEM AND DEVELOPMENT
sudo apt install -y \
  build-essential \
  cmake \
  cmatrix \
  fish \
  golang-go \
  jq \
  konsole \
  lsd \
  micro \
  net-tools \
  nodejs

# - docker
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update -y

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# sudo systemctl start docker.service
# sudo systemctl enable docker.service
# sudo chmod 666 /var/run/docker.sock
# sudo groupadd docker
# sudo usermod -aG docker $USER
# newgrp docker

# // ------------------------------

# - starship
curl -sS https://starship.rs/install.sh | sh
# // ------------------------------

# - dbeaver
sudo wget -O /usr/share/keyrings/dbeaver.gpg.key https://dbeaver.io/debs/dbeaver.gpg.key
echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
sudo apt update -y && sudo apt install dbeaver-ce -y
# // ------------------------------

# - nitch
wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh && sh setup.sh
# // ------------------------------

# - rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable

# - cargo packages
sudo apt install -y \
  cmake \
  pkg-config \
  libfreetype6-dev \
  libfontconfig1-dev \
  libxcb-xfixes0-dev \
  libxkbcommon-dev \
  python3

cargo install \
  alacritty \
  bat \
  zellij \
  zoxide
# // ------------------------------

# - atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
# // ------------------------------

# -- Alacritty config
git clone https://github.com/alacritty/alacritty ~/temp/alacritty
cd ~/temp/alacritty
sudo cp -rv extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
# // ------------------------------

sudo update-desktop-database

# UTILITIES
sudo apt install -y \
  flameshot \
  solaar

# INSTALL CONFIGURATIONS
cp -rv "${initial_path}/.gitconfig" ~/.gitconfig
cp -rv "${initial_path}/starship.toml" ~/.config/
cp -rv "${initial_path}/fish/config.fish" ~/.config/fish/
cp -rv "${initial_path}/fish/zoxide-conf.fish" ~/.config/fish/
cp -rv "${initial_path}/lsd/config.yaml" ~/.config/lsd/
cp -rv "${initial_path}/pulse.conf" ~/.config/pulse/daemon.conf
cp -rv "${initial_path}/alacritty" ~/.config/
cp -rv "${initial_path}/darktable" ~/.config/
cp -rv "${initial_path}/konsole" ~/.local/share/

# SET FISH AS DEFAULT SHELL
chsh -s "$(which fish)"

# NPM PACKAGES
sudo apt install -y npm
sudo npm i -g n npm

# - set nodejs to LTS
sudo n lts

sudo npm i -g \
  gtop \
  localtunnel \
  svgo \
  vercel

mkdir -p ~/temp

# - microsoft edge
wget "https://go.microsoft.com/fwlink?linkid=2149051" -O ~/temp/edge.deb
sudo apt install -y ~/temp/edge.deb
# // ------------------------------

# - google chrome
wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O ~/temp/chrome.deb
sudo apt install -y ~/temp/chrome.deb
# // ------------------------------

# - visual studio code insiders
wget "https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-x64" -O ~/temp/vscode.deb
sudo apt install -y ~/temp/vscode.deb
# // ------------------------------

# - nerd fonts
current_dir=$(pwd)
wget "https://github.com/ryanoasis/nerd-fonts/archive/refs/heads/master.zip" -O ~/temp/nerd-fonts.zip
unzip ~/temp/nerd-fonts.zip -d ~/temp
cd ~/temp/nerd-fonts-master
bash install.sh
cd "$current_dir"
# // ------------------------------

sudo fc-cache -f -v

rm -rf ~/temp

exit 0

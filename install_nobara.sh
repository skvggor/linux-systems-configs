#!/bin/bash

set -euo pipefail

mkdir -pv \
  ~/Google\ Drive \
  ~/Projects/{personal,work} \
  ~/.config/{pulse,lsd,fish,darktable,zellij,alacritty,starship,konsole}

sudo dnf -y update

# ESSENTIALS
sudo dnf -y install \
  curl \
  git \
  unzip

# DESIGN AND MULTIMEDIA
sudo dnf -y install \
  cheese \
  darktable \
  gimp \
  inkscape \
  krita \
  obs-studio \
  vlc

# SYSTEM AND DEVELOPMENT
sudo dnf -y install \
  cmake \
  cmatrix \
  fish \
  golang \
  jq \
  konsole \
  lsd \
  micro \
  net-tools \
  nodejs

# - docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf -y install \
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

# - ms fonts
sudo dnf -y install \
  cabextract \
  xorg-x11-font-utils \
  fontconfig

sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
# // ------------------------------

# - nitch
wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh && sh setup.sh
# // ------------------------------

# - rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable

# - cargo packages
sudo dnf -y install \
  cmake \
  pkgconfig \
  freetype-devel \
  fontconfig-devel \
  libxcb-devel \
  libxkbcommon-devel \
  python3

cargo install \
  alacritty \
  bat \
  zoxide

sudo dnf copr enable varlad/zellij
sudo dnf -y install zellij
# // ------------------------------

# - atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
# // ------------------------------

# -- Alacritty config
git clone https://github.com/alacritty/alacritty ~/temp/alacritty
cd ~/temp/alacritty
sudo cp -rv extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
cd ~
# // ------------------------------

sudo update-desktop-database

# UTILITIES
sudo dnf -y install \
  flameshot \
  solaar

# INSTALL CONFIGURATIONS
cp -rv .gitconfig ~/.gitconfig
cp -rv starship.toml ~/.config/
cp -rv fish/config.fish ~/.config/fish/
cp -rv fish/zoxide-conf.fish ~/.config/fish/
cp -rv lsd/config.yaml ~/.config/lsd/
cp -rv pulse.conf ~/.config/pulse/daemon.conf
cp -rv alacritty ~/.config/
cp -rv darktable ~/.config/
cp -rv konsole ~/.local/share/

# SET FISH AS DEFAULT SHELL
chsh -s "$(which fish)"

# NPM PACKAGES
sudo dnf -y install nodejs-npm
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
wget "https://go.microsoft.com/fwlink?linkid=2149137" -O ~/temp/edge.rpm
sudo dnf -y install ~/temp/edge.rpm
# // ------------------------------

# - dbeaver
wget "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" -O ~/temp/dbeaver.rpm
sudo dnf -y install ~/temp/dbeaver.rpm
# // ------------------------------


# - google chrome
wget "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" -O ~/temp/chrome.rpm
sudo dnf -y install ~/temp/chrome.rpm
# // ------------------------------

# - visual studio code insiders
wget "https://code.visualstudio.com/sha/download?build=insider&os=linux-rpm-x64" -O ~/temp/vscode.rpm
sudo dnf -y install ~/temp/vscode.rpm
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

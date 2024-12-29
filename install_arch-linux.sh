#!/bin/bash

set -euo pipefail

mkdir -pv \
  ~/Google\ Drive \
  ~/Projects/{personal,work} \
  ~/.config/{pulse,lsd,fish,darktable,zellij,alacritty,starship,konsole}

sudo pacman -Syu --noconfirm

# ESSENTIALS
sudo pacman -S --noconfirm --needed \
  base-devel \
  unzip \
  curl \
  git

# DESIGN AND MULTIMEDIA
sudo pacman -S --noconfirm --needed \
  cheese \
  darktable \
  gimp \
  inkscape \
  krita \
  obs-studio \
  vlc

# SYSTEM AND DEVELOPMENT
sudo pacman -S --noconfirm --needed \
  cmake \
  cmatrix \
  fish \
  go \
  jq \
  konsole \
  lsd \
  micro \
  net-tools \
  nodejs

# - docker
sudo pacman -S --noconfirm --needed \
  docker

sudo systemctl start docker.service
# sudo systemctl enable docker.service
# sudo chmod 666 /var/run/docker.sock
# sudo groupadd docker
# sudo usermod -aG docker $USER
# newgrp docker

# // ------------------------------

# - starship
sudo pacman -S --noconfirm --needed starship
# // ------------------------------

# - dbeaver
# (dbeaver is in the AUR, so we need yay; install yay if missing)
if ! command -v yay &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

yay -S --noconfirm dbeaver-ce
# // ------------------------------

# - nitch
yay -S --noconfirm nitch
# // ------------------------------

# - rustup
sudo pacman -S --noconfirm --needed rustup
rustup default stable

# - cargo packages
sudo pacman -S --noconfirm --needed \
  cmake \
  pkg-config \
  freetype2 \
  fontconfig \
  libxcb \
  libxkbcommon \
  python

cargo install \
  alacritty \
  bat \
  zellij \
  zoxide
# // ------------------------------

# - atuin
yay -S --noconfirm atuin
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
sudo pacman -S --noconfirm --needed \
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
sudo pacman -S --noconfirm --needed npm
sudo npm i -g n npm

# - set nodejs to LTS
sudo n lts

sudo npm i -g \
  gtop \
  localtunnel \
  svgo \
  vercel

# - microsoft edge
yay -S --noconfirm microsoft-edge-stable-bin
# // ------------------------------

# - google chrome
yay -S --noconfirm google-chrome
# // ------------------------------

# - visual studio code insiders
yay -S --noconfirm visual-studio-code-insiders-bin
# // ------------------------------

# - nerd fonts
current_dir=$(pwd)
mkdir -p ~/temp
wget "https://github.com/ryanoasis/nerd-fonts/archive/refs/heads/master.zip" -O ~/temp/nerd-fonts.zip
unzip ~/temp/nerd-fonts.zip -d ~/temp
cd ~/temp/nerd-fonts-master
bash install.sh
cd "$current_dir"
# // ------------------------------

sudo fc-cache -f -v

rm -rf ~/temp

exit 0

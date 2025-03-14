#!/bin/bash

set -euo pipefail

initial_path=$(pwd)

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
  git \
  xclip

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
sudo pacman -S --noconfirm --needed npm
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
wget "https://github.com/ryanoasis/nerd-fonts/archive/refs/heads/master.zip" -O ~/temp/nerd-fonts.zip
unzip ~/temp/nerd-fonts.zip -d ~/temp
cd ~/temp/nerd-fonts-master
bash install.sh
cd "$current_dir"
# // ------------------------------

sudo fc-cache -f -v

rm -rf ~/temp

bash setup-gnome-terminal.sh

exit 0

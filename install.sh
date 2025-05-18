#!/bin/bash

set -euo pipefail

log_info() { echo "[INFO] $*" >&2; }

log_warn() { echo "[WARN] $*" >&2; }

log_error() {
  echo "[ERROR] $*" >&2
  exit 1
}

detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
    SUDO_CMD="sudo"
    UPDATE_CMD="$SUDO_CMD apt update -y"
    UPGRADE_CMD="$SUDO_CMD apt upgrade -y"
    INSTALL_CMD="$SUDO_CMD apt install -y"
    ADD_REPO_CMD="$SUDO_CMD add-apt-repository -y"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    SUDO_CMD="sudo"
    UPDATE_CMD="$SUDO_CMD dnf check-update || true"
    UPGRADE_CMD="$SUDO_CMD dnf upgrade -y"
    INSTALL_CMD="$SUDO_CMD dnf install -y"
    ADD_REPO_DNF_CMD="$SUDO_CMD dnf config-manager --add-repo"
  elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    SUDO_CMD="sudo"
    UPDATE_CMD="$SUDO_CMD pacman -Syu --noconfirm"
    UPGRADE_CMD=""
    INSTALL_CMD="$SUDO_CMD pacman -S --noconfirm --needed"
  else
    log_error "Package manager not supported."
  fi
}

install_packages() {
  if [ $# -gt 0 ]; then
    $INSTALL_CMD "$@"
  fi
}

install_yay_if_needed() {
  if [ "$PKG_MANAGER" == "pacman" ] && ! command -v yay &>/dev/null; then

    local current_dir_yay_install
    current_dir_yay_install=$(pwd)

    $SUDO_CMD pacman -S --noconfirm --needed git base-devel

    cd /tmp || exit 1
    [ -d "yay" ] && rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit 1
    makepkg -si --noconfirm
    cd "$current_dir_yay_install" || exit 1
  fi
}

install_aur_packages() {
  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_yay_if_needed
    if [ $# -gt 0 ]; then
      yay -S --noconfirm "$@"
    fi
  fi
}

initial_path=$(pwd)
TEMP_DIR="$HOME/temp_install_$(date +%s)"

trap 'rm -rf "$TEMP_DIR"' EXIT

detect_package_manager

mkdir -p "$TEMP_DIR"

mkdir -pv \
  "$HOME/Google Drive" \
  "$HOME/Projects/personal" \
  "$HOME/Projects/work" \
  "$HOME/.config/pulse" \
  "$HOME/.config/lsd" \
  "$HOME/.config/fish" \
  "$HOME/.config/darktable" \
  "$HOME/.config/zellij" \
  "$HOME/.config/alacritty" \
  "$HOME/.config/starship" \
  "$HOME/.config/konsolerc"

$UPDATE_CMD

[ -n "$UPGRADE_CMD" ] && $UPGRADE_CMD

# ESSENTIALS
common_essentials=(curl git unzip xclip)

case $PKG_MANAGER in
apt | dnf) install_packages "${common_essentials[@]}" ;;
pacman) install_packages base-devel "${common_essentials[@]}" ;;
esac

# DESIGN AND MULTIMEDIA
common_design=(cheese darktable gimp inkscape krita obs-studio vlc)

case $PKG_MANAGER in
apt)
  $ADD_REPO_CMD ppa:obsproject/obs-studio
  $UPDATE_CMD
  install_packages "${common_design[@]}" ttf-mscorefonts-installer
  ;;
dnf)
  install_packages "${common_design[@]}"
  install_packages cabextract xorg-x11-font-utils fontconfig
  sudo rpm -i \
    https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm ||
    log_warn "Failed to install MS Core Fonts RPM."
  ;;
pacman)
  install_packages "${common_design[@]}"
  install_aur_packages ttf-ms-fonts
  ;;
esac

# SYSTEM AND DEVELOPMENT
common_dev_base=(cmake cmatrix fish jq konsole lsd micro net-tools)
nodejs_pkg="nodejs"
golang_pkg="golang"

case $PKG_MANAGER in
apt)
  golang_pkg="golang-go"
  install_packages build-essential "$golang_pkg" "$nodejs_pkg" \
    "${common_dev_base[@]}"
  ;;
dnf)
  install_packages "$golang_pkg" "$nodejs_pkg" "${common_dev_base[@]}"
  ;;
pacman)
  golang_pkg="go"
  install_packages "$golang_pkg" "$nodejs_pkg" "${common_dev_base[@]}"
  ;;
esac

# DOCKER
docker_pkgs_main=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin
  docker-compose-plugin)

case $PKG_MANAGER in
apt)
  install_packages apt-transport-https ca-certificates gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/\
docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release &&
    echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  $UPDATE_CMD
  install_packages "${docker_pkgs_main[@]}"
  ;;
dnf)
  install_packages dnf-plugins-core
  sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
  install_packages "${docker_pkgs_main[@]}"
  ;;
pacman)
  install_packages docker docker-compose
  ;;
esac

if ! getent group docker >/dev/null; then sudo groupadd docker; fi

sudo usermod -aG docker "$USER"

# STARSHIP
if [ "$PKG_MANAGER" == "pacman" ]; then
  install_packages starship
else
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# DBEAVER
case $PKG_MANAGER in
apt)
  wget -O "$TEMP_DIR/dbeaver.gpg.key" https://dbeaver.io/debs/dbeaver.gpg.key
  sudo mv "$TEMP_DIR/dbeaver.gpg.key" /usr/share/keyrings/dbeaver.gpg.key
  echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] \
https://dbeaver.io/debs/dbeaver-ce /" |
    sudo tee /etc/apt/sources.list.d/dbeaver.list
  $UPDATE_CMD
  install_packages dbeaver-ce
  ;;
dnf)
  wget "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" \
    -O "$TEMP_DIR/dbeaver.rpm"
  install_packages "$TEMP_DIR/dbeaver.rpm"
  ;;
pacman)
  install_aur_packages dbeaver-ce
  ;;
esac

# NITCH
if [ "$PKG_MANAGER" == "pacman" ]; then
  install_aur_packages nitch
else
  wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh \
    -O "$TEMP_DIR/nitch_setup.sh"
  sh "$TEMP_DIR/nitch_setup.sh"
fi

# RUSTUP
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  --no-modify-path

export PATH="$HOME/.cargo/bin:$PATH"

if [ -f "$HOME/.profile" ] &&
  ! grep -q '\$HOME/.cargo/bin' "$HOME/.profile"; then
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>"$HOME/.profile"
fi

if command -v fish &>/dev/null && [ -d "$HOME/.config/fish" ] &&
  ! grep -q '\$HOME/.cargo/bin' "$HOME/.config/fish/config.fish"; then
  echo 'set -gx PATH "$HOME/.cargo/bin" $PATH' \
    >>"$HOME/.config/fish/config.fish"
fi

rustup default stable

# CARGO PACKAGES
pkgs_build_cargo_common=(cmake pkg-config)
pkgs_build_cargo_python="python3"
pkgs_build_cargo_apt=(libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev
  libxkbcommon-dev)
pkgs_build_cargo_dnf=(fontconfig-devel freetype-devel libxcb-devel
  libxkbcommon-devel)
pkgs_build_cargo_pacman=(freetype2 fontconfig libxcb libxkbcommon python)

case $PKG_MANAGER in
apt)
  install_packages "${pkgs_build_cargo_common[@]}" "$pkgs_build_cargo_python" \
    "${pkgs_build_cargo_apt[@]}"
  ;;
dnf)
  install_packages "${pkgs_build_cargo_common[@]}" "$pkgs_build_cargo_python" \
    "${pkgs_build_cargo_dnf[@]}"
  ;;
pacman)
  install_packages "${pkgs_build_cargo_common[@]}" \
    "${pkgs_build_cargo_pacman[@]}"
  ;;
esac

cargo_pkgs_to_install=(alacritty zoxide)

if [ "$PKG_MANAGER" != "dnf" ]; then
  cargo_pkgs_to_install+=(bat zellij)
else
  install_packages bat
  sudo dnf copr enable varlad/zellij -y
  install_packages zellij
fi
cargo install "${cargo_pkgs_to_install[@]}"

# ATUIN
if [ "$PKG_MANAGER" == "pacman" ]; then
  install_aur_packages atuin
else
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

# ALACRITTY DESKTOP/ICON
if [ ! -d "$TEMP_DIR/alacritty_extras" ]; then
  git clone https://github.com/alacritty/alacritty "$TEMP_DIR/alacritty_extras"
fi
if [ -d "$TEMP_DIR/alacritty_extras/extra" ]; then
  cd "$TEMP_DIR/alacritty_extras" || exit 1
  [ -f "extra/logo/alacritty-term.svg" ] &&
    sudo cp -v extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
  if [ -f "extra/linux/Alacritty.desktop" ]; then
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
  fi
  cd "$initial_path" || exit 1
fi

install_packages flameshot solaar

# CONFIG FILES
CONFIG_SOURCE_DIR="${initial_path}"

declare -A config_map

config_map=(
  ["${CONFIG_SOURCE_DIR}/.gitconfig"]="$HOME/.gitconfig"
  ["${CONFIG_SOURCE_DIR}/starship.toml"]="$HOME/.config/starship.toml"
  ["${CONFIG_SOURCE_DIR}/fish/config.fish"]="$HOME/.config/fish/config.fish"
  ["${CONFIG_SOURCE_DIR}/fish/zoxide-conf.fish"]="$HOME/.config/fish/zoxide-conf.fish"
  ["${CONFIG_SOURCE_DIR}/lsd/config.yaml"]="$HOME/.config/lsd/config.yaml"
  ["${CONFIG_SOURCE_DIR}/pulse.conf"]="$HOME/.config/pulse/daemon.conf"
  ["${CONFIG_SOURCE_DIR}/alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
  ["${CONFIG_SOURCE_DIR}/darktable/darktablerc"]="$HOME/.config/darktable/darktablerc"
)

for src_cfg in "${!config_map[@]}"; do
  dest_cfg="${config_map[$src_cfg]}"
  dest_dir=$(dirname "$dest_cfg")

  mkdir -p "$dest_dir"

  if [ -e "$src_cfg" ]; then
    cp -rv "$src_cfg" "$dest_cfg"
  else
    log_warn "Config not found: $src_cfg"
  fi
done

declare -A dir_map

dir_map=(
  ["${CONFIG_SOURCE_DIR}/alacritty"]="$HOME/.config/alacritty"
  ["${CONFIG_SOURCE_DIR}/darktable"]="$HOME/.config/darktable"
  ["${CONFIG_SOURCE_DIR}/konsole"]="$HOME/.local/share/konsole"
)

for src_dir in "${!dir_map[@]}"; do
  dest_dir="${dir_map[$src_dir]}"
  if [ -d "$src_dir" ]; then
    mkdir -p "$dest_dir"
    cp -rv "$src_dir/"* "$dest_dir/"
  fi
done

# SET FISH AS DEFAULT SHELL
if command -v fish &>/dev/null && [ "$SHELL" != "$(which fish)" ]; then
  chsh -s "$(which fish)"
fi

# NPM PACKAGES
npm_pkg_dep="npm"

[ "$PKG_MANAGER" == "dnf" ] && npm_pkg_dep="nodejs-npm"
install_packages "$npm_pkg_dep"

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"
export NPM_CONFIG_PREFIX="$N_PREFIX"

npm config set prefix "$N_PREFIX"

mkdir -p "$N_PREFIX"
chown -R "$(whoami)" "$N_PREFIX"

if ! command -v n &>/dev/null; then
  npm install -g n
fi

n lts

hash -r

if [ "$PKG_MANAGER" == "apt" ]; then
  sudo apt remove -y nodejs npm || true
elif [ "$PKG_MANAGER" == "dnf" ]; then
  sudo dnf remove -y nodejs npm || true
elif [ "$PKG_MANAGER" == "pacman" ]; then
  sudo pacman -Rs --noconfirm nodejs npm || true
fi

if [ -f "$HOME/.profile" ] &&
  ! grep -q '\$N_PREFIX/bin' "$HOME/.profile"; then
  echo -e 'export N_PREFIX="$HOME/.n"\n\
export PATH="$N_PREFIX/bin:$PATH"' \
    >>"$HOME/.profile"
fi

if command -v fish &>/dev/null &&
  [ -d "$HOME/.config/fish" ] &&
  ! grep -q '\$N_PREFIX/bin' \
    "$HOME/.config/fish/config.fish"; then
  echo -e 'set -gx N_PREFIX "$HOME/.n"\n\
set -gx PATH "$N_PREFIX/bin" $PATH' \
    >>"$HOME/.config/fish/config.fish"
fi

npm_global_pkgs=(
  npm@latest
  gtop
  localtunnel
  svgo
  vercel
)

npm install -g "${npm_global_pkgs[@]}"

# MS EDGE
case $PKG_MANAGER in
apt)
  wget "https://go.microsoft.com/fwlink?linkid=2149051" \
    -O "$TEMP_DIR/edge.deb"
  sudo apt install -y "$TEMP_DIR/edge.deb" || sudo apt --fix-broken install -y
  ;;
dnf)
  wget "https://go.microsoft.com/fwlink?linkid=2149137" \
    -O "$TEMP_DIR/edge.rpm"
  install_packages "$TEMP_DIR/edge.rpm"
  ;;
pacman) install_aur_packages microsoft-edge-stable-bin ;;
esac

# GOOGLE CHROME
case $PKG_MANAGER in
apt)
  wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
    -O "$TEMP_DIR/chrome.deb"
  sudo apt install -y "$TEMP_DIR/chrome.deb" || sudo apt --fix-broken install -y
  ;;
dnf)
  wget "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" \
    -O "$TEMP_DIR/chrome.rpm"
  install_packages "$TEMP_DIR/chrome.rpm"
  ;;
pacman) install_aur_packages google-chrome ;;
esac

# VISUAL STUDIO CODE INSIDERS
case $PKG_MANAGER in
apt)
  wget "https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-x64" \
    -O "$TEMP_DIR/vscode.deb"
  sudo apt install -y "$TEMP_DIR/vscode.deb" || sudo apt --fix-broken install -y
  ;;
dnf)
  wget "https://code.visualstudio.com/sha/download?build=insider&os=linux-rpm-x64" \
    -O "$TEMP_DIR/vscode.rpm"
  install_packages "$TEMP_DIR/vscode.rpm"
  ;;
pacman) install_aur_packages visual-studio-code-insiders-bin ;;
esac

# NERD FONTS
nerd_fonts_dir="$TEMP_DIR/nerd-fonts-master"
wget "https://github.com/ryanoasis/nerd-fonts/archive/refs/heads/master.zip" \
  -O "$TEMP_DIR/nerd-fonts.zip"
unzip -o "$TEMP_DIR/nerd-fonts.zip" -d "$TEMP_DIR"

if [ -d "$nerd_fonts_dir" ] && [ -f "$nerd_fonts_dir/install.sh" ]; then
  cd "$nerd_fonts_dir" || exit 1
  ./install.sh
  cd "$initial_path" || exit 1
fi

# MONASPACE FONT
monaspace_dir="$TEMP_DIR/monaspace-main"
wget "https://github.com/githubnext/monaspace/archive/refs/heads/main.zip" \
  -O "$TEMP_DIR/monaspace.zip"
unzip -o "$TEMP_DIR/monaspace.zip" -d "$TEMP_DIR"

if [ -d "$monaspace_dir" ] && [ -f "$monaspace_dir/util/install_linux.sh" ]; then
  cd "$monaspace_dir" || exit 1
  bash util/install_linux.sh
  cd "$initial_path" || exit 1
else
  mkdir -p "$HOME/.local/share/fonts/monaspace"
  [ -d "$monaspace_dir" ] &&
    find "$monaspace_dir" \( -name "*.otf" -o -name "*.ttf" \) \
      -exec cp {} "$HOME/.local/share/fonts/monaspace/" \;
fi

sudo fc-cache -f -v

rm -rf "$TEMP_DIR"

log_info "Installation completed successfully."

exit 0

#!/bin/bash

install_starship() {
  log_info "Installing Starship..."
  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_packages starship
  else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
}

install_nitch() {
  log_info "Installing Nitch..."
  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_aur_packages nitch
  else
    local temp_setup="$HOME/temp_nitch_setup.sh"
    wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh -O "$temp_setup"
    sh "$temp_setup"
    rm "$temp_setup"
  fi
}

install_atuin() {
  log_info "Installing Atuin..."
  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_aur_packages atuin
  else
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  fi
}

install_cargo_tools() {
  log_info "Installing Cargo tools..."

  local pkgs_build_cargo_common=(cmake pkg-config)
  local pkgs_build_cargo_python="python3"

  case $PKG_MANAGER in
    apt)
      install_packages "${pkgs_build_cargo_common[@]}" "$pkgs_build_cargo_python" \
        libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
      ;;
    dnf)
      install_packages "${pkgs_build_cargo_common[@]}" "$pkgs_build_cargo_python" \
        fontconfig-devel freetype-devel libxcb-devel libxkbcommon-devel
      ;;
    pacman)
      install_packages "${pkgs_build_cargo_common[@]}" python freetype2 fontconfig libxcb libxkbcommon
      ;;
  esac

  local cargo_pkgs=(zoxide)

  case $PKG_MANAGER in
    pacman)
      install_packages bat zellij
      ;;
    dnf)
      install_packages bat
      sudo dnf copr enable varlad/zellij -y
      install_packages zellij
      ;;
    *)
      cargo_pkgs+=(bat zellij)
      ;;
  esac

  cargo_pkgs+=(alacritty)

  if [ ${#cargo_pkgs[@]} -gt 0 ]; then
    cargo install "${cargo_pkgs[@]}"
  fi
}

setup_alacritty_extras() {
  log_info "Setting up Alacritty extras (icon/desktop)..."
  local temp_dir="/tmp/alacritty_extras"

  if [ ! -d "$temp_dir" ]; then
    git clone https://github.com/alacritty/alacritty "$temp_dir"
  fi

  if [ -d "$temp_dir/extra" ]; then
    local current_dir=$(pwd)
    cd "$temp_dir" || return

    if [ -f "extra/logo/alacritty-term.svg" ]; then
      sudo cp -v extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    fi

    if [ -f "extra/linux/Alacritty.desktop" ]; then
      sudo desktop-file-install extra/linux/Alacritty.desktop
      sudo update-desktop-database
    fi

    cd "$current_dir" || return
    rm -rf "$temp_dir"
  fi
}

run_cli_tools_setup() {
  install_starship
  install_nitch
  install_atuin
  install_cargo_tools
  setup_alacritty_extras
}

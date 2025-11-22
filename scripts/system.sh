#!/bin/bash

setup_directories() {
  log_info "Creating directories..."
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
}

install_essentials() {
  log_info "Installing essential packages..."
  local common_essentials=(curl git unzip xclip)

  case $PKG_MANAGER in
    apt | dnf) install_packages "${common_essentials[@]}" ;;
    pacman) install_packages base-devel "${common_essentials[@]}" ;;
  esac
}

install_system_tools() {
  log_info "Installing system and development tools..."
  local common_dev_base=(cmake cmatrix fish jq konsole lsd micro net-tools)

  case $PKG_MANAGER in
    apt)
      curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh | bash
      install_packages build-essential "${common_dev_base[@]}"
      ;;
    dnf)
      dnf copr enable pgdev/ghostty
      install_packages ghostty "${common_dev_base[@]}"
      ;;
    pacman)
      install_packages ghostty "${common_dev_base[@]}"
      ;;
  esac
}

setup_shell() {
  log_info "Setting up Fish shell..."
  if command -v fish &>/dev/null; then
    if [ "$SHELL" != "$(which fish)" ]; then
      chsh -s "$(which fish)"
    fi
  fi
}

run_system_setup() {
  setup_directories
  install_essentials
  install_system_tools
  setup_shell
}

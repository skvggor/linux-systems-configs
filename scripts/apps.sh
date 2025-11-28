#!/bin/bash

install_design_apps() {
  log_info "Installing design and multimedia apps..."
  local common_design=(cheese darktable gimp inkscape krita obs-studio vlc)

  case $PKG_MANAGER in
    apt)
      $ADD_REPO_CMD ppa:obsproject/obs-studio
      $UPDATE_CMD
      install_packages "${common_design[@]}" ttf-mscorefonts-installer
      ;;
    dnf)
      install_packages "${common_design[@]}"
      install_packages cabextract xorg-x11-font-utils fontconfig
      sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm || log_warn "Failed to install MS Core Fonts RPM."
      ;;
    pacman)
      install_packages "${common_design[@]}"
      install_aur_packages ttf-ms-fonts
      ;;
  esac
}

install_docker() {
  log_info "Installing Docker..."
  local docker_pkgs_main=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)

  case $PKG_MANAGER in
    apt)
      install_packages apt-transport-https ca-certificates gnupg lsb-release
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
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
}

install_dbeaver() {
  log_info "Installing DBeaver..."

  case $PKG_MANAGER in
    apt)
      wget -O /tmp/dbeaver.gpg.key https://dbeaver.io/debs/dbeaver.gpg.key
      sudo mv /tmp/dbeaver.gpg.key /usr/share/keyrings/dbeaver.gpg.key
      echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
      $UPDATE_CMD
      install_packages dbeaver-ce
      ;;
    dnf)
      local rpm_url="https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm"
      install_packages "$rpm_url"
      ;;
    pacman)
      install_aur_packages dbeaver-ce-bin
      ;;
  esac
}

install_browsers() {
  log_info "Installing Browsers (Edge & Chrome)..."

  # Edge
  case $PKG_MANAGER in
    apt)
      local edge_deb="/tmp/edge.deb"
      wget "https://go.microsoft.com/fwlink?linkid=2149051" -O "$edge_deb"
      sudo apt install -y "$edge_deb" || sudo apt --fix-broken install -y
      rm "$edge_deb"
      ;;
    dnf)
      local edge_rpm="/tmp/edge.rpm"
      wget "https://go.microsoft.com/fwlink?linkid=2149137" -O "$edge_rpm"
      install_packages "$edge_rpm"
      rm "$edge_rpm"
      ;;
    pacman)
      install_aur_packages microsoft-edge-stable-bin
      ;;
  esac

  # Chrome
  case $PKG_MANAGER in
    apt)
      local chrome_deb="/tmp/chrome.deb"
      wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -O "$chrome_deb"
      sudo apt install -y "$chrome_deb" || sudo apt --fix-broken install -y
      rm "$chrome_deb"
      ;;
    dnf)
      local chrome_rpm="/tmp/chrome.rpm"
      wget "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" -O "$chrome_rpm"
      install_packages "$chrome_rpm"
      rm "$chrome_rpm"
      ;;
    pacman)
      install_aur_packages google-chrome
      ;;
  esac
}

install_vscode() {
  log_info "Installing VS Code Insiders..."

  case $PKG_MANAGER in
    apt)
      local vscode_deb="/tmp/vscode.deb"
      wget "https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-x64" -O "$vscode_deb"
      sudo apt install -y "$vscode_deb" || sudo apt --fix-broken install -y
      rm "$vscode_deb"
      ;;
    dnf)
      local vscode_rpm="/tmp/vscode.rpm"
      wget "https://code.visualstudio.com/sha/download?build=insider&os=linux-rpm-x64" -O "$vscode_rpm"
      install_packages "$vscode_rpm"
      rm "$vscode_rpm"
      ;;
    pacman)
      install_aur_packages visual-studio-code-insiders-bin
      ;;
  esac
}

install_misc_apps() {
  log_info "Installing miscellaneous apps (Flameshot, Solaar)..."
  install_packages flameshot solaar
}

install_insomnia() {
  log_info "Installing Insomnia..."

  case $PKG_MANAGER in
    apt)
      curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.deb.sh' | sudo -E distro=ubuntu codename=focal bash
      install_packages insomnia
      ;;
    dnf)
      curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.rpm.sh' | sudo -E bash
      install_packages insomnia
      ;;
    pacman)
      install_aur_packages insomnia-bin
      ;;
  esac
}

run_apps_setup() {
  install_design_apps
  install_docker
  install_dbeaver
  install_insomnia
  install_browsers
  install_vscode
  install_misc_apps
}

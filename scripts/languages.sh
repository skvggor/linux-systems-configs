#!/bin/bash

install_go() {
  log_info "Installing Go..."
  local golang_pkg="golang"

  case $PKG_MANAGER in
    apt) golang_pkg="golang-go" ;;
    pacman) golang_pkg="go" ;;
  esac

  install_packages "$golang_pkg"
}

install_rust() {
  if command -v rustc &>/dev/null; then
    log_info "Rust is already installed ($(rustc --version)). Skipping installation."
    return
  fi

  log_info "Installing Rust (rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

  export PATH="$HOME/.cargo/bin:$PATH"

  rustup default stable
}

install_node() {
  log_info "Installing Node.js (via nvm)..."

  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"

  # Temporarily disable nounset as nvm doesn't support it
  set +u

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if command -v nvm &>/dev/null; then
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*

    local npm_global_pkgs=(npm@latest gtop localtunnel svgo vercel)
    npm install -g "${npm_global_pkgs[@]}"
  else
    log_error "NVM failed to load. Please check installation."
  fi

  # Re-enable nounset
  set -u
}

run_language_setup() {
  install_go
  install_rust
  install_node
}

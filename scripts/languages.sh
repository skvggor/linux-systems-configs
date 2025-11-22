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
  log_info "Installing Rust (rustup)..."

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

  export PATH="$HOME/.cargo/bin:$PATH"

  if [ -f "$HOME/.profile" ] && ! grep -q '\$HOME/.cargo/bin' "$HOME/.profile"; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>"$HOME/.profile"
  fi

  if command -v fish &>/dev/null && [ -d "$HOME/.config/fish" ] && ! grep -q '\$HOME/.cargo/bin' "$HOME/.config/fish/config.fish"; then
    echo 'set -gx PATH "$HOME/.cargo/bin" $PATH' >>"$HOME/.config/fish/config.fish"
  fi

  rustup default stable
}

install_node() {
  log_info "Installing Node.js (via nvm)..."

  export NVM_DIR="$HOME/.nvm"

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  nvm install --lts
  nvm use --lts
  nvm alias default lts/*

  local npm_global_pkgs=(npm@latest gtop localtunnel svgo vercel)
  npm install -g "${npm_global_pkgs[@]}"

  if command -v fish &>/dev/null && [ -d "$HOME/.config/fish" ]; then
    local node_version
    node_version=$(nvm version default)

    if ! grep -q "NVM_DIR" "$HOME/.config/fish/config.fish"; then
      echo "" >> "$HOME/.config/fish/config.fish"
      echo "# NVM configuration (manual path for default version)" >> "$HOME/.config/fish/config.fish"
      echo "set -gx NVM_DIR \"$HOME/.nvm\"" >> "$HOME/.config/fish/config.fish"
      echo "set -gx PATH \"\$NVM_DIR/versions/node/$node_version/bin\" \$PATH" >> "$HOME/.config/fish/config.fish"
    fi
  fi
}

run_language_setup() {
  install_go
  install_rust
  install_node
}

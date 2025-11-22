#!/bin/bash

run_configs_setup() {
  local config_source_dir="$1"

  if [ -z "$config_source_dir" ]; then
    log_error "Config source directory not provided to run_configs_setup"
  fi

  log_info "Setting up configuration files from $config_source_dir..."

  declare -A config_map
  config_map=(
    ["${config_source_dir}/.gitconfig"]="$HOME/.gitconfig"
    ["${config_source_dir}/starship.toml"]="$HOME/.config/starship.toml"
    ["${config_source_dir}/fish/config.fish"]="$HOME/.config/fish/config.fish"
    ["${config_source_dir}/fish/zoxide-conf.fish"]="$HOME/.config/fish/zoxide-conf.fish"
    ["${config_source_dir}/lsd/config.yaml"]="$HOME/.config/lsd/config.yaml"
    ["${config_source_dir}/pulse.conf"]="$HOME/.config/pulse/daemon.conf"
    ["${config_source_dir}/alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml"
    ["${config_source_dir}/darktable/darktablerc"]="$HOME/.config/darktable/darktablerc"
    ["${config_source_dir}/ghostty/config"]="$HOME/.config/ghostty/config"
  )

  for src_cfg in "${!config_map[@]}"; do
    dest_cfg="${config_map[$src_cfg]}"
    dest_dir=$(dirname "$dest_cfg")

    mkdir -p "$dest_dir"

    if [ -e "$src_cfg" ]; then
      log_info "Copying $src_cfg to $dest_cfg"
      cp -rv "$src_cfg" "$dest_cfg"
    else
      log_warn "Config not found: $src_cfg"
    fi
  done

  declare -A dir_map
  dir_map=(
    ["${config_source_dir}/alacritty"]="$HOME/.config/alacritty"
    ["${config_source_dir}/darktable"]="$HOME/.config/darktable"
    ["${config_source_dir}/konsole"]="$HOME/.local/share/konsole"
  )

  for src_dir in "${!dir_map[@]}"; do
    dest_dir="${dir_map[$src_dir]}"
    if [ -d "$src_dir" ]; then
      log_info "Copying directory $src_dir to $dest_dir"
      mkdir -p "$dest_dir"
      cp -rv "$src_dir/"* "$dest_dir/"
    fi
  done
}

#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$SCRIPT_DIR/scripts"

if [ -f "$SCRIPTS_PATH/utils.sh" ]; then
  source "$SCRIPTS_PATH/utils.sh"
else
  echo "Error: scripts/utils.sh not found."
  exit 1
fi

detect_package_manager
log_info "Detected package manager: $PKG_MANAGER"

modules=(
  "system.sh"
  "languages.sh"
  "cli_tools.sh"
  "apps.sh"
  "fonts.sh"
  "configs.sh"
)

for module in "${modules[@]}"; do
  if [ -f "$SCRIPTS_PATH/$module" ]; then
    source "$SCRIPTS_PATH/$module"
  else
    log_error "Module $module not found in $SCRIPTS_PATH"
  fi
done

log_info "Starting installation..."

run_system_setup
run_language_setup
run_cli_tools_setup
run_apps_setup
run_fonts_setup
run_configs_setup "$SCRIPT_DIR"

log_info "Installation completed successfully!"
log_info "Please restart your shell or computer to apply all changes."

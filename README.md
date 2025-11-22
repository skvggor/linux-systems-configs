# Universal Configs and Installation Scripts

A collection of **system configuration** and **package installation** scripts for various Linux distributions.

Supported distributions:
- **Ubuntu/Debian-like systems** (uses `apt`) - Tested in **Ubuntu 24.04 LTS**
- **Arch-based systems** (uses `pacman` + `yay`) - Tested in **Manjaro GNOME 25.01**
- **Fedora/Nobara/RHEL-like systems** (uses `dnf`) - Tested in **Fedora 42 Workstation**

## Overview

This project provides a modular installation script that automatically detects your distribution and sets up a complete development and multimedia environment. It handles:

- **System Essentials**: Basic tools (curl, git, unzip) and shell setup (Fish).
- **Languages**: Go, Rust (via rustup), and Node.js (via nvm).
- **CLI Tools**: Starship, Atuin, Nitch, Bat, Zellij, Zoxide.
- **Apps**: VS Code Insiders, Chrome, Edge, Docker, DBeaver, and design tools.
- **Fonts**: Optimized installation of specific Nerd Fonts and Monaspace.
- **Configs**: Automatic dotfiles linking for Alacritty, Fish, Starship, etc.

## Prerequisites

- A supported Linux distribution.
- `curl` and `git` (usually pre-installed or easily installable).
- `sudo` privileges.

## How to Use

1. **Clone** this repository:
   ```bash
   git clone https://github.com/yourusername/linux-systems-configs.git
   cd linux-systems-configs
   ```

2. **Run the installation script**:
   ```bash
   ./install.sh
   ```

3. **Follow the prompts** (you will need to enter your sudo password).

4. **Restart your computer** or log out/in to apply all changes (especially for group changes like Docker and shell changes).

## Project Structure

The installation logic is modularized in the `scripts/` directory:

- `install.sh`: Main entry point and orchestrator.
- `scripts/system.sh`: Base system packages and directories.
- `scripts/languages.sh`: Programming language environments (Go, Rust, Node/NVM).
- `scripts/cli_tools.sh`: Terminal utilities and shell prompts.
- `scripts/apps.sh`: GUI applications and Docker.
- `scripts/fonts.sh`: Font installation (downloads only specific fonts to save bandwidth).
- `scripts/configs.sh`: Dotfiles management.
- `scripts/utils.sh`: Helper functions and package manager detection.

## Included Software

### Development
- **Languages**: Go, Rust, Node.js (LTS via NVM)
- **Editors**: VS Code Insiders, Micro
- **Terminal**: Ghostty, Alacritty, Konsole
- **Shell**: Fish (default), Starship (prompt)
- **Tools**: Docker, Docker Compose, DBeaver CE, Git, JQ, Net-tools

### CLI Utilities
- **Atuin**: Shell history sync
- **Bat**: Better `cat`
- **LSD**: Better `ls`
- **Nitch**: System fetch
- **Zellij**: Terminal multiplexer
- **Zoxide**: Smarter `cd`

### Multimedia & Design
- **Apps**: OBS Studio, Krita, Inkscape, Gimp, Darktable, VLC, Cheese
- **Browsers**: Google Chrome, Microsoft Edge

### Fonts
- **Nerd Fonts**: JetBrainsMono, FiraCode, Hack, Meslo, GeistMono
- **Monaspace**: GitHub's new font family

## Contributing

1. **Fork** the repository.
2. Create a **feature branch**.
3. Modify the relevant scripts in `scripts/`.
4. Open a **pull request**.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

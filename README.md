# Universal Configs and Installation Scripts

A collection of **system configuration** and **package installation** scripts for various Linux distributions. Currently includes:

- **Ubuntu/Debian-like systems** (uses `apt`) - Tested in **Ubuntu 24.04 LTS**
- **Arch-based systems** (uses `pacman` + `yay`) - Tested in **Manjaro GNOME 25.01**
- **Fedora/Nobara/RHEL-like systems** (uses `dnf`) - Tested in **Fedora 42 Workstation**

## Overview

These scripts help you quickly set up a development or multimedia environment with essential tools, fonts, and configurations. Each script is tailored to a specific distro family, installing packages, configuring shells, and more.

## Prerequisites

- A Linux distribution supported by one of the scripts above.
- Basic command-line usage (e.g., navigating directories, running `bash` scripts).

## How to Use

1. **Clone or download** this repository (as ZIP) to your local machine.
2. **Extract** the ZIP file (if downloaded) or open the cloned folder.
3. **Run the script** in a terminal:

```bash
bash install.sh
```

4. **Follow any prompts** or confirmations during package installation.

## Included Software

- alacritty
- bat
- cheese
- code-insiders
- curl
- darktable
- dbeaver-ce
- docker
- docker-compose
- fish
- flameshot
- gimp
- git
- google-chrome-stable
- gtop
- inkscape
- jq
- konsole
- krita
- localtunnel
- micro
- microsoft-edge-stable
- monaspace
- nerd-fonts
- net-tools
- nitch
- npm@latest
- obs-studio
- rustup
- solaar
- starship
- svgo
- unzip
- vercel
- vlc
- xclip
- zellij
- zoxide

## Contributing

1. **Fork** the repository.
2. Create a **feature branch**.
3. Make changes or add new scripts for other distros.
4. Open a **pull request** to have your changes reviewed and merged.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

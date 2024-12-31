# Universal Configs and Installation Scripts

A collection of **system configuration** and **package installation** scripts for various Linux distributions. Currently includes:

- **Ubuntu-/Debian-like systems** (uses `apt`)
- **Arch-based systems** (uses `pacman` + `yay`)
- **Fedora/Nobara/RHEL-like systems** (uses `dnf`)

## Overview

These scripts help you quickly set up a development or multimedia environment with essential tools, fonts, and configurations. Each script is tailored to a specific distro family, installing packages, configuring shells, and more.

## Contents

1. **`install_apt.sh`** – Installs packages and configures Ubuntu-/Debian-like systems.
2. **`install_pacman.sh`** – Installs packages and configures Arch-based systems (e.g., Arch Linux, Manjaro, EndeavourOS).
3. **`install_dnf.sh`** – Installs packages and configures Fedora-like systems (e.g., Fedora, Nobara, RHEL family).

## Prerequisites

- A Linux distribution supported by one of the scripts above.
- Basic command-line usage (e.g., navigating directories, running `bash` scripts).

## How to Use

1. **Clone or download** this repository (as ZIP) to your local machine.
2. **Extract** the ZIP file (if downloaded) or open the cloned folder.
3. Based on your distro, pick the corresponding script:
   - **Ubuntu/Debian**: `install_apt.sh`
   - **Arch-based**: `install_pacman.sh`
   - **Fedora/Nobara**: `install_dnf.sh`
4. **Run the script** in a terminal:
   
```bash
bash install_apt.sh
```
Or:

```bash
bash install_pacman.sh
```
Or:

```bash
bash install_dnf.sh
```

5. **Follow any prompts** or confirmations during package installation.

> **Note**: Depending on your system, you may need to run the script with `sudo` privileges or input your password when prompted.

## Contributing

1. **Fork** the repository.
2. Create a **feature branch**.
3. Make changes or add new scripts for other distros.
4. Open a **pull request** to have your changes reviewed and merged.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

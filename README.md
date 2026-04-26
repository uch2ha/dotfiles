# dotfiles

Personal configuration files and automated setup scripts for my development environment.

## About

This repository contains my dotfiles and installation scripts to quickly set up a consistent development environment across different machines. Everything is designed to be modular and safe - all scripts create backups before making changes.

## Zsh Configuration

Modern Zsh setup with Powerlevel10k theme, productivity plugins, and custom aliases.

**Quick install:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/uch2ha/dotfiles/main/setup-zsh.sh)
```

The `setup-zsh.sh` script automates the complete installation of Zsh, Oh My Zsh, Powerlevel10k theme, plugins, and additional CLI tools. All existing files are backed up before installation.

→ See [zsh/README.md](./zsh/README.md) for detailed configuration information.

### What Gets Set Up

After running the script, your `$HOME` directory will have:

```
$HOME/
├── .setup-zsh-backup/
│   └── YYYY-MM-DDTHH-MM-SSZ/    # Timestamped backup of existing files
│       ├── .zshrc
│       ├── .p10k.zsh
│       └── ...
├── .dotfiles/
│   └── zsh/                      # Source configuration files
│       ├── .zshrc                # Can be pushed to personal GitHub
│       ├── .p10k.zsh
│       ├── .aliases
│       ├── .plugins.zsh
│       └── .packages.apt
├── .oh-my-zsh/                   # Oh My Zsh installation
├── .zshrc           -> symlink to ~/.dotfiles/zsh/.zshrc
├── .p10k.zsh        -> symlink to ~/.dotfiles/zsh/.p10k.zsh
├── .aliases         -> symlink to ~/.dotfiles/zsh/.aliases
├── .envs.custom     (optional, create manually for custom env vars)
└── .aliases.custom  (optional, create manually for custom aliases)
```

### Requirements

- Linux (Debian/Ubuntu-based distributions)
- `sudo` access
- Internet connection


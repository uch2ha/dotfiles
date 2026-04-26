# Zsh Configuration

This directory contains all <b>zsh</b> configuration files used by the automated setup script.

## Files

### `.zshrc`
Main Zsh configuration file that:
- Enables Powerlevel10k instant prompt for fast shell startup
- Configures Oh My Zsh with automatic update reminders
- Enables command auto-correction
- Loads internal plugins like <b>git</b>, <b>z</b>
- Sources custom configuration files and nvm

### `.p10k.zsh`
Powerlevel10k theme configuration. Defines the appearance and segments of the prompt.
Run `p10k configure` to reconfigure interactively.

### `.aliases`
Shell aliases including:
- Modern `ls` replacement using `eza` (with fallback to standard `ls`)
- `ll` alias for detailed file listings with icons

### `.plugins.zsh`
List of external Zsh plugins to be cloned from GitHub:
- `zsh-users/zsh-syntax-highlighting` - Syntax highlighting for commands
- `zsh-users/zsh-autosuggestions` - Fish-like autosuggestions

### `.packages.apt`
Additional APT packages to install:
- `fzf` - Fuzzy finder for command-line

## Customization

You can create custom configuration files in your home directory that will be automatically sourced:
- `~/.envs.custom` - Custom environment variables
- `~/.aliases.custom` - Custom aliases

These files are gitignored and won't be tracked in the repository.


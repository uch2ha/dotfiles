# uch2ha/dotfiles

Fedora dotfiles managed with `stow`.

## Quick start

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/uch2ha/dotfiles/main/setup.sh)
```

This clones the repo, backup existing dotfiles, installs packages, deploys symlinks, and sets up the fish shell.

## What's inside

| Step               | What it does                                      |
| ------------------ | ------------------------------------------------- |
| `backup`           | Moves conflicting dotfiles to `dotfiles/_backup/` |
| `install-packages` | Installs packages from `.packages` via `dnf`      |
| `deploy-stow`      | Symlinks `linux/` into `$HOME` via stow           |
| `deploy-fish`      | Sets fish as the default shell                    |

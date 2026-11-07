# uch2ha/dotfiles

Fedora dotfiles managed with plain symlinks (`script/deploy-symlinks.sh`).

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
| `deploy-symlinks`  | Symlinks `linux/` into `$HOME` (see below)        |
| `deploy-fish`      | Sets fish as the default shell                    |

## Linking rules

`linux/` mirrors `$HOME`. What you put in the repo decides how it is linked:

| Want                   | In the repo                                       | Result in `$HOME`                      |
| ---------------------- | ------------------------------------------------- | -------------------------------------- |
| 1-2 files from a dir   | only those files                                  | one symlink per file, rest stays real  |
| whole dir              | a `.fold` file inside the dir                     | one symlink to the dir                 |
| whole dir except `X`   | `.fold` + `.gitignore` in the dir containing `X/` | dir symlink; `X` is ignored by git     |

New file in a folded dir appears instantly; otherwise move it into `linux/` and re-run `script/deploy-symlinks.sh`.
If a real dir already exists where a folded link goes, its extra content is copied into the repo dir first (nothing is lost).

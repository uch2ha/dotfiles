# uch2ha/dotfiles

Fedora dotfiles managed with plain symlinks (`script/setup/deploy-symlinks.sh`).

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
| whole dir              | a `.folder` file inside the dir                     | one symlink to the dir                 |
| whole dir except `X`   | `.folder` + `.gitignore` in the dir containing `X/` | dir symlink; `X` is ignored by git     |

New file in a folded dir appears instantly; otherwise move it into `linux/` and re-run `script/setup/deploy-symlinks.sh`.
If a real dir already exists where a folded link goes, its extra content is copied into the repo dir first (nothing is lost).

## Using agent files in a project

Manual only (not run by `setup.sh`). Links every skill folder of the listed groups into a project:

```sh
bash ~/dotfiles/script/link-agent-to-project.sh [--dry-run] --from skills \
  --folders java-quarkus react-vite docker postgres \
  --to ~/projects/myapp/.claude/skills
```

All `--folders` are checked first; every missing one is listed and nothing is linked. Added a skill to a group? Re-run the same command (existing links are skipped, dead ones pruned). Gitignore the project's `.claude/skills/`: the links are absolute.

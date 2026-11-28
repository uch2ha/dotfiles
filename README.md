# uch2ha/dotfiles

Fedora dotfiles managed with plain symlinks (`script/setup/deploy-symlinks.sh`).

## Contents

- [Quick start](#quick-start)
- [Setup steps](#setup-steps)
- [How files are linked](#how-files-are-linked)
- [Project skills (linking agent/skills)](#project-skills-linking-agentskills)
- [Adding and checking skills (skill-alchemy)](#adding-and-checking-skills-skill-alchemy)

## Quick start

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/uch2ha/dotfiles/main/setup.sh)
```

This clones the repo, backup existing dotfiles, installs packages, deploys symlinks, and sets up the fish shell.

## Setup steps

| Step               | What it does                                      |
| ------------------ | ------------------------------------------------- |
| `backup`           | Moves conflicting dotfiles to `dotfiles/_backup/` |
| `install-packages` | Installs packages from `.packages` via `dnf`      |
| `deploy-symlinks`  | Symlinks `linux/` into `$HOME` (see below)        |
| `deploy-fish`      | Sets fish as the default shell                    |

## How files are linked

`linux/` mirrors `$HOME`. What you put in the repo decides how it is linked:

| Want                   | In the repo                                       | Result in `$HOME`                      |
| ---------------------- | ------------------------------------------------- | -------------------------------------- |
| 1-2 files from a dir   | only those files                                  | one symlink per file, rest stays real  |
| whole dir              | a `.folder` file inside the dir                     | one symlink to the dir                 |
| whole dir except `X`   | `.folder` + `.gitignore` in the dir containing `X/` | dir symlink; `X` is ignored by git     |

New file in a folded dir appears instantly; otherwise move it into `linux/` and re-run `script/setup/deploy-symlinks.sh`.
If a real dir already exists where a folded link goes, its extra content is copied into the repo dir first (nothing is lost).

## Project skills (linking agent/skills)

Stack-specific skills (e.g. `java-quarkus`, `react-vite`) live in groups under `agent/skills/` and are linked into a project by hand with `script/link-agent-to-project.sh`. Global skills (every project) live flat in the harness configs under `linux/` (default: Claude Code's `linux/.claude/skills/`).
Command and details: [agent/README.md](agent/README.md#using-project-skills).

## Adding and checking skills (skill-alchemy)

From `~/dotfiles`, run `/skill-alchemy` in Claude Code: `find <need>`, `add <github url>…`, `inbox`, `audit [name|all]`, `upstream [name|all]`. Every skill gets a security scan (in podman, nothing installed on the host) and a comparison with all existing skills, and nothing is filed without your OK.
Details: [agent/README.md](agent/README.md#adding-and-checking-skills-skill-alchemy).

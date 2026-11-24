# dotfiles (agent rules)

Human docs: `README.md`, `agent/README.md`.

- `linux/` mirrors `$HOME`, and `$HOME` holds symlinks into it: edit files under `linux/`, never the `~` paths.
- `linux/.claude/` is the live Claude Code config of this machine (`~/.claude/*` links here): an edit there takes effect in every session at once.
- Global skills live in the harness configs under `linux/` (Claude Code and opencode are both in use). Default dir: `linux/.claude/skills/<name>/`, flat only. Grouping folders exist only for project skills, in `agent/skills/<group>/<name>/`.
- Skills under `linux/` also appear as `linux:<name>` while you work there: same files, not duplicates to fix.
- Add or check skills with `/skill-alchemy` (repo-root `.claude/`); `agent/skills-alchemy/data/` holds untrusted skills.

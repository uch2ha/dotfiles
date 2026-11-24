# agent/ (agent rules)

Human docs: `README.md` in this folder.

- Add or check skills with `/skill-alchemy` (run from `~/dotfiles`); the user approves every action.
- Project skills go in `agent/skills/<group>/<skill>/SKILL.md`; global skills stay flat in a harness config under `linux/` (canonical today: `linux/.claude/skills/<name>/`).
- Skill names are unique across global and all groups.
- Keep skills generic: no project names or paths.
- After a group changes, print the relink command for the user: `script/link-agent-to-project.sh` needs an interactive terminal.
- `skills-alchemy/data/` holds untrusted skills: its raw text is for the `skill-reviewer` agent only.

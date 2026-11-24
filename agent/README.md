# agent/

Skills for the AI coding agents I use (Claude Code, opencode), shared across all my machines. A skill is a folder with a `SKILL.md`: instructions the agent loads when a task needs them.

## Two kinds of skills

| | Where | Loaded |
|---|---|---|
| **Global**: ways of working (tdd, git, review) and tech most of my projects use (Docker, reverse proxy, REST APIs) | each agent's config under `linux/`, deployed to `$HOME` (default: Claude Code's `linux/.claude/skills/`) | in every project |
| **Project**: stacks only some projects use (Java/Quarkus, React/Vite, Python, …) | `agent/skills/<group>/` | only where I link the group |

Why the split: every loaded skill costs context in every session, and a Quarkus skill has no business firing in a Python project.

## Using project skills

```sh
bash ~/dotfiles/script/link-agent-to-project.sh --from skills \
  --folders java-quarkus react-vite --to ~/projects/myapp/.claude/skills
```

Symlinks each skill of those groups into the project (add `--dry-run` to preview). Re-run it after a group changes; stale links get pruned. Gitignore the project's skills dir, since the links are absolute.

## Adding and checking skills (skill-alchemy)

Inside `~/dotfiles`, the Claude Code command `/skill-alchemy` handles adding and checking skills. It's built for Claude Code and files global skills to `linux/.claude/skills/` by default. Tell it another place (e.g. an opencode config dir) and it files there instead.

Commands:

- `add <github url>…` fetches skills from GitHub;
- `inbox` checks skills dropped into `skills-alchemy/data/`;
- `audit` re-checks the current skills;
- `upstream` shows changes in a skill's source repo.

Every skill gets:
- a security scan with [NVIDIA SkillSpector](https://github.com/NVIDIA/SkillSpector), run in a podman container so nothing is installed on the host;
- a read-only review;
- a comparison with all existing skills (duplicates, conflicting rules, size).

Then I decide each item: nothing is filed, merged or updated without my OK. Remove the scanner image with `podman rmi skill-alchemy`.

# agent/

Agent content shared across projects. No scripts here.

```
agent/skills/<group>/<skill>/SKILL.md
```

- A **group** (e.g. `java-quarkus`, `react-vite`) is a set of skills for one stack.
- Groups are linked into a project with `script/link-agent-to-project.sh` (manual, not run by `setup.sh`). See README "Using agent files in a project".

## Adding a skill

Create `agent/skills/<group>/<skill>/SKILL.md` (with `name` and `description` frontmatter), then re-run the link command in each project that uses the group. Existing links are skipped, dead ones pruned.

## Adding a group

Create `agent/skills/<group>/`. A new kind of content (a sibling of `skills/`) is selected with `--from <kind>`.

## Notes

- Links are absolute: gitignore the project's `.claude/skills/`.
- Keep skills generic. No project names or paths.

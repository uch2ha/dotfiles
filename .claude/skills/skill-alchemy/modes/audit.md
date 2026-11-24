# audit: check current skills in place

Argument: a skill name, or `all` (default when omitted). These skills are **trusted**: read them directly, no `skill-reviewer`.

Items:
- own skills: the global skills dir (Settings), `agent/skills/*/*/` and `agent/skills-alchemy/result/*/`;
- plugin skills from S1: report-only, their verdict is keep or hide (`skillOverrides` in `linux/.claude/settings.json`) / disable the plugin. Plugin files are never edited.

1. S1: load the trusted set (it already holds the items).
2. S2: scan, mounting the global skills dir, `agent/skills`, `agent/skills-alchemy/result` (if present), and each enabled plugin's `<installPath>/skills` (one run each).
3. S3: compare each item against all the others. Report each duplicate or conflict pair once.
4. S4 report, S5 decisions, S6 apply. Edits to own skills are written in place; a moved skill (global ↔ group) gets the relink reminder for every project that links it (`find ~ -maxdepth 6 -type l -lname "*dotfiles/agent/skills/<group>/*"`).

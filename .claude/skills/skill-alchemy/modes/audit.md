# audit: check current skills in place

Argument: a skill name, or `all` (default when omitted). These skills are **trusted**: read them directly, no `skill-reviewer`.

Items:
- own skills: the global skills dir (Settings), `agent/skills/*/*/` and `agent/skills-alchemy/result/*/`;
- plugin skills from S1: report-only, their verdict is keep or disable the whole plugin (`/plugin`); `skillOverrides` does not apply to plugin skills. Plugin files are never edited.

1. S1: load the trusted set (it already holds the items).
2. S2: scan, mounting the global skills dir, each non-empty `agent/skills/<group>` (not `agent/skills` itself: the scanner does not descend two levels), `agent/skills-alchemy/result` (if present), and each enabled plugin's `<installPath>/skills` (one run each).
3. Items with `metadata.source`: run [upstream.md](upstream.md) steps 1–3 as checks only (no writes, no staging, temp dirs deleted after). Report a source that was removed or moved upstream (with its re-search advice), and each folder that changed upstream with the advice `/skill-alchemy upstream <name>`. A moved HEAD with an unchanged folder is not a finding.
4. S3: compare each item against all the others. Report each duplicate or conflict pair once.
5. S4 report, S5 decisions, S6 apply. Edits to own skills are written in place; a moved skill (global ↔ group) gets the relink reminder for every project that links it (`find ~ -maxdepth 6 -type l -lname "*dotfiles/agent/skills/<group>/*"`).

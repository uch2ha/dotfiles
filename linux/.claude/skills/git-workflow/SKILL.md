---
name: git-workflow
description: Git conventions: small atomic commits, short messages, branch and PR hygiene. Use when preparing commits, branches or a PR.
---

# Git workflow

- Commit or push **only when the user asks**.
- Small, atomic commits: one logical change each, tests with the code they cover; a Flyway migration ships in the same commit as the code that uses it.
- Messages: short imperative subject (≤ 72 chars), optional body for the why. No mention of models or sessions.
- Branches: `feat/…`, `fix/…`, `chore/…` off `main`; keep them short-lived. Rebase local work on `main`; do not rewrite shared history.
- Never commit `.env`, real data, keys, `target/`, `node_modules/`.
- Before a PR: run the `verification-loop` skill, then write the body with the `pr` skill.
- Conflicts: resolve by understanding both sides, re-run tests after.

---
name: verification-loop
description: Full-stack verification before declaring work done or opening a PR. Use after finishing a feature or refactor.
---

# Verification loop

Run what applies to the change; report real output; never claim a skipped step passed.

1. **Backend**: the project build + test command (e.g. `./mvnw verify`, see AGENTS.md)
2. **Frontend**: the project build + test commands (e.g. `npm run build`, `npm test`)
3. **Stack** (if API, config or Docker changed): start it as AGENTS.md says (e.g. `docker compose up --build`), exercise the changed flow.
4. **Diff review**: `git diff` for leftover debug code, `float`/`double` money, edited applied migrations, secrets or real data, unrelated changes.
5. **Rules check** against `AGENTS.md`: tests for each new rule, project invariants respected.

Output:
```
Backend: PASS|FAIL  Frontend: PASS|FAIL  Stack: PASS|FAIL|SKIPPED
Issues: <list or none>
```

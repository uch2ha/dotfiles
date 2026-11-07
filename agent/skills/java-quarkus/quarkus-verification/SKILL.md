---
name: quarkus-verification
description: Pre-PR verification checklist for the backend and full stack: build, tests, migrations, container startup. Use before saying backend work is done.
---

# Backend verification

Run in order; stop at the first failure and report real output.

1. `./mvnw -q verify` (compiles + all tests, includes Flyway migrations on a fresh DB).
2. New/changed rule code has a unit test; new endpoint has a `@QuarkusTest`.
3. Migration check: only **new** `V<n>__*.sql` files added; no applied migration edited (`git diff --stat -- '*/db/migration/*'`).
4. Grep the diff for `double`/`float`/`Double` near money, `LocalDate.now()` inside rule code, and hard-coded secrets.
5. Stack check when API/config/Docker changed: `docker compose up --build`, then `curl -f` the health endpoint (`/q/health`) through the proxy.
6. Report: PASS/FAIL per step, with the failing output if any. Say plainly what was skipped.

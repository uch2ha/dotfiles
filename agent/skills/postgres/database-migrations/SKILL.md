---
name: database-migrations
description: Flyway migration rules. Use whenever the schema or reference data changes.
---

# Flyway migrations

- Location `backend/src/main/resources/db/migration`, name `V<next>__short_snake_description.sql`.
- **Never edit an applied migration.** A mistake is fixed by a new migration.
- One logical change per migration; each runs in a transaction (Postgres DDL is transactional).
- Forward-only: no down scripts. If a change is risky, plan the reverse as a later migration.
- Adding a NOT NULL column to a populated table: add nullable → backfill → set NOT NULL (same migration is fine at this size).
- Renames/drops of used columns: expand → deploy code that stops using it → drop in a later migration.
- Create indexes for new foreign keys in the same migration.
- Test: `./mvnw test` runs all migrations from empty on Dev Services Postgres; also check a migration against data from the previous version when it transforms rows.
- No real data in seed migrations; reference data only.

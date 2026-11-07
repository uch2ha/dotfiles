---
name: postgres-patterns
description: PostgreSQL schema, index and query conventions. Use when designing tables, indexes, or fixing slow queries.
---

# PostgreSQL patterns

- Money: `NUMERIC(14,2)` NOT NULL with CHECK constraints where sensible. Never `float`/`money`.
- Dates: `DATE` for calendar days, `TIMESTAMPTZ` for instants. Never store dates as text.
- Keys: `UUID` (or `BIGINT GENERATED ALWAYS AS IDENTITY`); pick one and stay consistent.
- Enforce rules in the DB too: `NOT NULL`, `UNIQUE`, `CHECK`, foreign keys with explicit `ON DELETE`.
- Append-only tables: no UPDATE/DELETE in code; optionally a trigger that raises on UPDATE/DELETE.
- Index every foreign key and every column used in frequent `WHERE`/`ORDER BY`; composite order = equality columns first, range last. Check with `EXPLAIN (ANALYZE, BUFFERS)` before adding.
- Avoid `SELECT *`, N+1 loading (use `JOIN FETCH` or a projection), and unbounded lists (paginate).
- Use `text` over `varchar(n)` unless the length is a real rule.
- Snake_case names; plural table names; `created_at` on every table.

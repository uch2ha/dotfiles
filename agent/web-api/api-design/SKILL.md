---
name: api-design
description: REST API conventions for a backend consumed by a SPA through a reverse proxy. Use when adding or changing endpoints.
---

# API design

- Base path `/api`; plural nouns (`/api/orders`); nesting at most one level.
- Methods: GET read, POST create (201 + `Location`), PUT/PATCH update, DELETE remove (204). Append-only resources expose POST only.
- Status codes: 400 validation, 404 missing, 409 conflict, 422 rule violation, 500 never carries internals.
- Error body: `{ "code": "...", "message": "...", "fields": {"name": "..."} }`.
- Money as a JSON **string** (`"12.50"`) to avoid float loss; dates `YYYY-MM-DD`, year-month `YYYY-MM`.
- Lists are bounded: `?page`/`?size` or a date range.
- Response DTOs are records separate from entities; fields are additive, so the frontend does not break.
- Document each endpoint (request/response example) in the spec before building.

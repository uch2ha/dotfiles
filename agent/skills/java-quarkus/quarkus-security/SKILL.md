---
name: quarkus-security
description: Security checklist for the Quarkus backend: input validation, SQL injection, secrets, CORS, auth, headers. Use when adding endpoints, auth, or handling config.
---

# Quarkus security

- **Input**: every request body is a validated DTO record; path/query params are typed (`UUID`, `LocalDate`), never raw strings parsed by hand.
- **SQL**: Panache named/positional parameters only (`find("owner = ?1", id)`); never concatenate user input into HQL/SQL.
- **AuthZ**: every query is scoped to the caller's own data; an id from the URL is never trusted alone. Test that user A cannot read user B's rows.
- **Auth** (when added): use `quarkus-oidc` or `smallrye-jwt` with `@RolesAllowed`; passwords, if stored, hashed with BCrypt (`quarkus-elytron-security-common`). Do not write custom crypto.
- **Secrets**: only from env vars; `.env` never committed; `.env.example` lists names with no real values.
- **CORS**: prefer same-origin through the reverse proxy; keep `quarkus.http.cors` off unless needed.
- **Errors**: mapped to generic JSON; no stack traces or SQL in responses; no sensitive values in logs.
- **Headers**: set in the reverse proxy (`X-Content-Type-Options`, `Referrer-Policy`, `X-Frame-Options`).
- **Dependencies**: review new Maven/npm deps before adding; pin versions.

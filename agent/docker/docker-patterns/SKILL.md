---
name: docker-patterns
description: Docker Compose and Dockerfile conventions for multi-service apps (reverse proxy + backend + database). Use when editing docker-compose.yml or Dockerfiles.
---

# Docker patterns

- `docker compose up --build` must start everything from a clean checkout plus `.env` copied from `.env.example`.
- Database service: named volume and a `pg_isready` healthcheck. App services use `depends_on: <db>: condition: service_healthy`.
- Every variable lives in `.env.example` with a placeholder; compose reads `${VAR}`; no real values in compose or images.
- Only the reverse proxy publishes a host port. Database and backend stay on the internal network (publish the DB only in a dev override).
- Multi-stage builds: build stage (node / Maven) → slim runtime stage. Pin image tags (no `latest`). Run as non-root where the image allows.
- Add `.dockerignore` (`node_modules`, `target`, `.git`, `.env`).
- Debug: `docker compose logs -f <svc>`, `docker compose exec <db> psql -U $POSTGRES_USER`.
- Proxy config (nginx / Traefik) lives in the `reverse-proxy-patterns` skill.

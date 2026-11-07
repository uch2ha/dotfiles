---
name: vite-patterns
description: Vite config, env and dev-proxy conventions for the frontend. Use when touching vite.config.ts, env variables or build setup.
---

# Vite patterns

- Dev: `server.proxy` forwards `/api` to the backend so the browser sees one origin (same as the reverse proxy in production).
- Env: only `VITE_`-prefixed vars reach the client and they are **public**; never put secrets there. Declare types in `vite-env.d.ts`.
- Use relative `/api` URLs in code, not absolute hosts.
- `npm run build` outputs `dist/`, which the web-server image copies; base path stays `/`.
- Pin Vite and plugin versions; keep the config minimal (react plugin + proxy + Vitest `test` block).
- Path aliases are optional; if added, mirror them in `tsconfig.json` and Vitest.

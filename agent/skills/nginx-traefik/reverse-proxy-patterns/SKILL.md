---
name: reverse-proxy-patterns
description: nginx and Traefik reverse-proxy conventions for serving a SPA and proxying /api to a backend. Use when editing nginx.conf or Traefik labels/config.
---

# Reverse proxy patterns (nginx / Traefik)

- Serve the built SPA with a fallback: `try_files $uri /index.html`.
- Proxy `/api/` to the backend service by its compose name; pass `Host`, `X-Forwarded-For`, `X-Forwarded-Proto`.
- Compress text assets (gzip); long immutable cache only for hashed asset files, never for `index.html`.
- Set security headers here: `X-Content-Type-Options`, `Referrer-Policy`, `X-Frame-Options`.
- Keep the app same-origin through the proxy so CORS stays off.
- Traefik: routers/services via compose labels (`traefik.http.routers.<n>.rule=PathPrefix(...)`), TLS via a resolver; same rules apply (SPA fallback, `/api` route, headers middleware).
- Validate config before reload: `nginx -t`.

---
name: multi-stage-dockerfile
description: "Dockerfile authoring rules: multi-stage builds, base image choice and pinning, layer caching, non-root runtime, HEALTHCHECK. Use when writing, editing or reviewing a Dockerfile or Containerfile."
metadata:
  source:
    repo: "github.com/github/awesome-copilot"
    path: "skills/multi-stage-dockerfile"
    commit: "93fc8b9ee3ef56b9b5e7261e6ce92d314cb2c1cf"
    license: "MIT"
    checked: "2026-11-27"
---

## Multi-Stage Structure

- Use a builder stage for compilation, dependency installation, and other build-time operations
- Use a separate runtime stage that only includes what's needed to run the application
- Copy only the necessary artifacts from the builder stage to the runtime stage
- Use meaningful stage names with the `AS` keyword (e.g., `FROM node:18 AS builder`)
- Place stages in logical order: dependencies → build → test → runtime

## Base Images

- Start with official, minimal base images when possible
- Specify exact version tags to ensure reproducible builds (e.g., `python:3.11-slim` not just `python`)
- Consider distroless images for runtime stages where appropriate
- Use Alpine-based images for smaller footprints when compatible with your application
- Ensure the runtime image has the minimal necessary dependencies

## Layer Optimization

- Organize commands to maximize layer caching
- Place commands that change frequently (like code changes) after commands that change less frequently (like dependency installation)
- Use `.dockerignore` to prevent unnecessary files from being included in the build context
- Combine related RUN commands with `&&` to reduce layer count
- Consider using COPY --chown to set permissions in one step

## Security Practices

- Avoid running containers as root - use `USER` instruction to specify a non-root user
- Remove build tools and unnecessary packages from the final image
- Scan the final image for vulnerabilities
- Set restrictive file permissions
- Pass build secrets with `RUN --mount=type=secret,id=...`; never via `ARG`/`ENV` (they show in `docker history` and the build cache, even in builder stages)

## Performance Considerations

- Use build arguments for configuration that might change between environments
- Leverage build cache efficiently by ordering layers from least to most frequently changing
- Consider parallelization in build steps when possible
- Set appropriate environment variables like NODE_ENV=production to optimize runtime behavior
- Use appropriate healthchecks for the application type with the HEALTHCHECK instruction

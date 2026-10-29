---
name: conventions-docker
description: Docker and Compose default conventions — multi-stage builds, pinned bases, cache-friendly layers, non-root runtime, secrets, healthchecks. Use when writing or changing Dockerfiles, compose.yaml or container configuration.
---

The repo's own deployment docs win over these. Container security review: `check-security`.

## Dockerfile

- **Multi-stage**: a build stage with the toolchain, and a runtime stage with only the artifacts and production dependencies.
- **Pin base images** to a specific version (`node:22.12-alpine`), and to a digest for production images. Never `latest`.
- **Smallest viable base**: `alpine` or `distroless`; `slim` when musl causes problems.
- **Cache-friendly order**: copy the manifests and lockfile, install with a frozen lockfile (`pnpm install --frozen-lockfile`, `npm ci`), then copy the source. Use BuildKit cache mounts for package stores.
- **Non-root runtime** (`USER node` or equivalent). One process per container.
- **No secrets in images**: no `ARG` or `ENV` for secrets. Use BuildKit `--mount=type=secret` at build time and environment variables at runtime.
- **A `HEALTHCHECK`**, or a healthcheck in Compose, for every long-running service.
- **Commit a `.dockerignore`** that excludes `.git`, `node_modules`, build output and `.env*`.

## Compose

- `compose.yaml` for local development and tests. Production uses the platform's own manifests.
- Use `depends_on` with `condition: service_healthy` instead of sleep loops.
- Use named volumes for data and pinned images for dependencies (Postgres, Redis).

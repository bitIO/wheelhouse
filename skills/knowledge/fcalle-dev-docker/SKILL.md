---
name: fcalle-dev-docker
description: Docker conventions — multi-stage builds, pinned base images, non-root user, layer ordering, secrets, healthchecks. Use when writing Dockerfiles, docker-compose files, or reviewing container configuration.
---

## Docker

- **Multi-stage builds** — build stage with toolchain, runtime stage with only artifacts.
- **Pin base image versions** — `node:20.11-alpine`, not `node:latest`.
- **Non-root user** — `USER node` (or equivalent) in the runtime stage.
- **`.dockerignore`** committed; exclude `node_modules`, `.git`, build outputs, secrets.
- **One process per container.**
- **Layer ordering** — copy `package.json` + lockfile and install deps *before* copying source, to maximize cache hits.
- **No secrets in images** — use build args sparingly, runtime env for secrets.
- **Smallest viable base** — `alpine` or `distroless` for production; `slim` if alpine causes glibc issues.
- **Healthchecks** defined in `Dockerfile` or compose.
- **`docker-compose.yml`** for local dev; production uses orchestrator-native manifests (k8s, ECS, etc.).

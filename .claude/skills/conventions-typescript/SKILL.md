---
name: conventions-typescript
description: TypeScript and Node.js default conventions — strict config, runtime validation at boundaries, unions over flags, error handling, ESM, exports, async. Use when writing TS/JS code, configuring tsconfig or package.json, or debugging type errors.
---

The repo's own conventions (`AGENTS.md`, `tsconfig`, lint rules) win over these.

## Types

- **`strict: true`**, plus `noUncheckedIndexedAccess` on new projects. No `any` without a comment explaining why; use `unknown` and narrow it.
- **Types don't validate input.** Parse everything that crosses a boundary (HTTP bodies, env vars, files, third-party responses) with a schema (zod, valibot) and derive the type from the schema.
- **Discriminated unions** for states and results, instead of boolean flags.
- **`as const` objects or string-literal unions** instead of `enum`. Use `satisfies` to check a value without widening it.
- `import type` for type-only imports.

## Errors

- **Expected failures are values** (`Result<T, E>` or a discriminated union). `throw` is for programmer errors and truly exceptional cases.
- Never swallow errors: no empty `catch`, and no `catch` that only logs and continues as if nothing happened.

## Modules and async

- **ESM** unless the project is CommonJS. Prefer `node:` built-ins and existing dependencies over adding packages.
- **Named exports**, except where a framework requires a default export (Next.js pages, layouts and route files; config files).
- **`async/await`**; don't mix it with `.then()` in the same function. Never leave floating promises. Use `AbortSignal` for cancellable work and timeouts on all I/O.
- Top-level `await` only in entry points.

## Tooling

- Node version pinned in `.nvmrc` and `engines`. Lockfile committed. pnpm or npm workspaces for monorepos.

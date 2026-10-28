---
name: fcalle-dev-typescript
description: TypeScript and Node.js conventions — strict mode, unknown over any, discriminated unions, ESM, enums, async/await, monorepo setup. Use when writing TS/JS code, configuring tsconfig, reviewing types, or debugging type errors.
---

## TypeScript / Node.js

- **`strict: true`** in `tsconfig.json`. No `any` without an inline justification comment.
- **Prefer `unknown` over `any`** when the type is genuinely unknown; narrow with type guards.
- **Discriminated unions** for state machines and result types over boolean flags.
- **`Result<T, E>` / `Either`** patterns for expected errors; `throw` for programmer errors only.
- **No default exports** in libraries — named exports only. Default exports break refactors and tree-shaking.
- **ESM unless the project is CommonJS** — prefer `node:` built-ins (`node:fs/promises`, `node:test`) and existing dependencies over pulling in new packages.
- **Avoid `enum`** — use `as const` objects or string literal unions.
- **`async/await` over raw `.then()`**; never mix the two in one function. Never leave floating promises — `await` them or attach `.catch`. Use `AbortSignal` for cancellable work. Don't swallow errors.
- **Top-level `await`** only at entry points.
- **Prefer `pnpm` or `npm` workspaces** for monorepos; lockfile committed.
- **Node version pinned** in `.nvmrc` / `engines`.
- **Use DDD when the project justifies it** — a non-trivial domain with clear bounded contexts. Do not force DDD onto CRUD glue.

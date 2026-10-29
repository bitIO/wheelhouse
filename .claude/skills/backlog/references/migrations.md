# Slicing migrations

A migration has no new features, so slicing it "vertically" means slicing by **behaviour that moves to the new stack**. The old stack keeps serving everything else until the cutover.

## Shape of a migration backlog

```text
1. Walking skeleton   new stack runs, deploys and answers one trivial route, side by side with the old one
2. First real slice   the simplest route group that matters; establishes the pattern (mode: pair)
3. Riskiest slice     auth, writes, money, data: early, while it's cheap to change course (mode: pair)
4…n-2. Repetitions    remaining route groups, following the pattern (mode: deliver)
n-1. Cutover          consumers switch to the new stack; rollback is a config change
n. Decommission       old stack, its adapters and its docs are removed
```

## What "done" means for a migrated slice

`story` turns these into acceptance criteria:

- **Contract parity**: same paths, status codes, body shapes and error formats as before. If the repo already has contract or parity tests, they run against the new stack too.
- **Auth parity**: the same callers are allowed and denied, with the same error codes.
- **Data parity**: same reads; writes produce the same rows. No schema change unless it's a story of its own.
- **Operability**: health check, logs and environment variables documented.

## Expensive decisions to ask about up front

- Can both stacks run side by side (proxy, path routing, a second port), or is a single cutover the only option?
- Rollback: an environment variable or route switch, a redeploy, or a revert?
- Runtime and deployment target (for example Node vs Bun vs edge). It constrains libraries.
- Validation and serialization: keep the current library or switch? Switching changes error formats, which affects contract parity.
- How long is the old stack allowed to live after the cutover?

## Example (generic): NestJS → Hono

Context: a REST backend in NestJS (about 60 routes in 13 modules). Business logic already lives in framework-free packages (use cases and repositories). Frontends reach it only through an HTTP client package.

```markdown
## Backlog
1. As an operator, I want a Hono backend that serves /api/health next to the current backend, so that I can deploy and monitor it before it takes traffic.
2. As a visitor, I want team and category listings served by the new backend, so that read-only pages keep working on the new stack. Requires: #1
3. As staff, I want to manage players through the new backend with the same permissions as today, so that admin keeps working. Requires: #2
4. As a recorder, I want to record match events through the new backend, only for matches I'm allowed to record, so that live recording keeps working. Requires: #3
5. As staff, I want to manage people, coaches and staff through the new backend, so that the remaining admin screens keep working. Requires: #3
6. As staff, I want file uploads handled by the new backend, so that attachments keep working. Requires: #3
7. As an operator, I want every app pointed at the new backend with a one-variable rollback, so that we can switch safely. Requires: #2–#6
8. As an operator, I want the old backend and its adapters removed, so that we maintain one stack. Requires: #7
```

Notes on that example:

- Story 2 builds the routing, error mapping and test harness, inside the first story that needs them.
- Story 3 brings authentication and authorization, because it's the first story that needs them. It's high risk, so mode `pair`.
- Stories 5 and 6 follow the pattern from 3, so mode `deliver`.
- Nothing like "set up Hono", "port DTOs" or "replace DI" appears as a story.

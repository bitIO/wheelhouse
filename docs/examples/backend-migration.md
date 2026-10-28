# Example: migrating a NestJS backend to Hono

A walkthrough of every workflow on a realistic initiative. The setup:

- A pnpm + Turbo monorepo. The NestJS backend serves about 60 REST routes in 13 modules under `/api`.
- Business logic already lives in framework-free packages (`domain`, `application`, repository adapters).
- Frontends never call the backend directly; they go through an HTTP client package.
- Authentication is a JWT guard, authorization is a policy guard plus a per-resource guard, and there are route-parity tests from an earlier migration.

Outputs below are shortened. Your tool's real output will differ in wording.

## 1. `/lead` (once, in its own session)

```text
> /lead Quiero migrar el backend de NestJS a Hono
```

**Triage.** Too big for one story, and the outcome is clear (same API, new framework), so the lead confirms the intent instead of running a full interview:

```text
Understood: replace the NestJS HTTP layer with Hono, keeping every /api contract,
auth rule and data behaviour unchanged. Frontends should not change.
Correct? One question before I investigate:
Can both backends run side by side during the migration (a second port behind
the same client package), or do you need a single cutover?
Suggested: side by side, switched per environment variable.
```

**Investigation** (delegated to `investigator` with a brief):

```text
1. HTTP layer → 13 controllers, 61 routes (apps/backend/src/**.controller.ts)
2. Logic → controllers call application use cases; no business logic in the
   controllers (sampled player, match, team)
3. Auth → auth.guard.ts (JWT), require-can.guard.ts (policy), match-access.guard.ts
   (per resource); the policy itself lives in packages/application/src/auth
4. Contract tests → src/parity/http-routes.test.ts, http-shapes.test.ts: these use
   the NestJS testing module, so they won't run against Hono as they are
5. Validation → class-validator DTOs: the error body format is part of the contract
6. Hono docs (hono.dev): @hono/node-server for Node 22; app.request() for
   in-process tests; validator middleware via @hono/zod-validator
Unknowns: whether any client relies on NestJS's default error body shape
```

**Gate** (initiative mode):

```markdown
## Gate: GO_WITH_NOTES
Understood: framework swap of the HTTP layer; contracts, auth and data unchanged.
Material risks:
- The parity tests are coupled to NestJS. Make them framework-agnostic (plain HTTP)
  first, or the contract has no guard during the migration.
- Validation error bodies: switching away from class-validator changes the 400 format.
- Guard order: authentication must run before every handler (default-deny).
Notes carried into stories: parity suite runs against both stacks; one error-mapping
module that reproduces today's error bodies; no schema changes in this epic.
```

**Backlog** (migration mode), with risk, checks and suggested mode:

```markdown
1. As an operator, I want the Hono backend serving /api/health next to the current
   one, so that I can deploy and monitor it before it takes traffic.
   risk: low · checks: testing · mode: pair
2. As a visitor, I want team and category listings from the new backend, so that
   read-only pages keep working on it. Requires: #1
   risk: medium · checks: testing · mode: pair   ← sets the pattern
3. As staff, I want to manage players through the new backend with today's
   permissions, so that admin keeps working. Requires: #2
   risk: high · checks: security, data, testing · mode: pair
4. As a recorder, I want to record match events only for matches I'm allowed to record.
   Requires: #3 · risk: high · checks: security, data · mode: pair
5. As staff, I want to manage people, coaches and staff through the new backend.
   Requires: #3 · risk: medium · checks: security, testing · mode: deliver
6. As staff, I want file uploads handled by the new backend. Requires: #3
   risk: medium · checks: security · mode: deliver
7. As an operator, I want every app pointed at the new backend with a one-variable
   rollback. Requires: #2–#6 · risk: high · checks: security, perf · mode: pair
8. As an operator, I want the NestJS backend and its adapters removed.
   Requires: #7 · risk: low · checks: testing · mode: deliver

Delivery: one branch and PR per story into main. Hono runs on a second port; the
client package picks the backend by an environment variable. Rollback = flip the
variable.
```

Note what is **not** in the backlog: "set up Hono", "port the DTOs", "replace dependency injection". That work happens inside the first story that needs it.

After you lock it, the lead creates the epic and eight story issues, then ends with:

```text
Next: /story #101 in a fresh session.
```

## 2. `/story #102` (session per story)

Story 1 (the skeleton) is done. Story 2 sets the pattern:

```markdown
## Story
As a visitor, I want team and category listings from the new backend, so that
read-only pages keep working on it.

## Acceptance criteria
- [ ] Given the parity suite, when it runs against the Hono backend, then GET /api/teams,
      /api/teams/:id and /api/categories return the same status and body shape as NestJS.
- [ ] Given an unknown team id, when it's requested from Hono, then the response is
      404 with today's error body.
- [ ] Given CLIENT_BACKEND=hono, when the public pages load, then they render the same data.

## Plan
- Make the parity suite framework-agnostic (plain HTTP against a base URL).
- Add routing for the three routes, calling the existing use cases.
- Add one error-mapping module reproducing today's error bodies.
- Let the client package pick the backend by environment variable.

## Out of scope
- Authenticated routes, validation of request bodies, OpenAPI.

## Gate
GO_WITH_NOTES · Risk: medium · Checks: testing · Mode: pair
- Run the parity suite against NestJS first: it must stay green before any Hono code.
```

## 3. `/pair #102`

The navigator approves the test list (names only), then the AI moves one step at a time:

```text
✅ Passes "parity: GET /api/teams matches NestJS" (red → green).
   Routing + use-case call, apps/backend-hono/src/routes/teams.ts:12
Decided: the base URL comes from PARITY_BASE_URL, defaulting to NestJS.
Change anything, or continue with "parity: GET /api/teams/:id 404 body"?
```

It stops mid-batch when it hits something outside the plan:

```text
⏸ The NestJS 404 body includes "path", which needs the request URL in the error
mapper. Not in the plan. Options: (a) include it, (b) drop it and note a contract
change for /lead. Suggested: (a), it keeps parity.
```

## 4. `/deliver #105`

Story 5 repeats the pattern from stories 2–3, so it's delegated. Three checkpoints:

1. **Plan**: "follows routes/players.ts (story #103) and the error mapper (story #102)".
2. **Test list**: approved by you, and frozen from then on.
3. **Result**: all tests green, a `verify` verdict, proposed commits. The AI commits only on your yes.

## 5. `/verify #105`

```markdown
## Verify #105: FAIL
Range: 3f2a1c..HEAD (+ uncommitted: no) · Commands: typecheck ✅ lint ✅ test ✅

| Criterion | Proven by | OK |
|---|---|---|
| Staff can create a coach | coaches.parity.test.ts › "POST /api/coaches 201" | ✅ |
| Non-staff gets 403 | (none) | ❌ |

Findings:
1. [BLOCKER] No test proves the 403 for non-staff on POST /api/coaches. Add a parity
   case with a team-member token.
2. [MAJOR] routes/coaches.ts:40 registers the handler before requireCan; a route
   added later in this file would be public by default.
```

`deliver` fixes both findings, re-verifies, and reports PASS.

## 6. `/accept #105`, `/lead #100`, `/accept #100`

- `/accept #105`: every criterion has its evidence, the manual check is confirmed, the PR is proposed with `Closes #105`.
- `/lead #100`: shows status ("5/8 done, next #106"). It also handles a discovery reported by `/pair` ("the files route streams uploads; NestJS buffers them") by re-gating story #106.
- `/accept #100`, after the decommission story: a system-level `verify` across the whole epic, a check that the non-goals were respected, the rollback documented, and your sign-off.

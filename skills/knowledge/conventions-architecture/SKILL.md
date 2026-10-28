---
name: conventions-architecture
description: Default architecture principles — existing patterns first, YAGNI for seams, DDD and hexagonal boundaries when justified, Twelve-Factor services, observability and decision records. Use when designing or changing modules, services, boundaries or abstractions, or writing an ADR.
---

The repo's own architecture docs and ADRs win over these. Performance review: `check-perf`.

## Before adding structure

- **The existing architecture wins by default.** Before introducing a mechanism, check whether the repo already has one.
- **No seam without a real variation point.** Ask whether there's a second implementation today, or a requirement that demands one. "Maybe later" isn't a reason for an interface, a provider abstraction, a new package or a config option.
- **The smallest design that meets today's requirement.** Separate what's required from what's merely possible.

## Boundaries

- **Hexagonal / ports and adapters**: the domain and use cases don't import frameworks, HTTP or database drivers. Adapters depend on the core, never the other way round. Enforce it with a dependency rule (lint or test), not by convention alone.
- **DDD only when the domain is non-trivial**: ubiquitous language in code, bounded contexts that don't leak models, entities vs value objects, aggregates that enforce invariants, repositories that hide persistence. Don't force it onto CRUD glue.
- **Twelve-Factor services**: config from the environment (validated at startup), stateless processes, logs to stdout.

## Operability

- **Budgets on hot paths** (p95 latency) defined up front for critical flows.
- **Caching is a contract**: define TTL, invalidation and stampede protection before you add it.
- **Structured logs** with consistent fields (`requestId`, `userId`, `traceId`). Metrics, logs and traces for production services. Error tracking on frontend and backend.

## Decisions and docs

- **Write an ADR** for any choice a future reader will question: context, decision, alternatives, consequences.
- **Code is the primary documentation.** Comments explain *why*, never *what*. Public APIs get doc comments.
- READMEs answer what it is, how to run it and how to contribute. A doc that lies is worse than no doc: update or delete it.

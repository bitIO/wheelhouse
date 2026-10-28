---
name: fcalle-dev-architecture
description: Architecture patterns — DDD, hexagonal/ports-and-adapters, Twelve-Factor, performance, observability, documentation standards. Use when designing new domains, services, or systems, discussing bounded contexts, ADRs, or performance/observability strategy.
---

## Architecture

- **Domain-Driven Design (DDD)** when the domain is non-trivial:
  - Model the **ubiquitous language** of the business; names in code mirror names used by domain experts.
  - Identify **bounded contexts**; don't let one context's model leak into another.
  - Separate **entities** (identity-bearing) from **value objects** (immutable, equality by value).
  - Aggregates enforce invariants; cross-aggregate consistency is eventual.
  - Repositories hide persistence; domain logic stays free of ORM/DB concerns.
- **Hexagonal / Ports & Adapters** — domain core has no knowledge of frameworks, HTTP, or DB drivers.
- **Separation of concerns** — UI, business logic, persistence, and I/O live in distinct layers.
- **Twelve-Factor App** for services — config in env, stateless processes, logs as event streams, etc.

## Performance & Observability

- **Measure before optimizing.** No premature optimization.
- **Hot path budgets** — define and enforce p95 latency budgets for critical paths.
- **N+1 queries are bugs** — eager-load or batch.
- **Caching is a contract** — define TTL, invalidation, and stampede protection up front.
- **Structured logging** — JSON logs with consistent fields (`requestId`, `userId`, `traceId`).
- **Metrics, logs, traces** — instrument all three for production services.
- **Error tracking** — Sentry / equivalent on frontend and backend.

## Documentation

- **Code is the primary documentation** — clear names, small functions, obvious flow.
- **Comments explain WHY, never WHAT.** A comment restating the code is noise.
- **Public APIs documented** — JSDoc / docstrings on exported functions and types.
- **READMEs** answer: *what is this*, *how do I run it*, *how do I contribute*.
- **Architecture Decision Records (ADRs)** for non-obvious choices that future readers will question.
- **No stale docs** — docs that lie are worse than no docs. Delete or update.

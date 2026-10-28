---
name: check-perf
description: Performance checklist for reviewing changes on hot paths (queries, N+1, payloads, bundles, caching, load). Use when verifying or gating work that could materially affect latency, throughput, bundle size or resource use.
---

# Performance check

Measure before you claim. No gut-feel findings. Report; don't optimize.

## Checklist

- **Evidence**: profilers, `EXPLAIN ANALYZE`, Lighthouse and web vitals, bundle analyzers, load tools (k6, autocannon). Show the measurement.
- **Baseline and budget**: compare before and after, not absolute numbers in isolation.
- **Database**: N+1 queries, missing indexes, unindexed joins, full scans, unbounded pagination.
- **Wire**: oversized payloads, missing compression, no caching on immutable resources.
- **Frontend**: render-blocking assets, bundle bloat, unnecessary re-renders, waterfalls.
- **Load**: find the bottleneck (CPU, database, network, memory) at realistic concurrency.

## Migrations and framework swaps

- Compare p50 and p95 latency for the same routes on the old and new stacks, under the same load.
- Check cold start and memory per process if the runtime changed.
- Make sure middleware that was cheap before (body parsing, validation, logging) didn't become expensive per request.

## Report

For each finding give what's slow, by how much (with the measurement), the bottleneck, the location (`file:line` or endpoint) and the fix. State what was profiled, at what load and with which metrics. If it's fine, say so.

---
name: 4r-code-review
description: >
  Perform structured code reviews using the 4R framework (Risk, Readability,
  Reliability, Resilience). Use this skill whenever the user asks to review
  code, audit a PR, check a diff, analyze a file for quality issues, or says
  anything like "review this", "check this code", "is this safe to merge", or
  "what's wrong with this". Also trigger when the user pastes code and asks for
  feedback, even without explicitly requesting a "review". Do NOT skip this
  skill for "quick" reviews — the 4R structure is fast and catches things
  ad-hoc review misses.
---

# 4R Code Review

A structured code review framework aligned with industry standards:
OWASP Top 10, CWE Top 25, STRIDE, Clean Code (Martin), ISTQB, AWS
Well-Architected (Reliability), and Google SRE.

## When to use

- User shares a file, diff, or PR and asks for feedback
- User asks "is this safe / ready / mergeable?"
- User pastes code and wants it checked
- Auditing a specific concern (security, test coverage, resilience)

## Review ground rules

Apply these to every review, across all four R's:

- **Evidence over assertion.** Every finding cites its exact location
  (`file:line`, function, or branch) and, for dependency/security claims, a
  concrete source (scan output, CVE/GHSA id, log line). "Looks risky" is not a
  finding.
- **Proportionality.** Severity scales with blast radius and context: public
  API or auth/payment path > internal tool; production > prototype; reachable
  code > dead code. Never inflate a style nit to HIGH.
- **Balanced.** Report what is done well too. A review that only lists
  negatives hides whether the change is fundamentally sound.
- **No nitpicking.** Skip issues with no real impact (cosmetic but clear
  naming, one-off formatting). One actionable finding beats five pedantic ones.
- **Don't fix, report.** You review; the author fixes. Do not rewrite code
  in a review.

---

## The Four Rs

### R1 — RISK
**Standards:** OWASP Top 10 (2021) · CWE Top 25 · STRIDE · PCI-DSS

Check for:
- **OWASP A01 Broken Access Control** — endpoints without auth/authz, IDOR
- **OWASP A03 Injection** — string concatenation in SQL, shell, LDAP, NoSQL
- **OWASP A04 Insecure Design** — privilege escalation, cross-user data access
- **STRIDE Spoofing/Tampering** — critical data without signatures or integrity validation
- **STRIDE Information Disclosure** — secrets, internals leaked via headers, errors, logs
- **PCI-DSS** (if applicable) — PAN data logged, payment data mishandled
- **Production impact** — touches payments, auth, users, production DB
- **Regression** — public API behavior changed without versioning
- **Data safety** — destructive migrations, no rollback, edge-case data loss
- **Dependencies** — unaudited libraries, known CVEs/GHSAs in selected versions

**Do not flag:** React/JSX default escaping as XSS unless there is a raw-HTML
sink (`dangerouslySetInnerHTML`, `v-html`, innerHTML). Secrets in local-only,
gitignored dev config. Auth UI states used purely as UX affordances — but flag
any frontend-only enforcement as authorization.

**Scoring (start: 10)**

| Severity | Examples | Deduction |
|----------|----------|-----------|
| CRITICAL | SQL injection, auth bypass, secret exposure, migration without rollback | −3 each |
| HIGH | XSS, CSRF without token, sensitive data in logs, breaking API change | −2 each |
| MEDIUM | Missing rate limiting, missing security headers (CSP, HSTS) | −1 each |

FAIL if score < 6.

---

### R2 — READABILITY
**Standards:** Clean Code (Martin) · Google Style Guides · SonarQube Cognitive Complexity

Check for:
- **Naming** — names reveal intent, no cryptic abbreviations, booleans use is/has/should
- **Function SRP** — single responsibility, under 20 lines, no hidden side effects
- **Comments** — explain WHY not WHAT, no commented-out dead code
- **Cognitive Complexity** — nesting deeper than 3 levels, compound conditions with 3+ operators
- **Style conventions** — Effective TypeScript for TS, PEP8 for Python, etc.
- **AI Slop** — generic variable names, redundant logic, unused imports
- **Complexity budget** — functions >40 lines, files >400 lines (except config/data-mapping)

**Do not flag:** short, self-explanatory inline values and helpers; naming
that is clear without a comment; style that already matches the surrounding
file. Flag magic numbers only when they hide business meaning.

**Scoring (start: 10)**

| Severity | Examples | Deduction |
|----------|----------|-----------|
| CRITICAL | Function >100 lines, nesting >5 levels, file >1000 lines | −3 each |
| HIGH | Function >40 lines, cognitive complexity >15, magic numbers | −2 each |
| MEDIUM | Single-letter vars (except i/j/k), WHAT comments, unused imports | −1 each |

FAIL if score < 5.

---

### R3 — RELIABILITY
**Standards:** ISTQB · Google Testing Blog · Chaos Engineering (Netflix) · Pact

Check for:
- **Coverage** — unit tests cover all new branches, coverage >80% for new logic
- **Boundary testing** — empty, null, malformed inputs, array boundaries tested
- **Behavioral tests** — validate behavior not implementation, external deps mocked at process boundaries
- **Regression** — bug fixes carry a test that fails without the fix
- **Error handling** — every fallible operation handled, no `except: pass` or `catch {}`
- **Timeouts** — every I/O operation (HTTP, DB, filesystem) has explicit timeout <30s
- **Race conditions** — concurrent operations use locks, shared state is thread-safe
- **Contract testing** — API changes validated against Pact/OpenAPI contracts

**Do not flag:** missing unit tests for glue that integration/E2E already
covers; tests for throwaway scripts. Flag over-mocking that asserts
implementation instead of behavior.

**Scoring (start: 10)**

| Severity | Examples | Deduction |
|----------|----------|-----------|
| CRITICAL | No tests for new logic, `except: pass`, missing I/O timeout | −4 each |
| HIGH | Coverage <50% for new logic, missing edge cases, missing mutex | −2 each |
| MEDIUM | Brittle tests (over-mocked), missing assertions in happy path | −1 each |

FAIL if score < 5.

---

### R4 — RESILIENCE
**Standards:** AWS Well-Architected (Reliability) · Google SRE · Azure Well-Architected

Check for:
- **Retries** — fallible operations use exponential backoff with jitter
- **Graceful degradation** — system responds when external services are down (cache fallback, partial response)
- **Bulkheads** — failure in one component doesn't cascade, connection pools isolated per service
- **Circuit breaker** — open/closed/half-open states implemented for cascading failure protection
- **Error budget** — change stays within SLI/SLO error budget
- **Observability** — structured logs, latency/error/throughput metrics, distributed tracing
- **Recovery** — automatic recovery exists, rollback plan defined, state classified as ephemeral or durable

**Do not flag:** low-impact expected failures already isolated by alert
grouping or silence rules; retry logic on operations that are safe to fail
fast (validation, idempotent reads).

**Scoring (start: 10)**

| Severity | Examples | Deduction |
|----------|----------|-----------|
| CRITICAL | Missing retries for critical ops, no graceful degradation, no logging | −4 each |
| HIGH | Retries without backoff, missing bulkheads, no latency metrics | −2 each |
| MEDIUM | Missing tracing, unstructured logs, no health check endpoint | −1 each |

FAIL if score < 5.

---

## Output Format

Always render results in this exact structure:

```text
╔═══════════════════════════════════════════════╗
║  4R CODE REVIEW                               ║
║  File/PR: <path or ref>                       ║
║  Reviewer: <model used>                       ║
╚═══════════════════════════════════════════════╝

R1 - RISK: <✅ PASS | ⚠️ WARN | ❌ FAIL>
├─ <finding> [CRITICAL | HIGH | MEDIUM | LOW] — <file:line>
├─ <finding> [CRITICAL | HIGH | MEDIUM | LOW] — <file:line>
└─ Score: <0-10>

R2 - READABILITY: <✅ PASS | ⚠️ WARN | ❌ FAIL>
├─ <finding>
└─ Score: <0-10>

R3 - RELIABILITY: <✅ PASS | ⚠️ WARN | ❌ FAIL>
├─ <finding>
└─ Score: <0-10>

R4 - RESILIENCE: <✅ PASS | ⚠️ WARN | ❌ FAIL>
├─ <finding>
└─ Score: <0-10>

✅ DONE WELL
├─ <what the change does right>

═══════════════════════════════════════════════
SUMMARY: <✅ PASS | ⚠️ CHANGES_REQUESTED | ❌ REJECTED>
Overall Score: <average of R1–R4, 0–10>
═══════════════════════════════════════════════
```

Each finding line carries its evidence (`file:line` or CVE/GHSA id). If an R
is FAIL, append a `## Recommended Fixes` section listing concrete fixes,
ordered by severity (critical first).

## Scoring legend

| R Score | Status |
|---------|--------|
| 9–10 | ✅ PASS |
| 6–8 | ⚠️ WARN |
| 0–5 | ❌ FAIL |

| Overall | Verdict |
|---------|---------|
| ≥ 8 | 👍 PASS — merge with confidence |
| 5–7 | 🧠 CHANGES_REQUESTED — fix before merging |
| < 5 | 👎 REJECTED — do not merge |

---

## Review workflow

1. **Identify scope** — file path, PR ref, or pasted snippet
2. **Assess context** — language, framework, what the change does, and its
   blast radius (public API? auth/payment path? production vs prototype)
3. **Score each R independently** — start at 10, deduct per finding, honor the
   "Do not flag" guards to avoid false positives
4. **Classify each finding** — CRITICAL / HIGH / MEDIUM / LOW with a brief
   rationale and its evidence
5. **Render the output block** — exact format above, no deviations
6. **If any R is FAIL** — add a `## Recommended Fixes` section with concrete,
   actionable suggestions per finding, ordered by severity

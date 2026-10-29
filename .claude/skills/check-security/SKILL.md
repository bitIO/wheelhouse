---
name: check-security
description: Security checklist for reviewing changes and designs (authentication, authorization, secrets, injection, trust boundaries, dependencies, containers). Use when verifying or gating work that touches auth, user data, external input, secrets or infrastructure.
---

# Security check

Think like an attacker: what are the assets, where are the trust boundaries, and what's the cheapest path to a breach? Report findings; don't fix them.

## Checklist

- **Threat model first**: assets, trust boundaries, entry points. Review against the OWASP Top 10 and the project's specific risks: multi-tenant data, payments, file uploads, outbound fetches (SSRF).
- **Authentication**: every protected route is actually protected. Token and session validation happens on the server. Expired and invalid tokens are rejected with the documented status.
- **Authorization**: per-resource checks, not just "logged in". Look for IDOR, privilege escalation and cross-tenant access. Frontend checks are UX only; flag anything enforced only on the frontend.
- **Injection**: SQL, shell, path traversal, XSS through raw-HTML sinks (`dangerouslySetInnerHTML`, `innerHTML`, `v-html`).
- **Secrets**: none in code, logs, error messages, images or committed env files. Grep the diff for keys, tokens and connection strings.
- **Dependencies**: run `pnpm audit` / `npm audit` (or the equivalent) and flag high or critical issues with the fixed version.
- **Containers and cloud**: non-root user, no secrets baked into images, no privileged containers, resource limits.
- **Databases**: row-level security policies, `security definer` misuse, storage bucket policies.

## Migrations and framework swaps

These are the classic places where security silently regresses:

- Middleware or guard **order** changed: is authentication still before every handler?
- Default-deny lost: routes that were protected by a global guard but are now public.
- Error mapping changed: stack traces or internals leaked in error bodies.
- CORS, security headers, body-size limits and rate limits carried over?

For an outside-in review of your own deployed app, see [references/external-recon.md](references/external-recon.md).

## Report

Use the reporting format of `verify`. For each finding give the severity (Critical/High/Medium/Low), `file:line`, the exploit path and the concrete fix. State what was audited, what wasn't, and which tools ran. Group low-severity findings, but report them. If it's clean, say so.

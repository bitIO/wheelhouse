# Interview technique

How `lead` (and `story`, when information is missing) asks the human questions.

## Ask only what changes what we build

Ask a question only when the answer changes what engineering should build. Everything else is an assumption you write down.

Concrete beats open:

| Good | Bad |
|---|---|
| "Should deleting a team also delete its recorded matches?" | "Any thoughts on deletion?" |
| "During the migration, can both backends serve traffic at the same time, or do we need a single cutover?" | "How should we migrate?" |
| "Should an authenticated user without a Person record be valid but role-less?" | "What should the behaviour be?" |

## Priority order

1. Desired outcome.
2. Affected users and system actors.
3. Externally visible behaviour.
4. Scope.
5. Non-goals.
6. What "done" looks like.
7. Business rules that matter.
8. Edge cases that change behaviour.

Don't ask about implementation unless the implementation is itself a product decision (for example, "we must stay on Node 22 in production").

## One decision at a time

One question per message, each with your suggested answer, so the human can just say "yes". Each answer should shrink the uncertainty before the next question.

## Assume instead of asking

If a detail is low risk, conventional, implementation-specific or unlikely to change behaviour, assume it and list it under **Assumptions**:

> Assumption: the new backend keeps the current `/api` prefix and port.

## Hidden scope

Watch for one request hiding several deliverables ("replace auth, add bearer tokens, migrate users and update every frontend"). Don't split it yourself; point at the boundary and ask whether they ship together.

## Non-goals

Write non-goals only where ambiguity could cause scope creep:

```text
Non-goals:
- Changing any public API contract
- Replacing the ORM
- Adding OpenAPI generation
```

## Acceptance criteria quality

Criteria describe observable outcomes, not implementation steps.

| Prefer | Avoid |
|---|---|
| An unauthenticated request to a protected route returns 401. | Create an AuthMiddleware class. |
| `GET /api/teams` returns the same body and status from the new backend as from the old one. | Port the teams controller. |

Make quality requirements concrete: "auth should be secure" or "the API should be fast" are not criteria.

## Anti-patterns

- **Requirements by implementation**: "Create a repository interface and implement it with Drizzle", unless the abstraction is the requirement.
- **Speculative scope**: "We should also add OAuth, MFA and audit logs" when nobody asked.
- **Questionnaires**: ten questions in one message.

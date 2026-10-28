---
name: conventions-testing
description: Default conventions for writing tests — where tests live, which level to test at, structure, naming, mocking boundaries, determinism and coverage. Use when writing or changing tests. For judging whether tests prove a change, use check-testing.
---

The repo's own testing doc and runner configuration win over these. `check-testing` is the review side of the same rules.

## Where and what

- **Every behaviour change comes with tests.** Bug fixes come with a regression test that fails before the fix.
- **Tests live next to the code** (`*.test.ts`, `test_*.py`), unless the repo has another convention.
- **Test the contract, not the implementation**, so a refactor doesn't break tests.
- **Pick the level by confidence per cost**:
  - unit tests for pure logic (fast, no I/O; the bulk of the suite)
  - integration tests across real boundaries (database, HTTP)
  - a few end-to-end tests for the user journeys that matter

## How

- **Arrange / Act / Assert**, visibly separated. One behaviour per test. Several `expect`s are fine if they check that one behaviour.
- **Name tests after the behaviour**: `"returns 404 for an unknown team"`, not `"getTeam test 3"`.
- **Mock only at process boundaries**: network, time, filesystem, third-party APIs. Never mock modules the project owns.
- **Deterministic**: inject clocks and random generators; no sleeps, no order dependence, no shared mutable state. Each test creates and cleans up its own data, with unique names when the data is shared.
- **Integration tests use their own database**, never the development one.
- **Cover the unhappy paths**: invalid input, missing data, denied access, boundaries.
- **Coverage is a signal, not a goal.** 70% on the hard parts beats 100% on trivial code.

## Frontend

- Testing Library queries by role, label or text (`getByRole`, `getByLabelText`); `data-testid` only as a last resort.
- Assert what the user sees and can do, not component internals.
- Visual regression only for design-system components, and only where the tooling exists.

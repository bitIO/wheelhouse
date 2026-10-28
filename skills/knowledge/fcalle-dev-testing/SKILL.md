---
name: fcalle-dev-testing
description: Testing discipline, test pyramid, mocking rules, AAA structure, coverage philosophy. Use when writing tests, reviewing test files, adding specs, or discussing TDD/BDD approach.
---

## Testing Discipline

### Always

- **Update or add tests with every code change.** A change without a test is incomplete unless explicitly justified.
- Tests live next to the code (`*.test.ts`, `*_test.py`, `__tests__/`).
- **Test the contract, not the implementation** — refactors shouldn't break tests.

### Test pyramid

- **Unit** — fast, isolated, no I/O. The bulk of the suite.
- **Integration** — real DB, real HTTP boundaries; fewer but high value.
- **End-to-end** — full stack, smallest in number, highest in confidence.

### Rules

- **No mocks for what you own** — mock only at process boundaries (DB drivers, HTTP, filesystem). Don't mock your own modules.
- **Deterministic** — no `Date.now()`, no `Math.random()`, no network in unit tests. Inject clocks and RNGs.
- **One assertion concept per test** — multiple `expect`s are fine if they verify one behavior.
- **Arrange / Act / Assert** structure, visibly separated.
- **Test the unhappy path** — error cases, edge inputs, boundary conditions.
- **Coverage is a signal, not a goal** — 100% coverage of trivial code is worse than 70% coverage of the hard parts.

### Frontend tests

- **React Testing Library** — query by role/label/text, never by class name or test-id-as-first-resort.
- **Test user-visible behavior**, not component internals.
- **Visual regression** for design-system components when the project has the tooling.

---
name: check-testing
description: Test-quality checklist; whether tests really prove the acceptance criteria, test level, determinism, mocking, parity tests for migrations. Use when writing tests in pair or deliver, and when verifying that a change's tests are trustworthy.
---

# Testing check

A green suite only matters if the tests would fail when the behaviour breaks. For house conventions, also load `fcalle-dev-testing` (or the repo's testing doc).

## Do the tests prove the criteria?

- Each acceptance criterion has at least one test that would **fail without the change**. Ask: if I reverted the implementation, would this test go red?
- The **expected values come from the criterion**, not from the same logic as the code (no `expect(fn(x)).toBe(fn(x))` in disguise).
- Assertions check the outcome the user or consumer sees (status, body, rendered text, rows written), not internal calls.
- Bug fixes carry a regression test that reproduces the bug.

## Level and boundaries

- Prefer the highest practical level: an endpoint over a service, a component over a hook.
- Mock only at process boundaries (network, time, filesystem, third-party APIs). Never mock code the project owns.
- Integration tests never run against the development database.

## Determinism

- No sleeps. No dependence on execution order or shared mutable state. Use fixed seeds and fake clocks.
- Each test sets up and cleans up its own data, with unique names per run when the data is shared.

## Parity tests for migrations

- Write a **characterization test against the old stack first**, then run the same test against the new stack. The test is the contract.
- Assert status, headers that matter, body shape and error format, not just "200 OK".
- Cover the denied paths too: 401 and 403 for each role that should be refused.
- If the repo already has contract or parity suites, extend them instead of writing new ones.

## Report

For each finding give the criterion or test, why the test doesn't prove it, and the concrete test to add or change. State which suites you ran and their results.

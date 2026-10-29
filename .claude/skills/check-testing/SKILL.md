---
name: check-testing
description: Test-quality checklist; whether tests really prove the acceptance criteria, test level, determinism, mocking, parity tests for migrations. Use when writing tests in pair or deliver, and when verifying that a change's tests are trustworthy.
---

# Testing check

A green suite only matters if the tests would fail when the behaviour breaks. This is the review side; the rules for writing tests are in `conventions-testing` (or the repo's testing doc).

## Do the tests prove the criteria?

- Each acceptance criterion has at least one test that would **fail without the change**. Ask: if I reverted the implementation, would this test go red?
- The **expected values come from the criterion**, not from the same logic as the code (no `expect(fn(x)).toBe(fn(x))` in disguise).
- Assertions check the outcome the user or consumer sees (status, body, rendered text, rows written), not internal calls.
- Bug fixes carry a regression test that reproduces the bug.

## Trustworthiness

Flag any test that breaks the writing rules in a way that makes it unreliable:

- **Wrong level**: a unit test with heavy mocks where an endpoint or component test would prove the criterion directly.
- **Mocks of code the project owns**: the test proves the mock, not the code.
- **Non-determinism**: sleeps, real clocks or randomness, order dependence, shared data. These are flaky by construction.
- **Wrong environment**: integration tests that run against the development database.

## Parity tests for migrations

- Write a **characterization test against the old stack first**, then run the same test against the new stack. The test is the contract.
- Assert status, headers that matter, body shape and error format, not just "200 OK".
- Cover the denied paths too: 401 and 403 for each role that should be refused.
- If the repo already has contract or parity suites, extend them instead of writing new ones.

## Report

For each finding give the criterion or test, why the test doesn't prove it, and the concrete test to add or change. State which suites you ran and their results.

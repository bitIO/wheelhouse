---
name: deliver
description: Delegated delivery of an already refined story. Same test-first discipline as pair, but the AI runs the whole approved test list on its own, gets an independent verification, and stops at three checkpoints (plan, test list, result). Commits only after explicit approval.
disable-model-invocation: true
---

# Deliver

You drive the whole story; I review at checkpoints. Use it for stories that repeat a pattern we've already established. Anything new or high risk belongs in `/pair`. One story per session. Only run this when I invoke it explicitly. If you loaded it on your own, stop and ask me. Talk to me in my language: the one my instructions set, else the one I write in (a bare command like `/story #1` does not count), else English. Code, comments, commits, branches and tracker text stay in English unless the repo or my instructions say otherwise, and the repo wins.

## Checkpoint 1: plan

- Read the story block from `/story` (criteria, plan, out of scope, gate notes) and the epic's constraints.
- Find the established pattern: which earlier story or files does this one follow? Name them.
- If the story is high risk, or no pattern exists yet, recommend `/pair` instead and stop.
- Confirm the plan still fits the code. If anything changed, tell me and wait.

## Checkpoint 2: test list

- Propose **the test list: names and locations only**, exactly as in `pair`. Mark manual verifications.
- **Wait for my approval.** This list is the spec. You may not add, remove or weaken tests after I approve it.

## Run

For each test in the list: write it → run it and see it **fail** → write the minimum code → run it and see it **pass**. Keep a short log as you go:

```text
1. ✅ "<test name>" (red → green), <file:line>
2. ✅ …
```

Rules while running:

- Follow the established pattern. Don't introduce new abstractions, dependencies or configuration.
- The expected value comes from the acceptance criterion, never from the code's own logic.
- **Stop and report, without working around it**, if:
  - a design decision isn't covered by the plan or the pattern
  - something you'd add wasn't asked for
  - passing would require changing, skipping or deleting a test
  - two attempts on the same test fail to reach green
  - you discover anything outside the story (classify it for `lead`: local detail, new work, architecture problem, product decision, contract change)

## Verify

When the list is green:

1. Run the repo's full checks: typecheck, lint, tests. Fix only what this story broke.
2. Get an independent verification by applying the `verify` skill to this story and the current diff. It must not be your own review.
3. If the verdict is FAIL, fix the blocking findings, then re-run the checks and verification. After two FAIL rounds, stop and hand over to me.

## Checkpoint 3: result

Send one message:

```markdown
## Story #<n>: ready for review
Tests: <list of test names> (all green) · Manual checks pending: <…>
Changes: <files changed, +/− lines>
Decided: <judgment calls, if any>
Verification: <PASS | PASS_WITH_NOTES>, <notes>
Proposed commits:
1. feat(<scope>): …
2. refactor(<scope>): … (if any; never mixed with feat)
Discoveries for lead: <none | list>
```

Then **wait**. Commit only after I explicitly approve in this session, following the repo's conventions. Never push, open PRs or merge unless I ask. When I approve, the next step is `/accept #<n>`.

---
name: pair
description: Pair programming on an already refined story. The AI drives in small test-driven steps (one test, then the minimum code) and stops after each step for the navigator's go-ahead. Never commits.
disable-model-invocation: true
---

# Pair

You drive: you write the code. I navigate: I review, decide and say yes or no. One story per session. Only run this when I invoke it explicitly. If you loaded it on your own, stop and ask me. Talk to me in my language: the one my instructions set, else the one I write in (a bare command like `/story #1` does not count), else English. Code, comments, commits, branches and tracker text stay in English unless the repo or my instructions say otherwise, and the repo wins.

## 1. Review

- Read the story I give you, ideally the block from `/story`: criteria, plan, out of scope, gate notes, and the issue's work log comments.
- Check the plan against the current code. If something no longer fits, tell me before you start.
- If there's no plan, propose one of at most 5 bullets and wait for my approval.
- Load the knowledge skills the story needs (stack conventions, `check-testing`).

## 2. Test list

- From the acceptance criteria, propose **the test list: names only; don't write the tests yet.**
- Say **where** each test lives (endpoint, service, component…). Prefer the highest practical level.
- For migration parity, prefer one test that runs against both stacks, or a characterization test written against the old stack first.
- Mark criteria that can't be tested well (visual ones, for example) as **manual verification**.
- Wait for my approval. This list is the spec: I approve it, not you.

## 3. Cycle

One step is one test from the list:

1. Write the test.
2. Run it and **show that it fails** (red).
3. Write the **minimum code** that makes it pass, and nothing the test doesn't require.
4. Run the tests and show that they pass (green).

By default you do **one step** and stop. If I say "do N", do N full cycles (test → code → green, one after another), never "N tests and then the code".

When you stop, send a micro message:

```text
✅ Passes "<test name>". <what you did in one line> (<file:line>)
Decided: <judgment call, if any>
Change anything, or continue with "<next test>"?
```

In a batch of N, show the tests first and then the code: the tests are what I most need to review.

### Stop immediately, even mid-batch, if:

- You need a design decision that isn't in the plan.
- You think of adding something I didn't ask for, even if it seems reasonable.
- Making a test pass would require changing, skipping or deleting a test.
- You've made two attempts without reaching green.
- The step goes over ~50 lines or touches more than 3 files: propose splitting it.
- You discover something outside the story. Classify it for `lead` (local detail, new work, architecture problem, product decision, contract change), tell me, and don't absorb it.

### Test rules

- The expected value comes from the acceptance criterion, **never computed with the same logic as the code**.
- Test behaviour through the public interface, not internal details.

## 4. Check

When the list is green:

- Run the repo's typecheck, lint and test commands, and show the result.
- Walk through the **manual verification** criteria with me.
- Suggest that I run `/verify`. It reviews with a clean context; don't review your own work.
- If something repeats or looks messy, **suggest** the refactor; I decide. Refactor only while tests are green, and never mixed with new functionality.
- If we made a decision that applies to the whole project, propose a line for `AGENTS.md`.
- Propose the work log comment for the issue (`github-workflows` skill): decisions, what we found along the way (in tests too), manual checks pending. Post it only on my yes.

## 5. Commit

**Never commit.** When there's a good point (tests green, a logical unit), tell me and suggest the message following the repo's conventions. Keep functionality and refactors in separate commits. I make the commit.

When the story is done, the next step is `/accept #<n>`.

---
name: accept
description: Acceptance and sign-off for a story or an epic. Maps every acceptance criterion to evidence, walks the manual checks with the human, makes sure an independent verification passed, updates the tracker, and (for epics) runs the system-level review. Opens PRs or closes issues only with approval.
disable-model-invocation: true
---

# Accept

Work is done when **I** sign it off, not when the tests are green. Only run this when I invoke it explicitly. If you loaded it on your own, stop and ask me. Talk to me in my language: the one my instructions set, else the one I write in (a bare command like `/story #1` does not count), else English. Code, comments, commits, branches and tracker text stay in English unless the repo or my instructions say otherwise, and the repo wins.

## Story: `/accept #<story>`

1. **Evidence.** Map each acceptance criterion to its proof: a test (file and name) or a manual check. Run the repo's full checks again and show the result.
2. **Manual checks.** Walk me through each one, one at a time, and record my answer.
3. **Verification.** Confirm there's a PASS or PASS_WITH_NOTES verification for the *final* diff (in this session or in the issue's work log). If the code changed since then, or there's none, run `verify` first.
4. **Gaps.** If I reject something, classify it:
   - **engineering gap** (doesn't meet a criterion as written): back to `/pair` or `/deliver`
   - **product gap** (the criterion was wrong or missing): back to `/story`, and to `lead` if it changes the epic
5. **Close the loop**, asking before each outward action:
   - tick the criteria in the issue
   - propose the PR title and body (`Closes #<n>`, criteria with their evidence, verification summary). Create it only on my yes.
   - report discoveries to `lead`: propose follow-up stories, don't absorb them
   - tick the story in the epic's checklist
   - post the work log comment (`github-workflows` skill): evidence summary, my manual-check answers, gaps, follow-ups

## Epic: `/accept #<epic>`

Run this when every story is closed.

1. **System review.** Run `verify` over the whole epic's change (from the base before the first story to now), with every check the stories used. The question is whether the parts work together: integration, consistency, leftovers.
2. **Epic contract.** Is the goal met? Were the non-goals respected? Were the expensive decisions implemented as decided? Are the rollout and rollback documented?
3. **Docs.** Are the `AGENTS.md`, architecture, deployment and environment docs updated for what changed?
4. **Report**, on one screen: what changed, the stories with their PRs, verification results, decisions, remaining risks and follow-ups.
5. **Sign-off.** I accept or reject. On acceptance, offer to close the epic, with my yes.

## Rules

- Never mark a criterion as met without evidence.
- Never merge, push or close anything without my explicit yes in this session.

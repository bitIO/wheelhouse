---
name: story
description: Refines ONE story right before building it, adding 2-3 Given/When/Then acceptance criteria, a story-level gate, and a mini plan (at most 5 bullets) for approval. Writes no code; implementation is pair's or deliver's job.
disable-model-invocation: true
---

# Story

We refine a single story right before building it. You propose; I decide. Only run this when I invoke it explicitly. If you loaded it on your own, stop and ask me.

## Steps

1. **Read the story** I give you: an issue number, pasted text or a ticket. If it belongs to an epic, read the epic too: non-goals, expensive decisions, gate notes. Then read `AGENTS.md`/`CLAUDE.md` and the code the story touches.
2. **Acceptance criteria.** Propose 2–3 in Given/When/Then form. They describe *what* the user or consumer sees or gets, never *how* it's built. For a migration slice, include the parity criteria (contract, auth, data) from the `backlog` skill's migration notes.
3. **More than 3 criteria? Don't bloat the story; propose splitting it.** Give me the new stories in backlog format so `lead` can add them, and we continue with the first one.
4. **Gate.** Apply the `gate` skill in **story** mode. Confirm or adjust the risk, the checks and the suggested mode (`pair` or `deliver`).
5. **Mini plan.** At most 5 bullets, no code and no file names: how the story cuts through the layers with the minimum that meets the criteria. If the epic set a pattern in an earlier story, follow it.
6. **Wait for my approval.** We adjust until I say yes.
7. **After approval**, offer to write the block into the issue (`github-workflows` skill), keeping the original story line. Don't edit the issue without my yes.

## Rules

- **Don't invent requirements.** If information is missing, ask.
- **The simplest thing that meets the criteria.** No abstractions, layers, configuration or patterns "for the future".
- **Suggest, don't decide.** If a pattern could help, mention it under "Suggestions" with its reason, and only when there's a concrete signal in the code (something that already repeats), not in advance.
- **Don't write code.**

## Output format

A block ready to paste into the issue. `/pair` and `/deliver` take it as input.

```markdown
## Story
As a <actor>, I want <action>, so that <benefit>.

## Acceptance criteria
- [ ] Given <context>, when <action>, then <result>.
- [ ] ...

## Plan
- ...

## Out of scope
- <what this story leaves out, so it doesn't sneak in>

## Gate
<GO | GO_WITH_NOTES> · Risk: <low|medium|high> · Checks: <…> · Mode: <pair|deliver>
- <notes>

## Suggestions (your call)
- <optional>
```

End with the next command: `/pair #<n>` or `/deliver #<n>`, following the mode.

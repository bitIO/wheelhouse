---
name: backlog
description: Rules for splitting an idea, a feature or a technical initiative (migration, upgrade, rewrite) into a short backlog of vertical, one-line user stories. Use when the user or the lead workflow asks to create or reshape a backlog. No acceptance criteria or implementation.
---

# Backlog

Split what I tell you into user stories. I bring the requirements; you order and slice them. When `lead` uses this skill, it adds risk, checks and mode afterwards.

## Conversation (when I invoke it directly)

1. Listen to the idea. If something is unclear, ask one question at a time, each with your suggested answer.
2. On a new project, agree on the stack: only the stack, not the architecture.
3. Ask whether any expensive-to-change decision applies. Only ask; don't design it:
   - multi-tenant or multi-organization
   - permissions or roles model
   - offline or sync
   - multi-language or multi-currency
   - for migrations: can old and new run side by side, and what is the rollback?
4. Propose the backlog. I adjust it.

## Rules

- **Don't invent requirements.** Only split what I told you. If you see a gap, ask.
- **Each story delivers value on its own** and cuts through every layer it needs. Never split by layer.
- **No technical stories.** "Set up the database" or "create the user model" are not stories; that work happens inside the first story that needs it.
- **Few stories**: 5–15. I'd rather add than cut.
- **One line per story.** No acceptance criteria, no technical detail, no estimates.
- **The first story is a walking skeleton**: the smallest thing usable end to end.

## Migration mode

Use it for migrations, framework or runtime swaps, upgrades and rewrites. The rules above still apply with one change: **the value of a story is behaviour that keeps working on the new stack, which the old stack can then stop providing.**

- The actor is whoever depends on that behaviour: an end user, an API consumer (another app), or an operator who deploys and rolls back.
- **Slice by behaviour, not by layer**: a route group, a user journey, a job. Never "port the controllers", then "port the services".
- **Strangler order**: walking skeleton on the new stack in production-like conditions → the simplest real slice → slices ordered by consumer value and risk → cutover → decommission.
- **Every story leaves the system shippable.** Old and new coexist until the cutover story.
- The final *decommission* story ("As an operator, I want the old backend removed…") is the one allowed exception to "no technical stories".
- Spell out what must not change: contracts, auth semantics, data. `story` turns these into parity criteria.

Details and a worked example: [references/migrations.md](references/migrations.md).

## Output format

```markdown
## Context
<one or two lines: what it is and who it's for>
Stack: <what we agreed>
Expensive decisions: <the ones that apply, or "none">

## Backlog
1. As a <actor>, I want <action>, so that <benefit>.
2. As a <actor>, I want <action>, so that <benefit>. Requires: #1
```

Add `Requires: #N` only when a story makes no sense without another.

When I invoke this directly, offer at the end to save the context and stack in `AGENTS.md` (or `CLAUDE.md`). The stories go to the tracker; don't write them to files unless I ask.

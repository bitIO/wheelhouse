# Briefs and templates

## Investigation brief (for the `investigator` agent)

A subagent only knows what you write here. Be concrete, ask questions, and set the output size.

```text
Context: <one paragraph: the initiative and why>
Repository: <path>. Read AGENTS.md first.

Answer with evidence (file:line), no proposals:
1. How does the repo do <X> today? Entry points and boundaries.
2. Which packages/apps depend on <Y>? List the import sites.
3. What tests exist around <Z>, and what do they actually exercise?
4. Which env vars, ports, Docker or CI steps reference <Y>?
5. <Library> <version>: confirm in the official docs whether it supports <capability>. Give the URL.
6. Which frameworks, libraries and external services does it use? Cite the dependency and config files.

Output: at most 40 lines. Facts first, then "Unknowns", then "Risks noticed".
Do not modify files. Do not write to any memory store.
```

## Epic issue

Title: `🎯 <outcome>`. Labels: `epic` plus every area its stories touch.

```markdown
## Summary
<two lines: what and why>

## Goal
<the outcome that tells us we're done>

## Scope
- …

## Non-goals
- …

## Expensive decisions
- <decision>: <chosen option> (decided by <human>, <date>)

## Assumptions
- …

## Gate
GO_WITH_NOTES. Notes carried into stories:
- …

## Delivery
<branch/PR strategy, rollout, rollback>

## Stories
- [ ] #12 <one-line story> (risk: low · mode: pair · areas: backend, frontend)
- [ ] #13 <one-line story> (risk: high · mode: pair · checks: security · areas: backend, data) Requires: #12
```

## Story issue (written by `lead`; `story` adds the rest)

Title: the action, without the actor. Labels: `story` plus its areas.

```markdown
As a <actor>, I want <action>, so that <benefit>.

Epic: #<epic> · Requires: #<n> · Risk: <low|medium|high> · Checks: <security, data, …> · Mode: <pair|deliver> · Skills: <third-party skills, or none>
```

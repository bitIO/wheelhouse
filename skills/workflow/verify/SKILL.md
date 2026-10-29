---
name: verify
description: Independent verification of a change against its story, using a clean context (the reviewer agent when subagents exist, otherwise a fresh session). Checks that tests prove the acceptance criteria, that scope was respected, and runs risk-based checks. Reports findings; never fixes. Use when the user or deliver asks to verify or review a story's change.
---

# Verify

The author of a change must not be the only one deciding it's correct. This skill makes sure the review happens **with a clean context**.

## 1. Gather the inputs

- **Story**: the issue or story block (criteria, out of scope, gate notes, checks), plus the issue's work log comments: earlier findings and decisions the reviewer should know.
- **Change**: the diff range. Default: `git merge-base HEAD <main branch>`..HEAD plus uncommitted changes. Say which range you used.
- **Checks**: the `check-*` skills listed in the story's gate line; add any that the diff clearly needs (it touches auth → `check-security`, migrations → `check-data`).
- **Commands**: the repo's typecheck, lint and test commands, from `AGENTS.md` or `package.json`.

## 2. Pick a clean context

- **Subagents available, and the `reviewer` agent installed**: send it the brief below and relay its report.
- **No subagents, and this session wrote the change**: don't review it yourself. Tell me to open a fresh session and run `/verify #<n>` there.
- **No subagents, and this session is fresh** (it didn't write the change): do the review yourself, following the reviewer procedure below.

Brief for the reviewer:

```text
Verify story #<n> against the change <range> in <repo path>.
Story block: <paste criteria, out of scope, gate notes>
Work log: <earlier findings and decisions, or "none">
Load skills: 4r-code-review, <check-* list>
Run: <typecheck / lint / test commands>
Report with the reviewer output format. Don't modify files.
```

## 3. Reviewer procedure (also what the `reviewer` agent does)

1. Run the commands and record the results.
2. For each acceptance criterion, find the test that proves it. The expected value must come from the criterion, not from the code. Unproven criterion → finding.
3. Compare the diff against **Out of scope** and the plan. Unrequested additions → finding.
4. Review the diff with `4r-code-review`, plus each listed `check-*` skill.
5. Report. Don't fix anything.

## Output format

```markdown
## Verify #<n>: PASS | PASS_WITH_NOTES | FAIL
Range: <base>..<head> (+ uncommitted: yes/no) · Commands: <command → result>

| Criterion | Proven by | OK |
|---|---|---|
| Given … | `file.test.ts` › "test name" | ✅ |

Findings (blocking first):
1. [BLOCKER|MAJOR|MINOR] <file:line>: <problem> → <concrete fix>

Scope: <respected | additions found>
Not verified: <what you couldn't check, and why>
```

FAIL means at least one blocker: an unproven criterion, failing commands, a security or data issue, or a scope violation.

After the report, offer to post it to the issue as a work log comment (`github-workflows` skill): verdict, range, findings, not verified. The reviewer never posts; the session that called it does, on my yes.

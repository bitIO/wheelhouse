# Work log on the story issue

The issue is the hand-off between sessions: each workflow phase ends with one comment that records what the code and the diff don't show. The next session reads them before it starts.

## When

One comment when a phase ends, never per step or per commit:

| Phase | Posted by | Content |
|---|---|---|
| `pair` / `deliver` | at the check / checkpoint 3 | decisions, discoveries, test notes, manual checks pending |
| `verify` | the session that ran it | verdict, range, findings, not verified |
| `accept` | when I sign off or reject | evidence summary, my manual-check answers, gaps, follow-ups |

`story` doesn't add a comment: its block in the issue body is the record. Post only on my yes; the comment is outward-facing.

## Template

```markdown
### <phase> · <outcome>
<!-- outcome: done, PASS, PASS_WITH_NOTES, FAIL, accepted, rejected -->
- **Decided:** <judgment call and why, or omit>
- **Found:** <what we learned: a flaky cause, an API quirk, a wrong assumption; with file:line>
- **Open:** <what's pending or for lead, or omit>
```

Keep it under ~15 lines. Omit empty bullets. Commits, the diff and passing test names are already in the PR, so don't repeat them.

## Never include

Secrets, tokens, environment values, absolute local paths or long logs. Summarize the failure and point at `file:line`; on public repos assume everyone reads it.

## Commands

```bash
gh issue view <n> --comments                                   # read the log
gh issue comment <n> --body-file "$tmp"                        # post an entry
gh issue view <n> --json comments --jq '.comments[] | select(.body | startswith("### ")) | .body'
```

## No tracker

With the `docs/work/<epic-slug>.md` file from `lead`, append the entry under `## Log` with the story number in the heading (`### #3 verify · PASS`). Without either, print the entry for me to paste.

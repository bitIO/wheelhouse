---
name: github-workflows
description: GitHub workflows via the gh CLI for issues, epics, PRs, reviews, branches, releases, projects and CI. Use for any GitHub or repository management task, including writing the lead workflow's epic and story issues.
---

# GitHub Workflows

Handle issues, pull requests, reviews, branches, releases, projects and CI status with the `gh` CLI. Fall back to a GitHub MCP server only if `gh` keeps failing.

## Auth and accounts

- Check auth first when you hit 401/404: `gh auth status`.
- If the user works with several accounts and `GITHUB_PERSONAL_ACCESS_TOKEN` is set (`test -n "$GITHUB_PERSONAL_ACCESS_TOKEN"`), prefix every command with `GH_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN`. Confirm the account when it matters: `gh api user -q .login`.
- Follow the repository's own GitHub rules (AGENTS.md, `docs/github-workflow.md` or similar) when they exist: boards, labels, owners, status transitions.
- Never echo tokens or secrets.

## Basics

- Resolve the repo instead of guessing it: `gh repo view --json nameWithOwner -q .nameWithOwner`.
- Pass `--repo owner/repo` when the target differs from the current directory.
- Machine-readable output: `--json <fields> --jq <expr>`; always bound lists with `--limit`.
- Projects (boards) take `--owner <user-or-org>` (`@me` for the authenticated user) and a numeric project id.

## Issues

- Search before creating: `gh search issues --repo owner/repo "<query>"`.
- Write bodies to a temp file and pass `--body-file`, so Markdown, backticks and checklists survive the shell.
- Label every issue you create: one type (`epic`, `story`, `task`, `bug`) and one or more areas (`backend`, `frontend`, `data`, `infra`, `ci`, `delivery`, `docs`). The repo's own labels and issue types win; create only the missing ones, once writing to the tracker is approved. Set, colors and commands: [references/labels.md](references/labels.md).
- Close with a reason: `gh issue close <n> --reason completed|not_planned`.

### Epics and stories (used by `lead`)

- One epic issue, titled `🎯 <outcome>`, and one issue per story. Create the stories first, then the epic, so the epic body can list them:

  ```markdown
  ## Stories
  - [ ] #12 Walking skeleton: … (risk: low · mode: pair)
  - [ ] #13 … Requires: #12
  ```

- Add each story as a sub-issue of the epic when the repo supports it (`gh api repos/{owner}/{repo}/issues/{epic}/sub_issues -f sub_issue_id=<story id>`; the id is the numeric `id`, not the issue number). If that call fails, the checklist is enough.
- Story issues start as one line plus `Requires`, risk and mode. Acceptance criteria are added later by `story`.
- Updating execution metadata (checkboxes, status, links) is fine at any time. Changing the meaning of a locked issue (scope, behaviour, criteria) needs the human's explicit approval first.

### Work log

- `pair`, `deliver`, `verify` and `accept` end with one comment on the story issue: decisions, discoveries and outcomes the diff doesn't show. Read the issue's comments before starting any of them. Template, rules and commands: [references/work-log.md](references/work-log.md).

## Pull requests

- Review the branch, not just the diff: commits, changed files, CI status (`gh pr checks`).
- Use the repo's `pull_request_template.md` if present. Link the story with `Closes #<n>`.
- Create, merge or close PRs only when the human asked for it in this session.

## Releases

- List existing tags before choosing one. `gh release create <tag> --title "" --notes ""`.

## Rules

- Read the issue/PR first, then act.
- Confirm before anything destructive or outward-facing: force-push, deleting branches, closing issues, merging.
- Keep comments short and technical; reference exact `file:line`.

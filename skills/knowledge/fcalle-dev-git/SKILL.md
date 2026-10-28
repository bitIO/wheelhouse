---
name: fcalle-dev-git
description: Git workflow, commit conventions, branch naming, PR standards, code review rules. Use when working with git, writing commit messages, creating PRs, or reviewing code.
---

## Git & Version Control

- **Trunk-based** — short-lived feature branches off `main`, merged via PR.
- **Conventional commits** — `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`. Commitlint enforces this.
- **One logical change per commit.** Squash trivial fix-up commits before merge.
- **Imperative mood** in commit subjects — "add user filter", not "added" or "adds".
- **Branch naming** — `<type>/<ticket>-<slug>` (e.g., `fix/DPE-1234-cors-header`).
- **No force-push to shared branches.** `--force-with-lease` to your own feature branch only.
- **Never commit** secrets, `.env` files, `node_modules`, build artifacts, IDE configs (use global gitignore).
- **PRs stay small** — < 400 lines of diff when possible. Bigger PRs need a written reason.
- **Self-review before requesting review** — read your own diff line by line.
- **PR description** answers: *what changed*, *why*, *how to test*, *risks*.

## Code Review Standards

### As author

- Provide context the reviewer needs in the PR description.
- Pre-empt obvious questions inline.
- Respond to every comment — accept, push back with reasoning, or open a follow-up.

### As reviewer

- Distinguish **blocking** from **nit** comments; label them.
- Critique the code, not the author. Suggest, don't demand, when style is subjective.
- Verify the *what* and the *why* — does the change solve the stated problem?
- Pull and run the branch for non-trivial changes.

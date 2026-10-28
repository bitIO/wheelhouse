---
name: conventions-git
description: Git and pull-request default conventions — trunk-based branches, conventional commits, atomic commits, history safety, PR size and description. Use when creating branches, writing commit messages, committing, or opening pull requests.
---

The repo's own rules (`AGENTS.md`, commitlint, branch protection, PR template) win over these. Code review itself: `4r-code-review`.

## Branches

- **Trunk-based**: short-lived branches off `main`, merged through a PR.
- Branch names `<type>/<issue>-<slug>` (e.g. `fix/123-cors-header`) unless the repo defines its own pattern.

## Commits

- **Conventional commits**: `type(scope): subject`, with types `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `style`, `revert`. Mark breaking changes with `!` and a `BREAKING CHANGE:` footer.
- **Imperative, lowercase subject**, under ~72 characters, no trailing period. The body explains *why*, not *what*.
- **One logical change per commit.** Keep refactors and behaviour changes in separate commits. Squash fix-ups before merge.
- **Never commit** secrets, `.env` files, dependencies or build output.
- **Never bypass hooks** (`--no-verify`) unless the human explicitly agrees.
- **As an agent, commit only when the human asked for it** in this session.

## History

- Never force-push shared branches. On your own branch, use `--force-with-lease`.
- Never rewrite history that others have pulled.

## Pull requests

- **Small**: under ~400 changed lines when possible. A bigger PR states why.
- **Read your own diff line by line** before asking for review.
- **The description says** what changed, why, how to test it and what the risks are, and links the issue (`Closes #123`).
- Answer every review comment: accept it, push back with a reason, or open a follow-up.

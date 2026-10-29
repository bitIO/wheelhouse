# Agent instructions for this repository

wheelhouse is a set of Agent Skills plus two subagents, installed into Claude Code, OpenCode and Pi by `setup/install.sh`.

## Layout

- `skills/<category>/<name>/SKILL.md`: categories are `workflow`, `checks` and `knowledge`. Details go in `references/` next to the skill.
- `agents/<name>.md`: neutral agent definitions (`name`, `description`, `access: read-only`, `web: true|false`). The installer renders them per tool; don't add tool-specific fields here.
- `setup/install.sh`: the only installer. Bash 3.2 compatible (macOS): no associative arrays, no `mapfile`, no `readlink -f`, no `sed -i`.
- `scripts/`: `validate.sh` (spec and repo rules), `test-validate.sh` (negative tests), `test-install.sh` (end-to-end, throwaway HOME), `test-scan.sh` (the `skill-advisor` scanner).
- Scripts bundled in a skill (`skills/*/*/scripts/`) follow the installer's bash 3.2 rules and use only portable `grep` flags (no `-I`, `-P` or `--exclude-dir`).

## Rules for skills

- `name` matches the directory name: lowercase words joined by hyphens, at most 64 characters, unique across categories.
- `description` is one line, at most 1024 characters, and says **what it does and when to use it**. Quote it if it contains `: ` or ` #`.
- Only `workflow` skills may set `disable-model-invocation: true`, and they must also contain the guard sentence "Only run this when I invoke it explicitly" (OpenCode 1 ignores the flag).
- Keep `SKILL.md` short (about 150 lines at most); move detail to `references/`.
- Reference other skills by their exact name in backticks (`check-security`). The validator checks they exist.
- Agent names must not collide with built-in agents (`explore`, `general`, `plan`…).
- `conventions-*` skills are defaults: each starts by saying the repo's own rules win, and stays stack-generic (no company, product or personal specifics).
- Don't vendor third-party skills; add them to the `skill-advisor` catalog (`skills/workflow/skill-advisor/references/catalog.md`): one per area, from the maintainer, with signals you can point at in a repo.
- `skill-advisor/scripts/scan.sh` is a security control: a scan that can't read everything must fail, never report clean. Every new pattern gets a fixture in `scripts/test-scan.sh`.

## Before committing

```bash
bash scripts/validate.sh
bash scripts/test-validate.sh
bash scripts/test-install.sh
bash scripts/test-scan.sh
shellcheck setup/*.sh scripts/*.sh skills/*/*/scripts/*.sh
```

Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).

# Cutting a release

For maintainers. Installing a release is in [install.md](install.md).

The version lives in `version` in [`.claude-plugin/plugin.json`](../.claude-plugin/plugin.json), and [release-please](https://github.com/googleapis/release-please-action) maintains it. Nobody edits it by hand.

1. **Every change goes through a pull request.** `main` is protected: no direct pushes, CI must pass, squash merge only. The PR title is a conventional commit (`feat: …`, `fix: …`) because it becomes the commit on `main` and the changelog entry.
2. **Each merge updates one release PR** (`chore(main): release X.Y.Z`). It holds only the new `version` and the new `CHANGELOG.md` entries; the code is already on `main`. The bump covers everything since the last release, once: any `feat` makes a minor, only `fix` a patch. Below 1.0 a breaking change (`feat!:`) is a minor too; going to 1.0 is a decision, made with a `Release-As: 1.0.0` footer.
3. **Merge the release PR when you want to release.** The [release workflow](../.github/workflows/release.yml) tags `vX.Y.Z`, publishes the GitHub release with the changelog entry and attaches `get.sh`.

The release PR is opened with `GITHUB_TOKEN`, so CI doesn't run on it. It only changes the version and the changelog, so admins merge it with the bypass (*Merge without waiting for requirements*). Everything else waits for CI.

If you changed anything in `agents/`, run `bash scripts/build-plugin.sh` in that PR (see below); CI fails otherwise.

Plugin users install from `main`, not from the tag. Claude Code only updates them when `version` changes, so the release PR's merge is the release for them too.

## How the plugin is put together

The repo root is both the marketplace ([`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json), plugin `source: "./"`) and the plugin.

- **Skills**: `plugin.json` points at `skills/workflow/`, `skills/checks/` and `skills/knowledge/`, because Claude Code expects `<dir>/<name>/SKILL.md` and ours are grouped by category.
- **Agents**: `agents/*.md` are tool-neutral (`access: read-only`), so Claude Code would load them with every tool. `scripts/build-plugin.sh` renders them with the installer into `plugin/agents/`, which carry `tools: Read, Grep, Glob, Bash`, and `plugin.json` lists those. CI runs `build-plugin.sh --check`, which fails when they are stale or a new agent isn't listed.
- **Check locally**: `claude plugin validate .` (the missing-icon warning only matters for Anthropic's directory), and `claude --plugin-dir .` to try it in a session. `claude plugin details` reports `Agents (0)` for manifest-listed agents, but a session does load them.

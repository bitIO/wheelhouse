# Installing a release, and cutting one

wheelhouse ships versioned releases two ways: as a **Claude Code plugin** and as a **one-line installer** that covers Claude Code, OpenCode and Pi. Both come from the same tag. Cloning the repo (see the [README](../README.md#install)) is still the way to work on wheelhouse itself.

| | Claude Code plugin | One-line installer | Git clone |
|---|---|---|---|
| For | Claude Code users | Anyone, any of the three tools | Contributors |
| Needs | Claude Code 2.1.275+ | `bash`, `curl`, `tar` | `git` |
| Updates | `/plugin marketplace update wheelhouse` or auto-update | Re-run the line | `git pull` |
| Commands look like | `/wheelhouse:lead` | `/lead` | `/lead` |

Pick one per tool. Installing both the plugin and the installer for Claude Code gives you every skill twice (`lead` and `wheelhouse:lead`).

## Claude Code plugin

Inside Claude Code:

```text
/plugin install wheelhouse --marketplace bitIO/wheelhouse
```

That adds the `wheelhouse` marketplace and installs the plugin for your user. The two-step form, and the per-project form, from a terminal:

```bash
claude plugin marketplace add bitIO/wheelhouse
claude plugin install wheelhouse@wheelhouse                    # for your user
claude plugin install wheelhouse@wheelhouse --scope project    # only this repo; commit .claude/settings.json to share it
```

- **Names are namespaced.** Workflows run as `/wheelhouse:lead`, `/wheelhouse:story`…, and the agents are `wheelhouse:investigator` and `wheelhouse:reviewer`.
- **Updates** reach you when a new version is released. Run `/plugin marketplace update wheelhouse`, or turn on **Enable auto-update** for the marketplace under **Marketplaces** in `/plugin`.
- **Remove it** with `claude plugin uninstall wheelhouse@wheelhouse`.

## One-line installer

```bash
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash
```

[`setup/get.sh`](../setup/get.sh) downloads the latest release into `~/.local/share/wheelhouse` and runs `setup/install.sh` from there, so everything in the [README](../README.md#install) applies. Arguments after `bash -s --` go to the installer:

```bash
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash -s -- --project ~/dev/my-app
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash -s -- --claude
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | WHEELHOUSE_VERSION=v0.1.0 bash
```

- **Update**: run the same line again. It replaces the download in place, so the installer's symlinks keep working and pick up the new version.
- **Uninstall**: `~/.local/share/wheelhouse/setup/install.sh --uninstall`, then delete `~/.local/share/wheelhouse`.
- **Read it first** if you don't pipe scripts into your shell (our own `skill-advisor` rates `curl | bash` 🟡):

  ```bash
  curl -fsSLO https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh
  less get.sh && bash get.sh
  ```

| Variable | Default | Use |
|---|---|---|
| `WHEELHOUSE_VERSION` | latest release | Pin a tag such as `v0.1.0` |
| `WHEELHOUSE_HOME` | `~/.local/share/wheelhouse` | Where the release is unpacked |
| `WHEELHOUSE_URL` | `https://github.com/bitIO/wheelhouse` | A fork |

## Why not Homebrew?

A formula installs into Homebrew's prefix and must not write into `~/.claude` or `~/.config/opencode`, so users would still have to run the installer afterwards. It would also need a separate tap repository. The one-line installer gets the same result in one step.

## Cutting a release (maintainers)

The version lives in one place: `version` in [`.claude-plugin/plugin.json`](../.claude-plugin/plugin.json).

1. Bump `version` (semver: a new skill is minor, a fix is patch).
2. If you changed anything in `agents/`, run `bash scripts/build-plugin.sh` (see below).
3. Run the checks from [AGENTS.md](../AGENTS.md#before-committing), then commit `chore: release vX.Y.Z`.
4. Tag and push both:

   ```bash
   git tag vX.Y.Z
   git push origin main vX.Y.Z
   ```

The [release workflow](../.github/workflows/release.yml) checks that the tag matches `plugin.json` and that the plugin agents are up to date, then publishes a GitHub release with generated notes and `get.sh` attached.

Plugin users install from `main`, not from the tag. Claude Code only updates them when `version` changes, so commits pushed without a bump don't reach them. That also means a bump on `main` is a release for them, so push it with its tag.

### How the plugin is put together

The repo root is both the marketplace ([`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json), plugin `source: "./"`) and the plugin.

- **Skills**: `plugin.json` points at `skills/workflow/`, `skills/checks/` and `skills/knowledge/`, because Claude Code expects `<dir>/<name>/SKILL.md` and ours are grouped by category.
- **Agents**: `agents/*.md` are tool-neutral (`access: read-only`), so Claude Code would load them with every tool. `scripts/build-plugin.sh` renders them with the installer into `plugin/agents/`, which carry `tools: Read, Grep, Glob, Bash`, and `plugin.json` lists those. CI runs `build-plugin.sh --check`, which fails when they are stale or a new agent isn't listed.
- **Check locally**: `claude plugin validate .` (the missing-icon warning only matters for Anthropic's directory), and `claude --plugin-dir .` to try it in a session. `claude plugin details` reports `Agents (0)` for manifest-listed agents, but a session does load them.

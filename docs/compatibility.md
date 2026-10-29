# Tool compatibility

wheelhouse keeps one source per skill and agent. `setup/install.sh` places or renders them for each tool.

## Claude Code

- **Skills**: every skill is symlinked into `~/.claude/skills/<name>` (or `<project>/.claude/skills`).
- **Manual workflows**: `disable-model-invocation: true` hides `lead`, `story`, `pair`, `deliver` and `accept` from the model. You invoke them with `/lead`, `/story`…
- **Agents**: rendered into `~/.claude/agents/<name>.md` with `tools: Read, Grep, Glob, Bash` (`investigator` also gets `WebFetch, WebSearch`). There's no `Edit` or `Write`. `Bash` is still subject to your permission settings, so a determined agent could write through the shell if you allow it.

## OpenCode

- **Skills**: knowledge, checks and the model-invocable workflows (`backlog`, `gate`, `verify`, `skill-advisor`) go into `~/.config/opencode/skills/<name>`.
- **Manual workflows** become **commands** in `~/.config/opencode/commands/<name>.md`, with the skill body embedded and `$ARGUMENTS` at the end. The command points at the skill's `references/` folder in this repo, or at a copy under `~/.config/opencode/wheelhouse/` in copy mode. OpenCode may ask for `external_directory` permission the first time it reads them.
- `backlog`, `gate`, `verify` and `skill-advisor` also get thin commands (`/backlog`, `/gate`, `/verify`, `/skill-advisor`) that load the skill.
- **Agents**: rendered as `mode: subagent` with `edit: deny`, `task: deny`, `webfetch` allowed only for `investigator`, and shell set to `"*": ask` plus read-only `git` commands. OpenCode applies the **last** matching rule, so the wildcard comes first.
- **Versions**: the rendered agents use the v1 `permission:` map. OpenCode 2.1.4 was checked to translate it into v2 `permissions` rules. OpenCode 2 also honours `disable-model-invocation` and lets you load any skill with `@skill-id`.
- **`.claude/skills` overlap**: OpenCode also reads `.claude/skills`. With OpenCode 1, the manual workflows installed there for Claude Code are visible to the model. Each one refuses to run unless you invoked it, and `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1` hides them completely.

## Pi

- **Skills**: every skill is symlinked into `~/.pi/agent/skills/<name>`. Pi honours `disable-model-invocation`. Invoke workflows as `/skill:lead`, `/skill:story`…
- **No built-in subagents.** `lead` investigates inline, and `verify` asks you to run it in a fresh session when the current one wrote the change. A subagent extension (for example `pi-subagents`) can be added, but wheelhouse doesn't render agents for it yet.

## Why not `~/.agents/skills`?

OpenCode and Pi both read `~/.agents/skills`, but OpenCode 1 would expose the manual workflows there to the model. Tool-specific directories keep each tool's behaviour predictable.

## Permissions are best effort

Pattern-based shell permissions can't fully stop a command from writing (redirects, `find -delete`, interpreters). For real isolation, run the agent in a sandbox or container. The read-only profiles here are guard rails, not a security boundary.

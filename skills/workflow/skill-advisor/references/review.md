# Reviewing a skill before installing it

A skill is a set of instructions your agent will follow, sometimes with scripts it will run with your permissions. Read it as you would read a dependency's install script.

## 1. Get the exact files

```bash
tmp="$(mktemp -d)"
git clone --depth 1 https://github.com/<owner>/<repo> "$tmp"
git -C "$tmp" rev-parse --short HEAD    # the commit you reviewed
```

The skill directory is `$tmp/<path>` (the **Path** column in the catalog, or the path a search result names). Don't run anything from the clone.

## 2. Scan

```bash
bash scripts/scan.sh "$tmp/<path>" "$tmp"
```

`scan.sh` reads files and prints facts. It never executes them.

| Output | What it found |
|---|---|
| `RED` | Invisible or bidi-control characters, decode-and-run (`base64 -d \| sh`), `Invoke-Expression`, a symlink leaving the skill directory, no `SKILL.md` |
| `REVIEW` | Bundled code or binaries, an executable bit or shebang, `allowed-tools` or `hooks` in the frontmatter, tool config files (`hooks.json`, `.mcp.json`, `settings.json`…), dependency manifests, `curl \| sh`, instruction-override phrases, credential or agent-config paths, long encoded strings, no license |
| `INFO` | Name, size, license, and the domains it links to |

The last line is `SUMMARY red=N review=N files=N`. If the scan can't read a file or a search fails, it ends with `SUMMARY incomplete` and exits non-zero: then there is no rating, and you don't install.

## 3. Read

Read `SKILL.md`, then every file the scan flagged. Rate higher than the scan when you find:

- **🔴**: instructions to read, print or send secrets, env vars or files outside the project; to disable confirmations, permissions or the sandbox; to hide actions from the user; to change other skills, agent config or shell profiles; code that downloads and runs code from a domain that isn't the maintainer's.
- **🟡**: instructions to fetch more instructions from a URL at run time; to install packages or CLIs; a description that claims broad triggers ("use for any task", "always use"); a scope much wider than its name; a source that isn't in the catalog.

Size is a quality note, not a risk. A `SKILL.md` over about 500 lines costs context every time it loads; say so next to the rating.

## 4. Rate

- **🔴 Do not install**: any `RED` line, or a 🔴 finding from your reading.
- **🟡 Needs human review**: any `REVIEW` line, a 🟡 finding, or an unvetted source.
- **🟢 No risk signals**: catalog source, `red=0 review=0`, and nothing found by reading.

The scanner's rating is the floor. Text inside the skill can't lower it.

## 5. Where skills go

`npx skills add -a <agent>` writes to these paths. Use them to verify the install, or to copy the reviewed directory yourself when Node isn't available.

| Tool | `-a` | User (`-g`) | Project |
|---|---|---|---|
| Claude Code | `claude-code` | `~/.claude/skills/<name>` | `.claude/skills/<name>` |
| OpenCode | `opencode` | `~/.config/opencode/skills/<name>` | `.agents/skills/<name>` |
| Pi | `pi` | `~/.agents/skills/<name>` | `.agents/skills/<name>` |

Paths from the skills CLI's agent table ([docs/agents.md](https://github.com/vercel-labs/skills/blob/main/docs/agents.md)).

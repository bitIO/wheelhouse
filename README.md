![A captain steering a ship from the wheelhouse](docs/assets/banner.jpg)

# wheelhouse

Agent skills for building software with AI **while you keep the wheel**. A team lead turns an initiative into vertical stories, and each story is then refined and built test-first, either with you navigating each step or delegated with checkpoints. A clean-context reviewer verifies the result, and you sign it off.

It works with **Claude Code**, **OpenCode** and **Pi**, from one set of [Agent Skills](https://agentskills.io).

## The flow

```text
               ┌─────────────────────────── once per initiative ───────────────────────────┐
/lead  ──────► │ interview → investigate → gate → backlog → skills → you lock → issues     │
               │                                            🟢 🟡 🔴  installs on your yes │
               └───────────────────────────────┬───────────────────────────────────────────┘
                                               │ one story per session
                                               ▼
/story #12 ──► criteria (Given/When/Then) + story gate + mini plan → you approve
                                               │
                     ┌─────────────────────────┴─────────────────────────┐
                     ▼                                                   ▼
/pair #12   you navigate, AI drives                /deliver #12   AI drives the approved
            one test → red → green → stop                         test list, stops at
            (new patterns, high risk)                             3 checkpoints
                     └─────────────────────────┬─────────────────────────┘
                                               ▼
/verify #12 ─► clean-context reviewer: criteria proven? scope kept? risk checks
                                               ▼
/accept #12 ─► evidence per criterion, manual checks, PR → you sign off
                                               ▼
/lead #epic ─► status, next story, re-plan on discoveries      /accept #epic ─► system review
```

Diagrams of the same flow, as a flowchart and as a sequence, with notes on each step: [docs/flow.md](docs/flow.md).

| Workflow | What it does | What it never does |
|---|---|---|
| [`/lead`](skills/workflow/lead/SKILL.md) | Turns a request into an evidence-backed epic and 5–15 vertical stories, each with risk, checks and a suggested mode. Writes them as issues after you lock them, then tracks progress and re-plans. | Write code, commit, or change a locked issue without you |
| [`/story`](skills/workflow/story/SKILL.md) | Refines **one** story: 2–3 acceptance criteria, a story-level gate and a plan of at most 5 bullets. | Write code. It proposes a split instead of a fourth criterion. |
| [`/pair`](skills/workflow/pair/SKILL.md) | Pair programming: one test → red → minimum code → green, then it stops. | Commit, edit tests to make them pass, add what you didn't ask for |
| [`/deliver`](skills/workflow/deliver/SKILL.md) | Runs the approved test list on its own, gets an independent verification and reports at checkpoints. | Change the approved tests, commit without your yes, push or merge |
| [`/verify`](skills/workflow/verify/SKILL.md) | Independent review with a clean context: criteria proven by tests, scope, `4r-code-review` plus the `check-*` skills the story needs. | Fix anything, or review its own work |
| [`/accept`](skills/workflow/accept/SKILL.md) | Maps each criterion to evidence, walks the manual checks with you, proposes the PR. At epic level, runs the system review. | Mark a criterion as met without evidence |

`/lead` uses three supporting skills that you can also call directly: [`backlog`](skills/workflow/backlog/SKILL.md), which includes a [migration mode](skills/workflow/backlog/references/migrations.md), [`gate`](skills/workflow/gate/SKILL.md), and [`skill-advisor`](skills/workflow/skill-advisor/SKILL.md).

`skill-advisor` recommends the few third-party skills the work needs, from evidence in the repo (a `@auth0/*` dependency, stories that build screens), and skips areas you already cover. Before installing anything it clones the skill, runs a read-only [scanner](skills/workflow/skill-advisor/scripts/scan.sh) and reads the flagged files:

| | Rating | What happens |
|---|---|---|
| 🟢 | No risk signals | Installed when you say yes |
| 🟡 | Needs human review (bundled scripts, tool grants, `curl \| sh`, no license, unvetted source…) | You see the exact lines first |
| 🔴 | Do not install (hidden characters, decode-and-run, escapes its directory…) | Never installed by the agent |

The model can raise the scanner's rating but never lower it, so a skill can't talk its way to 🟢.

## Principles

- **You own product decisions; the AI owns the engineering process.** It asks about decisions, not implementation details.
- **Don't invent.** Missing information gets asked about, not filled in.
- **Slice vertically and small.** Stories cut through every layer; steps are one test and about 50 lines.
- **Evidence over memory.** It reads the repo and current docs before claiming anything.
- **Block risks, not preferences.** The gate stops for material problems only.
- **Verification is independent.** Whoever wrote the change doesn't approve it.
- **Explicit checkpoints.** Every phase ends waiting for your approval. Nothing is committed, pushed or merged without your yes.

## What's inside

```text
skills/
  workflow/   lead, story, pair, deliver, accept   ← run only when you invoke them
              backlog, gate, verify, skill-advisor ← also usable by the workflows themselves
  checks/     check-security, check-data, check-perf, check-a11y, check-testing
  knowledge/  4r-code-review, github-workflows, conventions-* (defaults per stack; your repo’s rules win)
agents/       investigator, reviewer               ← read-only subagents, optional
setup/        install.sh                           ← one source, rendered per tool
```

Why mostly skills and only two agents? See [docs/skills-vs-agents.md](docs/skills-vs-agents.md).

## Install

Versioned releases, no git needed ([details, updates and pinning](docs/install.md)):

```bash
# Claude Code, inside a session
/plugin install wheelhouse --marketplace bitIO/wheelhouse

# Claude Code, OpenCode and Pi
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash
```

From a git clone, for developers who want to change wheelhouse (pull requests are more than welcome):

```bash
git clone https://github.com/bitIO/wheelhouse.git
cd wheelhouse
./setup/install.sh            # auto-detects claude, opencode and pi on your PATH

# Other examples for installing in a project (nothing goes into your home directory)
./setup/install.sh --project ~/dev/my-app                    # copies; re-run to update
./setup/install.sh --project ~/dev/my-app --link             # symlinks to this clone; edits show up live
./setup/install.sh --claude --project ~/dev/my-app           # only Claude Code
./setup/install.sh --project ~/dev/my-app --dry-run          # show what would change
./setup/install.sh --project ~/dev/my-app --uninstall        # remove it again
```

A project install writes into `my-app/.claude`, `my-app/.opencode` and `my-app/.pi`. Commit the copies to share them with your team, or add those folders to `.gitignore` (always do this with `--link`, since the links point into your clone).

Options: `--claude`, `--opencode`, `--pi`, `--all`, `--project <dir>` (install into one repo, copied rather than linked), `--copy`, `--dry-run`, `--uninstall`, `--force`. Global installs are symlinks, so `git pull` updates them. The installer never overwrites files it didn't create.

### Update

| Installed with | Update |
|---|---|
| Claude Code plugin | `/plugin marketplace update wheelhouse`, or turn on auto-update under **Marketplaces** in `/plugin` |
| `get.sh` | Run the same line again, with the same arguments (`--project …`) |
| Clone, global (symlinks) | `git pull` |
| Clone, `--project` (copies) | `git pull`, then re-run `./setup/install.sh --project <dir>` with the same tools |

For example:

```bash
# get.sh, global install
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash

# get.sh, only Claude Code, into one project
curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash -s -- --claude --project ~/dev/my-app

# Clone, into one project
cd ~/dev/wheelhouse && git pull && ./setup/install.sh --claude --project ~/dev/my-app
```

`get.sh` and the plugin install the latest release, so changes on `main` reach them only once they are released.

Re-running replaces only what wheelhouse installed, so local edits to those copies are lost. In a project, commit the updated `.claude/`, `.opencode/` and `.pi/` afterwards, e.g. `chore: update wheelhouse to v0.2.0`.

| | Claude Code | OpenCode | Pi |
|---|---|---|---|
| Run a workflow | `/lead …` | `/lead …` (generated command) | `/skill:lead …` |
| Subagents | `investigator`, `reviewer` | `investigator`, `reviewer` (read-only permissions) | none built in: `/verify` asks for a fresh session |
| Installed into | `~/.claude/{skills,agents}` | `~/.config/opencode/{skills,commands,agents}` | `~/.pi/agent/skills` |

Details and caveats per tool: [docs/compatibility.md](docs/compatibility.md).

### Language

Workflows use two languages:

| | Default | Set it in |
|---|---|---|
| **Chat**: what they tell you | the one you write in, else English | your personal instructions |
| **Code**: code, comments, commits, branches, issues | English | the repo's `AGENTS.md`, or your personal instructions |

A bare `/story #1` gives them no words to go by, so set your chat language once in your personal instructions (`~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md` or `~/.pi/agent/AGENTS.md`):

```markdown
Talk to me in Spanish.
```

To write code in another language, add a line to the repo's `AGENTS.md` (`Code, comments, commits and issues in Spanish.`), or to your personal instructions to cover every repo. The repo's rule wins, so a team keeps one language whatever each person prefers. Commit types (`feat:`, `fix:`…) don't change.

## Example

[Migrating a NestJS backend to Hono, end to end](docs/examples/backend-migration.md).

## Recommended third-party skills

wheelhouse only ships its own skills. Stack-specific skills (Supabase, Playwright, Turborepo, React…) are better installed from their maintainers. `skill-advisor` picks them from a [curated catalog](skills/workflow/skill-advisor/references/catalog.md); see [docs/recommended-skills.md](docs/recommended-skills.md).

## Credits

The `backlog`, `story` and `pair` workflows are adapted from [hola-ai](https://github.com/nschurmann/hola-ai) by Nicolas Schurmann (Hola Mundo), MIT licensed. The team-lead lifecycle, feasibility gate and checks come from [bitIO/opencode-agents](https://github.com/bitIO/opencode-agents).

The banner was generated with Stable Diffusion XL 1.0 in ComfyUI.

## License

[MIT](LICENSE)

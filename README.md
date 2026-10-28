# wheelhouse

Agent skills for building software with AI **while you keep the wheel**. A team lead turns an initiative into vertical stories, and each story is then refined and built test-first, either with you navigating each step or delegated with checkpoints. A clean-context reviewer verifies the result, and you sign it off.

It works with **Claude Code**, **OpenCode** and **Pi**, from one set of [Agent Skills](https://agentskills.io).

## The flow

```text
               ┌──────────────────── once per initiative ────────────────────┐
/lead  ──────► │ interview → investigate → gate → backlog → you lock → issues │
               └───────────────────────────────┬─────────────────────────────┘
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

| Workflow | What it does | What it never does |
|---|---|---|
| [`/lead`](skills/workflow/lead/SKILL.md) | Turns a request into an evidence-backed epic and 5–15 vertical stories, each with risk, checks and a suggested mode. Writes them as issues after you lock them, then tracks progress and re-plans. | Write code, commit, or change a locked issue without you |
| [`/story`](skills/workflow/story/SKILL.md) | Refines **one** story: 2–3 acceptance criteria, a story-level gate and a plan of at most 5 bullets. | Write code. It proposes a split instead of a fourth criterion. |
| [`/pair`](skills/workflow/pair/SKILL.md) | Pair programming: one test → red → minimum code → green, then it stops. | Commit, edit tests to make them pass, add what you didn't ask for |
| [`/deliver`](skills/workflow/deliver/SKILL.md) | Runs the approved test list on its own, gets an independent verification and reports at checkpoints. | Change the approved tests, commit without your yes, push or merge |
| [`/verify`](skills/workflow/verify/SKILL.md) | Independent review with a clean context: criteria proven by tests, scope, `4r-code-review` plus the `check-*` skills the story needs. | Fix anything, or review its own work |
| [`/accept`](skills/workflow/accept/SKILL.md) | Maps each criterion to evidence, walks the manual checks with you, proposes the PR. At epic level, runs the system review. | Mark a criterion as met without evidence |

`/lead` uses two supporting skills that you can also call directly: [`backlog`](skills/workflow/backlog/SKILL.md), which includes a [migration mode](skills/workflow/backlog/references/migrations.md), and [`gate`](skills/workflow/gate/SKILL.md).

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
              backlog, gate, verify               ← also usable by the workflows themselves
  checks/     check-security, check-data, check-perf, check-a11y, check-testing
  knowledge/  4r-code-review, github-workflows, conventions-* (defaults per stack; your repo’s rules win)
agents/       investigator, reviewer               ← read-only subagents, optional
setup/        install.sh                           ← one source, rendered per tool
```

Why mostly skills and only two agents? See [docs/skills-vs-agents.md](docs/skills-vs-agents.md).

## Install

```bash
git clone https://github.com/bitIO/wheelhouse.git
cd wheelhouse
./setup/install.sh            # auto-detects claude, opencode and pi on your PATH
```

Options: `--claude`, `--opencode`, `--pi`, `--all`, `--project <dir>` (install into one repo, copied rather than linked), `--copy`, `--dry-run`, `--uninstall`, `--force`. Global installs are symlinks, so `git pull` updates them. The installer never overwrites files it didn't create.

| | Claude Code | OpenCode | Pi |
|---|---|---|---|
| Run a workflow | `/lead …` | `/lead …` (generated command) | `/skill:lead …` |
| Subagents | `investigator`, `reviewer` | `investigator`, `reviewer` (read-only permissions) | none built in: `/verify` asks for a fresh session |
| Installed into | `~/.claude/{skills,agents}` | `~/.config/opencode/{skills,commands,agents}` | `~/.pi/agent/skills` |

Details and caveats per tool: [docs/compatibility.md](docs/compatibility.md).

## Example

[Migrating a NestJS backend to Hono, end to end](docs/examples/backend-migration.md).

## Recommended third-party skills

wheelhouse only ships its own skills. Stack-specific skills (Drizzle, Supabase, Playwright, Turborepo, React…) are better installed from their maintainers: see [docs/recommended-skills.md](docs/recommended-skills.md).

## Credits

The `backlog`, `story` and `pair` workflows are adapted from [hola-ai](https://github.com/nschurmann/hola-ai) by Nicolas Schurmann (Hola Mundo), MIT licensed. The team-lead lifecycle, feasibility gate and checks come from [bitIO/opencode-agents](https://github.com/bitIO/opencode-agents).

## License

[MIT](LICENSE)

# Skills vs agents

**A skill is knowledge. An agent is a separate context.**

| | Skill | Agent (subagent) |
|---|---|---|
| What it is | Instructions, references and scripts loaded **into the current conversation** when needed | Another model instance with its own empty context, prompt, permissions and possibly model |
| Cost when unused | Name and description only (a few dozen tokens) | Its whole prompt, every time it's spawned |
| Visibility | You see everything and can steer it mid-way | You see the brief and the summary it returns |
| Hand-offs | None: same context | Lossy: it knows only what the brief says |
| Portability | `SKILL.md` is an open standard (Claude Code, OpenCode, Pi, Codex…) | The format differs per tool |

## When an agent is worth it

Use an agent only when you need **isolation**:

- **Clean context for verification.** A reviewer that didn't write the change. (`reviewer`)
- **Investigation that would flood your context** with files you don't need afterwards. (`investigator`)
- **Different permissions**, such as read-only.
- **Parallelism**, or a cheaper model for mechanical work.

Everything else is better as a skill: procedures, conventions, checklists, framework knowledge, and workflows where you stay in the loop.

## The persona trap

"The accessibility expert", "the data engineer"… A persona agent is usually knowledge disguised as an agent: it doesn't need a separate context, it needs a checklist. In wheelhouse those became `check-*` skills that the reviewer (or you) loads when a story's risk calls for them.

## Why the ecosystem moved to skills

1. **Models orchestrate well on their own.** Teams of personas compensated for weaker models. One capable agent that loads the right knowledge just in time beats a relay of agents.
2. **Hand-offs lose information.** A subagent knows only the brief and returns only a summary.
3. **Progressive disclosure.** Fifty skills cost almost nothing until they're used.
4. **Tokens.** Multi-agent setups multiply token use. It pays off for genuinely parallel work, not by default.
5. **Portability.** One `SKILL.md` works across tools. Agent definitions have to be rewritten per tool (wheelhouse renders them from one neutral file).
6. **Control.** A skill runs in front of you, so you can intervene.

Agents haven't disappeared; they're kept for what they do well, which is isolating context.

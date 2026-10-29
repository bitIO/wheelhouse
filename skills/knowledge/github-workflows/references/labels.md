# Labels for epics, stories and tasks

Every issue gets **one type** label and **one or more area** labels. The repo's own labels win: if it already has labels for the same purpose (`type: story`, `area/api`, GitHub issue types), use those and say which you mapped. Create only the ones that are missing, and only once the human has approved writing to the tracker.

## Type (exactly one)

| Label | Color | Use |
|---|---|---|
| `epic` | `5319E7` | An initiative that groups stories. The title starts with 🎯 |
| `story` | `0E8A16` | A vertical slice that delivers value on its own |
| `task` | `C5DEF5` | Work outside a story: a chore, a spike, a follow-up |
| `bug` | `D73A4A` | Behaviour that is broken today |

## Area (one or more: what the issue touches)

| Label | Color | Use |
|---|---|---|
| `backend` | `1D76DB` | APIs, services, jobs, business logic |
| `frontend` | `FBCA04` | UI, client state, accessibility |
| `data` | `006B75` | Schema, migrations, data jobs |
| `infra` | `B60205` | Cloud resources, containers, networking, IaC |
| `ci` | `BFD4F2` | Pipelines, checks, builds |
| `delivery` | `F9D0C4` | Deploy, release, rollout, feature flags, rollback |
| `docs` | `0075CA` | Documentation only |

An epic carries the union of its stories' areas.

## Titles

- Epic: `🎯 <outcome>`, e.g. `🎯 Backend runs on Hono`.
- Story, task, bug: plain, no emoji.

## Commands

```bash
gh label list --limit 200 --json name -q '.[].name'          # what the repo has
gh label create story --color 0E8A16 --description "Vertical slice that delivers value on its own"
gh issue create --title "🎯 Backend runs on Hono" --label epic,backend,delivery --body-file "$tmp"
gh issue edit 13 --add-label frontend
```

`gh label create` fails on a label that already exists; leave that one as it is.

## Without a tracker

In `docs/work/<epic-slug>.md`, the heading is `# 🎯 <outcome>` and every issue carries a line `Labels: story · backend, frontend`.

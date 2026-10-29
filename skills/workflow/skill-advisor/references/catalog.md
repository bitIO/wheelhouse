# Skill catalog

Third-party skills that `skill-advisor` may recommend, one per area. Each comes from the maintainer of the technology it covers, or from a well-known publisher. Being listed means "worth considering when the signal is there", not "safe": every candidate is still reviewed before installing.

Install source: `https://github.com/<Repo>`, skill directory `<Path>`.

| Area | Skill | Repo | Path | Signals |
|---|---|---|---|---|
| Frontend visual design | `frontend-design` | anthropics/skills | skills/frontend-design | Stories that create or redesign user-facing screens |
| React performance | `vercel-react-best-practices` | vercel-labs/agent-skills | skills/react-best-practices | `react` or `next` in the dependencies |
| React component APIs | `vercel-composition-patterns` | vercel-labs/agent-skills | skills/composition-patterns | Stories that design reusable React components or a component library |
| React view transitions | `vercel-react-view-transitions` | vercel-labs/agent-skills | skills/react-view-transitions | Stories with animated route or state transitions in React |
| Postgres | `supabase-postgres-best-practices` | supabase/agent-skills | skills/supabase-postgres-best-practices | `pg`, `postgres` or a Postgres `DATABASE_URL`, and stories that change the schema or queries |
| Supabase | `supabase` | supabase/agent-skills | skills/supabase | `@supabase/*` in the dependencies, or a `supabase/` directory |
| Auth0 | `auth0` | auth0/agent-skills | plugins/auth0/skills/auth0 | `@auth0/*` or `auth0` in the dependencies |
| Monorepo builds | `turborepo` | vercel/turborepo | skills/turborepo | A `turbo.json` file |
| Render deploys | `render-docker` | render-oss/skills | skills/render-docker | A `render.yaml` file, or deploy stories that target Render |
| End-to-end tests | `playwright-best-practices` | currents-dev/playwright-best-practices-skill | playwright-best-practices | `@playwright/test` in the dependencies, or stories that need browser tests |

## Adding an entry

- One skill per area. To replace one, change the row; don't add a competing one.
- Prefer the technology's maintainer. Check the license, size and bundled files with `scan.sh` before proposing it.
- **Signals** must be things you can point at in a repo or a story, not topics.
- `scripts/validate.sh` checks the table's shape, unique areas and skills, and names that don't clash with wheelhouse's own.

# Recommended third-party skills

wheelhouse ships only its own skills. Install stack-specific skills from their maintainers, so they stay current and keep their licenses. Search for them with `npx skills find <name>` (the open skills registry) or on the maintainer's repo.

| Area | Skill | Maintainer |
|---|---|---|
| Postgres | `supabase-postgres-best-practices` | Supabase |
| Supabase | `supabase` | Supabase |
| React / Next.js | `vercel-react-best-practices`, `vercel-composition-patterns`, `vercel-react-view-transitions` | Vercel |
| Monorepo | `turborepo` | Vercel |
| Auth | `auth0` | Auth0 |
| Deploy | `render-docker` | Render |
| E2E testing | `playwright-best-practices` | Currents |

## Avoid overlapping skills

Several skills that compete for the same trigger make the model's choice unpredictable. Keep **one** per concern:

- **One Docker skill.** `conventions-docker` covers the conventions; add a platform skill (such as `render-docker`) only if you deploy there.
- **One frontend design skill.** Pick one; they give conflicting directions.
- **One browser-automation skill.** Pick one; some claim priority over every other tool.
- **One code-review skill.** `4r-code-review`, plus `check-*` skills for depth.

## Check before installing

- **License**: is it present, and does it allow your use?
- **Scope**: does the description stay within its domain, or does it claim broad triggers ("use for any task…")?
- **Size**: a 2,000-line `SKILL.md` costs context every time it loads. Prefer skills that keep details in `references/`.
- **Tools**: `allowed-tools` grants and bundled scripts run with your permissions. Read them.

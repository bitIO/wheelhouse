# Recommended third-party skills

wheelhouse ships only its own skills. Install stack-specific skills from their maintainers, so they stay current and keep their licenses.

You rarely need to pick them by hand: `/lead` runs `skill-advisor` before you lock the plan, and you can ask for it directly ("which skills should I add for this?"). It recommends from the [catalog](../skills/workflow/skill-advisor/references/catalog.md) first, searches the open registry (`npx skills find`) only when you agree, and reviews every candidate before installing it. How the review and the 🟢 🟡 🔴 ratings work: [review.md](../skills/workflow/skill-advisor/references/review.md).

## Avoid overlapping skills

Several skills that compete for the same trigger make the model's choice unpredictable. Keep **one** per concern:

- **One Docker skill.** `conventions-docker` covers the conventions; add a platform skill (such as `render-docker`) only if you deploy there.
- **One frontend design skill.** Pick one; they give conflicting directions.
- **One browser-automation skill.** Pick one; some claim priority over every other tool.
- **One code-review skill.** `4r-code-review`, plus `check-*` skills for depth.

The catalog follows the same rule: one skill per area, and `scripts/validate.sh` rejects a second one.

## Installing one yourself

Do what `skill-advisor` does: clone it, scan it, read it, then install the copy you read.

```bash
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/<owner>/<repo> "$tmp"
bash skills/workflow/skill-advisor/scripts/scan.sh "$tmp/<path>" "$tmp"
DISABLE_TELEMETRY=1 npx skills add "$tmp/<path>" -a claude-code -g --copy -y   # or -a opencode / -a pi; drop -g for this project only
```

Things to check that a scanner can't: is the license compatible with your use? Does the description stay within its domain? Is the `SKILL.md` small enough to load often, with details in `references/`?

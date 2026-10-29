#!/usr/bin/env bash
# Negative tests: scripts/validate.sh must reject each broken fixture.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# Resolve symlinks (macOS /var -> /private/var) so paths compare equal to the installer's `pwd -P`.
WORK="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$WORK"' EXIT
passed=0
failed=0

# expect_fail NAME EXPECTED_MESSAGE SETUP_COMMANDS: SETUP runs inside a fresh copy of the repo.
expect_fail() {
  local name=$1 expected=$2 setup=$3 copy="$WORK/$1"
  cp -R "$REPO" "$copy"
  (cd "$copy" && eval "$setup")
  if out="$(bash "$copy/scripts/validate.sh" 2>&1)"; then
    printf 'FAIL: %s was accepted\n' "$name"; failed=$((failed + 1))
  elif ! printf '%s' "$out" | grep -q "$expected"; then
    printf 'FAIL: %s rejected for the wrong reason:\n%s\n' "$name" "$out"; failed=$((failed + 1))
  else
    passed=$((passed + 1))
  fi
}

expect_fail name-mismatch "must match directory" \
  "sed 's/^name: gate$/name: gates/' skills/workflow/gate/SKILL.md > x && mv x skills/workflow/gate/SKILL.md"
expect_fail bad-name "lowercase words" \
  "mkdir -p skills/knowledge/Bad_Name && printf -- '---\nname: Bad_Name\ndescription: x\n---\n' > skills/knowledge/Bad_Name/SKILL.md"
expect_fail missing-description "missing one-line description" \
  "mkdir -p skills/knowledge/nodesc && printf -- '---\nname: nodesc\n---\n' > skills/knowledge/nodesc/SKILL.md"
expect_fail duplicate "duplicate skill name" \
  "mkdir -p skills/checks/gate && cp skills/workflow/gate/SKILL.md skills/checks/gate/SKILL.md"
expect_fail broken-link "broken link" \
  "printf '\nSee [x](references/nope.md).\n' >> skills/workflow/gate/SKILL.md"
expect_fail missing-guard "explicit-invocation guard" \
  "grep -v 'Only run this when I invoke it explicitly' skills/workflow/pair/SKILL.md > x && mv x skills/workflow/pair/SKILL.md"
expect_fail missing-language "missing the language rule" \
  "sed 's/ Talk to me in my language.*//' skills/workflow/story/SKILL.md > x && mv x skills/workflow/story/SKILL.md"
expect_fail manual-knowledge "only workflow skills" \
  "awk '{ print } /^description:/ { print \"disable-model-invocation: true\" }' skills/knowledge/conventions-git/SKILL.md > x && mv x skills/knowledge/conventions-git/SKILL.md"
expect_fail unquoted-colon "needs quoting" \
  "mkdir -p skills/knowledge/colon && printf -- '---\nname: colon\ndescription: Use for: everything\n---\n' > skills/knowledge/colon/SKILL.md"
expect_fail unknown-skill-ref "unknown skill" \
  "printf '\nLoad \`check-nonexistent\`.\n' >> skills/workflow/verify/SKILL.md"
expect_fail agent-access "access must be read-only" \
  "sed 's/^access: read-only$/access: full/' agents/reviewer.md > x && mv x agents/reviewer.md"
expect_fail missing-agent "reviewer" "rm agents/reviewer.md"
expect_fail conventions-precedence "repo's own rules win" \
  "grep -v 'win over these' skills/knowledge/conventions-git/SKILL.md > x && mv x skills/knowledge/conventions-git/SKILL.md"
expect_fail builtin-agent-name "collides with a built-in" \
  "sed 's/^name: investigator$/name: explore/' agents/investigator.md > agents/explore.md && rm agents/investigator.md"
CATALOG=skills/workflow/skill-advisor/references/catalog.md
expect_fail catalog-duplicate-area "duplicate area" \
  "printf '| Postgres | \`other-pg\` | acme/skills | skills/pg | \`pg\` in the dependencies |\n' >> $CATALOG"
expect_fail catalog-duplicate-skill "duplicate skill" \
  "printf '| Other area | \`turborepo\` | acme/skills | skills/turbo | A \`turbo.json\` file |\n' >> $CATALOG"
expect_fail catalog-clash "clashes with a wheelhouse skill" \
  "printf '| Gates | \`gate\` | acme/skills | skills/gate | Always |\n' >> $CATALOG"
expect_fail catalog-bad-repo "repo must be owner/name" \
  "printf '| Elixir | \`elixir\` | https://example.com/x | skills/elixir | \`mix.exs\` |\n' >> $CATALOG"
expect_fail catalog-columns "exactly 5 columns" \
  "printf '| Elixir | \`elixir\` | acme/skills | skills/elixir |\n' >> $CATALOG"
expect_fail catalog-path "relative to the repo" \
  "printf '| Elixir | \`elixir\` | acme/skills | ../elixir | \`mix.exs\` |\n' >> $CATALOG"

if bash "$REPO/scripts/validate.sh" >/dev/null; then passed=$((passed + 1)); else echo "FAIL: clean repo rejected"; failed=$((failed + 1)); fi

printf '%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]

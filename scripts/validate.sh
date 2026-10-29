#!/usr/bin/env bash
# Validate skills and agents against the Agent Skills spec and this repo's rules.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
errors=0
fail() { printf 'FAIL %s: %s\n' "$1" "$2"; errors=$((errors + 1)); }
# report OUTPUT: print collected FAIL lines and count them as one problem.
report() { if [ -n "$1" ]; then printf '%s\n' "$1"; errors=$((errors + 1)); fi; }

fm_get() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ":") == 1 {
      v = substr($0, length(key) + 2); sub(/^[ \t]+/, "", v); print v; exit
    }' "$1"
}

check_frontmatter() {
  local f=$1 rel=$2
  [ "$(head -n 1 "$f")" = "---" ] || { fail "$rel" "must start with a frontmatter block"; return 1; }
  [ "$(awk '$0 == "---" { c++ } END { print c + 0 }' "$f")" -ge 2 ] || { fail "$rel" "frontmatter is not closed"; return 1; }
  # Plain YAML scalars can't contain ": " or " #"; our renderers only handle one-line values.
  report "$(awk 'NR > 1 && $0 == "---" { exit } NR > 1' "$f" | grep -E '^[a-z-]+:' | unquoted_values "$rel")"
  return 0
}

# The loops below live in functions because bash 3.2 can't parse `case` inside $(...).

# unquoted_values REL: read `key: value` lines, flag values that need YAML quoting.
unquoted_values() {
  local line value
  while IFS= read -r line; do
    value="${line#*:}"
    value="${value# }"
    case "$value" in \"* | \'*) continue ;; esac
    case "$value" in *": "* | *" #"*) printf 'FAIL %s: unquoted value needs quoting: %s\n' "$1" "$line" ;; esac
  done
}

# broken_links FILE REL: read link targets, flag the ones missing next to FILE.
broken_links() {
  local link
  while IFS= read -r link; do
    [ -e "$(dirname "$1")/$link" ] || printf 'FAIL %s: broken link %s\n' "$2" "$link"
  done
}

# unknown_refs: read skill names, flag the ones not in $names.
unknown_refs() {
  local ref
  while IFS= read -r ref; do
    case " $names " in *" $ref "*) ;; *) printf 'FAIL reference: unknown skill `%s`\n' "$ref" ;; esac
  done
}

# catalog_rows: read the skill-advisor catalog, flag malformed, duplicate or clashing rows.
catalog_rows() {
  local line area skill repo path signals extra areas=" " skills=" " rows=0
  while IFS= read -r line; do
    case "$line" in "| Area |"* | "|---"* | "| ---"*) continue ;; "| "*) ;; *) continue ;; esac
    rows=$((rows + 1))
    IFS='|' read -r _ area skill repo path signals extra <<EOF
$line
EOF
    area="$(trim "$area")"; skill="$(trim "$skill")"; repo="$(trim "$repo")"
    path="$(trim "$path")"; signals="$(trim "$signals")"; extra="$(trim "$extra")"
    if [ -z "$signals" ] || [ -n "$extra" ]; then
      printf 'FAIL catalog: row needs exactly 5 columns: %s\n' "$line"; continue
    fi
    printf '%s' "$skill" | grep -Eq '^`[a-z0-9]+(-[a-z0-9]+)*`$' || printf 'FAIL catalog: skill must be a backticked name: %s\n' "$skill"
    skill="$(printf '%s' "$skill" | tr -d '`')"
    printf '%s' "$repo" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' || printf 'FAIL catalog: repo must be owner/name: %s\n' "$repo"
    case "$path" in /* | *..* | "") printf 'FAIL catalog: path must be relative to the repo: %s\n' "$path" ;; esac
    case "$areas" in *" $area|"*) printf 'FAIL catalog: duplicate area %s (one skill per area)\n' "$area" ;; esac
    case "$skills" in *" $skill "*) printf 'FAIL catalog: duplicate skill %s\n' "$skill" ;; esac
    case " $names " in *" $skill "*) printf 'FAIL catalog: %s clashes with a wheelhouse skill\n' "$skill" ;; esac
    areas="$areas $area|"
    skills="$skills$skill "
  done
  [ "$rows" -gt 0 ] || printf 'FAIL catalog: no rows found\n'
}
trim() { local s="${1#"${1%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

names=""
for f in "$REPO"/skills/*/*/SKILL.md; do
  rel="${f#"$REPO"/}"
  dir="$(basename "$(dirname "$f")")"
  category="$(basename "$(dirname "$(dirname "$f")")")"
  check_frontmatter "$f" "$rel" || continue

  name="$(fm_get "$f" name)"
  desc="$(fm_get "$f" description)"
  [ "$name" = "$dir" ] || fail "$rel" "name '$name' must match directory '$dir'"
  printf '%s' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || fail "$rel" "name must be lowercase words joined by hyphens"
  [ "${#name}" -le 64 ] || fail "$rel" "name longer than 64 characters"
  [ -n "$desc" ] || fail "$rel" "missing one-line description"
  [ "${#desc}" -le 1024 ] || fail "$rel" "description longer than 1024 characters"
  case " $names " in *" $name "*) fail "$rel" "duplicate skill name '$name'" ;; esac
  names="$names $name"

  # Every relative link inside a skill must resolve.
  report "$(grep -oE '\]\([^)#:]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//' | broken_links "$f" "$rel")"

  if [ "$category" = "workflow" ] && [ "$(fm_get "$f" disable-model-invocation)" = "true" ]; then
    # OpenCode ignores disable-model-invocation, so manual workflows must guard themselves.
    grep -q 'Only run this when I invoke it explicitly' "$f" || fail "$rel" "manual-only workflow is missing the explicit-invocation guard"
    grep -q 'Talk to me in my language' "$f" || fail "$rel" "manual-only workflow is missing the language rule"
  fi
  case "$name" in
    conventions-*) grep -q 'win over these' "$f" || fail "$rel" "conventions skill must state that the repo's own rules win over these" ;;
  esac
  if [ "$category" != "workflow" ] && [ "$(fm_get "$f" disable-model-invocation)" = "true" ]; then
    fail "$rel" "only workflow skills may disable model invocation"
  fi
done

for f in "$REPO"/agents/*.md; do
  rel="${f#"$REPO"/}"
  check_frontmatter "$f" "$rel" || continue
  name="$(fm_get "$f" name)"
  [ "$name" = "$(basename "$f" .md)" ] || fail "$rel" "name '$name' must match file name"
  # A file with a built-in's name silently overrides it (OpenCode merges into its own agent).
  case "$name" in
    explore | general | plan | build | general-purpose | statusline-setup | summary | title | compaction | scout)
      fail "$rel" "'$name' collides with a built-in agent in Claude Code or OpenCode" ;;
  esac
  [ -n "$(fm_get "$f" description)" ] || fail "$rel" "missing one-line description"
  [ "$(fm_get "$f" access)" = "read-only" ] || fail "$rel" "access must be read-only (the only profile the installer renders)"
  case "$(fm_get "$f" web)" in true | false) ;; *) fail "$rel" "web must be true or false" ;; esac
done

# Skills and agents referenced by name must exist.
agents=" $(for f in "$REPO"/agents/*.md; do basename "$f" .md; done | tr '\n' ' ') "
sources=""
for p in skills agents README.md docs; do [ -e "$REPO/$p" ] && sources="$sources $REPO/$p"; done
# shellcheck disable=SC2086 # $sources is a list of repo paths without spaces in their names
report "$(grep -rhoE '`(check-[a-z0-9-]+|conventions-[a-z0-9-]+|github-workflows|4r-code-review|skill-advisor)`' $sources |
  tr -d '`' | sort -u | unknown_refs)"
catalog="$REPO/skills/workflow/skill-advisor/references/catalog.md"
if [ -f "$catalog" ]; then report "$(catalog_rows <"$catalog")"; fi

for a in investigator reviewer; do
  case "$agents" in *" $a "*) ;; *) fail "agents" "workflows reference the '$a' agent but agents/$a.md is missing" ;; esac
done

if [ "$errors" -gt 0 ]; then
  printf '\n%d problem(s) found.\n' "$errors"
  exit 1
fi
agent_count=$(find "$REPO/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
# shellcheck disable=SC2086 # split the space-separated name list on purpose
set -- $names
printf 'OK: %d skills, %d agents\n' "$#" "$agent_count"

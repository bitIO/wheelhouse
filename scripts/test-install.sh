#!/usr/bin/env bash
# End-to-end tests for setup/install.sh, run against a throwaway HOME.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL="$REPO/setup/install.sh"
# Resolve symlinks (macOS /var -> /private/var) so paths compare equal to the installer's `pwd -P`.
WORK="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$WORK"' EXIT

passed=0
failed=0
ok() { passed=$((passed + 1)); }
ko() { printf 'FAIL: %s\n' "$1"; failed=$((failed + 1)); }
check() { if eval "$2"; then ok; else ko "$1"; fi; }

fresh_home() {
  export HOME="$WORK/home-$1"
  export XDG_CONFIG_HOME="$HOME/.config"
  mkdir -p "$HOME"
}
run() { bash "$INSTALL" "$@" >"$WORK/last.log" 2>&1; }

manual="lead story pair deliver accept"
invocable="backlog gate verify skill-advisor"
# shellcheck disable=SC2034 # read inside check() eval strings
n_skills=$(find "$REPO/skills" -mindepth 2 -maxdepth 2 -type d | wc -l | tr -d ' ')

# 1. Global install for every tool, symlink mode.
fresh_home link
run --all
check "install --all exits 0" '[ $? -eq 0 ]'
check "claude: every skill linked" '[ "$(find "$HOME/.claude/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d " ")" = "$n_skills" ]'
check "claude: skill symlink points into repo" '[ "$(readlink "$HOME/.claude/skills/lead")" = "$REPO/skills/workflow/lead" ]'
check "claude: reviewer agent rendered" 'grep -q "^tools: Read, Grep, Glob, Bash$" "$HOME/.claude/agents/reviewer.md"'
check "claude: investigator agent gets web tools" 'grep -q "WebFetch, WebSearch" "$HOME/.claude/agents/investigator.md"'
check "claude: agent has no access/web source keys" '! grep -qE "^(access|web):" "$HOME/.claude/agents/investigator.md"'
for s in $manual; do
  check "opencode: $s is a command, not a skill" '[ -f "$XDG_CONFIG_HOME/opencode/commands/'"$s"'.md" ] && [ ! -e "$XDG_CONFIG_HOME/opencode/skills/'"$s"'" ]'
  check "opencode: $s command embeds body and \$ARGUMENTS" 'grep -q "Only run this when I invoke it explicitly" "$XDG_CONFIG_HOME/opencode/commands/'"$s"'.md" && grep -q "^\$ARGUMENTS$" "$XDG_CONFIG_HOME/opencode/commands/'"$s"'.md"'
done
for s in $invocable; do
  check "opencode: $s installed as skill" '[ -L "$XDG_CONFIG_HOME/opencode/skills/'"$s"'" ]'
  check "opencode: $s has a stub command" 'grep -q "Load the \`'"$s"'\` skill" "$XDG_CONFIG_HOME/opencode/commands/'"$s"'.md"'
done
check "opencode: lead command points at its references" 'grep -q "$REPO/skills/workflow/lead/references/" "$XDG_CONFIG_HOME/opencode/commands/lead.md"'
check "opencode: knowledge skill installed" '[ -L "$XDG_CONFIG_HOME/opencode/skills/check-security" ]'
check "opencode: reviewer is a read-only subagent" 'grep -q "^mode: subagent$" "$XDG_CONFIG_HOME/opencode/agents/reviewer.md" && grep -q "^  edit: deny$" "$XDG_CONFIG_HOME/opencode/agents/reviewer.md" && grep -q "^  webfetch: deny$" "$XDG_CONFIG_HOME/opencode/agents/reviewer.md"'
check "opencode: wildcard bash rule comes first (last match wins)" '[ "$(grep -A1 "^  bash:" "$XDG_CONFIG_HOME/opencode/agents/reviewer.md" | tail -n 1)" = "    \"*\": ask" ]'
check "opencode: note about .claude/skills printed" 'grep -q OPENCODE_DISABLE_CLAUDE_CODE_SKILLS "$WORK/last.log"'
check "pi: every skill linked" '[ "$(find "$HOME/.pi/agent/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d " ")" = "$n_skills" ]'
check "pi: manual flag preserved" 'grep -q "^disable-model-invocation: true$" "$HOME/.pi/agent/skills/lead/SKILL.md"'

# Rendered frontmatter must be valid YAML (when PyYAML is available).
if python3 -c 'import yaml' 2>/dev/null; then
  for f in "$HOME/.claude/agents/"*.md "$XDG_CONFIG_HOME/opencode/agents/"*.md "$XDG_CONFIG_HOME/opencode/commands/"*.md; do
    check "valid YAML frontmatter: ${f#"$HOME"/}" 'python3 -I -c "import sys,yaml; t=open(sys.argv[1]).read().split(\"---\")[1]; d=yaml.safe_load(t); assert d[\"description\"]" "$f"'
  done
else
  echo "skip: PyYAML not installed, YAML parse checks skipped"
fi

# 2. Idempotent: a second run changes nothing and skips nothing.
# shellcheck disable=SC2034 # read inside check() eval strings
before="$(cd "$HOME" && find . | sort | cksum)"
run --all
check "re-run exits 0" '[ $? -eq 0 ]'
check "re-run reports no skips" '! grep -q "skip:" "$WORK/last.log"'
check "re-run leaves the same tree" '[ "$(cd "$HOME" && find . | sort | cksum)" = "$before" ]'

# 3. Never clobbers files it didn't create.
rm "$HOME/.claude/skills/pair"
mkdir -p "$HOME/.claude/skills/pair" && echo mine >"$HOME/.claude/skills/pair/SKILL.md"
run --claude
check "foreign skill dir is skipped" 'grep -q "skip: $HOME/.claude/skills/pair" "$WORK/last.log" && grep -q mine "$HOME/.claude/skills/pair/SKILL.md"'
run --claude --force
check "--force replaces foreign dir" '[ -L "$HOME/.claude/skills/pair" ]'

# 4. Dry run touches nothing.
fresh_home dry
run --all --dry-run
check "dry run exits 0" '[ $? -eq 0 ]'
check "dry run creates nothing" '[ -z "$(ls -A "$HOME")" ]'
check "dry run lists actions" 'grep -q "would: ln -s" "$WORK/last.log"'

# 5. Copy mode marks what it copies and uninstall removes it all.
fresh_home copy
run --all --copy
check "copy: skill is a real dir with marker" '[ -d "$HOME/.claude/skills/gate" ] && [ ! -L "$HOME/.claude/skills/gate" ] && [ -f "$HOME/.claude/skills/gate/.wheelhouse" ]'
check "copy: marker records the version" 'grep -qE "^generated by wheelhouse v[0-9]+\.[0-9]+\.[0-9]+ from " "$HOME/.claude/skills/gate/.wheelhouse"'
check "copy: opencode command references copied data" 'grep -q "$XDG_CONFIG_HOME/opencode/wheelhouse/lead/references/" "$XDG_CONFIG_HOME/opencode/commands/lead.md"'
mkdir -p "$HOME/.claude/skills/someone-else" && echo x >"$HOME/.claude/skills/someone-else/SKILL.md"
run --all --uninstall
check "uninstall exits 0" '[ $? -eq 0 ]'
check "uninstall leaves foreign skills" '[ -f "$HOME/.claude/skills/someone-else/SKILL.md" ]'
check "uninstall removes every wheelhouse file" '[ -z "$(find "$HOME" -name .wheelhouse -o -type l | head -n 1)" ] && ! grep -rqs "generated by wheelhouse" "$HOME"'
run --all --uninstall
check "second uninstall is a no-op" '[ $? -eq 0 ] && ! grep -q "rm:" "$WORK/last.log"'

# 6. Project mode defaults to copies inside the project.
fresh_home proj
mkdir -p "$WORK/project"
run --claude --opencode --pi --project "$WORK/project"
check "project: claude skills copied" '[ -f "$WORK/project/.claude/skills/story/SKILL.md" ] && [ ! -L "$WORK/project/.claude/skills/story" ]'
check "project: opencode commands" '[ -f "$WORK/project/.opencode/commands/deliver.md" ]'
check "project: pi skills" '[ -f "$WORK/project/.pi/skills/verify/SKILL.md" ]'
check "project: home untouched" '[ -z "$(ls -A "$HOME")" ]'

# 7. Paths with spaces.
SPACED="$WORK/with space/wheelhouse"
mkdir -p "$(dirname "$SPACED")" && cp -R "$REPO" "$SPACED"
fresh_home spaced
bash "$SPACED/setup/install.sh" --claude >"$WORK/last.log" 2>&1
check "repo path with spaces installs" '[ "$(readlink "$HOME/.claude/skills/lead")" = "$SPACED/skills/workflow/lead" ]'

# 8. get.sh downloads a release tarball into one stable path and upgrades in place.
release() {
  mkdir -p "$WORK/remote/archive/refs/tags" "$WORK/src-$1"
  cp -R "$REPO" "$WORK/src-$1/wheelhouse-${1#v}"
  tar -czf "$WORK/remote/archive/refs/tags/$1.tar.gz" -C "$WORK/src-$1" "wheelhouse-${1#v}"
}
get() { WHEELHOUSE_URL="file://$WORK/remote" WHEELHOUSE_VERSION="$1" bash "$REPO/setup/get.sh" --claude >"$WORK/last.log" 2>&1; }
fresh_home get
release v0.1.0
release v0.2.0
get v0.1.0
check "get.sh installs a release" '[ $? -eq 0 ] && [ "$(cat "$HOME/.local/share/wheelhouse/VERSION")" = v0.1.0 ]'
check "get.sh links skills to the download" '[ "$(readlink "$HOME/.claude/skills/lead")" = "$HOME/.local/share/wheelhouse/skills/workflow/lead" ]'
get v0.2.0
check "get.sh upgrades in place" '[ "$(cat "$HOME/.local/share/wheelhouse/VERSION")" = v0.2.0 ] && ! grep -q "skip:" "$WORK/last.log"'
rm -rf "$HOME/.local/share/wheelhouse" && mkdir -p "$HOME/.local/share/wheelhouse/mine"
get v0.2.0
check "get.sh refuses a folder it did not create" '[ $? -ne 0 ] && [ -d "$HOME/.local/share/wheelhouse/mine" ]'
WHEELHOUSE_URL="file://$WORK/remote" WHEELHOUSE_VERSION=latest bash "$REPO/setup/get.sh" >/dev/null 2>&1
check "get.sh rejects a non-version tag" '[ $? -ne 0 ]'

# 9. Argument errors.
bash "$INSTALL" --nope >/dev/null 2>&1
check "unknown option exits 2" '[ $? -eq 2 ]'
bash "$INSTALL" --project "$WORK/missing" --all >/dev/null 2>&1
check "missing project dir fails" '[ $? -ne 0 ]'

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]

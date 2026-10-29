#!/usr/bin/env bash
# Render the Claude Code agents the plugin ships (plugin/agents/) from agents/*.md.
# With --check, fail instead if they are stale or missing from .claude-plugin/plugin.json.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir "$TMP/project"
bash "$REPO/setup/install.sh" --claude --project "$TMP/project" >/dev/null
rendered="$TMP/project/.claude/agents"

if [ "${1:-}" != "--check" ]; then
  rm -rf "$REPO/plugin/agents"
  mkdir -p "$REPO/plugin"
  cp -R "$rendered" "$REPO/plugin/agents"
  echo "updated plugin/agents"
  exit 0
fi

status=0
if ! diff -r "$rendered" "$REPO/plugin/agents"; then
  echo "plugin/agents is stale: run scripts/build-plugin.sh" >&2
  status=1
fi
for f in "$REPO"/agents/*.md; do
  if ! grep -q "\"./plugin/agents/$(basename "$f")\"" "$REPO/.claude-plugin/plugin.json"; then
    echo "agents/$(basename "$f") is not listed in .claude-plugin/plugin.json" >&2
    status=1
  fi
done
exit "$status"

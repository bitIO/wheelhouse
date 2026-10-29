# Claude Code

Extras that only apply to Claude Code. What every tool supports, and the caveats per tool, is in [compatibility.md](compatibility.md).

## Show the wheelhouse version in the status line

A [status line](https://code.claude.com/docs/en/statusline) segment that shows which wheelhouse a session is using, e.g. `🛞 v0.3.1`, next to the folder name:

![Claude Code status line ending in 🛞 v0.2.0, the folder and the branch](assets/claude-code-status-sample.png)

It looks in this order:

1. **The project's copy** (`--project`). The installer records the version in `.claude/skills/lead/.wheelhouse`. Copies made before v0.4.0 don't have it, so the segment shows the version of the source they were copied from, which may be newer.
2. **A global install** (symlinks): the `VERSION` that `get.sh` writes, or `plugin.json` in a git clone.
3. **The plugin**: its entry in `~/.claude/plugins/installed_plugins.json`.

It needs `jq`. Add the function to your status line script and append its output to what you print:

```bash
# wheelhouse version: project copy, then global install (symlinks), then the plugin
wheelhouse_version() {
  local dir=$1 marker root v
  if [ -f "$dir/.claude/skills/lead/.wheelhouse" ]; then
    marker=$(cat "$dir/.claude/skills/lead/.wheelhouse")
    v=$(grep -oE ' v[0-9][0-9.]*' <<< "$marker" | head -n 1 | tr -d ' ')
    [ -n "$v" ] && { echo "$v"; return; }
    root=${marker#* from }; root=${root%/skills/*}
  elif [ -L ~/.claude/skills/lead ]; then
    root=$(cd ~/.claude/skills/lead && pwd -P); root=${root%/skills/*}
  fi
  if [ -n "$root" ]; then
    [ -f "$root/VERSION" ] && { cat "$root/VERSION"; return; }
    v=$(jq -r '.version // empty' "$root/.claude-plugin/plugin.json" 2>/dev/null)
    [ -n "$v" ] && { echo "v$v"; return; }
  fi
  v=$(jq -r '.plugins["wheelhouse@wheelhouse"][0].version // empty' ~/.claude/plugins/installed_plugins.json 2>/dev/null)
  [ -n "$v" ] && echo "v$v"
}

input=$(cat)
wh=$(wheelhouse_version "$(jq -r '.workspace.project_dir // .cwd' <<< "$input")")
[ -n "$wh" ] && printf '🛞 %s' "$wh"
```

No status line yet? Save the snippet as `~/.claude/statusline.sh` and point `~/.claude/settings.json` at it:

```json
{
  "statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" }
}
```

The segment is empty when no wheelhouse is installed for that project.

### Full example

The complete script behind the screenshot: model, effort, session and daily cost, duration, tokens, context window, rate limits, wheelhouse version, folder and branch. It needs `jq`, `bc` and `git`. The daily cost reads today's transcripts in `~/.claude/projects` and prices them at fixed per-million-token rates ($3 input, $15 output, $3.75 cache write, $0.30 cache read), so it is an estimate; edit the `awk` line for your model.

<details>
<summary><code>~/.claude/statusline.sh</code></summary>

```bash
#!/usr/bin/env bash
# ~/.claude/statusline.sh

input=$(cat)

today=$(date +%Y-%m-%d)
transcript_path=""
sentinel=/tmp/.claude_dc_sentinel
if [[ ! -f "$sentinel" ]] || [[ $(date -r "$sentinel" +%Y-%m-%d 2>/dev/null) != "$today" ]]; then
  touch -d "$today 00:00:00" "$sentinel" 2>/dev/null || touch "$sentinel"
fi

fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then printf '%.1fM' "$(bc -l <<< "$n/1000000")"
  elif [ "$n" -ge 1000 ]; then printf '%.1fk' "$(bc -l <<< "$n/1000")"
  else echo "$n"
  fi
}

calc_daily_cost() {
  local today
  today=$(date +%Y-%m-%d)

  find ~/.claude/projects -name '*.jsonl' -newer /tmp/.claude_dc_sentinel 2>/dev/null | \
  while read -r f; do
    [[ $(date -r "$f" +%Y-%m-%d 2>/dev/null || stat -c %y "$f" 2>/dev/null | cut -d' ' -f1) == "$today" ]] || continue
    cat "$f"
  done | \
  jq -r --arg today "$today" '
    select(.type == "assistant") |
    select(.timestamp != null) |
    select(.timestamp | startswith($today)) |
    select(.message.usage != null) |
    .message as $msg |
    "\($msg.id // "x") \($msg.usage.input_tokens // 0) \($msg.usage.output_tokens // 0) \($msg.usage.cache_creation_input_tokens // 0) \($msg.usage.cache_read_input_tokens // 0)"
  ' 2>/dev/null | \
  sort -u -k1,1 | \
  awk '
    {
      inp += $2; out += $3; cache_w += $4; cache_r += $5
    }
    END {
      cost = (inp * 3 + out * 15 + cache_w * 3.75 + cache_r * 0.3) / 1000000
      printf "%.4f", cost
    }
  '
}

model=$(jq -r '.model.display_name // .model.id // "?"' <<< "$input")
effort=$(jq -r '.reasoning_effort.level // .reasoning_effort // .effort.level // .effort // empty' <<< "$input")
cost=$(jq -r '.cost.total_cost_usd // .cost.total_cost // empty' <<< "$input")
duration_ms=$(jq -r '.cost.total_duration_ms // empty' <<< "$input")
tokens_in=$(jq -r '.cost.total_input_tokens // .usage.input_tokens // empty' <<< "$input")
tokens_out=$(jq -r '.cost.total_output_tokens // .usage.output_tokens // empty' <<< "$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // "."' <<< "$input")
daily_cost=$(calc_daily_cost)

# Context window fields
ctx_used_pct=$(jq -r '.context_window.used_percentage // empty' <<< "$input")
ctx_remaining_pct=$(jq -r '.context_window.remaining_percentage // empty' <<< "$input")
ctx_total_tokens=$(jq -r '.context_window.total_input_tokens // empty' <<< "$input")
ctx_window_size=$(jq -r '.context_window.context_window_size // empty' <<< "$input")


# wheelhouse version: project copy, then global install (symlinks), then the plugin
wheelhouse_version() {
  local dir=$1 marker root v
  if [ -f "$dir/.claude/skills/lead/.wheelhouse" ]; then
    marker=$(cat "$dir/.claude/skills/lead/.wheelhouse")
    v=$(grep -oE ' v[0-9][0-9.]*' <<< "$marker" | head -n 1 | tr -d ' ')   # stamped by newer installers
    [ -n "$v" ] && { echo "$v"; return; }
    root=${marker#* from }; root=${root%/skills/*}
  elif [ -L ~/.claude/skills/lead ]; then
    root=$(cd ~/.claude/skills/lead && pwd -P); root=${root%/skills/*}
  fi
  if [ -n "$root" ]; then
    [ -f "$root/VERSION" ] && { cat "$root/VERSION"; return; }   # get.sh download
    v=$(jq -r '.version // empty' "$root/.claude-plugin/plugin.json" 2>/dev/null)   # git clone
    [ -n "$v" ] && { echo "v$v"; return; }
  fi
  v=$(jq -r '.plugins["wheelhouse@wheelhouse"][0].version // empty' ~/.claude/plugins/installed_plugins.json 2>/dev/null)
  [ -n "$v" ] && echo "v$v"
}

parts=("🤖 $model")
[ -n "$effort" ] && parts+=("🧠 $effort")
if [ -n "$cost" ]; then
  color=$(awk -v v="$cost" 'BEGIN{if(v>10)print"31";else if(v>8)print"38;5;208";else if(v>5)print"33";else print"32"}')
  parts+=("$(printf '\033[%sm💰 $%.4f\033[0m' "$color" "$cost")")
fi
if [ -n "$daily_cost" ] && [ "$daily_cost" != "0.0000" ]; then
  dcolor=$(awk -v v="$daily_cost" 'BEGIN{if(v>20)print"31";else if(v>10)print"38;5;208";else if(v>5)print"33";else print"32"}')
  parts+=("$(printf '\033[%sm📅 $%.2f\033[0m' "$dcolor" "$daily_cost")")
fi
[ -n "$duration_ms" ] && parts+=("⏱  $((duration_ms/1000))s")
[ -n "$tokens_in" ] && parts+=("⬇ $(fmt_tokens "$tokens_in")")
[ -n "$tokens_out" ] && parts+=("⬆ $(fmt_tokens "$tokens_out")")

# Context window display
if [ -n "$ctx_used_pct" ]; then
  ctx_pct_int=$(printf '%.0f' "$ctx_used_pct")
  ctx_color=$(awk -v v="$ctx_pct_int" 'BEGIN{if(v>=80)print"31";else if(v>=50)print"33";else print"32"}')

  # Build a small progress bar (10 chars wide)
  bar_width=10
  filled=$(( ctx_pct_int * bar_width / 100 ))
  empty=$(( bar_width - filled ))
  bar=""
  [ "$filled" -gt 0 ] && bar=$(printf "%${filled}s" | tr ' ' '#')
  [ "$empty"  -gt 0 ] && bar="${bar}$(printf "%${empty}s"  | tr ' ' '-')"

  # Optionally show used/total token counts if available
  if [ -n "$ctx_total_tokens" ] && [ -n "$ctx_window_size" ]; then
    ctx_label="$(fmt_tokens "$ctx_total_tokens")/$(fmt_tokens "$ctx_window_size") ${bar} ${ctx_pct_int}%"
  else
    ctx_label="${bar} ${ctx_pct_int}%"
  fi

  parts+=("$(printf '\033[%sm📊 %s\033[0m' "$ctx_color" "$ctx_label")")
fi

# Subscription rate limits (5h / 7d): used % and time until reset
fmt_left() {
  local s=$(( $1 - $(date +%s) ))
  [ "$s" -lt 0 ] && s=0
  if [ "$s" -ge 86400 ]; then printf '%dd%dh' $((s/86400)) $((s%86400/3600))
  elif [ "$s" -ge 3600 ]; then printf '%dh%02dm' $((s/3600)) $((s%3600/60))
  else printf '%dm' $((s/60))
  fi
}
for win in five_hour:5h seven_day:7d; do
  read -r pct reset < <(jq -r --arg k "${win%%:*}" '.rate_limits[$k] // empty | "\(.used_percentage // "") \(.resets_at // "")"' <<< "$input")
  [ -z "$pct" ] && continue
  pct_int=$(printf '%.0f' "$pct")
  rcolor=$(awk -v v="$pct_int" 'BEGIN{if(v>=90)print"31";else if(v>=75)print"33";else print"32"}')
  label="${win##*:} ${pct_int}%"
  [ -n "$reset" ] && label="$label ↻$(fmt_left "$reset")"
  parts+=("$(printf '\033[%sm⏳ %s\033[0m' "$rcolor" "$label")")
done

wh=$(wheelhouse_version "$(jq -r '.workspace.project_dir // empty' <<< "$input")")
[ -z "$wh" ] && wh=$(wheelhouse_version "$cwd")
[ -n "$wh" ] && parts+=("🛞 $wh")

parts+=("📁 $(basename "$cwd")")

if branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null); then
  git -C "$cwd" --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null || branch="$branch*"
  parts+=("🌿 $branch")
fi

(IFS=' | '; echo "${parts[*]}")
```

</details>

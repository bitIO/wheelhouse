#!/usr/bin/env bash
# Static, read-only scan of a third-party skill before installing it. Never runs the skill's code.
# Usage: scan.sh SKILL_DIR [REPO_ROOT]
# Prints RED / REVIEW / INFO lines and ends with `SUMMARY red=N review=N files=N`.
set -uo pipefail

if [ $# -lt 1 ] || [ ! -d "$1" ]; then
  echo "usage: scan.sh SKILL_DIR [REPO_ROOT]" >&2
  exit 2
fi
dir="$(cd "$1" && pwd -P)"
root="${2:-}"
red=0
review=0
files=0
MAX_HITS=10
# Text files to search, one path per line. Only portable grep flags below (BusyBox has no -I or --exclude-dir).
text_files="$(mktemp)"
trap 'rm -f "$text_files"' EXIT

flag() {
  printf '%s %s\n' "$1" "$2"
  case "$1" in RED) red=$((red + 1)) ;; REVIEW) review=$((review + 1)) ;; esac
}
info() { printf 'INFO %s\n' "$1"; }

# fm_value KEY: one-line frontmatter value of SKILL.md. fm_has KEY: the key exists.
fm_value() {
  awk -v key="$1" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ":") == 1 { v = substr($0, length(key) + 2); sub(/^[ \t]+/, "", v); print v; exit }
  ' "$dir/SKILL.md"
}
fm_has() {
  awk -v key="$1" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ":") == 1 { found = 1; exit }
    END { exit !found }
  ' "$dir/SKILL.md"
}

# A scan that can't read everything must not look clean.
die() { printf 'ERROR %s\nSUMMARY incomplete\n' "$1"; exit 3; }

# grep_text GREP_ARGS...: run grep over every text file as file:line:text; fail loudly on errors.
grep_text() {
  local f out rc
  while IFS= read -r f; do
    out="$(LC_ALL=C grep -nH "$@" "$f" 2>&1)"
    rc=$?
    [ "$rc" -le 1 ] || die "grep failed on ${f#"$dir"/}: $out"
    [ -n "$out" ] && printf '%s\n' "$out"
  done <"$text_files"
  return 0
}

# hits LEVEL LABEL GREP_ARGS...: one flag per matching line (capped), as file:line plus the text.
hits() {
  local level=$1 label=$2 line n=0 matches
  shift 2
  matches="$(grep_text "$@")" || { printf '%s\n' "$matches"; exit 3; }
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    n=$((n + 1))
    [ "$n" -le "$MAX_HITS" ] || continue
    line="${line#"$dir"/}"
    flag "$level" "$label: $(printf '%s' "$line" | cut -c1-200)"
  done <<EOF
$matches
EOF
  [ "$n" -le "$MAX_HITS" ] || info "$label: $((n - MAX_HITS)) more matching lines not shown"
}

# --- the skill itself ----------------------------------------------------------------

if [ ! -f "$dir/SKILL.md" ]; then
  flag RED "no SKILL.md: this is not a skill directory"
  printf 'SUMMARY red=%d review=%d files=0\n' "$red" "$review"
  exit 0
fi
info "name: $(fm_value name)"
info "SKILL.md: $(wc -l <"$dir/SKILL.md" | tr -d ' ') lines"
fm_has allowed-tools && flag REVIEW "SKILL.md: frontmatter grants allowed-tools: $(fm_value allowed-tools)"
fm_has hooks && flag REVIEW "SKILL.md: frontmatter declares hooks"

license="$(fm_value license)"
lic_file="$(find "$dir" -maxdepth 1 -iname 'license*' 2>/dev/null | head -n 1)"
if [ -z "$lic_file" ] && [ -n "$root" ] && [ -d "$root" ]; then
  lic_file="$(find "$root" -maxdepth 1 -iname 'license*' 2>/dev/null | head -n 1)"
fi
if [ -n "$license" ] || [ -n "$lic_file" ]; then
  info "license: ${license:-none in frontmatter}${lic_file:+ (file: $(basename "$lic_file"))}"
  [ -n "$lic_file" ] && info "license file starts: $(grep -m 1 -v '^[[:space:]]*$' "$lic_file" | sed 's/^[[:space:]]*//' | cut -c1-80)"
else
  flag REVIEW "no license in the frontmatter, the skill directory or the repo root"
fi

# --- files ---------------------------------------------------------------------------

while IFS= read -r p; do
  files=$((files + 1))
  rel="${p#"$dir"/}"
  if [ -L "$p" ]; then
    target="$(readlink "$p")"
    case "$target" in
      /* | *..*) flag RED "symlink points outside the skill: $rel -> $target" ;;
      *) info "symlink: $rel -> $target" ;;
    esac
    continue
  fi
  case "$(basename "$p")" in
    hooks.json | settings.json | settings.local.json | .mcp.json | mcp.json | plugin.json | marketplace.json)
      flag REVIEW "tool configuration file (hooks, MCP servers, permissions): $rel" ;;
    package.json | requirements.txt | pyproject.toml | Gemfile | go.mod | Cargo.toml)
      flag REVIEW "declares dependencies or install scripts: $rel" ;;
  esac
  case "$p" in
    *.sh | *.bash | *.zsh | *.fish | *.py | *.js | *.mjs | *.cjs | *.ts | *.mts | *.rb | *.pl | *.php | *.ps1 | *.bat | *.cmd | *.lua)
      flag REVIEW "executable code: $rel"; printf '%s\n' "$p" >>"$text_files"; continue ;;
    *.exe | *.dll | *.so | *.dylib | *.jar | *.wasm | *.bin)
      flag REVIEW "compiled binary: $rel"; continue ;;
    *.png | *.jpg | *.jpeg | *.gif | *.webp | *.ico | *.pdf | *.woff | *.woff2 | *.ttf | *.otf) continue ;;
  esac
  [ -r "$p" ] || die "cannot read $rel"
  if [ "$(LC_ALL=C tr -d '\000' <"$p" | wc -c)" -ne "$(wc -c <"$p")" ]; then
    flag REVIEW "binary file: $rel"
    continue
  fi
  printf '%s\n' "$p" >>"$text_files"
  if [ -x "$p" ]; then
    flag REVIEW "executable bit set: $rel"
  elif [ "$(head -c 2 "$p")" = "#!" ]; then
    flag REVIEW "script with a shebang: $rel"
  fi
done < <(find "$dir" \( -type f -o -type l \) ! -path '*/.git/*' | sort)

# --- content -------------------------------------------------------------------------

# Never legitimate in a skill: hidden payloads, decode-and-run, escaping the directory (above).
hits RED "decodes and runs code" -iE -e '(base64[[:space:]]+(-d|--decode)|xxd[[:space:]]+-r)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|python3?|node)([^a-z]|$)'
hits RED "runs a downloaded string" -iE -e 'Invoke-Expression|iex[[:space:]]*\(|eval[[:space:]]*\(?[[:space:]]*"?\$\((curl|wget)'
# Invisible characters: zero-width, bidi overrides, word joiners, BOM, Unicode tag characters.
hits RED "invisible or bidi-control characters" -E -e $'\xe2\x80[\x8b-\x8f\xaa-\xae]|\xe2\x81[\xa0-\xa4\xa6-\xa9]|\xef\xbb\xbf|\xf3\xa0[\x80-\x81]'

# Legitimate in some skills, so a human decides.
hits REVIEW "downloads and runs code" -iE -e '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh)([^a-z]|$)'
hits REVIEW "tries to override instructions" -iE -e 'ignore (all |any )?(the )?(previous|prior|above|earlier) instructions|disregard (the |all )?(previous|prior|system)|do not (tell|inform|mention (it |this )?to) the user|without (asking|telling|informing) the user|(takes?|has) precedence over (all |any |every |other )*(the )?(user|system|instructions|rules|skills|tools)|always use this skill'
hits REVIEW "skips permissions or confirmations" -iE -e '--dangerously|dangerously[-_ ]?(skip|disable|bypass|allow)|skip[- ]permissions|--no-verify|bypass(es|ing)? (the )?(permission|approval|sandbox|confirmation)|auto[- ]?approve|yolo'
# shellcheck disable=SC2088 # a literal `~/` is what we look for, not a path to expand
hits REVIEW "touches credentials or agent configuration" -E -e '~/\.ssh|id_rsa|id_ed25519|\.aws/credentials|~/\.aws|~/\.claude/|\.claude/settings|~/\.config/opencode|~/\.pi/|\.bashrc|\.zshrc|/etc/(passwd|shadow|sudoers)|printenv|keychain'
hits REVIEW "long encoded string" -E -e '[A-Za-z0-9+/]{200,}={0,2}'

urls="$(grep_text -oE -e 'https?://[A-Za-z0-9.-]+')" || { printf '%s\n' "$urls"; exit 3; }
domains="$(printf '%s\n' "$urls" | sed -E 's#^.*https?://##' | grep -v '^$' | sort -u | head -n 15 | tr '\n' ' ')"
[ -n "$domains" ] && info "links to: $domains"

printf 'SUMMARY red=%d review=%d files=%d\n' "$red" "$review" "$files"

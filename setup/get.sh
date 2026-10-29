#!/usr/bin/env bash
# Download a wheelhouse release and run its installer. Arguments go to setup/install.sh:
#   curl -fsSL https://github.com/bitIO/wheelhouse/releases/latest/download/get.sh | bash
#   curl -fsSL .../get.sh | bash -s -- --project ~/dev/my-app
# WHEELHOUSE_VERSION=v1.2.0 pins a release. Works with bash 3.2 (macOS).
set -euo pipefail

URL="${WHEELHOUSE_URL:-https://github.com/bitIO/wheelhouse}"
DEST="${WHEELHOUSE_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/wheelhouse}"
version="${WHEELHOUSE_VERSION:-}"

if [ -z "$version" ]; then
  # /releases/latest redirects to /releases/tag/<version>; no API token or jq needed.
  version="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$URL/releases/latest")"
  version="${version##*/}"
fi
case "$version" in
  v[0-9]*) ;;
  *) echo "Could not find a wheelhouse release (got: $version)" >&2; exit 1 ;;
esac

if [ -e "$DEST" ] && [ ! -f "$DEST/setup/install.sh" ]; then
  echo "$DEST exists and is not a wheelhouse download; set WHEELHOUSE_HOME to another path" >&2
  exit 1
fi

if [ "$(cat "$DEST/VERSION" 2>/dev/null || true)" != "$version" ]; then
  echo "wheelhouse: downloading $version into $DEST"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "$URL/archive/refs/tags/$version.tar.gz" | tar -xz -C "$tmp"
  src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d)"
  [ -f "$src/setup/install.sh" ] || { echo "Download did not contain setup/install.sh" >&2; exit 1; }
  printf '%s\n' "$version" >"$src/VERSION"
  # Same path every version, so the installer recognises and updates its earlier symlinks.
  mkdir -p "$(dirname "$DEST")"
  rm -rf "$DEST"
  mv "$src" "$DEST"
  rm -rf "$tmp" # exec below skips the EXIT trap
fi

exec bash "$DEST/setup/install.sh" "$@"

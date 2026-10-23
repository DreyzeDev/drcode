#!/usr/bin/env bash

set -Eeuo pipefail

readonly DRCODE_HOME="${DRCODE_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/drcode}"
readonly DRCODE_CONFIG_HOME="${DRCODE_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/drcode}"
readonly DRCODE_BIN_DIR="${DRCODE_BIN_DIR:-$HOME/.local/bin}"

purge=false
case "${1:-}" in
  "") ;;
  --purge) purge=true ;;
  --help | -h)
    cat <<'EOF'
Usage: bash uninstall.sh [--purge]

Removes the DrCode launcher and engine. Configuration and the AgentRouter key
are preserved unless --purge is supplied.
EOF
    exit 0
    ;;
  *)
    printf 'Unknown argument: %s\n' "$1" >&2
    exit 1
    ;;
esac

safe_remove_directory() {
  local target="$1"
  [[ -n "$target" && "$target" != "/" && "$target" != "$HOME" ]] || {
    printf 'Refusing to remove unsafe path: %s\n' "$target" >&2
    exit 1
  }
  if [[ -d "$target" && ! -f "$target/.drcode-install" ]]; then
    printf 'Refusing to remove an unrecognized directory: %s\n' "$target" >&2
    exit 1
  fi
  rm -rf "$target"
}

launcher="$DRCODE_BIN_DIR/drcode"
if [[ -f "$launcher" ]]; then
  if grep -Fq 'DRCODE_LAUNCHER=1' "$launcher"; then
    rm -f "$launcher"
  else
    printf 'Preserving unrecognized launcher: %s\n' "$launcher" >&2
  fi
fi

safe_remove_directory "$DRCODE_HOME"

if "$purge"; then
  safe_remove_directory "$DRCODE_CONFIG_HOME"
  printf 'DrCode and its configuration were removed.\n'
  exit 0
fi

printf 'DrCode was removed. Configuration was preserved at %s\n' "$DRCODE_CONFIG_HOME"
printf 'Run with --purge to remove configuration and the API key too.\n'

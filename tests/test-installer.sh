#!/usr/bin/env bash

set -Eeuo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/drcode-test.XXXXXX")"
trap 'rm -rf "$temporary_directory"' EXIT

home="$temporary_directory/home"
fixture="$temporary_directory/fixture"
archive="$temporary_directory/opencode.tar.gz"
mkdir -p "$home" "$fixture"

cat >"$fixture/opencode" <<'EOF'
#!/usr/bin/env bash
if [[ -n "${DRCODE_TEST_ARGUMENTS:-}" ]]; then
  printf '%s\n' "$@" >"$DRCODE_TEST_ARGUMENTS"
fi
if [[ "${1:-}" == "--version" ]]; then
  printf 'opencode test-engine\n'
fi
EOF
chmod 755 "$fixture/opencode"
tar -czf "$archive" -C "$fixture" opencode

HOME="$home" \
XDG_CONFIG_HOME="$home/.config" \
XDG_DATA_HOME="$home/.local/share" \
DRCODE_SOURCE_DIR="$PROJECT_ROOT" \
DRCODE_ENGINE_ARCHIVE="$archive" \
bash "$PROJECT_ROOT/install.sh"

launcher="$home/.local/bin/drcode"
config="$home/.config/drcode/opencode"

[[ -x "$launcher" ]]
[[ -x "$home/.local/share/drcode/bin/opencode" ]]
[[ -s "$config/opencode.json" ]]
[[ -s "$config/cli.json" ]]
[[ -s "$config/AGENTS.md" ]]
[[ -s "$config/themes/drcode.json" ]]
[[ -s "$home/.local/share/drcode/.drcode-install" ]]
[[ -s "$home/.config/drcode/.drcode-install" ]]

HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_DATA_HOME="$home/.local/share" "$launcher" doctor >/dev/null

arguments="$temporary_directory/arguments"
HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_DATA_HOME="$home/.local/share" DRCODE_TEST_ARGUMENTS="$arguments" "$launcher" --model sol --help
grep -Fxq -- '--standalone' "$arguments"
grep -Fxq -- '--model' "$arguments"
grep -Fxq -- 'agentrouter/gpt-6.1-sol' "$arguments"

HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_DATA_HOME="$home/.local/share" DRCODE_TEST_ARGUMENTS="$arguments" "$launcher" models
[[ "$(sed -n '1p' "$arguments")" == "models" ]]
[[ "$(sed -n '2p' "$arguments")" == "--standalone" ]]

config_checksum="$(sha256sum "$config/opencode.json")"
HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_DATA_HOME="$home/.local/share" bash "$PROJECT_ROOT/uninstall.sh"
[[ ! -e "$launcher" ]]
[[ ! -e "$home/.local/share/drcode/bin" ]]
[[ -s "$home/.local/share/drcode/.drcode-install" ]]
[[ -s "$home/.config/drcode/.drcode-install" ]]

HOME="$home" \
XDG_CONFIG_HOME="$home/.config" \
XDG_DATA_HOME="$home/.local/share" \
DRCODE_SOURCE_DIR="$PROJECT_ROOT" \
DRCODE_ENGINE_ARCHIVE="$archive" \
bash "$PROJECT_ROOT/install.sh" >/dev/null
[[ "$(sha256sum "$config/opencode.json")" == "$config_checksum" ]]

HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_DATA_HOME="$home/.local/share" bash "$PROJECT_ROOT/uninstall.sh" --purge
[[ ! -e "$home/.local/bin/drcode" ]]
[[ ! -e "$home/.config/drcode" ]]

printf 'Installer test passed.\n'

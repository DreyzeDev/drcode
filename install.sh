#!/usr/bin/env bash

set -Eeuo pipefail

readonly DRCODE_INSTALLER_VERSION="0.1.0"
readonly DRCODE_REPOSITORY="https://github.com/DreyzeDev/drcode"
readonly DRCODE_REF="${DRCODE_REF:-main}"
readonly DRCODE_RAW_BASE="${DRCODE_RAW_BASE:-https://raw.githubusercontent.com/DreyzeDev/drcode/$DRCODE_REF}"
readonly DRCODE_HOME="${DRCODE_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/drcode}"
readonly DRCODE_CONFIG_HOME="${DRCODE_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/drcode}"
readonly DRCODE_BIN_DIR="${DRCODE_BIN_DIR:-$HOME/.local/bin}"
readonly DRCODE_ENGINE_DIR="$DRCODE_HOME/bin"
readonly DRCODE_OPENCODE_CONFIG="$DRCODE_CONFIG_HOME/opencode"

temporary_directory=""
source_directory="${DRCODE_SOURCE_DIR:-}"
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
if [[ -z "$source_directory" && -f "$script_directory/bin/drcode" && -f "$script_directory/assets/drcode.json" ]]; then
  source_directory="$script_directory"
fi

cleanup() {
  if [[ -n "$temporary_directory" && -d "$temporary_directory" ]]; then
    rm -rf "$temporary_directory"
  fi
}
trap cleanup EXIT

fail() {
  printf 'DrCode installer: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '  %s\n' "$*"
}

usage() {
  cat <<'EOF'
Install DrCode for the current Linux user.

Usage:
  bash install.sh

Environment overrides:
  DRCODE_HOME            Application data directory
  DRCODE_CONFIG_HOME     Configuration directory
  DRCODE_BIN_DIR         Launcher directory
  DRCODE_SOURCE_DIR      Local checkout used for installer assets
  DRCODE_ENGINE_ARCHIVE  Existing OpenCode .tar.gz archive (testing/offline use)
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi
if [[ "${1:-}" == "--version" ]]; then
  printf '%s\n' "$DRCODE_INSTALLER_VERSION"
  exit 0
fi
[[ $# -eq 0 ]] || fail "неизвестный аргумент: $1"

[[ "$(uname -s)" == "Linux" ]] || fail "сейчас поддерживается только Linux"
for command_name in curl tar mktemp install uname; do
  command -v "$command_name" >/dev/null 2>&1 || fail "не найдена команда: $command_name"
done

architecture=""
case "$(uname -m)" in
  x86_64 | amd64)
    architecture="x64"
    if [[ -r /proc/cpuinfo ]] && ! grep -qw avx2 /proc/cpuinfo; then
      architecture="x64-baseline"
    fi
    ;;
  aarch64 | arm64)
    architecture="arm64"
    ;;
  *)
    fail "неподдерживаемая архитектура: $(uname -m)"
    ;;
esac

libc_suffix=""
if command -v ldd >/dev/null 2>&1 && ldd_output="$(ldd --version 2>&1 || true)" && grep -qi musl <<<"$ldd_output"; then
  libc_suffix="-musl"
fi

platform="$architecture$libc_suffix"
if [[ "$architecture" == "x64-baseline" && "$libc_suffix" == "-musl" ]]; then
  platform="x64-baseline-musl"
fi

temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/drcode-install.XXXXXX")"
archive="$temporary_directory/opencode.tar.gz"

printf 'Installing DrCode %s\n' "$DRCODE_INSTALLER_VERSION"
info "platform: linux-$platform"

if [[ -e "$DRCODE_BIN_DIR/drcode" ]] && ! grep -Fq 'DRCODE_LAUNCHER=1' "$DRCODE_BIN_DIR/drcode"; then
  fail "путь уже занят другим файлом: $DRCODE_BIN_DIR/drcode"
fi
if [[ -d "$DRCODE_HOME" && ! -f "$DRCODE_HOME/.drcode-install" ]] && [[ -n "$(find "$DRCODE_HOME" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  fail "каталог уже содержит другие данные: $DRCODE_HOME"
fi

if [[ -n "${DRCODE_ENGINE_ARCHIVE:-}" ]]; then
  [[ -f "$DRCODE_ENGINE_ARCHIVE" ]] || fail "архив не найден: $DRCODE_ENGINE_ARCHIVE"
  cp "$DRCODE_ENGINE_ARCHIVE" "$archive"
else
  drcode_engine_url="https://github.com/DreyzeDev/drcode/releases/download/v0.2.0-drcode/drcode-engine-linux-$platform.tar.gz"
  if [[ "$platform" == "x64" ]] && curl --proto '=https' --tlsv1.2 -fsSL --retry 2 "$drcode_engine_url" -o "$archive" 2>/dev/null; then
    info "downloading DrCode engine $platform"
  else
    rm -f "$archive"
    engine_url="https://opencode.ai/update/api/latest/cli/opencode/opencode-linux-$platform.tar.gz"
    info "downloading OpenCode engine"
    curl --proto '=https' --tlsv1.2 -fsSL --retry 3 "$engine_url" -o "$archive"
  fi
fi

archive_entries="$(tar -tzf "$archive")"
[[ "$archive_entries" == "opencode" || "$archive_entries" == "./opencode" ]] || fail "неожиданное содержимое архива движка"
tar -xzf "$archive" -C "$temporary_directory"
[[ -f "$temporary_directory/opencode" ]] || fail "движок отсутствует в архиве"

install -d -m 700 "$DRCODE_HOME"
install -d -m 755 "$DRCODE_ENGINE_DIR" "$DRCODE_BIN_DIR"
install -m 755 "$temporary_directory/opencode" "$DRCODE_ENGINE_DIR/.opencode.new"
mv -f "$DRCODE_ENGINE_DIR/.opencode.new" "$DRCODE_ENGINE_DIR/opencode"
printf '%s\n' "$DRCODE_INSTALLER_VERSION" >"$DRCODE_HOME/.drcode-install"
chmod 600 "$DRCODE_HOME/.drcode-install"

asset() {
  local source_path="$1"
  local output_path="$2"

  if [[ -n "$source_directory" ]]; then
    [[ -f "$source_directory/$source_path" ]] || fail "файл установщика не найден: $source_path"
    cp "$source_directory/$source_path" "$output_path"
    return
  fi

  if curl --proto '=https' --tlsv1.2 -fsSL --retry 3 "$DRCODE_RAW_BASE/$source_path" -o "$output_path" 2>/dev/null; then
    return
  fi
  rm -f "$output_path"

  if command -v gh >/dev/null 2>&1 && gh api \
    --header 'Accept: application/vnd.github.raw+json' \
    "repos/DreyzeDev/drcode/contents/$source_path?ref=$DRCODE_REF" >"$output_path"; then
    return
  fi
  fail "не удалось получить $source_path; клонируйте приватный репозиторий через gh"
}

asset "bin/drcode" "$temporary_directory/drcode"
install -m 755 "$temporary_directory/drcode" "$DRCODE_BIN_DIR/drcode"

install -d -m 700 "$DRCODE_CONFIG_HOME"
install -d -m 755 "$DRCODE_OPENCODE_CONFIG" "$DRCODE_OPENCODE_CONFIG/themes"
printf '%s\n' "$DRCODE_INSTALLER_VERSION" >"$DRCODE_CONFIG_HOME/.drcode-install"
chmod 600 "$DRCODE_CONFIG_HOME/.drcode-install"

install_default() {
  local source_path="$1"
  local destination="$2"
  local temporary="$temporary_directory/$(basename "$source_path")"

  if [[ -e "$destination" ]]; then
    info "preserving existing $(basename "$destination")"
    return
  fi
  asset "$source_path" "$temporary"
  install -m 644 "$temporary" "$destination"
}

install_default "config/opencode.json" "$DRCODE_OPENCODE_CONFIG/opencode.json"
install_default "config/cli.json" "$DRCODE_OPENCODE_CONFIG/cli.json"
install_default "config/AGENTS.md" "$DRCODE_OPENCODE_CONFIG/AGENTS.md"

asset "assets/drcode.json" "$temporary_directory/drcode.json"
install -m 644 "$temporary_directory/drcode.json" "$DRCODE_OPENCODE_CONFIG/themes/drcode.json"

asset "uninstall.sh" "$temporary_directory/uninstall.sh"
install -m 755 "$temporary_directory/uninstall.sh" "$DRCODE_HOME/uninstall.sh"

printf '\nDrCode installed successfully.\n'
info "launcher: $DRCODE_BIN_DIR/drcode"
info "config:   $DRCODE_CONFIG_HOME"
printf '\nNext steps:\n'
printf '  1. drcode ~/path/to/project and type your first prompt\n'
printf '     (connection window opens immediately if no key is connected)\n'
printf '  2. Choose AgentRouter and/or OxionAI, enter your own API key\n'

case ":$PATH:" in
  *":$DRCODE_BIN_DIR:"*) ;;
  *)
    printf '\nAdd this directory to PATH:\n  export PATH="%s:$PATH"\n' "$DRCODE_BIN_DIR"
    ;;
esac

printf '\nDocumentation: %s\n' "$DRCODE_REPOSITORY"

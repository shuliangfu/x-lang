#!/usr/bin/env bash
# std-cli.sh — STD-077 manifest 与烟测辅助

STD_CLI_PREFIX="${SHUX_STD_CLI_PREFIX:-shux: [SHUX_STD_CLI]}"

std_cli_symbols_ok() {
  local mod_x="$1"
  local cli_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-cli FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/cli/cli.c" ] || [ "$path" = "std/cli/cli.x" ]; then path="$cli_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-cli FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|cookbook)
        if [ ! -f "$anchor" ]; then
          echo "std-cli FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_cli_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-cli}"
  local exe="/tmp/shux_std_cli_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-cli FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-cli FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_cli_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_CLI_PREFIX} status=${status} c_smoke=${c_ok} x=${su_ok} skip=${skip}"
}

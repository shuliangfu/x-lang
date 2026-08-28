#!/usr/bin/env bash
# std-cli.sh — STD-077 std.cli helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_cli_symbols_ok MOD_X CLI_X TSV [DOC]
#   std_cli_host_c_obs SMOKE_C
#   std_cli_run_smoke XLANG SRC [TAG]
#   std_cli_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CLI_PREFIX="${XLANG_STD_CLI_PREFIX:-xlang: [XLANG_STD_CLI]}"

# Validate manifest api/symbol/file/smoke/script/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_cli_symbols_ok() {
  local mod_x="$1"
  local cli_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-cli-v1.md}"
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
        if [ "$path" = "std/cli/cli.c" ] || [ "$path" = "std/cli/cli.x" ]; then path="$cli_x"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-cli FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|cookbook|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-cli FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-cli FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt std/cli/cli.o only.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# Returns 0 C smoke linked+ran on existing object, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_cli_host_c_obs() {
  local smoke_c="${1:-tests/std-cli/cli_smoke_ok.c}"
  local cli_o="std/cli/cli.o"
  if [ ! -f "$cli_o" ]; then
    echo "std-cli OBS host-C (missing prebuilt $cli_o; refuse soft auto-make)" >&2
    return 2
  fi
  if [ ! -f "$smoke_c" ]; then
    echo "std-cli OBS host-C (missing $smoke_c)" >&2
    return 2
  fi
  local out="/tmp/xlang_cli_smoke_$$"
  local log="/tmp/xlang_cli_smoke_link_$$.err"
  if ! cc -std=c11 -O1 -o "$out" "$smoke_c" "$cli_o" 2>"$log"; then
    echo "std-cli OBS host-C link (existing .o only; refuse soft auto-make)" >&2
    tail -n 10 "$log" 2>/dev/null || true
    rm -f "$out" "$log"
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-cli OBS host-C run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product -o smoke. Return 0 exit0, 1 compile/run fail.
# Do not restore set -e before return 1.
std_cli_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-cli}"
  local exe="/tmp/xlang_std_cli_${tag}_$$"
  local log="/tmp/xlang_std_cli_${tag}_build_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-cli FAIL: compile $src" >&2
    tail -n 12 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-cli FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_cli_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CLI_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

#!/usr/bin/env bash
# std-async-api.sh — STD-004 manifest + smoke helpers.
#
# Usage (after source):
#   std_async_api_symbols_ok MOD_X TSV
#   std_async_api_run_smoke XLANG_BIN X TAG
#   std_async_api_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/coop = obs; switch+imp+drain product -o hard,
# all three folded into run=). Refuse soft RUN_XLANG / soft ensure.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ASYNC_API_PREFIX="${XLANG_STD_ASYNC_API_PREFIX:-xlang: [XLANG_STD_ASYNC_API]}"

# Count missing Tier-S symbols from one-symbol-per-line TSV against mod.x.
# Prints miss count on stdout; returns 0 iff miss==0.
std_async_api_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local n=0
  local line sym
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac
    # Ignore future structured TSV rows (kind in column 2).
    case "$line" in
      *$'\t'*) continue ;;
    esac
    sym="$line"
    n=$((n + 1))
    if ! grep -qE "(function|extern function) ${sym}[[:space:](]" "$mod_x" 2>/dev/null; then
      echo "std-async-api FAIL: missing symbol ${sym} in $mod_x" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  if [ "$n" -lt 1 ]; then
    echo "std-async-api FAIL: empty symbol list in $tsv" >&2
    echo 1
    return 1
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x via product XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG / soft ensure rebuild (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path.
std_async_api_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_async_api_${tag}_$$"
  local log="/tmp/xlang_std_async_api_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-async-api FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-async-api FAIL: compile $src" >&2
    tail -n 10 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-async-api FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal = switch + imp + drain product -o (run=3); check/coop = obs.
std_async_api_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ASYNC_API_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

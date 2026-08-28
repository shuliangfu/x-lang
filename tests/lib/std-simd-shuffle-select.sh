#!/usr/bin/env bash
# std-simd-shuffle-select.sh — STD-047 manifest + smoke helpers.
#
# Usage (after source):
#   std_simd_ss_symbols_ok MOD_X TSV
#   std_simd_ss_run_smoke XLANG_BIN X TAG
#   std_simd_ss_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/s4-non-x86 = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SIMD_SS_PREFIX="${XLANG_STD_SIMD_SHUFFLE_SELECT_PREFIX:-xlang: [XLANG_STD_SIMD_SHUFFLE_SELECT]}"

std_simd_ss_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-simd-shuffle-select FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-simd-shuffle-select FAIL: missing smoke '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x smoke via product XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG remap / soft auto-make (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path; SIMD needs asm backend.
std_simd_ss_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_simd_ss_${tag}_$$"
  local log="/tmp/xlang_std_simd_ss_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-simd-shuffle-select FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-simd-shuffle-select FAIL: compile $src" >&2
    tail -n 12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-shuffle-select FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o shuffle_select_roundtrip.x; check/s4-non-x86 = obs.
std_simd_ss_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SIMD_SS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

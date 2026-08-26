#!/usr/bin/env bash
# std-simd-shuffle-select.sh — STD-047 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_simd_ss_symbols_ok MOD_X TSV
#   std_simd_ss_run_smoke XLANG_BIN X TAG
#   std_simd_ss_emit_report status check_ok shuffle_ok select_ok s4_ok skip
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

# Compile + link + run .x smoke via product asm. Hard-fail on any step.
# Prefer RUN_XLANG (bootstrap-link) when gate pinned XLANG_LINK_XLANG.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_simd_ss_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_simd_ss_${tag}_$$"
  local log="/tmp/xlang_std_simd_ss_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-simd-shuffle-select FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-simd-shuffle-select FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-simd-shuffle-select FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
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

# Structured report: check observational; shuffle/select hard; s4 platform;
# skip=0 when runnable roundtrip ran.
std_simd_ss_emit_report() {
  local status="$1"
  local check_ok="$2"
  local shuffle_ok="$3"
  local select_ok="$4"
  local s4_ok="$5"
  local skip="${6:-0}"
  echo "${STD_SIMD_SS_PREFIX} status=${status} check=${check_ok} shuffle=${shuffle_ok} select=${select_ok} s4=${s4_ok} skip=${skip}"
}

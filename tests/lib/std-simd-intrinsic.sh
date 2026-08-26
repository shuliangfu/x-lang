#!/usr/bin/env bash
# std-simd-intrinsic.sh — STD-SIMD-INTRINSIC manifest 与烟测辅助
#
# 用法（source 后）：
#   std_simd_intrinsic_symbols_ok MOD_X TSV
#   std_simd_intrinsic_run_smoke XLANG_BIN X [TAG]
#   std_simd_intrinsic_emit_report status check_ok x_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SIMD_INTRINSIC_PREFIX="${XLANG_STD_SIMD_INTRINSIC_PREFIX:-xlang: [XLANG_STD_SIMD_INTRINSIC]}"

std_simd_intrinsic_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null || miss=$((miss + 1))
        ;;
      smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile + link + run .x smoke via product asm. Hard-fail on any step.
# Prefer RUN_XLANG (bootstrap-link) when gate pinned XLANG_LINK_XLANG.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_simd_intrinsic_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_simd_intrinsic_${tag}_$$"
  local log="/tmp/xlang_std_simd_intrinsic_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-simd-intrinsic FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-simd-intrinsic FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-simd-intrinsic FAIL: compile $src" >&2
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
    echo "std-simd-intrinsic FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report: check observational; x hard; skip=0 when runnable ran.
std_simd_intrinsic_emit_report() {
  local status="$1"
  local check_ok="$2"
  local x_ok="$3"
  local skip="${4:-0}"
  echo "${STD_SIMD_INTRINSIC_PREFIX} status=${status} check=${check_ok} x=${x_ok} skip=${skip}"
}

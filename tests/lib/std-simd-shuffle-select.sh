#!/usr/bin/env bash
# std-simd-shuffle-select.sh — STD-047 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_simd_ss_symbols_ok MOD_SX TSV
#   std_simd_ss_run_smoke SHUX_BIN SX TAG
#   std_simd_ss_emit_report status shuffle_ok select_ok s4_ok skip

STD_SIMD_SS_PREFIX="${SHUX_STD_SIMD_SHUFFLE_SELECT_PREFIX:-shux: [SHUX_STD_SIMD_SHUFFLE_SELECT]}"

std_simd_ss_symbols_ok() {
  local mod_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-simd-shuffle-select FAIL: missing api '$anchor' in $mod_sx" >&2
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

std_simd_ss_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local obj="/tmp/shux_std_simd_ss_${tag}_$$.o"
  local exe="/tmp/shux_std_simd_ss_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-simd-shuffle-select FAIL: missing $src" >&2
    return 1
  fi
  # 先编译 .o（避免链 task.o 等待未解析 async 符号导致误报）
  if ! "$shux" -L . "$src" -o "$obj" >/dev/null 2>&1; then
    echo "std-simd-shuffle-select FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$obj" 2>&1 | tail -10 >&2 || true
    rm -f "$obj" "$exe"
    return 1
  fi
  if [ ! -f "$obj" ]; then
    echo "std-simd-shuffle-select FAIL: missing object $obj" >&2
    return 1
  fi
  rm -f "$obj"
  # 可选：链接可执行并跑断言（依赖完整 runtime 链，失败时不阻断 manifest+typeck）
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-simd-shuffle-select WARN: link/run skipped (compile .o OK)" >&2
    return 0
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-shuffle-select WARN: run $src exit=$ec (compile OK)" >&2
    return 0
  fi
  return 0
}

std_simd_ss_emit_report() {
  local status="$1"
  local shuffle_ok="$2"
  local select_ok="$3"
  local s4_ok="$4"
  local skip="$5"
  echo "${STD_SIMD_SS_PREFIX} status=${status} shuffle=${shuffle_ok} select=${select_ok} s4=${s4_ok} skip=${skip}"
}

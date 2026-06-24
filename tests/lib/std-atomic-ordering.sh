#!/usr/bin/env bash
# std-atomic-ordering.sh — STD-046 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_atomic_ord_symbols_ok MOD_SX ATOMIC_C TSV
#   std_atomic_ord_run_smoke SHUX_BIN SX TAG
#   std_atomic_ord_emit_report status fence_ok main_ok skip

STD_ATOMIC_ORD_PREFIX="${SHUX_STD_ATOMIC_ORDERING_PREFIX:-shux: [SHUX_STD_ATOMIC_ORDERING]}"

std_atomic_ord_symbols_ok() {
  local mod_sx="$1"
  local atomic_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|const)
        if ! grep -qE "(function ${anchor}\\(|const ${anchor}:)" "$mod_sx" 2>/dev/null; then
          echo "std-atomic-ordering FAIL: missing '$anchor' in $mod_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/atomic/atomic_glue.c|compiler/src/asm/runtime_atomic_glue.c) mod_path="$atomic_c" ;;
          *) mod_path="$mod_sx" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-atomic-ordering FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-atomic-ordering FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_atomic_ord_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_atomic_ord_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-atomic-ordering FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-atomic-ordering FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-atomic-ordering FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_atomic_ord_emit_report() {
  local status="$1"
  local fence_ok="$2"
  local main_ok="$3"
  local skip="$4"
  echo "${STD_ATOMIC_ORD_PREFIX} status=${status} fence=${fence_ok} main=${main_ok} skip=${skip}"
}

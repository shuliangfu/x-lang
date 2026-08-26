#!/usr/bin/env bash
# std-queue-concurrent.sh — STD-048 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_queue_conc_symbols_ok MOD_X QUEUE_C TSV
#   std_queue_conc_run_smoke XLANG_BIN X TAG
#   std_queue_conc_emit_report status check_ok main_ok sync_ok c_ok skip

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_QUEUE_CONC_PREFIX="${XLANG_STD_QUEUE_CONCURRENT_PREFIX:-xlang: [XLANG_STD_QUEUE_CONCURRENT]}"

std_queue_conc_symbols_ok() {
  local mod_x="$1"
  local queue_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-queue-concurrent FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-queue-concurrent FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/queue/queue.x) mod_path="$queue_c" ;;
          *) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-queue-concurrent FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-queue-concurrent FAIL: missing smoke '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_queue_conc_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_queue_conc_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-queue-concurrent FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-queue-concurrent FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-queue-concurrent FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_queue_conc_run_c_smoke() {
  local queue_c="$1"
  local src="tests/queue/sync_queue_contention_ok.c"
  local out="/tmp/xlang_sync_queue_contention_$$"
  local queue_o
  queue_o="$(dirname "$queue_c")/queue.o"
  if [ ! -f "$queue_o" ]; then
    echo "std-queue-concurrent FAIL: missing $queue_o" >&2
    return 1
  fi
  xlang_compiler_make runtime_queue_contention.o >/dev/null 2>&1 || true
  if ! cc -std=c11 -O1 -o "$out" "$src" "$queue_o" compiler/runtime_queue_contention.o -lpthread 2>/dev/null; then
    echo "std-queue-concurrent FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-queue-concurrent FAIL: contention smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_queue_conc_emit_report() {
  local status="$1"
  local check_ok="$2"
  local main_ok="$3"
  local sync_ok="$4"
  local c_ok="$5"
  local skip="$6"
  echo "${STD_QUEUE_CONC_PREFIX} status=${status} check=${check_ok} main=${main_ok} sync=${sync_ok} c=${c_ok} skip=${skip}"
}

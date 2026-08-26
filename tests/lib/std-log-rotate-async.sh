#!/usr/bin/env bash
# std-log-rotate-async.sh — STD-106 manifest 与烟测辅助（日志轮转 + 异步缓冲）。
#
# 用法（source 后）：
#   std_log_rotate_async_symbols_ok MOD_X LOG_X LOG_GLUE TSV
#   std_log_rotate_async_run_c_smoke LOG_X
#   std_log_rotate_async_emit_report status check_ok run_ok skip
# 2026-08-26: report check=/run=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_LOG_ROTATE_ASYNC_PREFIX="${XLANG_STD106_LOG_ROTATE_ASYNC_PREFIX:-xlang: [XLANG_STD106_LOG_ROTATE_ASYNC]}"

# Validate manifest; echo miss count. Rotate/async C symbols live in runtime_log_os.
std_log_rotate_async_symbols_ok() {
  local mod_x="$1"
  local log_x="$2"
  local log_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-log-rotate-async FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/log/log.c|std/log/log.x) path="$log_x" ;;
          std/log/log_os_glue.c|compiler/seeds/runtime_log_os.from_x.c) path="$log_glue" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-log-rotate-async FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-log-rotate-async FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|anchor|doc)
        # DOC keyword / ## 5. Gate anchors are validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational host-C archaeology smoke (link log.o + runtime_log_os.o).
# Not a hard-green signal; callers must treat failure as SKIP note.
std_log_rotate_async_run_c_smoke() {
  local _log_impl="$1"
  local src="tests/std-log/rotate_async_smoke_ok.c"
  local out="/tmp/xlang_std_log_rotate_async_$$"
  local log_o="std/log/log.o"
  local rt_o="compiler/runtime_log_os.o"
  if [ ! -f "$log_o" ]; then
    return 1
  fi
  if [ ! -f "$rt_o" ]; then
    xlang_compiler_make -q runtime_log_os.o 2>/dev/null || xlang_compiler_make runtime_log_os.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$rt_o" ]; then
    return 1
  fi
  # Observational only: silent link failure (gate prints SKIP note).
  if ! cc -std=c11 -O1 -o "$out" "$src" "$log_o" "$rt_o" 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Emit structured report line (honesty: check=/run=/skip=).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 run_ok — runnable .x smoke exit0 (hard green signal)
# @param $4 skip — 1 only for manifest-only / no-native paths
std_log_rotate_async_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_LOG_ROTATE_ASYNC_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

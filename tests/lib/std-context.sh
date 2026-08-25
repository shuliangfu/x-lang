#!/usr/bin/env bash
# std-context.sh — STD-071 manifest helpers (F-context v2: pure context.x)
#
# Usage (after source):
#   std_context_symbols_ok MOD_X CTX_X TSV
#   std_context_run_c_smoke CTX_X   # observational host-C archaeology only
#   std_context_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_CONTEXT_PREFIX="${XLANG_STD_CONTEXT_PREFIX:-xlang: [XLANG_STD_CONTEXT]}"

# Validate manifest api/symbol/file/smoke anchors; symbols live in context.x.
# Echo miss count; return 0 when miss=0.
std_context_symbols_ok() {
  local mod_x="$1"
  local ctx_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-context FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/context/context.c|std/context/context.x|std/context/context_node_glue.c) path="$ctx_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-context FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-context FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: context.o + time.o (host-C archaeology; not hard green).
# PLATFORM: SHARED archaeology — product honesty is cancel_smoke.x via prefer-asm.
std_context_run_c_smoke() {
  local ctx_x="$1"
  local src="tests/std-context/context_smoke_ok.c"
  local out="/tmp/xlang_std_context_$$"
  local ctx_o time_o
  ctx_o="$(dirname "$ctx_x")/context.o"
  time_o="std/time/time.o"
  if [ ! -f "$ctx_o" ]; then
    echo "std-context FAIL: missing $ctx_o" >&2
    return 1
  fi
  if [ ! -f "$time_o" ]; then
    xlang_compiler_make ../std/time/time.o >/dev/null 2>&1 || true
  fi
  xlang_compiler_make runtime_time_os.o >/dev/null 2>&1 || true
  if ! cc -std=c11 -O1 -o "$out" "$src" "$ctx_o" "$time_o" compiler/runtime_time_os.o 2>/dev/null; then
    echo "std-context FAIL: compile c smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-context FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_context_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_CONTEXT_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

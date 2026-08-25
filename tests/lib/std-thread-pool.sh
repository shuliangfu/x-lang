#!/usr/bin/env bash
# std-thread-pool.sh — STD-043 manifest + smoke helpers
#
# Usage (after source):
#   std_thread_pool_symbols_ok MOD_X THREAD_C TSV
#   std_thread_pool_run_smoke XLANG_BIN X TAG
#   std_thread_pool_emit_report status check_ok pool_ok name_ok main_ok skip
# 2026-08-26: report check=/pool=/name=/main=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_THREAD_POOL_PREFIX="${XLANG_STD_THREAD_POOL_PREFIX:-xlang: [XLANG_STD_THREAD_POOL]}"

# Validate manifest symbol/file/api; echo miss count; return 0 iff miss==0.
std_thread_pool_symbols_ok() {
  local mod_x="$1"
  local thread_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-thread-pool FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          compiler/seeds/runtime_thread_glue.from_x.c) mod_path="$thread_c" ;;
          *) mod_path="${mod_path:-$mod_x}" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-thread-pool FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-thread-pool FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script|cross_ref)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run a smoke .x (thread.o must already be ensured by the gate).
# Honors XLANG / XLANG_LINK_XLANG when the caller pinned prefer-asm.
std_thread_pool_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_thread_pool_${tag}_$$"
  local run_xlang="${XLANG:-$xlang}"
  if [ ! -f "$src" ]; then
    echo "std-thread-pool FAIL: missing $src" >&2
    return 1
  fi
  if ! "$run_xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-thread-pool FAIL: compile $src" >&2
    "$run_xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-thread-pool FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/pool=/name=/main=/skip=).
# Hard-green signal = pool= + main=; check observational; name tracks pool
# (pool_roundtrip exercises set_name_self).
std_thread_pool_emit_report() {
  local status="$1"
  local check_ok="$2"
  local pool_ok="$3"
  local name_ok="$4"
  local main_ok="$5"
  local skip="$6"
  echo "${STD_THREAD_POOL_PREFIX} status=${status} check=${check_ok} pool=${pool_ok} name=${name_ok} main=${main_ok} skip=${skip}"
}

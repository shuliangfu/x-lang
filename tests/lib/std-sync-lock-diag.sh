#!/usr/bin/env bash
# std-sync-lock-diag.sh — STD-111 manifest 与烟测辅助（F-sync-lock-diag v2：逻辑在 sync.x）
# Honesty 2026-08-26: report check=/run=/skip=; TSV anchors = product lock_diag_*.

STD_SYNC_LOCK_DIAG_PREFIX="${XLANG_STD111_SYNC_LOCK_DIAG_PREFIX:-xlang: [XLANG_STD111_SYNC_LOCK_DIAG]}"

# Validate manifest entries against product mod.x / sync.x; echo miss count.
# @param mod_x path to std/sync/mod.x
# @param sync_diag_x path to std/sync/sync.x (symbol anchors)
# @param tsv path to baseline TSV
# @return 0 when miss==0
std_sync_lock_diag_symbols_ok() {
  local mod_x="$1"
  local sync_diag_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-sync-lock-diag FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/sync/sync.c|std/sync/sync_lock_diag_glue.c|std/sync/sync.x) path="$sync_diag_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sync-lock-diag FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-sync-lock-diag FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        : # gate path checked by gate itself
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x smoke (legacy helper; gate prefers RUN_XLANG build).
# @param xlang compiler binary
# @param src .x smoke path
# @param tag temp exe tag
# @return 0 on exit 0
std_sync_lock_diag_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-lock_diag}"
  local exe="/tmp/xlang_std_sync_lock_diag_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-sync-lock-diag FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-sync-lock-diag FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Emit structured report line (honesty: check=/run=/skip=).
# @param status ok|fail
# @param check_ok 0|1 observational xlang check
# @param run_ok 0|1 hard runnable exit0
# @param skip 0|1 residual skip bit (0 when runnable hard-green)
std_sync_lock_diag_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_SYNC_LOCK_DIAG_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

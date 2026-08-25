#!/usr/bin/env bash
# std-bytes.sh — STD-072 manifest helpers (dynamic Bytes buffer).
#
# Usage (after source):
#   std_bytes_symbols_ok MOD_X TSV [DOC]
#   std_bytes_run_smoke XLANG SRC [TAG]
#   std_bytes_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_BYTES_PREFIX="${XLANG_STD_BYTES_PREFIX:-xlang: [XLANG_STD_BYTES]}"

# Validate manifest api/file/smoke/script/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_bytes_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local doc="${3:-analysis/archive/std/std-bytes-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-bytes FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-bytes FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-bytes FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x round-trip smoke; exit 0 required.
# Prefer callers pin XLANG_LINK_XLANG to product asm before invoke.
std_bytes_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-bytes}"
  local exe="/tmp/xlang_std_bytes_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-bytes FAIL: compile $src" >&2
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
    echo "std-bytes FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; run hard; skip only when no binary path).
std_bytes_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_BYTES_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

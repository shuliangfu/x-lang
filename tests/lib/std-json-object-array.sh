#!/usr/bin/env bash
# std-json-object-array.sh — json-object-array (cursor/parse) manifest helpers
#
# Usage (after source):
#   std_joa_symbols_ok MOD_X JSON_X TSV
#   std_joa_run_smoke XLANG_BIN smoke_x tag
#   std_joa_emit_report status check_ok oa_ok skip
# 2026-08-26: report check=/oa=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology.

STD_JOA_PREFIX="${XLANG_STD_JSON_OBJECT_ARRAY_PREFIX:-xlang: [XLANG_STD_JSON_OBJECT_ARRAY]}"

# Validate manifest symbol/file/smoke rows; echo miss count; return 0 on success.
std_joa_symbols_ok() {
  local mod_x="$1"
  local json_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/json/json.c|std/json/json_parse_glue.c|std/json/json.x) mod_path="$json_x" ;;
          std/json/mod.x) mod_path="$mod_x" ;;
          *) mod_path="${mod_path:-$mod_x}" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-json-object-array FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-json-object-array FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-json-object-array FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      anchor|section)
        # DOC keyword / section anchors are validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_joa_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_joa_${tag}_$$"
  local log="/tmp/xlang_std_joa_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-json-object-array FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-json-object-array FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-json-object-array FAIL: compile $src" >&2
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
    echo "std-json-object-array FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/oa=/skip=).
std_joa_emit_report() {
  local status="$1"
  local check_ok="$2"
  local oa_ok="$3"
  local skip="$4"
  echo "${STD_JOA_PREFIX} status=${status} check=${check_ok} oa=${oa_ok} skip=${skip}"
}

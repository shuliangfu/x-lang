#!/usr/bin/env bash
# exc-error-code-layer.sh — EXC-003 manifest and smoke helpers (honesty).
# PLATFORM: SHARED archaeology.

EXC_ERROR_CODE_LAYER_PREFIX="${XLANG_EXC003_ERROR_CODE_LAYER_PREFIX:-xlang: [XLANG_EXC003_ERROR_CODE_LAYER]}"

# Validate manifest entries; echo missing count.
# @param $1 doc — archive DOC path
# @param $2 tsv — baseline manifest
exc_error_code_layer_symbols_ok() {
  local doc="$1"
  local tsv="$2"
  local miss=0
  local item_id kind sym src _notes
  while IFS=$'\t' read -r item_id kind sym src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      doc_anchor|section)
        if ! grep -qF "$sym" "$doc" 2>/dev/null; then
          echo "exc-error-code-layer FAIL: doc missing '$sym' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      naming_rule)
        if [ ! -f "$src" ] || ! grep -qF "$sym" "$src" 2>/dev/null; then
          echo "exc-error-code-layer FAIL: naming '$sym' not in $src" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if [ ! -f "$src" ]; then
          echo "exc-error-code-layer FAIL: missing $src ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -qE "(function|void|int32_t|i32) ${sym}\\(" "$src" 2>/dev/null; then
          echo "exc-error-code-layer FAIL: symbol ${sym} not in $src" >&2
          miss=$((miss + 1))
        fi
        ;;
      run|smoke|file)
        local path="$src"
        if [ -z "$path" ] || [ ! -f "$path" ]; then
          path="$sym"
        fi
        if [ ! -f "$path" ]; then
          echo "exc-error-code-layer FAIL: missing smoke/file '$sym' ($path)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x smoke with given compiler; require exit 0.
# @param $1 xlang — compiler binary
# @param $2 src — .x smoke path
exc_error_code_layer_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_exc_error_code_layer_$$"
  local log="/tmp/xlang_exc_error_code_layer_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "exc-error-code-layer FAIL: compile $src" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  [ "$ec" -eq 0 ]
}

# Emit structured report line (honesty: check=/run=/skip=).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 run_ok — runnable .x smoke exit0 (hard green signal)
# @param $4 skip — 1 only for manifest-only / no-native paths
exc_error_code_layer_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${EXC_ERROR_CODE_LAYER_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

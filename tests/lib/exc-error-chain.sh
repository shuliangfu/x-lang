#!/usr/bin/env bash
# exc-error-chain.sh — EXC-004 manifest and smoke helpers (honesty).
# PLATFORM: SHARED archaeology.

EXC_ERROR_CHAIN_PREFIX="${XLANG_EXC004_ERROR_CHAIN_PREFIX:-xlang: [XLANG_EXC004_ERROR_CHAIN]}"

# Validate manifest entries; echo missing count.
# @param $1 err_mod — std/error/mod.x
# @param $2 tsv — baseline manifest
# @param $3 doc — archive DOC path
exc_error_chain_symbols_ok() {
  local err_mod="$1"
  local tsv="$2"
  local doc="$3"
  local miss=0
  local item_id kind sym src _notes
  while IFS=$'\t' read -r item_id kind sym src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      section)
        if ! grep -qF "$sym" "$doc" 2>/dev/null; then
          echo "exc-error-chain FAIL: doc missing '$sym' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol|fn_*|type_*)
        if ! grep -qE "(struct|function) ${sym}[ ({]" "$err_mod" 2>/dev/null; then
          echo "exc-error-chain FAIL: ${sym} not in $err_mod" >&2
          miss=$((miss + 1))
        fi
        ;;
      import)
        if ! grep -qF "$sym" "$err_mod" 2>/dev/null; then
          echo "exc-error-chain FAIL: missing import $sym" >&2
          miss=$((miss + 1))
        fi
        ;;
      run|smoke|file)
        local path="$src"
        if [ -z "$path" ] || [ ! -f "$path" ]; then
          path="$sym"
        fi
        if [ ! -f "$path" ]; then
          echo "exc-error-chain FAIL: missing smoke/file '$sym' ($path)" >&2
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
exc_error_chain_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_exc_error_chain_$$"
  local log="/tmp/xlang_exc_error_chain_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "exc-error-chain FAIL: compile $src" >&2
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
exc_error_chain_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${EXC_ERROR_CHAIN_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

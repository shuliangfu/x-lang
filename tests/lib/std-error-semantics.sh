#!/usr/bin/env bash
# std-error-semantics.sh — STD-158: cross-module error semantics helpers.
#
# Usage (after source):
#   std_error_semantics_symbols_ok ERR_MOD TSV
#   std_error_semantics_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_ERR_SEM_PREFIX="${XLANG_STD_ERR_SEM_PREFIX:-xlang: [XLANG_STD_ERROR_SEMANTICS]}"

# Validate manifest symbol/file/run/recipe anchors. Echo miss count.
std_error_semantics_symbols_ok() {
  local err_mod="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor path
  while IFS=$'\t' read -r item_id kind anchor path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qE "function ${anchor}\\(" "$err_mod" 2>/dev/null; then
          echo "std-error-semantics FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|run|recipe)
        if [ ! -f "$anchor" ]; then
          echo "std-error-semantics FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_error_semantics_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ERR_SEM_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

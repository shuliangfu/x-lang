#!/usr/bin/env bash
# std-option-result.sh — STD-080/081 manifest helpers (option + result).
#
# Usage (after source):
#   std_option_result_symbols_ok MOD_X TSV
#   std_option_result_check_manifest MOD_X TSV MIN_APIS LABEL
#   std_option_result_run_smoke XLANG SRC [TAG]
#   std_option_result_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_OPTION_RESULT_PREFIX="${XLANG_STD_OPTION_RESULT_PREFIX:-xlang: [XLANG_STD_OPTION_RESULT]}"

# Validate manifest api/file/smoke anchors. Echo miss count; return 0 when miss=0.
std_option_result_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-option-result FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-option-result FAIL: missing '$anchor'" >&2
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
std_option_result_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-or}"
  local exe="/tmp/xlang_std_option_result_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-option-result FAIL: compile $src" >&2
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
    echo "std-option-result FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_option_result_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_OPTION_RESULT_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

# Count + validate apis against mod.x; fail when below min or symbols miss.
std_option_result_check_manifest() {
  local mod_x="$1"
  local tsv="$2"
  local min_apis="$3"
  local label="$4"
  local api_n=0
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    [ "$kind" = "api" ] || continue
    api_n=$((api_n + 1))
    if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
      echo "std-option-result gate FAIL: $label missing api $anchor" >&2
      return 1
    fi
  done < "$tsv"
  if [ "$api_n" -lt "$min_apis" ]; then
    echo "std-option-result gate FAIL: $label api count $api_n < min $min_apis" >&2
    return 1
  fi
  sym_miss="$(std_option_result_symbols_ok "$mod_x" "$tsv" || true)"
  if [ "${sym_miss:-0}" -gt 0 ]; then
    return 1
  fi
  return 0
}

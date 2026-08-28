#!/usr/bin/env bash
# core-fmt-f64-special.sh — CORE-011: f64 NaN/Inf/precision manifest helpers.
# Honesty: emit_report uses run=/obs=/skip= (soft SKIP→OK / soft auto-make retired).
#
# Usage (after source):
#   core_fmt_f64_special_symbols_ok FMT_X STD_FMT_X TSV
#   core_fmt_f64_special_emit_report status run_ok obs skip

CORE_FMT_F64_SPECIAL_PREFIX="${XLANG_CORE_FMT_F64_SPECIAL_PREFIX:-xlang: [XLANG_CORE_FMT_F64_SPECIAL]}"

# Validate manifest symbol anchors; echo miss count; return 0 on success.
core_fmt_f64_special_symbols_ok() {
  local fmt_x="$1"
  local std_fmt_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local target="${mod_path:-$fmt_x}"
        if [ "$item_id" = "std_reexport" ]; then
          target="$std_fmt_x"
        elif [ -z "$mod_path" ] || [ "$mod_path" = "core/fmt/mod.x" ]; then
          target="$fmt_x"
        fi
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "core-fmt-f64-special FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report: run= hard product; obs= check; skip= N/A.
core_fmt_f64_special_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_FMT_F64_SPECIAL_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

#!/usr/bin/env bash
# std-fmt-multi.sh — STD-019 format_2/3 manifest helpers.
#
# Usage (after source):
#   std_fmt_multi_symbols_ok FMT_X TSV [DOC]
#   std_fmt_multi_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_FMT_MULTI_PREFIX="${XLANG_STD_FMT_MULTI_PREFIX:-xlang: [XLANG_STD_FMT_MULTI]}"

# Validate manifest symbol/overload/file/script/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_fmt_multi_symbols_ok() {
  local fmt_x="$1"
  local tsv="$2"
  local doc="${3:-analysis/archive/std/std-fmt-multi-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$fmt_x" 2>/dev/null; then
          echo "std-fmt-multi FAIL: missing '$anchor' in $fmt_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      overload)
        if ! grep -qE "$anchor" "$fmt_x" 2>/dev/null; then
          echo "std-fmt-multi FAIL: missing overload pattern '$anchor' in $fmt_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-fmt-multi FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        # Prefer tests/… path in anchor (honesty); fall back to mod_path.
        local sp="$anchor"
        if [ ! -f "$sp" ] && [ -n "${mod_path:-}" ] && [ -f "$mod_path" ]; then
          sp="$mod_path"
        fi
        if [ ! -f "$sp" ]; then
          echo "std-fmt-multi FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF -- "$anchor" "$doc" 2>/dev/null; then
          echo "std-fmt-multi FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Emit structured report line: check=/run=/skip= (run= is hard-green signal).
std_fmt_multi_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_FMT_MULTI_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

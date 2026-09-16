#!/usr/bin/env bash
# std-set-extend.sh — STD-015: Set_u64/Set_str manifest helpers.
#
# Usage (after source):
#   std_set_extend_symbols_ok SET_X TSV
#   std_set_extend_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SET_EXTEND_PREFIX="${XLANG_STD_SET_EXTEND_PREFIX:-xlang: [XLANG_STD_SET_EXTEND]}"

# Validate manifest symbol anchors against product std/set/mod.x.
# Struct anchors (Set_*) use fixed-string presence; function anchors require
# `function <name>(` so overload surface names (insert/remove/str_*) match.
# Echo miss count; return 0 when miss=0.
std_set_extend_symbols_ok() {
  local set_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        case "$anchor" in
          Set_*|set_str_key_cap)
            if ! grep -qF "$anchor" "$set_x" 2>/dev/null; then
              echo "std-set-extend FAIL: missing '$anchor' in $set_x" >&2
              miss=$((miss + 1))
            fi
            ;;
          *)
            if ! grep -qE "function ${anchor}\\(" "$set_x" 2>/dev/null; then
              echo "std-set-extend FAIL: missing function '${anchor}(' in $set_x" >&2
              miss=$((miss + 1))
            fi
            ;;
        esac
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_set_extend_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SET_EXTEND_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}

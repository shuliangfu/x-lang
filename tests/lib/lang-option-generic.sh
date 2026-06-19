#!/usr/bin/env bash
# lang-option-generic.sh — LANG-009 manifest 与烟测辅助
#
# 用法（source 后）：
#   lang_option_generic_check MANIFEST
#   lang_option_generic_emit_report status golden_ok typeck_ok skip

LANG_OPTION_GENERIC_PREFIX="${SHUX_LANG009_PREFIX:-shux: [SHUX_LANG009_OPTION_GENERIC]}"

# 校验 manifest；echo 缺失数。
lang_option_generic_check() {
  local tsv="$1"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|section)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "lang-option-generic FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "lang-option-generic FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|file)
        if [ ! -f "$anchor" ]; then
          echo "lang-option-generic FAIL: missing $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "lang-option-generic FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$mod_path" ]; then
          echo "lang-option-generic FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
lang_option_generic_emit_report() {
  local status="$1"
  local golden_ok="$2"
  local typeck_ok="$3"
  local skip="$4"
  echo "${LANG_OPTION_GENERIC_PREFIX} status=${status} golden=${golden_ok} typeck=${typeck_ok} skip=${skip}"
}

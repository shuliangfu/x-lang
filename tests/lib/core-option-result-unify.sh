#!/usr/bin/env bash
# core-option-result-unify.sh — CORE-016 manifest 与烟测辅助
#
# 用法（source 后）：
#   core016_check MANIFEST
#   core016_emit_report status golden_ok typeck_ok skip

CORE016_PREFIX="${SHU_CORE016_PREFIX:-shu: [SHU_CORE016_OPTION_RESULT_UNIFY]}"

# 校验 manifest；echo 缺失数。
core016_check() {
  local tsv="$1"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      section)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "core016 FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "core016 FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke)
        if [ ! -f "$anchor" ]; then
          echo "core016 FAIL: missing $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "core016 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$mod_path" ]; then
          echo "core016 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
core016_emit_report() {
  local status="$1"
  local golden_ok="$2"
  local typeck_ok="$3"
  local skip="$4"
  echo "${CORE016_PREFIX} status=${status} golden=${golden_ok} typeck=${typeck_ok} skip=${skip}"
}

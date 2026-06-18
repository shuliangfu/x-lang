#!/usr/bin/env bash
# std-json-object-array.sh — STD-034 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_joa_symbols_ok JSON_SU JSON_C TSV
#   std_joa_emit_report status oa_ok skip

STD_JOA_PREFIX="${SHU_STD_JSON_OBJECT_ARRAY_PREFIX:-shu: [SHU_STD_JSON_OBJECT_ARRAY]}"

# 校验 manifest；echo 缺失数，成功返回 0。
std_joa_symbols_ok() {
  local json_su="$1"
  local json_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/json/json.c) mod_path="$json_c" ;;
          *) mod_path="$json_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-json-object-array FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-json-object-array FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_joa_emit_report() {
  local status="$1"
  local oa_ok="$2"
  local skip="$3"
  echo "${STD_JOA_PREFIX} status=${status} oa=${oa_ok} skip=${skip}"
}

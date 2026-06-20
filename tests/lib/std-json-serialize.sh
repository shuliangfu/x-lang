#!/usr/bin/env bash
# std-json-serialize.sh — STD-035 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_jsz_symbols_ok JSON_SU JSON_C TSV
#   std_jsz_emit_report status rt_ok skip

STD_JSZ_PREFIX="${SHUX_STD_JSON_SERIALIZE_PREFIX:-shux: [SHUX_STD_JSON_SERIALIZE]}"

# 校验 manifest symbol/file；echo 缺失数，成功返回 0。
std_jsz_symbols_ok() {
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
          echo "std-json-serialize FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-json-serialize FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_jsz_emit_report() {
  local status="$1"
  local rt_ok="$2"
  local skip="$3"
  echo "${STD_JSZ_PREFIX} status=${status} rt=${rt_ok} skip=${skip}"
}

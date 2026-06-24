#!/usr/bin/env bash
# std-map-vec-extend.sh — STD-013/014 manifest 与 typeck 辅助
#
# 用法（source 后）：
#   std_mve_symbols_ok MAP_SX VEC_SX HEAP_SX TSV
#   std_mve_emit_report status map_ok vec_ok skip

STD_MVE_PREFIX="${SHUX_STD_MAP_VEC_EXTEND_PREFIX:-shux: [SHUX_STD_MAP_VEC_EXTEND]}"

# 校验 manifest symbol 锚点；echo 缺失数，成功返回 0。
std_mve_symbols_ok() {
  local map_sx="$1"
  local vec_sx="$2"
  local heap_sx="$3"
  local tsv="$4"
  local miss=0
  local sym mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/vec/mod.sx) mod_path="$vec_sx" ;;
          std/heap/mod.sx) mod_path="$heap_sx" ;;
          *) mod_path="$map_sx" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-map-vec-extend FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_mve_emit_report() {
  local status="$1"
  local map_ok="$2"
  local vec_ok="$3"
  local skip="$4"
  echo "${STD_MVE_PREFIX} status=${status} map=${map_ok} vec=${vec_ok} skip=${skip}"
}

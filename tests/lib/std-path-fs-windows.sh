#!/usr/bin/env bash
# std-path-fs-windows.sh — STD-021/022 manifest 与 typeck 辅助
#
# 用法（source 后）：
#   std_pfw_symbols_ok PATH_SX TSV
#   std_pfw_emit_report status path_ok fs_ok skip

STD_PFW_PREFIX="${SHUX_STD_PATH_FS_WIN_PREFIX:-shux: [SHUX_STD_PATH_FS_WIN]}"

# 校验 manifest symbol 锚点；echo 缺失数，成功返回 0。
std_pfw_symbols_ok() {
  local path_sx="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$path_sx" 2>/dev/null; then
          echo "std-path-fs-windows FAIL: missing '$anchor' in $path_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-path-fs-windows FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      absent)
        if [ -f "$anchor" ]; then
          echo "std-path-fs-windows FAIL: should not exist '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_pfw_emit_report() {
  local status="$1"
  local path_ok="$2"
  local fs_ok="$3"
  local skip="$4"
  echo "${STD_PFW_PREFIX} status=${status} path=${path_ok} fs=${fs_ok} skip=${skip}"
}

#!/usr/bin/env bash
# std-strview-zc4.sh — STD-016 StrView/ZC-4 manifest 辅助
#
# 用法（source 后）：
#   std_sv_zc4_manifest_ok STRING_SU DOC TSV
#   std_sv_zc4_emit_report status lifecycle_ok typeck_ok zc4_skip

STD_SV_ZC4_PREFIX="${SHUX_STD_STRVIEW_ZC4_PREFIX:-shux: [SHUX_STD_STRVIEW_ZC4]}"

# 校验 manifest symbol/anchor；echo 缺失数，成功返回 0。
std_sv_zc4_manifest_ok() {
  local string_su="$1"
  local doc="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$string_su" 2>/dev/null; then
          echo "std-strview-zc4 FAIL: missing symbol '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      anchor)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-strview-zc4 FAIL: doc missing anchor '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-strview-zc4 FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_sv_zc4_emit_report() {
  local status="$1"
  local lifecycle_ok="$2"
  local typeck_ok="$3"
  local zc4_skip="$4"
  echo "${STD_SV_ZC4_PREFIX} status=${status} lifecycle=${lifecycle_ok} typeck=${typeck_ok} zc4_skip=${zc4_skip}"
}

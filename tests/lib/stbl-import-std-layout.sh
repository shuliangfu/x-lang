#!/usr/bin/env bash
# stbl-import-std-layout.sh — STBL-004：import 路径解析与文档 § 校验
#
# 用法（source 后）：
#   stbl_import_std_resolve_probe LIB_ROOT IMPORT EXPECTED_RELPATH
#   stbl_import_std_sections_ok DOC TSV
#   stbl_import_std_emit_report status resolve_ok check_ok skip

STBL_IMPORT_STD_PREFIX="${SHUX_STBL_IMPORT_STD_PREFIX:-shux: [SHUX_STBL_IMPORT_STD]}"

# 依赖 TOOL-007 解析子集（须先 source tests/lib/tool-pkgmgr.sh）。
stbl_import_std_resolve_probe() {
  local lib_root="$1"
  local import_path="$2"
  local expected="$3"
  local got

  if ! got="$(tool_pkg_resolve_import "$lib_root" "$import_path")"; then
    echo "stbl-import-std FAIL: cannot resolve '$import_path' under '$lib_root'" >&2
    return 1
  fi
  # tool_pkg_resolve_import 可能返回 ./ 前缀，与 manifest 相对路径对齐
  case "$got" in
    ./*) got="${got#./}" ;;
  esac
  if [ "$got" != "$expected" ]; then
    echo "stbl-import-std FAIL: $import_path -> '$got' (want '$expected')" >&2
    return 1
  fi
  return 0
}

# 校验 RFC 含 manifest 所列 section 锚点；echo 缺失数。
stbl_import_std_sections_ok() {
  local doc="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _expected _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*|min_*|resolve_*|cross_*|smoke|lib|gate) continue ;;
    esac
    case "$kind" in
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "stbl-import-std FAIL: doc missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "stbl-import-std FAIL: missing cross_ref '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
stbl_import_std_emit_report() {
  local status="$1"
  local resolve_ok="$2"
  local check_ok="$3"
  local skip="$4"
  echo "${STBL_IMPORT_STD_PREFIX} status=${status} resolve=${resolve_ok} check=${check_ok} skip=${skip}"
}

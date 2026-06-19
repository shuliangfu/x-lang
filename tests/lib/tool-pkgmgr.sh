#!/usr/bin/env bash
# tool-pkgmgr.sh — TOOL-007 共享：import 路径解析（对齐 driver 规则子集）
#
# 用法（source 后）：
#   tool_pkg_resolve_import LIB_ROOT IMPORT_PATH
#   tool_pkg_parse_requires MANIFEST_TSV
#   tool_pkg_catalog_count [catalog_tsv]

# 将 dotted import 解析为可读文件路径；成功打印路径并返回 0。
tool_pkg_resolve_import() {
  local lib_root="$1"
  local import_path="$2"
  local path

  # a.b.c -> lib_root/a/b/c.sx
  path="$lib_root/$(echo "$import_path" | tr '.' '/').sx"
  if [ -f "$path" ]; then
    printf '%s\n' "$path"
    return 0
  fi

  # a.b -> lib_root/a/b/mod.sx
  path="$lib_root/$(echo "$import_path" | tr '.' '/')/mod.sx"
  if [ -f "$path" ]; then
    printf '%s\n' "$path"
    return 0
  fi

  # 单段 foo -> lib_root/foo/foo.sx
  if ! echo "$import_path" | grep -q '\.'; then
    path="$lib_root/${import_path}/${import_path}.sx"
    if [ -f "$path" ]; then
      printf '%s\n' "$path"
      return 0
    fi
  fi

  return 1
}

# 统计 catalog 包行数。
tool_pkg_catalog_count() {
  local cat="${1:-tests/baseline/tool-pkgmgr-catalog.tsv}"
  awk -F'\t' '$2=="bundled" && $1 !~ /^#/ { n++ } END { print n+0 }' "$cat"
}

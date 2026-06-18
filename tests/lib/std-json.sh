#!/usr/bin/env bash
# std-json.sh — STD-008 共享：std.json API 与烟测辅助
#
# 用法（source 后）：
#   std_json_api_count [manifest_tsv]
#   std_json_has_api MOD_SU fn_name
#   std_json_has_c_impl JSON_C sym_name
#   std_json_run_smoke SHU_BIN smoke_su tag

# 统计 manifest 中 api 行数。
std_json_api_count() {
  local man="${1:-tests/baseline/std-json-manifest.tsv}"
  awk -F'\t' '$2=="api" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 检查 mod.su 是否导出指定函数。
std_json_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# 检查 json.c 是否实现 C 符号。
std_json_has_c_impl() {
  local cfile="$1"
  local sym="$2"
  grep -qF "${sym}(" "$cfile" 2>/dev/null
}

# 编译并运行烟测 .su；期望退出码 0。
std_json_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shu_std_json_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-json FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shu" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-json FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

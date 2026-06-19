#!/usr/bin/env bash
# std-time.sh — STD-005 共享：std.time API 与烟测辅助
#
# 用法（source 后）：
#   std_time_api_count [manifest_tsv]
#   std_time_has_api MOD_SU fn_name
#   std_time_run_smoke SHUX_BIN smoke_su

# 统计 manifest 中 api 行数（不含注释）。
std_time_api_count() {
  local man="${1:-tests/baseline/std-time-manifest.tsv}"
  awk -F'\t' '$2=="api" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 检查 mod.sx 是否导出指定函数。
std_time_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# 编译并运行烟测 .sx；期望退出码 0。
std_time_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_time_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-time FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shux" -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-time FAIL: $tag exit=$ec ($src)" >&2
    return 1
  fi
  return 0
}

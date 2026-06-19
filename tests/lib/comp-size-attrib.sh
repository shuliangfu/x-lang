#!/usr/bin/env bash
# comp-size-attrib.sh — COMP-010 编译产物体积归因共享库
#
# 读取 matrix TSV，统计 file_bytes / text_bytes，输出 distribution report。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MATRIX="${SHUX_SIZE_ATTRIB_MATRIX:-$ROOT/tests/baseline/comp-size-attrib-matrix.tsv}"

# 返回文件字节数（跨 Darwin/Linux stat）。
comp_size_attrib_file_bytes() {
  local f="$1"
  [ -f "$f" ] || return 1
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    stat -f%z "$f" 2>/dev/null || wc -c <"$f"
  else
    stat -c%s "$f" 2>/dev/null || wc -c <"$f"
  fi
}

# 读 .o 代码段大小（Mach-O __text 或 ELF .text）；失败返回 0。
comp_size_attrib_o_text_bytes() {
  local o="$1"
  local hex=""
  [ -f "$o" ] || { echo 0; return 0; }
  if ! command -v objdump >/dev/null 2>&1; then
    echo 0
    return 0
  fi
  hex="$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')"
  if [ -z "$hex" ]; then
    hex="$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')"
  fi
  if [ -n "$hex" ]; then
    printf '%d' "0x$hex" 2>/dev/null || echo 0
  else
    echo 0
  fi
}

# 对 build_asm 目录下所有 .o 做 rollup（file_bytes 与 text_bytes 合计）。
comp_size_attrib_rollup_build_asm() {
  local dir="$1"
  local sum_file=0
  local sum_text=0
  local f
  [ -d "$dir" ] || { echo "0	0"; return 0; }
  for f in "$dir"/*.o; do
    [ -f "$f" ] || continue
    local fb tb
    fb="$(comp_size_attrib_file_bytes "$f" 2>/dev/null || echo 0)"
    tb="$(comp_size_attrib_o_text_bytes "$f" 2>/dev/null || echo 0)"
    sum_file=$((sum_file + fb))
    sum_text=$((sum_text + tb))
  done
  echo "${sum_file}	${sum_text}"
}

# 解析 matrix 中路径为绝对路径。
comp_size_attrib_resolve_path() {
  local rel="$1"
  if [ -f "$ROOT/$rel" ]; then
    echo "$ROOT/$rel"
  elif [ -d "$ROOT/$rel" ]; then
    echo "$ROOT/$rel"
  else
    return 1
  fi
}

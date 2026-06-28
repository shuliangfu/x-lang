#!/usr/bin/env bash
# F-03 v1：std.heap 算法层去 C 门禁（ops.sx + heap.c 无 mem/map 符号）。
#
# 用法：./tests/run-f03-std-heap-ops-gate.sh
# 环境：SHUX_F03_HEAP_OPS_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F03_HEAP_OPS_FAIL:-0}
DOC="analysis/phase-f-f03-v1.md"

die() {
  echo "f03-heap-ops gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-03 v1: std.heap heap_ops remove C algorithms ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v1' "$DOC" || die "doc missing F-03 v1 marker"
[ -f std/heap/ops.sx ] || die "missing ops.sx"
grep -q 'heap_mem_set_c' std/heap/ops.sx || die "heap_ops missing heap_mem_set_c"
grep -q 'map_i32_i32_find_c' std/heap/ops.sx || die "heap_ops missing map find"
if grep -q 'heap_mem_set_c' std/heap/heap.c 2>/dev/null; then
  die "heap.c still defines heap_mem_set_c (should be in ops.sx)"
fi
if grep -q 'map_i32_i32_find_c' std/heap/heap.c 2>/dev/null; then
  die "heap.c still defines map_i32_i32_find_c"
fi
grep -q 'import("std.heap.ops")' std/heap/mod.sx || die "mod.sx missing ops import"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  export SHUX="$SHUX_BIN"
  if [ -f tests/run-heap.sh ]; then
    echo "=== F-03 v1: delegate run-heap.sh (SHUX=$SHUX_BIN) ==="
    chmod +x tests/run-heap.sh
    if ! tests/run-heap.sh; then
      die "run-heap sub-gate failed"
    fi
  fi
  if [ -f tests/run-std-mem-safe-gate.sh ]; then
    echo "=== F-03 v1: delegate run-std-mem-safe-gate ==="
    chmod +x tests/run-std-mem-safe-gate.sh
    if ! tests/run-std-mem-safe-gate.sh; then
      die "std-mem-safe sub-gate failed"
    fi
  fi
else
  echo "f03-heap-ops: SKIP runtime sub-gates (no native shux on this host)"
fi

echo "f03 std.heap ops gate OK (F-03 v1)"

#!/usr/bin/env bash
# B-16 v0：macOS std.sys.macos 匿名 mmap 烟测（Darwin 常规链接）。
# 用法：./tests/run-macos-mmap-gate.sh
# 环境：XLANG_MACOS_MMAP_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_MACOS_MMAP_FAIL:-0}
X="tests/sys/macos_mmap_smoke.x"
OUT="/tmp/xlang_macos_mmap.$$.out"
XLANG="${XLANG:-./compiler/xlang-c}"

if [ "$(uname -s 2>/dev/null)" != "Darwin" ]; then
  echo "macos-mmap-gate: N/A (Darwin only)"
  exit 0
fi

if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "macos-mmap-gate: SKIP (no xlang/xlang-c)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG" build -o "$OUT" "$X" 2>/tmp/xlang_macos_mmap.log; then
  echo "macos-mmap-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/xlang_macos_mmap.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "macos-mmap-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "macos-mmap-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "macos-mmap-gate OK (macOS libSystem mmap/munmap)"
exit 0

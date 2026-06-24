#!/usr/bin/env bash
# B-16 v0：macOS std.sys.macos 匿名 mmap 烟测（Darwin 常规链接）。
# 用法：./tests/run-macos-mmap-gate.sh
# 环境：SHUX_MACOS_MMAP_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_MACOS_MMAP_FAIL:-0}
SX="tests/sys/macos_mmap_smoke.sx"
OUT="/tmp/shux_macos_mmap.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ "$(uname -s 2>/dev/null)" != "Darwin" ]; then
  echo "macos-mmap-gate: N/A (Darwin only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "macos-mmap-gate: SKIP (no shux/shux-c)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -o "$OUT" "$SX" 2>/tmp/shux_macos_mmap.log; then
  echo "macos-mmap-gate FAIL: compile $SX" >&2
  tail -n 10 /tmp/shux_macos_mmap.log 2>/dev/null || true
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

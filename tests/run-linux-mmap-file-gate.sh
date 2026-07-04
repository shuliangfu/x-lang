#!/usr/bin/env bash
# F-02 v1：Linux std.sys 文件 MAP_SHARED mmap 烟测（hosted -o exe，无 mmap.inc.c）。
# 用法：./tests/run-linux-mmap-file-gate.sh
# 环境：SHUX_LINUX_MMAP_FILE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_LINUX_MMAP_FILE_FAIL:-0}
X="tests/sys/linux_mmap_file_smoke.x"
OUT="/tmp/shux_linux_mmap_file.$$.out"
GATE_FILE="/tmp/shux_linux_mmap_file_gate.dat"
SHUX="${SHUX:-./compiler/shux-c}"

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "linux-mmap-file-gate: N/A (Linux only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "linux-mmap-file-gate: SKIP (no shux/shux-c)"
  exit 0
fi

if [ -f std/sys/mmap.inc.c ]; then
  echo "linux-mmap-file-gate FAIL: mmap.inc.c should be removed (F-02 v1)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

: >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -o "$OUT" "$X" 2>/tmp/shux_linux_mmap_file.log; then
  echo "linux-mmap-file-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/shux_linux_mmap_file.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "linux-mmap-file-gate FAIL: no executable $OUT" >&2
  rm -f "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "linux-mmap-file-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "linux-mmap-file-gate OK (Linux MAP_SHARED os_mmap_rw via std.sys.linux; F-02 v1)"
exit 0

#!/usr/bin/env bash
# B-17 v1：Windows std.sys os_write_stdout（GetStdHandle + WriteFile）烟测。
# 用法：./tests/run-win32-write-gate.sh
# 环境：SHUX_WIN32_WRITE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_WIN32_WRITE_FAIL:-0}
SU="tests/sys/win32_write_smoke.sx"
OUT="/tmp/shux_win32_write.$$.exe"
SHUX="${SHUX:-./compiler/shux-c}"
WIN32_O="std/sys/win32.o"

if [ "$(uname -s 2>/dev/null)" != "MINGW"* ] && [ "$(uname -s 2>/dev/null)" != "MSYS"* ] \
   && [ "${OS:-}" != "Windows_NT" ]; then
  echo "win32-write-gate: N/A (Windows/MSYS2 only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "win32-write-gate: SKIP (no shux/shux-c)"
  exit 0
fi

if [ ! -f "$WIN32_O" ]; then
  if [ -f std/sys/win32.inc.c ]; then
    cc -c -o "$WIN32_O" std/sys/win32.inc.c 2>/tmp/shux_win32_o.log || true
  fi
fi

rm -f "$OUT" 2>/dev/null || true
# win32.o 由 invoke_cc 按 shux_win32_* 符号按需链入，勿作为 shux 输入文件（会被当 .sx 解析）。
if ! "$SHUX" -L . -o "$OUT" "$SU" 2>/tmp/shux_win32_write.log; then
  echo "win32-write-gate FAIL: compile $SU" >&2
  tail -n 10 /tmp/shux_win32_write.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ] && [ ! -f "$OUT" ]; then
  echo "win32-write-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
OUT=$( "$OUT" 2>/dev/null ) || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "win32-write-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

EXPECTED=$(printf 'Hello Shu!\n')
if [ "$OUT" != "$EXPECTED" ]; then
  echo "win32-write-gate FAIL: stdout='$OUT' expected='$EXPECTED'" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "win32-write-gate OK (Windows std.sys os_write_stdout via WriteFile)"
exit 0

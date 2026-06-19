#!/usr/bin/env bash
# B-17 v2：Windows std.sys os_read_file_into（CreateFileA + ReadFile）烟测。
# 用法：./tests/run-win32-read-file-gate.sh
# 环境：SHUX_WIN32_READ_FILE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_WIN32_READ_FILE_FAIL:-0}
SU="tests/sys/win32_read_file_smoke.sx"
GATE_FILE="/tmp/shux_win32_read_gate.txt"
OUT="/tmp/shux_win32_read_file.$$.exe"
SHUX="${SHUX:-./compiler/shux-c}"
WIN32_O="std/sys/win32.o"

if [ "$(uname -s 2>/dev/null)" != "MINGW"* ] && [ "$(uname -s 2>/dev/null)" != "MSYS"* ] \
   && [ "${OS:-}" != "Windows_NT" ]; then
  echo "win32-read-file-gate: N/A (Windows/MSYS2 only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "win32-read-file-gate: SKIP (no shux/shux-c)"
  exit 0
fi

printf 'WIN' >"$GATE_FILE"
if [ ! -f "$WIN32_O" ] && [ -f std/sys/win32.inc.c ]; then
  cc -c -o "$WIN32_O" std/sys/win32.inc.c 2>/tmp/shux_win32_o.log || true
fi

rm -f "$OUT" 2>/dev/null || true
# win32.o 由 invoke_cc 按需链入，勿作为 shux  positional 输入。
if ! "$SHUX" -L . -o "$OUT" "$SU" 2>/tmp/shux_win32_read_file.log; then
  echo "win32-read-file-gate FAIL: compile $SU" >&2
  tail -n 10 /tmp/shux_win32_read_file.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ] && [ ! -f "$OUT" ]; then
  echo "win32-read-file-gate FAIL: no executable $OUT" >&2
  rm -f "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "win32-read-file-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "win32-read-file-gate OK (Windows std.sys os_read_file_into via ReadFile)"
exit 0

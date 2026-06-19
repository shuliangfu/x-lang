#!/usr/bin/env bash
# B-14 v2：Linux freestanding open+read（os_read_file_into / shux_sys_open）烟测。
# 用法：./tests/run-linux-open-read-gate.sh
# 环境：SHUX_LINUX_OPEN_READ_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_LINUX_OPEN_READ_FAIL:-0}
SU="tests/sys/linux_open_read_smoke.sx"
GATE_FILE="/tmp/shux_linux_open_read_gate.txt"
OUT="/tmp/shux_linux_open_read.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "linux-open-read-gate: N/A (Linux x86_64 freestanding only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "linux-open-read-gate: SKIP (no shux/shux-c)"
  exit 0
fi

printf 'OK' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -freestanding -backend asm -o "$OUT" "$SU" 2>/tmp/shux_linux_open_read.log; then
  echo "linux-open-read-gate FAIL: compile $SU" >&2
  tail -n 10 /tmp/shux_linux_open_read.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "linux-open-read-gate FAIL: no executable $OUT" >&2
  rm -f "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "linux-open-read-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "linux-open-read-gate OK (Linux freestanding shux_sys_open + read loop)"
exit 0

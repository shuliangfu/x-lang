#!/usr/bin/env bash
# B-14 v2：Linux freestanding open+read（os_read_file_into / xlang_sys_open）烟测。
# 用法：./tests/run-linux-open-read-gate.sh
# 环境：XLANG_LINUX_OPEN_READ_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_LINUX_OPEN_READ_FAIL:-0}
X="tests/sys/linux_open_read_smoke.x"
GATE_FILE="/tmp/xlang_linux_open_read_gate.txt"
OUT="/tmp/xlang_linux_open_read.$$.out"
XLANG="${XLANG:-./compiler/xlang-c}"

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "linux-open-read-gate: N/A (Linux x86_64 freestanding only)"
  exit 0
fi

if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "linux-open-read-gate: SKIP (no xlang/xlang-c)"
  exit 0
fi

printf 'OK' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/xlang_linux_open_read.log; then
  echo "linux-open-read-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/xlang_linux_open_read.log 2>/dev/null || true
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

echo "linux-open-read-gate OK (Linux freestanding xlang_sys_open + read loop)"
exit 0

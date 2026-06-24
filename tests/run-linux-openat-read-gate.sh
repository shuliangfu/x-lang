#!/usr/bin/env bash
# B-14 v3：Linux freestanding openat+read 烟测。
# 用法：./tests/run-linux-openat-read-gate.sh
# 环境：SHUX_LINUX_OPENAT_READ_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_LINUX_OPENAT_READ_FAIL:-0}
SX="tests/sys/linux_openat_read_smoke.sx"
GATE_FILE="/tmp/shux_linux_openat_read_gate.txt"
OUT="/tmp/shux_linux_openat_read.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "linux-openat-read-gate: N/A (Linux x86_64 freestanding only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "linux-openat-read-gate: SKIP (no shux/shux-c)"
  exit 0
fi

printf 'AT' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -freestanding -backend asm -o "$OUT" "$SX" 2>/tmp/shux_linux_openat_read.log; then
  echo "linux-openat-read-gate FAIL: compile $SX" >&2
  tail -n 10 /tmp/shux_linux_openat_read.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "linux-openat-read-gate FAIL: no executable $OUT" >&2
  rm -f "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "linux-openat-read-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "linux-openat-read-gate OK (Linux freestanding shux_sys_openat + read)"
exit 0

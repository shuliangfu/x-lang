#!/usr/bin/env bash
# B-20 v0：std.sys os_read_file_into 烟测（Darwin 常规 / Linux freestanding）。
# 用法：./tests/run-sys-read-file-gate.sh
# 环境：XLANG_SYS_READ_FILE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_SYS_READ_FILE_FAIL:-0}
X="tests/sys/sys_read_file_smoke.x"
OUT="/tmp/xlang_sys_read_file.$$.out"
GATE_FILE="/tmp/xlang_read_file_gate.txt"
XLANG="${XLANG:-./compiler/xlang-c}"

if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "sys-read-file-gate: SKIP (no xlang/xlang-c)"
  exit 0
fi

printf 'ABC' >"$GATE_FILE"

OS="$(uname -s)"
EXTRA=()
if [ "$OS" = "Linux" ]; then
  EXTRA=(-freestanding -backend asm)
fi

rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG" build "${EXTRA[@]}" -o "$OUT" "$X" 2>/tmp/xlang_sys_read_file.log; then
  echo "sys-read-file-gate FAIL: compile $X on $OS" >&2
  tail -n 10 /tmp/xlang_sys_read_file.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "sys-read-file-gate FAIL: no executable $OUT" >&2
  rm -f "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "sys-read-file-gate FAIL: expected exit 0, got $rc on $OS" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "sys-read-file-gate OK (std.sys os_read_file_into on $OS)"
exit 0

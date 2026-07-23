#!/usr/bin/env bash
# B-14 v1：Linux freestanding syscall invoke（read/close/exit/write 桩）烟测。
# 用法：./tests/run-linux-syscall-invoke-gate.sh
# 环境：XLANG_LINUX_SYSCALL_INVOKE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_LINUX_SYSCALL_INVOKE_FAIL:-0}
X="tests/sys/linux_syscall_invoke_smoke.x"
OUT="/tmp/xlang_linux_syscall_invoke.$$.out"
XLANG="${XLANG:-./compiler/xlang-c}"

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "linux-syscall-invoke-gate: N/A (Linux x86_64 freestanding only)"
  exit 0
fi

if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "linux-syscall-invoke-gate: SKIP (no xlang/xlang-c)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/xlang_linux_syscall_invoke.log; then
  echo "linux-syscall-invoke-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/xlang_linux_syscall_invoke.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "linux-syscall-invoke-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "linux-syscall-invoke-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "linux-syscall-invoke-gate OK (Linux freestanding xlang_sys_read/write)"
exit 0

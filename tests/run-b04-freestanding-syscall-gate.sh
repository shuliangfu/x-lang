#!/usr/bin/env bash
# B-04 v1：freestanding syscall 等价路径（extern → freestanding_io_x86_64.s，非 asm{} 语法）。
#
# 用法：./tests/run-b04-freestanding-syscall-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-04: freestanding syscall (extern→.s) ==="
for f in std/sys/linux.x compiler/src/asm/freestanding_io_x86_64.s analysis/phase-b-completion-v1.md; do
  [ -f "$f" ] || { echo "b04 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'extern function xlang_sys_write' std/sys/mod.x || { echo "b04 gate FAIL: mod.x missing extern write" >&2; exit 1; }

if [ "$(uname -s)" = "Linux" ]; then
  chmod +x tests/run-linux-syscall-invoke-gate.sh
  XLANG="${XLANG:-./compiler/xlang-c}"
  if [ ! -x "$XLANG" ]; then
    XLANG="./compiler/xlang_asm"
  fi
  if [ -x "$XLANG" ]; then
    XLANG="$XLANG" XLANG_LINUX_SYSCALL_INVOKE_FAIL=${XLANG_LINUX_SYSCALL_INVOKE_FAIL:-1} ./tests/run-linux-syscall-invoke-gate.sh
  else
    echo "b04 gate SKIP invoke (no xlang)"
  fi
else
  echo "b04 gate SKIP invoke (non-Linux)"
fi
echo "b04 freestanding-syscall gate OK"

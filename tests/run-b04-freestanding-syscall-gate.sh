#!/usr/bin/env bash
# B-04 v1：freestanding syscall 等价路径（extern → freestanding_io_x86_64.s，非 asm{} 语法）。
#
# 用法：./tests/run-b04-freestanding-syscall-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-04: freestanding syscall (extern→.s) ==="
for f in std/sys/linux.sx compiler/src/asm/freestanding_io_x86_64.s analysis/phase-b-completion-v1.md; do
  [ -f "$f" ] || { echo "b04 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'extern function shux_sys_write' std/sys/mod.sx || { echo "b04 gate FAIL: mod.sx missing extern write" >&2; exit 1; }

if [ "$(uname -s)" = "Linux" ]; then
  chmod +x tests/run-linux-syscall-invoke-gate.sh
  SHUX="${SHUX:-./compiler/shux-c}"
  if [ ! -x "$SHUX" ]; then
    SHUX="./compiler/shux_asm"
  fi
  if [ -x "$SHUX" ]; then
    SHUX="$SHUX" SHUX_LINUX_SYSCALL_INVOKE_FAIL=${SHUX_LINUX_SYSCALL_INVOKE_FAIL:-1} ./tests/run-linux-syscall-invoke-gate.sh
  else
    echo "b04 gate SKIP invoke (no shux)"
  fi
else
  echo "b04 gate SKIP invoke (non-Linux)"
fi
echo "b04 freestanding-syscall gate OK"

#!/usr/bin/env bash
# B-31：freestanding_io_x86_64.s 极薄 .s 桩登记 + Linux freestanding hello 烟测。
#
# 用法：./tests/run-b31-freestanding-io-gate.sh
set -e
cd "$(dirname "$0")/.."

ASM="compiler/src/asm/freestanding_io_x86_64.s"
FAIL=${SHUX_B31_FAIL:-0}

echo "=== B-31: freestanding_io .s baseline ==="
for f in "$ASM" tests/run-freestanding-hello.sh analysis/phase-b-completion-v1.md; do
  [ -f "$f" ] || { echo "b31 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'shux_sys_write' "$ASM" || { echo "b31 gate FAIL: .s missing shux_sys_write" >&2; exit 1; }
grep -q 'shux_sys_read' "$ASM" || { echo "b31 gate FAIL: .s missing shux_sys_read" >&2; exit 1; }

if [ "$(uname -s)" = "Linux" ]; then
  chmod +x tests/run-freestanding-hello.sh
  if ! tests/run-freestanding-hello.sh; then
    echo "b31 gate FAIL: freestanding hello" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
else
  echo "b31 gate SKIP smoke (non-Linux)"
fi
echo "b31 freestanding-io gate OK"

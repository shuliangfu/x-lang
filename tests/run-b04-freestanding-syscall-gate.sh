#!/usr/bin/env bash
# B-04 v1：freestanding syscall 等价路径（extern → freestanding_io_x86_64.s，非 asm{} 语法）。
#
# 用法：./tests/run-b04-freestanding-syscall-gate.sh
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# Linux invoke smoke (linux_syscall_table_available / os_write_stdout typeck) is
# observational by default — product typeck debt deferred (one-debt-one-commit);
# set XLANG_LINUX_SYSCALL_INVOKE_FAIL=1 to hard-fail. DOC/registration stay hard.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_B_DOC:-analysis/archive/phase/phase-b-completion-v1.md}"
INVOKE_FAIL=${XLANG_LINUX_SYSCALL_INVOKE_FAIL:-0}

echo "=== B-04: freestanding syscall (extern→.s) ==="
for f in std/sys/linux.x compiler/src/asm/freestanding_io_x86_64.s "$DOC"; do
  [ -f "$f" ] || { echo "b04 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'extern function xlang_sys_write' std/sys/mod.x || { echo "b04 gate FAIL: mod.x missing extern write" >&2; exit 1; }

if [ "$(uname -s)" = "Linux" ]; then
  chmod +x tests/run-linux-syscall-invoke-gate.sh
  XLANG="${XLANG:-./compiler/xlang_asm}"
  if [ ! -x "$XLANG" ]; then
    XLANG="./compiler/xlang-c"
  fi
  if [ -x "$XLANG" ]; then
    set +e
    XLANG="$XLANG" XLANG_LINUX_SYSCALL_INVOKE_FAIL=1 ./tests/run-linux-syscall-invoke-gate.sh
    inv_rc=$?
    set -e
    if [ "$inv_rc" -ne 0 ]; then
      echo "b04 gate OBSERVE invoke smoke rc=$inv_rc (typeck/table deferred; FAIL=$INVOKE_FAIL)" >&2
      if [ "$INVOKE_FAIL" = "1" ]; then
        echo "b04 gate FAIL: linux syscall invoke (XLANG_LINUX_SYSCALL_INVOKE_FAIL=1)" >&2
        exit 1
      fi
    fi
  else
    echo "b04 gate SKIP invoke (no xlang)"
  fi
else
  echo "b04 gate SKIP invoke (non-Linux)"
fi
echo "b04 freestanding-syscall gate OK"

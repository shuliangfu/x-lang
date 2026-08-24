#!/usr/bin/env bash
# B-04 v1：freestanding syscall 等价路径（extern → freestanding_io_x86_64.s，非 asm{} 语法）。
#
# 用法：./tests/run-b04-freestanding-syscall-gate.sh
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# wave (2026-08-24): Linux invoke smoke hard-green — smoke uses live write_stdout
# (retired os_write_stdout name was the XT001 hard fail). Soft T001 on
# std.sys→linux.linux_syscall_table_available during dep typeck remains residual
# (does not fail freestanding -o). DOC/registration stay hard.
# PLATFORM: SHARED archaeology / LINUX invoke gold.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_B_DOC:-analysis/archive/phase/phase-b-completion-v1.md}"

echo "=== B-04: freestanding syscall (extern→.s) ==="
for f in std/sys/linux.x compiler/src/asm/freestanding_io_x86_64.s "$DOC"; do
  [ -f "$f" ] || { echo "b04 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'extern function xlang_sys_write' std/sys/mod.x || { echo "b04 gate FAIL: mod.x missing extern write" >&2; exit 1; }
grep -q 'sys.write_stdout' tests/sys/linux_syscall_invoke_smoke.x || {
  echo "b04 gate FAIL: invoke smoke must use live sys.write_stdout" >&2
  exit 1
}
# Refuse call-site resurrection only (comments may mention the retired name).
if grep -qE 'sys\.os_write_stdout\s*\(|[^[:alnum:]_]os_write_stdout\s*\(' tests/sys/linux_syscall_invoke_smoke.x; then
  echo "b04 gate FAIL: invoke smoke resurrected retired os_write_stdout call" >&2
  exit 1
fi

if [ "$(uname -s)" = "Linux" ]; then
  chmod +x tests/run-linux-syscall-invoke-gate.sh
  XLANG="${XLANG:-./compiler/xlang_asm}"
  if [ ! -x "$XLANG" ]; then
    XLANG="./compiler/xlang-c"
  fi
  if [ -x "$XLANG" ]; then
    XLANG="$XLANG" XLANG_LINUX_SYSCALL_INVOKE_FAIL=1 ./tests/run-linux-syscall-invoke-gate.sh
  else
    echo "b04 gate SKIP invoke (no xlang)"
  fi
else
  echo "b04 gate SKIP invoke (non-Linux)"
fi
echo "b04 freestanding-syscall gate OK"

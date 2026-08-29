#!/usr/bin/env bash
# B-04 v1: freestanding syscall equivalent path (extern →
# freestanding_io_x86_64.s, not asm{} syntax).
#
# Honesty: leftover XLANG seed/c fallthrough (`if [ ! -x "$XLANG" ]; then
# XLANG=./compiler/xlang-c`) retired. Linux invoke hard-delegates already-
# honesty-closed run-linux-syscall-invoke-gate.sh (resolve_shu / prefer-asm /
# explicit-bad hard-die). Prefer xlang_asm; pin XLANG_LINK_XLANG lives in
# the nested gate. Explicit-bad XLANG / missing native = hard die on Linux.
# Darwin stays N/A for invoke (Linux gold covers; DOC/manifest still hard).
# G.7: complete existing nested resolve_shu; do not fork a third resolver
# in this host.
#
# Usage: ./tests/run-b04-freestanding-syscall-gate.sh
# Report: run=/skip=
# PLATFORM: SHARED archaeology / LINUX invoke gold.
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when
# archived; live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# wave (2026-08-24): Linux invoke smoke hard-green — smoke uses live write_stdout
# (retired os_write_stdout name was the XT001 hard fail). Soft T001 on
# std.sys→linux.linux_syscall_table_available during dep typeck remains residual
# (does not fail freestanding -o). DOC/registration stay hard.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_B_DOC:-analysis/archive/phase/phase-b-completion-v1.md}"
PREFIX="xlang: [XLANG_B04]"
RUN_OK=0
SKIP=1

die() {
  echo "b04 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

echo "=== B-04: freestanding syscall (extern→.s) ==="
for f in std/sys/linux.x compiler/src/asm/freestanding_io_x86_64.s "$DOC"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'extern function xlang_sys_write' std/sys/mod.x || die "mod.x missing extern write"
grep -q 'sys.write_stdout' tests/sys/linux_syscall_invoke_smoke.x || {
  die "invoke smoke must use live sys.write_stdout"
}
# Refuse call-site resurrection only (comments may mention the retired name).
if grep -qE 'sys\.os_write_stdout\s*\(|[^[:alnum:]_]os_write_stdout\s*\(' tests/sys/linux_syscall_invoke_smoke.x; then
  die "invoke smoke resurrected retired os_write_stdout call"
fi

# PLATFORM: LINUX|UBUNTU — invoke gold is nested linux-syscall-invoke.
# PLATFORM: MACOS|DARWIN / other — DOC/manifest only; invoke N/A skip=1
# before nested resolve (existing leftover, like linux-* Darwin N/A).
if ci_is_linux; then
  chmod +x tests/run-linux-syscall-invoke-gate.sh
  # Drop leftover XLANG rewrite. Nested gate already honesty-closed:
  # explicit XLANG that is missing/non-native hard-dies; unset prefers asm.
  ./tests/run-linux-syscall-invoke-gate.sh
  RUN_OK=1
  SKIP=0
else
  echo "b04 gate SKIP invoke (non-Linux)"
fi

echo "b04 freestanding-syscall gate OK"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0

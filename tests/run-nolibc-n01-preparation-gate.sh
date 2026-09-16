#!/usr/bin/env bash
# NL-01 v1: F-no-libc preparation gate (manifest + infra audit).
#
# Usage: ./tests/run-nolibc-n01-preparation-gate.sh
#        XLANG_NOLIBC_N01_MANIFEST_ONLY=1 ./tests/run-nolibc-n01-preparation-gate.sh
# Honesty: soft XLANG_NOLIBC_N01_FAIL retired — missing DOC/infra was portable
# false-green (die→exit0). Live = archive DOC + baseline TSV + runtime_link_abi
# freestanding block (refuse Makefile / runtime.from_x.c resurrect).
# Report doc=/manifest=/asm=/sys=/rt=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_NOLIBC_N01_DOC:-analysis/archive/phase/phase-f-n01-v1.md}"
PARENT="${XLANG_NOLIBC_PARENT_DOC:-analysis/archive/phase/phase-f-no-libc-v1.md}"
MANIFEST="tests/baseline/nolibc-n01-preparation.tsv"
ROADMAP="tests/baseline/no-libc-roadmap.tsv"
POLICY="tests/baseline/no-libc-link-policy.tsv"
ASM_IO="compiler/src/asm/freestanding_io_x86_64.s"
PREFIX="xlang: [XLANG_NOLIBC_N01]"

DOC_OK=0
MANIFEST_OK=0
ASM_OK=0
SYS_OK=0
RT_OK=0
SKIP=1

die() {
  echo "nolibc-n01 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} asm=${ASM_OK} sys=${SYS_OK} rt=${RT_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-01: F-no-libc preparation (honesty) ==="
if [ -f analysis/phase-f-n01-v1.md ] || [ -f analysis/phase-f-no-libc-v1.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (NL-05 live = runtime_link_abi)"
fi

for f in "$DOC" "$PARENT" "$MANIFEST" "$ROADMAP" "$POLICY" "$ASM_IO"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'NL-01 v1' "$DOC" || die "doc missing NL-01 v1 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n01-v1.md missing ## Gate honesty section"
grep -q 'F-no-libc' "$PARENT" || die "parent doc missing F-no-libc marker"
grep -qE '^## Gate$' "$PARENT" || die "phase-f-no-libc-v1.md missing ## Gate honesty section"
DOC_OK=1

# shellcheck source=tests/lib/nolibc-n01-manifest.sh
. tests/lib/nolibc-n01-manifest.sh
# shellcheck source=tests/lib/no-libc-link-audit.sh
. tests/lib/no-libc-link-audit.sh

if ! nolibc_n01_audit_manifest "$MANIFEST"; then
  die "NL-01 preparation manifest audit failed"
fi
MANIFEST_OK=1

if ! nolibc_n01_audit_asm_syms "$ASM_IO" "$NOLIBC_N01_P0_SYSCALLS $NOLIBC_N01_SOCKET_SYSCALLS"; then
  die "freestanding_io syscall symbol audit failed"
fi
ASM_OK=1

if ! nolibc_n01_audit_sys_linux std/sys/linux.x; then
  die "std/sys/linux.x audit failed"
fi
SYS_OK=1

if ! nolibc_audit_runtime_freestanding_block compiler/seeds/runtime_link_abi.from_x.c; then
  die "runtime NL-05 freestanding block audit failed"
fi
RT_OK=1
SKIP=0

echo "nolibc-n01 gate OK (manifest + infra; sub-gates NL-02～05 via run-no-libc-gate.sh)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} asm=${ASM_OK} sys=${SYS_OK} rt=${RT_OK} skip=${SKIP} host=$(ci_host_summary)"

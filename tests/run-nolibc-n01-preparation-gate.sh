#!/usr/bin/env bash
# NL-01 v1：F-no-libc 准备门禁（manifest + 基础设施审计，无行为变更）。
#
# 用法：./tests/run-nolibc-n01-preparation-gate.sh
# 环境：
#   SHUX_NOLIBC_N01_FAIL=1              — 失败时硬退出
#   SHUX_NOLIBC_N01_MANIFEST_ONLY=1     — 仅 manifest（默认行为等价）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N01_FAIL:-0}
DOC="analysis/phase-f-n01-v1.md"
PARENT="analysis/phase-f-no-libc-v1.md"
MANIFEST="tests/baseline/nolibc-n01-preparation.tsv"
ROADMAP="tests/baseline/no-libc-roadmap.tsv"
POLICY="tests/baseline/no-libc-link-policy.tsv"
ASM_IO="compiler/src/asm/freestanding_io_x86_64.s"

die() {
  echo "nolibc-n01 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-01: F-no-libc preparation (manifest + infra audit) ==="
for f in "$DOC" "$PARENT" "$MANIFEST" "$ROADMAP" "$POLICY" "$ASM_IO"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'NL-01 v1' "$DOC" || die "doc missing NL-01 v1 marker"
grep -q 'F-no-libc' "$PARENT" || die "parent doc missing F-no-libc marker"

# shellcheck source=tests/lib/nolibc-n01-manifest.sh
. tests/lib/nolibc-n01-manifest.sh
# shellcheck source=tests/lib/no-libc-link-audit.sh
. tests/lib/no-libc-link-audit.sh

if ! nolibc_n01_audit_manifest "$MANIFEST"; then
  die "NL-01 preparation manifest audit failed"
fi
if ! nolibc_n01_audit_asm_syms "$ASM_IO" "$NOLIBC_N01_P0_SYSCALLS $NOLIBC_N01_SOCKET_SYSCALLS"; then
  die "freestanding_io syscall symbol audit failed"
fi
if ! nolibc_n01_audit_sys_linux std/sys/linux.sx; then
  die "std/sys/linux.sx audit failed"
fi
if ! nolibc_audit_runtime_freestanding_block compiler/src/runtime_link_abi.c; then
  die "runtime NL-05 freestanding block audit failed"
fi

echo "nolibc-n01 gate OK (manifest + infra; sub-gates NL-02～05 via run-no-libc-gate.sh)"

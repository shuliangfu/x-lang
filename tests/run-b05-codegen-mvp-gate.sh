#!/usr/bin/env bash
# B-05：Codegen 自举 MVP 清单 — 委托 run-asm-73-gate（指针/struct/控制流/ABI 子集）。
#
# 用法：./tests/run-b05-codegen-mvp-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-05: codegen MVP (asm-73) ==="
[ -f analysis/phase-b-completion-v1.md ] || { echo "b05 gate FAIL: missing phase-b doc" >&2; exit 1; }
chmod +x tests/run-asm-73-gate.sh
XLANG_ASM="./compiler/xlang_asm"
if [ -f /.dockerenv ] || [ -n "${XLANG_CI_DOCKER:-}" ]; then
  echo "b05 gate SKIP asm-73 inside Docker (bootstrap-repro policy)"
elif [ ! -x "$XLANG_ASM" ] || ! "$XLANG_ASM" --version >/dev/null 2>&1; then
  echo "b05 gate SKIP asm-73 (xlang_asm not runnable on this host)"
else
  tests/run-asm-73-gate.sh
fi
echo "b05 codegen-mvp gate OK"

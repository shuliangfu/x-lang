#!/usr/bin/env bash
# C-05 v1：LSP lsp_diag.x 链入 + --lsp 烟测（方案 B 子集）。
#
# 用法：./tests/run-c05-lsp-x-gate.sh
# 环境：
#   XLANG_C05_FAIL=1           — 失败时硬退出
#   XLANG_C05_MANIFEST_ONLY=1  — 仅 manifest，不跑 LSP 烟测
#   XLANG=./compiler/xlang      — 默认 bootstrap seed xlang
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# Makefile → compiler/mk/driver_seed_export_lists.mk + ensure_lsp_pipeline_gen.sh。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

FAIL=${XLANG_C05_FAIL:-0}
DOC="${XLANG_C05_DOC:-analysis/archive/phase/phase-c-c05-v1.md}"
MANIFEST="tests/baseline/c05-lsp-x-manifest.tsv"
MK_EXPORT="${XLANG_C05_MK_EXPORT:-compiler/mk/driver_seed_export_lists.mk}"
ENSURE_LSP="compiler/scripts/ensure_lsp_pipeline_gen.sh"
LSP_X="compiler/src/lsp/lsp_diag.x"
XLANG_BIN="${XLANG:-./compiler/xlang}"

die() {
  echo "c05 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== C-05: LSP lsp_diag.x (v1) ==="
for f in "$DOC" "$MANIFEST" "$MK_EXPORT" "$ENSURE_LSP" "$LSP_X" \
  compiler/seeds/lsp_diag_pipeline_ctx.from_x.c tests/run-lsp.sh tests/run-lsp-completion.sh; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk + ./xbuild)"
fi
grep -q 'C-05 v1' "$DOC" || die "doc missing C-05 v1 marker"
grep -q 'pipeline_lsp_diag_parse_typeck_buf' "$LSP_X" || die "lsp_diag.x missing pipeline hook"
grep -q 'lsp_diag_gen' "$ENSURE_LSP" || die "ensure_lsp_pipeline_gen.sh missing lsp_diag_gen"
grep -q 'lsp_diag_x.o' "$MK_EXPORT" || die "$MK_EXPORT missing lsp_diag_x.o"
grep -q 'lsp_diag_pipeline_ctx' "$MK_EXPORT" || die "$MK_EXPORT missing lsp_diag_pipeline_ctx"

if [ "${XLANG_C05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "c05 lsp-x gate OK (manifest only; archive DOC + mk LSP objs)"
  exit 0
fi

if ! native_xlang "$XLANG_BIN"; then
  echo "c05 lsp-x gate: SKIP smoke (no native XLANG); manifest OK"
  echo "c05 lsp-x gate OK (manifest only)"
  exit 0
fi

echo "=== C-05: LSP smoke (delegated) ==="
chmod +x tests/run-lsp.sh
XLANG="$XLANG_BIN" ./tests/run-lsp.sh || die "run-lsp.sh failed"

echo "c05 lsp-x gate OK (archive DOC + mk lsp_diag_x + smoke)"

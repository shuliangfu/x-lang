#!/usr/bin/env bash
# E-02 v1：lsp_diag.c 软退役门禁（文件硬删；默认 LSP_DIAG_LINK_O / stubs 活面）。
#
# 用法：./tests/run-e02-lsp-diag-soft-gate.sh
# 环境：
# 2026-08-26: soft XLANG_E02_FAIL retired (die always hard).
#   XLANG_E02_MANIFEST_ONLY=1     — 仅 manifest（跳过 C-05 委托）
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# lsp_diag.c hard-retired；Makefile → compiler/mk/driver_seed_link_picks.mk
# LSP_DIAG_LINK_O（refuse resurrect）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_E02_DOC:-analysis/archive/phase/phase-e-e02-v1.md}"
MK_PICKS="${XLANG_E02_MK_PICKS:-compiler/mk/driver_seed_link_picks.mk}"
BUILD="compiler/scripts/build_xlang_asm.sh"
STUBS="compiler/seeds/lsp_diag_stubs_no_c.from_x.c"
LSP_X="compiler/src/lsp/lsp_diag.x"

die() {
  echo "e02 gate FAIL: $*" >&2
  exit 1
}

echo "=== E-02: lsp_diag soft-retire (c deleted; live LSP_DIAG_LINK_O) ==="
for f in "$DOC" "$MK_PICKS" "$BUILD" "$STUBS" "$LSP_X"; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_link_picks.mk + ./xbuild)"
fi
if [ -f compiler/src/lsp/lsp_diag.c ]; then
  die "compiler/src/lsp/lsp_diag.c resurrected (hard-retired; live = lsp_diag.x / stubs)"
fi

grep -q 'E-02 v1' "$DOC" || die "doc missing E-02 v1 marker"
grep -q 'LSP_DIAG_LINK_O' "$MK_PICKS" || die "$MK_PICKS missing LSP_DIAG_LINK_O"
grep -q 'ensure_lsp_diag_seed_obj\|lsp_diag_stubs_no_c' "$BUILD" \
  || die "build_xlang_asm missing lsp_diag seed/stubs ensure"
grep -q 'lsp_diag_stubs_no_c' "$STUBS" || grep -q 'Phase E\|E-02\|stub' "$STUBS" \
  || true

echo "e02 track: LSP_DIAG_LINK_O live face = $(grep -E '^LSP_DIAG_LINK_O' "$MK_PICKS" | head -1)"
echo "e02 track: lsp_diag.c hard-retired; live lsp_diag.x + stubs seed"

if [ "${XLANG_E02_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e02 lsp-diag soft-retire gate OK (manifest only)"
  exit 0
fi

if [ -f tests/run-c05-lsp-x-gate.sh ]; then
  echo "=== E-02: delegate run-c05-lsp-x-gate (manifest) ==="
  chmod +x tests/run-c05-lsp-x-gate.sh
  # Hard-delegate; soft XLANG_C05_FAIL retired with honesty wave.
  XLANG_C05_MANIFEST_ONLY=1 ./tests/run-c05-lsp-x-gate.sh || die "C-05 manifest failed"
fi

echo "e02 lsp-diag soft-retire gate OK (archive DOC + mk LSP_DIAG_LINK_O; c deleted)"

#!/usr/bin/env bash
# E-02 v1：lsp_diag.c 软退役门禁（默认 stubs，文件保留）。
#
# 用法：./tests/run-e02-lsp-diag-soft-gate.sh
# 环境：
#   SHUX_E02_FAIL=1              — 失败时硬退出
#   SHUX_E02_MANIFEST_ONLY=1     — 仅 manifest（跳过 C-05 委托）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E02_FAIL:-0}
DOC="analysis/phase-e-e02-v1.md"
MF="compiler/Makefile"
BUILD="compiler/scripts/build_shux_asm.sh"
LSP_C="compiler/src/lsp/lsp_diag.c"
STUBS="compiler/src/lsp/lsp_diag_stubs_no_c.c"

die() {
  echo "e02 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-02: lsp_diag.c soft-retire (default stubs) ==="
for f in "$DOC" "$MF" "$BUILD" "$LSP_C" "$STUBS"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-02 v1' "$DOC" || die "doc missing E-02 v1 marker"
grep -q 'LSP_DIAG_LINK_O' "$MF" || die "Makefile missing LSP_DIAG_LINK_O"
grep -q 'SHUX_LEGACY_LSP_DIAG_C' "$MF" || die "Makefile missing SHUX_LEGACY_LSP_DIAG_C"
grep -q 'lsp_diag_stubs_no_c.o' "$MF" || die "Makefile missing stubs default"
grep -q 'ensure_lsp_diag_seed_obj' "$BUILD" || die "build_shux_asm missing ensure_lsp_diag_seed_obj"
grep -q 'Phase E soft-retired' "$LSP_C" || die "lsp_diag.c missing Phase E marker"

# bootstrap 链接行不得硬编码 lsp_diag.o（须 $(LSP_DIAG_LINK_O)）
if grep -E 'bootstrap-driver-seed:|relink-shux:|^shux-x:' "$MF" | grep -q 'src/lsp/lsp_diag\.o'; then
  die "Makefile bootstrap link still hardcodes src/lsp/lsp_diag.o"
fi

# 默认 LSP_DIAG_LINK_O 须为 stubs
if ! awk '/^ifeq \(\$\(SHUX_LEGACY_LSP_DIAG_C\),1\)/,/^endif/' "$MF" | grep -q 'lsp_diag_stubs_no_c.o'; then
  die "Makefile E-02 block missing stubs default"
fi

echo "e02 track: OBJS_CORE still lists lsp_diag.o (shux-c cold start; defer E-02 v2)"

if [ "${SHUX_E02_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e02 lsp-diag soft-retire gate OK (manifest only)"
  exit 0
fi

if [ -f tests/run-c05-lsp-x-gate.sh ]; then
  echo "=== E-02: delegate run-c05-lsp-x-gate (manifest) ==="
  chmod +x tests/run-c05-lsp-x-gate.sh
  SHUX_C05_MANIFEST_ONLY=1 SHUX_C05_FAIL="$FAIL" ./tests/run-c05-lsp-x-gate.sh || die "C-05 manifest failed"
fi

echo "e02 lsp-diag soft-retire gate OK (default LSP_DIAG_LINK_O=stubs; LEGACY=SHUX_LEGACY_LSP_DIAG_C=1)"

#!/usr/bin/env bash
# E-01：LSP extern .h 软退役门禁（文件不删 / 不参与 -include 编译）。
#
# 用法：./tests/run-e01-extern-h-soft-gate.sh
# 环境：SHUX_E01_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E01_FAIL:-0}
DOC="analysis/phase-e-soft-v1.md"
LSP_EXTERN_C="compiler/src/lsp/lsp_codegen_extern.c"

die() {
  echo "e01 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-01: LSP extern .h soft-retire (no -include) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'E-01' "$DOC" || die "doc missing E-01 section"
[ -f "$LSP_EXTERN_C" ] || die "missing $LSP_EXTERN_C"

# shellcheck source=tests/lib/phase-e-soft-audit.sh
. tests/lib/phase-e-soft-audit.sh

# 独立 .h 已软删除（内容在 lsp_codegen_extern.c）。
for h in compiler/src/lsp/lsp_io_extern.h compiler/src/lsp/lsp_gen_extern.h; do
  if [ -f "$h" ]; then
    die "standalone $h still exists (should be embedded or removed)"
  fi
done

if ! phase_e_soft_audit_no_extern_h_include; then
  die "build still -include lsp_*_extern.h"
fi

grep -q 'lsp_io_extern_block' "$LSP_EXTERN_C" || die "lsp_codegen_extern.c missing lsp_io_extern_block"
grep -q 'lsp_gen_extern_block' "$LSP_EXTERN_C" || die "lsp_codegen_extern.c missing lsp_gen_extern_block"

echo "e01 extern-h soft-retire gate OK (embedded in lsp_codegen_extern.c; C-04 -E-extern)"

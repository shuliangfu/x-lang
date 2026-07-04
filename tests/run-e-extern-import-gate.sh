#!/usr/bin/env bash
# C-04 v0/v1：-E-extern 入口按 import 自动生成 extern（lsp_io / lsp_gen 烟测）。
# 用法：./tests/run-e-extern-import-gate.sh
# 环境：SHUX_E_EXTERN_IMPORT_FAIL=1 失败时硬退出
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/compiler"

FAIL=${SHUX_E_EXTERN_IMPORT_FAIL:-0}
SHUX="${SHUX:-./shux-c}"
LSP_DIRS="-L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen"

if [ ! -x "$SHUX" ]; then
  SHUX="./shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "e-extern-import-gate: SKIP (no shux/shux-c)"
  exit 0
fi

# --- lsp_io.x ---
GEN_IO="/tmp/shux_lsp_io_gen_$$.c"
OBJ_IO="/tmp/shux_lsp_io_gen_$$.o"
rm -f "$GEN_IO" "$OBJ_IO" 2>/dev/null || true

if ! "$SHUX" $LSP_DIRS src/lsp/lsp_io.x -E -E-extern >"$GEN_IO" 2>/tmp/shux_e_extern_io.log; then
  echo "e-extern-import-gate FAIL: -E-extern lsp_io.x" >&2
  tail -n 10 /tmp/shux_e_extern_io.log 2>/dev/null || true
  rm -f "$GEN_IO" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! grep -q 'extern int32_t std_io_read' "$GEN_IO"; then
  echo "e-extern-import-gate FAIL: missing auto extern std_io_read" >&2
  rm -f "$GEN_IO" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if grep -q 'lsp_io -E-extern stubs (io.o' "$GEN_IO"; then
  echo "e-extern-import-gate FAIL: deprecated full lsp_io extern block" >&2
  rm -f "$GEN_IO" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if grep -q '^extern void std_heap_free' "$GEN_IO"; then
  echo "e-extern-import-gate FAIL: duplicate wrong std_heap_free extern" >&2
  rm -f "$GEN_IO" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! cc -c -I. -Dstd_io_read=io_read -Dstd_io_write=io_write -o "$OBJ_IO" "$GEN_IO" 2>/tmp/shux_e_extern_io_cc.log; then
  echo "e-extern-import-gate FAIL: cc -c lsp_io_gen" >&2
  tail -n 10 /tmp/shux_e_extern_io_cc.log 2>/dev/null || true
  rm -f "$GEN_IO" "$OBJ_IO" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
rm -f "$GEN_IO" "$OBJ_IO" 2>/dev/null || true

# --- lsp.x (C-04 v1：lsp_io import 自动 typeck extern + inline wrapper) ---
GEN_LSP="/tmp/shux_lsp_gen_$$.c"
OBJ_LSP="/tmp/shux_lsp_gen_$$.o"
rm -f "$GEN_LSP" "$OBJ_LSP" 2>/dev/null || true

if ! "$SHUX" $LSP_DIRS src/lsp/lsp.x -E -E-extern >"$GEN_LSP" 2>/tmp/shux_e_extern_lsp.log; then
  echo "e-extern-import-gate FAIL: -E-extern lsp.x" >&2
  tail -n 10 /tmp/shux_e_extern_lsp.log 2>/dev/null || true
  rm -f "$GEN_LSP" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if grep -q 'lsp.x -E-extern stubs (lsp_io_x' "$GEN_LSP"; then
  echo "e-extern-import-gate FAIL: deprecated lsp_gen extern block still present" >&2
  rm -f "$GEN_LSP" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q 'extern ptrdiff_t typeck_read_message' "$GEN_LSP"; then
  echo "e-extern-import-gate FAIL: missing auto typeck_read_message extern" >&2
  rm -f "$GEN_LSP" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q 'static inline ptrdiff_t lsp_io_read_message' "$GEN_LSP"; then
  echo "e-extern-import-gate FAIL: missing auto lsp_io_read_message inline wrapper" >&2
  rm -f "$GEN_LSP" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if grep -q '^extern ptrdiff_t lsp_io_read_message' "$GEN_LSP"; then
  echo "e-extern-import-gate FAIL: wrong bare extern lsp_io_read_message (need wrapper)" >&2
  rm -f "$GEN_LSP" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! cc -c -I. -o "$OBJ_LSP" "$GEN_LSP" 2>/tmp/shux_e_extern_lsp_cc.log; then
  echo "e-extern-import-gate FAIL: cc -c lsp_gen" >&2
  tail -n 10 /tmp/shux_e_extern_lsp_cc.log 2>/dev/null || true
  rm -f "$GEN_LSP" "$OBJ_LSP" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
rm -f "$GEN_LSP" "$OBJ_LSP" 2>/dev/null || true

echo "e-extern-import-gate OK (lsp_io + lsp_gen -E-extern auto import extern)"
exit 0

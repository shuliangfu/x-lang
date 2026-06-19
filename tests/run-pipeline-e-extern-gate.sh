#!/usr/bin/env bash
# C-04 v4：pipeline.sx -E-extern 纯 codegen 产出，无 perl 后处理，须 cc -c 通过。
# 用法：./tests/run-pipeline-e-extern-gate.sh
# 环境：SHUX_PIPELINE_E_EXTERN_FAIL=1 失败时硬退出
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/compiler"

FAIL=${SHUX_PIPELINE_E_EXTERN_FAIL:-0}
SHUX="${SHUX:-./shux-c}"
DIRS="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess"
GEN="/tmp/shux_pipeline_e_extern_$$.c"
OBJ="/tmp/shux_pipeline_e_extern_$$.o"

# 与 Makefile PIPELINE_GEN_CFLAGS 对齐（Clang 追加 discards-qualifiers 等）
PIPE_CFLAGS="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
if cc -v 2>&1 | grep -q clang; then
  PIPE_CFLAGS="$PIPE_CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers"
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "pipeline-e-extern-gate: SKIP (no shux/shux-c)"
  exit 0
fi

rm -f "$GEN" "$OBJ" 2>/dev/null || true

if ! "$SHUX" $DIRS src/pipeline/pipeline.sx -E -E-extern >"$GEN" 2>/tmp/shux_pipeline_e_extern_gen.log; then
  echo "pipeline-e-extern-gate FAIL: pipeline -E-extern" >&2
  tail -n 10 /tmp/shux_pipeline_e_extern_gen.log 2>/dev/null || true
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$(grep -c '^struct shux_slice_uint8_t' "$GEN" 2>/dev/null || echo 0)" -ne 1 ]; then
  echo "pipeline-e-extern-gate FAIL: expected exactly one shux_slice_uint8_t definition" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! grep -q 'extern struct parser_ParseIntoResult parser_parse_into_buf' "$GEN"; then
  echo "pipeline-e-extern-gate FAIL: missing auto extern parser_parse_into_buf" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q 'extern int32_t typeck_typeck_sx_ast' "$GEN"; then
  echo "pipeline-e-extern-gate FAIL: missing auto extern typeck_typeck_sx_ast" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q 'extern int32_t shux_io_register' "$GEN"; then
  echo "pipeline-e-extern-gate FAIL: missing auto extern shux_io_register" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q 'extern int32_t parser_copy_module_import_path64.*out\[64\]' "$GEN"; then
  echo "pipeline-e-extern-gate FAIL: parser_copy_module_import_path64 must use out[64]" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! grep -q '#include "pipeline_glue.c"' "$GEN"; then
  echo "pipeline-e-extern-gate FAIL: missing #include pipeline_glue.c tail" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! cc -I.. -I. -Iinclude -Isrc $PIPE_CFLAGS \
  -Dstd_io_driver_driver_read_ptr_len=shux_io_read_ptr_len \
  -Dstd_io_driver_driver_read_ptr=shux_io_read_ptr \
  -c "$GEN" -o "$OBJ" 2>/tmp/shux_pipeline_e_extern_cc.log; then
  echo "pipeline-e-extern-gate FAIL: cc -c pipeline_gen (post bootstrap-pipeline fixes)" >&2
  tail -n 15 /tmp/shux_pipeline_e_extern_cc.log 2>/dev/null || true
  rm -f "$GEN" "$OBJ" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$GEN" "$OBJ" 2>/dev/null || true
echo "pipeline-e-extern-gate OK (pipeline -E-extern auto import extern + cc -c)"
exit 0

#!/usr/bin/env bash
# A-11/C-04：lexer.x parse 修复烟测 + pipeline -E-extern 可生成（解锁瘦 TU）。
# 用法：./tests/run-lexer-e-extern-gate.sh
# 环境：XLANG_LEXER_E_EXTERN_FAIL=1 失败时硬退出
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/compiler"

FAIL=${XLANG_LEXER_E_EXTERN_FAIL:-0}
XLANG="${XLANG:-./xlang-c}"
DIRS="-L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess"
GEN="/tmp/xlang_pipeline_gen_$$.c"

if [ ! -x "$XLANG" ]; then
  XLANG="./xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "lexer-e-extern-gate: SKIP (no xlang/xlang-c)"
  exit 0
fi

if ! "$XLANG" check src/lexer/lexer.x 2>/tmp/xlang_lexer_check.log; then
  echo "lexer-e-extern-gate FAIL: check lexer.x" >&2
  tail -n 8 /tmp/xlang_lexer_check.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$GEN" 2>/dev/null || true
if ! "$XLANG" $DIRS src/pipeline/pipeline.x -E -E-extern >"$GEN" 2>/tmp/xlang_pipeline_e.log; then
  echo "lexer-e-extern-gate FAIL: pipeline -E-extern" >&2
  tail -n 10 /tmp/xlang_pipeline_e.log 2>/dev/null || true
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! grep -q 'extern int32_t xlang_io_register' "$GEN"; then
  echo "lexer-e-extern-gate FAIL: pipeline_gen missing expected extern" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$GEN" 2>/dev/null || true
echo "lexer-e-extern-gate OK (lexer.x parse + pipeline -E-extern)"
exit 0

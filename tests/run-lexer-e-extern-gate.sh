#!/usr/bin/env bash
# A-11/C-04：lexer.x parse 修复烟测 + pipeline -E-extern 可生成（解锁瘦 TU）。
# 用法：./tests/run-lexer-e-extern-gate.sh
# 环境：SHUX_LEXER_E_EXTERN_FAIL=1 失败时硬退出
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/compiler"

FAIL=${SHUX_LEXER_E_EXTERN_FAIL:-0}
SHUX="${SHUX:-./shux-c}"
DIRS="-L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess"
GEN="/tmp/shux_pipeline_gen_$$.c"

if [ ! -x "$SHUX" ]; then
  SHUX="./shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "lexer-e-extern-gate: SKIP (no shux/shux-c)"
  exit 0
fi

if ! "$SHUX" check src/lexer/lexer.x 2>/tmp/shux_lexer_check.log; then
  echo "lexer-e-extern-gate FAIL: check lexer.x" >&2
  tail -n 8 /tmp/shux_lexer_check.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$GEN" 2>/dev/null || true
if ! "$SHUX" $DIRS src/pipeline/pipeline.x -E -E-extern >"$GEN" 2>/tmp/shux_pipeline_e.log; then
  echo "lexer-e-extern-gate FAIL: pipeline -E-extern" >&2
  tail -n 10 /tmp/shux_pipeline_e.log 2>/dev/null || true
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! grep -q 'extern int32_t shux_io_register' "$GEN"; then
  echo "lexer-e-extern-gate FAIL: pipeline_gen missing expected extern" >&2
  rm -f "$GEN" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$GEN" 2>/dev/null || true
echo "lexer-e-extern-gate OK (lexer.x parse + pipeline -E-extern)"
exit 0

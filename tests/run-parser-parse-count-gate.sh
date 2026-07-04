#!/usr/bin/env bash
# track/CI：asm pipeline 编 parser.x 时 pipeline num_funcs 须 ≥150；stretch 全量 module parse 目标 466。
# 用法：./tests/run-parser-parse-count-gate.sh
# 环境：SHUX_PARSER_PARSE_COUNT_FAIL=1 低于 MIN 时硬失败；SHUX_PARSER_PARSE_COUNT_MIN 默认 150
#       SHUX_PARSER_PARSE_COUNT_TARGET 默认 466（full module parse）；SHU 默认 shux_asm
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_PARSE_COUNT_FAIL:-0}
MIN_FUNCS=${SHUX_PARSER_PARSE_COUNT_MIN:-150}
TARGET_FUNCS=${SHUX_PARSER_PARSE_COUNT_TARGET:-466}
SHUX="${SHUX:-./compiler/shux_asm}"
PARSER_X="compiler/src/parser/parser.x"
OUT="/tmp/shux_parser_parse_count.$$.o"
LOG="/tmp/shux_parser_parse_count.$$.log"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-parse-count-gate: N/A on Darwin"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "parser-parse-count-gate: SKIP (no compiler shux/shux_asm)"
  exit 0
fi

src_count=$(grep -c '^function ' "$PARSER_X" 2>/dev/null || echo 0)
echo "parser-parse-count-gate: source functions in parser.x: ${src_count} (baseline min=${MIN_FUNCS}, stretch target>=${TARGET_FUNCS})"

rm -f "$OUT" "$LOG" 2>/dev/null || true

if ! (
  cd compiler
  env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_DEBUG_PIPE=1 \
    "../$SHUX" -backend asm -o "$OUT" $LIBROOT src/parser/parser.x
) >"$LOG" 2>&1; then
  echo "parser-parse-count-gate FAIL: compile command failed" >&2
  tail -n 8 "$LOG" 2>/dev/null || true
  rm -f "$OUT" "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$LOG" | tail -1)
if [ -z "$nf" ]; then
  echo "parser-parse-count-gate: no after_entry_parse in log (skip metric)" >&2
  rm -f "$OUT" "$LOG" 2>/dev/null || true
  exit 0
fi

rm -f "$OUT" "$LOG" 2>/dev/null || true

if [ "$nf" -lt "$MIN_FUNCS" ] 2>/dev/null; then
  echo "parser-parse-count-gate FAIL: num_funcs=${nf} < baseline ${MIN_FUNCS} (SHUX_DEBUG_PARSE=1 for skip list)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$nf" -ge "$TARGET_FUNCS" ] 2>/dev/null; then
  echo "parser-parse-count-gate OK (num_funcs=${nf} >= stretch ${TARGET_FUNCS}; full module parse)"
  exit 0
fi

echo "parser-parse-count-gate OK (num_funcs=${nf}; baseline ${MIN_FUNCS}; target ${TARGET_FUNCS} — mega parse via parser_x.o)"

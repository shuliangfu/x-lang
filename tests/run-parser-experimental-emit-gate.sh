#!/usr/bin/env bash
# track-only：experimental 链无 ENTRY_MODULE_ONLY 编 parser.sx（EMIT_HEAVY）须产出非空 .o（截断 ~4 func，≥500B）。
# 全量 ~288 func 仍靠 parser_sx.o；本门禁防 experimental asm emit 回归。
# 用法：./tests/run-parser-experimental-emit-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_EXPERIMENTAL_EMIT_FAIL:-0}
MIN_TEXT=${SHUX_PARSER_EXPERIMENTAL_EMIT_MIN_TEXT:-500}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-experimental-emit-gate: N/A on Darwin"
  exit 0
fi

COMP_IN="./shux_asm.experimental"
if [ -n "${SHUX_PARSER_EXPERIMENTAL_COMPILER:-}" ]; then
  case "${SHUX_PARSER_EXPERIMENTAL_COMPILER}" in
    compiler/*) COMP_IN="./${SHUX_PARSER_EXPERIMENTAL_COMPILER#compiler/}" ;;
    *) COMP_IN="${SHUX_PARSER_EXPERIMENTAL_COMPILER}" ;;
  esac
fi
if [ ! -x "compiler/$COMP_IN" ] && [ ! -x "$COMP_IN" ]; then
  echo "parser-experimental-emit-gate: SKIP (no compiler/$COMP_IN)"
  exit 0
fi

TMP="/tmp/shux_parser_exp_emit.$$.o"
rm -f "$TMP" /tmp/shux_parser_exp_emit.log 2>/dev/null || true

echo "parser-experimental-emit-gate: compile parser.sx (no ENTRY_ONLY, EMIT_HEAVY) with compiler/$COMP_IN ..."
if ! (
  cd compiler
  env -u SHUX_ASM_START_FUNC SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
    "$COMP_IN" -backend asm -o "$TMP" $LIBROOT src/parser/parser.sx
) > /tmp/shux_parser_exp_emit.log 2>&1; then
  echo "parser-experimental-emit-gate FAIL: compile command failed" >&2
  tail -n 8 /tmp/shux_parser_exp_emit.log 2>/dev/null || true
  rm -f "$TMP" /tmp/shux_parser_exp_emit.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if grep -q 'asm_codegen_elf_o failed' /tmp/shux_parser_exp_emit.log 2>/dev/null; then
  echo "parser-experimental-emit-gate FAIL: asm_codegen_elf_o failed" >&2
  tail -n 6 /tmp/shux_parser_exp_emit.log 2>/dev/null || true
  rm -f "$TMP" /tmp/shux_parser_exp_emit.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -s "$TMP" ]; then
  echo "parser-experimental-emit-gate FAIL: empty output" >&2
  rm -f "$TMP" /tmp/shux_parser_exp_emit.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
[ -z "$TEXT_HEX" ] && TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
TEXT=$(perl -e 'print hex(shift)' "$TEXT_HEX" 2>/dev/null || echo 0)
FILE_SZ=$(stat -c%s "$TMP" 2>/dev/null || stat -f%z "$TMP" 2>/dev/null || echo 0)
rm -f "$TMP" /tmp/shux_parser_exp_emit.log 2>/dev/null || true

if [ "${TEXT:-0}" -lt "$MIN_TEXT" ] 2>/dev/null && [ "${FILE_SZ:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  echo "parser-experimental-emit-gate FAIL: __text=${TEXT}B file=${FILE_SZ}B < min ${MIN_TEXT}B" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "parser-experimental-emit-gate OK (__text=${TEXT}B file=${FILE_SZ}B; mega parse via parser_sx.o)"

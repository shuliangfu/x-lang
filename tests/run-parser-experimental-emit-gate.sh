#!/usr/bin/env bash
# experimental-chain parser.x emit honesty gate (truncated heavy emit).
#
# Honesty: soft XLANG_PARSER_EXPERIMENTAL_EMIT_FAIL retired — compile /
# empty .o soft die→exit0 were portable false-green.
# Missing experimental compiler = honest skip=1. Present compiler must
# produce non-empty emit. Does NOT promote full mega parser.x product path.
#
# Report: compiler=/run=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_EXPERIMENTAL_EMIT]"
FAIL_RETIRED_NOTE="soft XLANG_PARSER_EXPERIMENTAL_EMIT_FAIL retired"
MIN_TEXT=${XLANG_PARSER_EXPERIMENTAL_EMIT_MIN_TEXT:-500}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

COMPILER_OK=0
RUN_OK=0
SKIP=1

die() {
  echo "parser-experimental-emit-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail compiler=${COMPILER_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok compiler=${COMPILER_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-experimental-emit-gate: N/A on Darwin (Linux covers experimental emit)"
  report_ok
  exit 0
fi


COMP_IN="./xlang_asm.experimental"
if [ -n "${XLANG_PARSER_EXPERIMENTAL_COMPILER:-}" ]; then
  case "${XLANG_PARSER_EXPERIMENTAL_COMPILER}" in
    compiler/*) COMP_IN="./${XLANG_PARSER_EXPERIMENTAL_COMPILER#compiler/}" ;;
    *) COMP_IN="${XLANG_PARSER_EXPERIMENTAL_COMPILER}" ;;
  esac
fi
if [ ! -x "compiler/$COMP_IN" ] && [ ! -x "$COMP_IN" ]; then
  echo "parser-experimental-emit-gate: SKIP (no compiler/$COMP_IN; $FAIL_RETIRED_NOTE)"
  report_ok
  exit 0
fi
COMPILER_OK=1

TMP="/tmp/xlang_parser_exp_emit.$$.o"
rm -f "$TMP" /tmp/xlang_parser_exp_emit.log 2>/dev/null || true

echo "parser-experimental-emit-gate: compile parser.x (no ENTRY_ONLY, EMIT_HEAVY) with compiler/$COMP_IN ..."
if ! (
  cd compiler
  env -u XLANG_ASM_START_FUNC XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY=1 XLANG_ASM_WPO_DCE=0 \
    "$COMP_IN" -backend asm -o "$TMP" $LIBROOT src/parser/parser.x
) > /tmp/xlang_parser_exp_emit.log 2>&1; then
  tail -n 8 /tmp/xlang_parser_exp_emit.log 2>/dev/null || true
  rm -f "$TMP" /tmp/xlang_parser_exp_emit.log 2>/dev/null || true
  die "compile command failed"
fi

if grep -q 'asm_codegen_elf_o failed' /tmp/xlang_parser_exp_emit.log 2>/dev/null; then
  tail -n 6 /tmp/xlang_parser_exp_emit.log 2>/dev/null || true
  rm -f "$TMP" /tmp/xlang_parser_exp_emit.log 2>/dev/null || true
  die "asm_codegen_elf_o failed"
fi

if [ ! -s "$TMP" ]; then
  rm -f "$TMP" /tmp/xlang_parser_exp_emit.log 2>/dev/null || true
  die "empty output"
fi

TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
[ -z "$TEXT_HEX" ] && TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
TEXT=$(perl -e 'print hex(shift)' "$TEXT_HEX" 2>/dev/null || echo 0)
FILE_SZ=$(stat -c%s "$TMP" 2>/dev/null || stat -f%z "$TMP" 2>/dev/null || echo 0)
rm -f "$TMP" /tmp/xlang_parser_exp_emit.log 2>/dev/null || true

if [ "${TEXT:-0}" -lt "$MIN_TEXT" ] 2>/dev/null && [ "${FILE_SZ:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  die "__text=${TEXT}B file=${FILE_SZ}B < min ${MIN_TEXT}B"
fi

RUN_OK=1
SKIP=0
echo "parser-experimental-emit-gate OK (__text=${TEXT}B file=${FILE_SZ}B; mega parse via parser_x.o)"
report_ok
exit 0

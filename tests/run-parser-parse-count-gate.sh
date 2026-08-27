#!/usr/bin/env bash
# asm pipeline parser.x num_funcs honesty gate.
#
# Honesty: soft XLANG_PARSER_PARSE_COUNT_FAIL retired — compile / low
# num_funcs soft die→exit0 were portable false-green.
# Prefer xlang_asm; missing compiler = honest skip. Missing after_entry_parse
# metric = skip=1 (probe not wired), not soft PASS on a failed compile.
#
# Report: compile=/funcs=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_PARSE_COUNT]"
MIN_FUNCS=${XLANG_PARSER_PARSE_COUNT_MIN:-150}
TARGET_FUNCS=${XLANG_PARSER_PARSE_COUNT_TARGET:-466}
XLANG="${XLANG:-./compiler/xlang_asm}"
PARSER_X="compiler/src/parser/parser.x"
OUT="/tmp/xlang_parser_parse_count.$$.o"
LOG="/tmp/xlang_parser_parse_count.$$.log"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

COMPILE_OK=0
FUNCS_OK=0
SKIP=1

die() {
  echo "parser-parse-count-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail compile=${COMPILE_OK:-0} funcs=${FUNCS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok compile=${COMPILE_OK:-0} funcs=${FUNCS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-parse-count-gate: N/A on Darwin (Linux covers parse count)"
  report_ok
  exit 0
fi

[ -f "$PARSER_X" ] || die "missing $PARSER_X"

if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "parser-parse-count-gate: SKIP (no compiler xlang/xlang_asm)"
  report_ok
  exit 0
fi

src_count=$(grep -c '^function ' "$PARSER_X" 2>/dev/null || echo 0)
echo "parser-parse-count-gate: source functions in parser.x: ${src_count} (baseline min=${MIN_FUNCS}, stretch target>=${TARGET_FUNCS})"

rm -f "$OUT" "$LOG" 2>/dev/null || true

if ! (
  cd compiler
  env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_DEBUG_PIPE=1 \
    "../$XLANG" build -backend asm -o "$OUT" $LIBROOT src/parser/parser.x
) >"$LOG" 2>&1; then
  tail -n 8 "$LOG" 2>/dev/null || true
  rm -f "$OUT" "$LOG" 2>/dev/null || true
  die "compile command failed"
fi
COMPILE_OK=1

nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$LOG" | tail -1)
if [ -z "$nf" ]; then
  echo "parser-parse-count-gate: SKIP metric (no after_entry_parse in log)" >&2
  rm -f "$OUT" "$LOG" 2>/dev/null || true
  report_ok
  exit 0
fi
rm -f "$OUT" "$LOG" 2>/dev/null || true

if [ "$nf" -lt "$MIN_FUNCS" ] 2>/dev/null; then
  die "num_funcs=${nf} < baseline ${MIN_FUNCS} (XLANG_DEBUG_PARSE=1 for skip list)"
fi
FUNCS_OK=1
SKIP=0

if [ "$nf" -ge "$TARGET_FUNCS" ] 2>/dev/null; then
  echo "parser-parse-count-gate OK (num_funcs=${nf} >= stretch ${TARGET_FUNCS}; full module parse)"
else
  echo "parser-parse-count-gate OK (num_funcs=${nf}; baseline ${MIN_FUNCS}; target ${TARGET_FUNCS} — mega parse via parser_x.o)"
fi
report_ok
exit 0

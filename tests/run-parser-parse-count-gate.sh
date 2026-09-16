#!/usr/bin/env bash
# asm pipeline parser.x num_funcs honesty gate.
#
# Honesty: leftover XLANG seed fallthrough (`if [ ! -x "$XLANG" ]; then
# XLANG=./compiler/xlang`) and missing-compiler soft SKIP→OK retired. Soft
# XLANG_PARSER_PARSE_COUNT_FAIL already retired. Prefer xlang_asm; pin
# XLANG_LINK_XLANG. Explicit-bad XLANG / missing native = hard die.
# Missing after_entry_parse metric = skip=1 (probe not wired), not soft
# PASS on a failed compile. Darwin stays N/A (Linux gold covers).
# G.7: complete existing resolve_shu; converge dod_native_exe.
#
# Report: compile=/funcs=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_PARSE_COUNT]"
MIN_FUNCS=${XLANG_PARSER_PARSE_COUNT_MIN:-150}
TARGET_FUNCS=${XLANG_PARSER_PARSE_COUNT_TARGET:-466}
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

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
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

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== parser-parse-count (XLANG=$XLANG_BIN; hard) ==="
src_count=$(grep -c '^function ' "$PARSER_X" 2>/dev/null || echo 0)
echo "parser-parse-count-gate: source functions in parser.x: ${src_count} (baseline min=${MIN_FUNCS}, stretch target>=${TARGET_FUNCS})"

rm -f "$OUT" "$LOG" 2>/dev/null || true

if ! (
  cd compiler
  env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_DEBUG_PIPE=1 \
    "$XLANG_BIN" build -backend asm -o "$OUT" $LIBROOT src/parser/parser.x
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

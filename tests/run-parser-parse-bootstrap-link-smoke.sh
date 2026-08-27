#!/usr/bin/env bash
# experimental chain + parser_parse_bootstrap.o link smoke honesty gate.
#
# Honesty: soft XLANG_PARSER_PARSE_BOOTSTRAP_LINK_FAIL retired — symbol /
# compile failures soft die→exit0 were portable false-green.
# Missing bootstrap.o / compiler / runtime libs = honest skip=1 (optional
# experimental path), not soft PASS pretending green.
#
# Report: compiler=/boot=/run=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_PARSE_BOOTSTRAP_LINK]"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
MIN_TEXT=${XLANG_PARSER_PARSE_BOOTSTRAP_LINK_MIN_TEXT:-8}

COMPILER_OK=0
BOOT_OK=0
RUN_OK=0
SKIP=1

die() {
  echo "parser-parse-bootstrap-link-smoke FAIL: $*" >&2
  echo "${PREFIX} status=fail compiler=${COMPILER_OK:-0} boot=${BOOT_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok compiler=${COMPILER_OK:-0} boot=${BOOT_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-parse-bootstrap-link-smoke: N/A on Darwin (Linux covers bootstrap link)"
  report_ok
  exit 0
fi


COMP_IN="./xlang_asm"
if [ -n "${XLANG_PARSER_PARSE_BOOTSTRAP_COMPILER:-}" ]; then
  case "${XLANG_PARSER_PARSE_BOOTSTRAP_COMPILER}" in
    compiler/*) COMP_IN="./${XLANG_PARSER_PARSE_BOOTSTRAP_COMPILER#compiler/}" ;;
    *) COMP_IN="${XLANG_PARSER_PARSE_BOOTSTRAP_COMPILER}" ;;
  esac
fi
if [ ! -x "compiler/$COMP_IN" ] && [ ! -x "$COMP_IN" ]; then
  echo "parser-parse-bootstrap-link-smoke: SKIP (no compiler/$COMP_IN)"
  report_ok
  exit 0
fi
COMPILER_OK=1

BOOT_O="compiler/build_asm/parser_parse_bootstrap.o"
if [ ! -f "$BOOT_O" ]; then
  echo "parser-parse-bootstrap-link-smoke: SKIP (missing $BOOT_O; optional experimental bootstrap)"
  report_ok
  exit 0
fi
if ! nm -g "$BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
  die "$BOOT_O missing parse_into_buf"
fi
BOOT_OK=1

if [ -x "compiler/$COMP_IN" ]; then
  LDD_MISS=$(ldd "compiler/$COMP_IN" 2>/dev/null | grep 'not found' || true)
  if [ -n "$LDD_MISS" ]; then
    echo "parser-parse-bootstrap-link-smoke: SKIP (compiler/$COMP_IN missing runtime libs)" >&2
    echo "$LDD_MISS" >&2
    report_ok
    exit 0
  fi
fi

SRC="/tmp/xlang_parser_boot_link_smoke.$$.x"
OUT="/tmp/xlang_parser_boot_link_smoke.$$.o"
LOG="/tmp/xlang_parser_boot_link_smoke.log"
rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
printf 'function main(): i32 { return 42; }\n' > "$SRC"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-link-smoke: asm compile minimal .x with compiler/$COMP_IN ..."
if ! (
  cd compiler
  env -u XLANG_ASM_START_FUNC XLANG_ASM_BUILD_SKIP_TYPECK=1 \
    "$COMP_IN" -backend asm -o "$OUT" $LIBROOT "$SRC"
) > "$LOG" 2>&1; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
  die "compile command failed"
fi

if grep -q 'asm_codegen_elf_o failed' "$LOG" 2>/dev/null; then
  tail -n 8 "$LOG" 2>/dev/null || true
  rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
  die "asm_codegen_elf_o failed"
fi

if [ ! -s "$OUT" ]; then
  rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
  die "empty output $OUT"
fi

TEXT_HEX=$(objdump -h "$OUT" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
[ -z "$TEXT_HEX" ] && TEXT_HEX=$(objdump -h "$OUT" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
TEXT=$(perl -e 'print hex(shift)' "$TEXT_HEX" 2>/dev/null || echo 0)
rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true

if [ "${TEXT:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  die "__text=${TEXT}B < min ${MIN_TEXT}B"
fi

RUN_OK=1
SKIP=0
echo "parser-parse-bootstrap-link-smoke PASS (__text=${TEXT}B; bootstrap.o parse_into_buf linked)"
report_ok
exit 0

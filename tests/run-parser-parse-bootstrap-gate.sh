#!/usr/bin/env bash
# parser_parse_bootstrap.o C seed TU honesty gate.
#
# Honesty: soft XLANG_PARSER_PARSE_BOOTSTRAP_FAIL retired — cc/nm/.text
# failures soft die→exit0 were portable false-green.
# Live authority: compiler/seeds/parser_asm/parser_asm_parse_bootstrap_obj.inc
# + analysis/archive/phase/phase-parser-soft-fail0-honesty.md ## Gate.
#
# Report: seed=/sym=/text=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
BOOT_SRC="compiler/seeds/parser_asm/parser_asm_parse_bootstrap_obj.inc"
PREFIX="xlang: [XLANG_PARSER_PARSE_BOOTSTRAP]"
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -Icompiler -Icompiler/include -Icompiler/src"
MIN_TEXT=${XLANG_PARSER_PARSE_BOOTSTRAP_MIN_TEXT:-512}

SEED_OK=0
SYM_OK=0
TEXT_OK=0
SKIP=1

die() {
  echo "parser-parse-bootstrap-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail seed=${SEED_OK:-0} sym=${SYM_OK:-0} text=${TEXT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok seed=${SEED_OK:-0} sym=${SYM_OK:-0} text=${TEXT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
if [ -f analysis/phase-parser-soft-fail0-honesty.md ]; then
  die "top-level analysis/phase-parser-soft-fail0-honesty.md resurrected (live = archive/phase/)"
fi

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-parse-bootstrap-gate: N/A on Darwin (Linux covers C seed TU)"
  report_ok
  exit 0
fi


[ -f "$BOOT_SRC" ] || die "missing $BOOT_SRC"
SEED_OK=1

BOOT_O="/tmp/xlang_parser_parse_bootstrap_gate.$$.o"
rm -f "$BOOT_O" 2>/dev/null || true

echo "parser-parse-bootstrap-gate: cc parser_asm_parse_bootstrap_obj.inc ..."
if ! $CC $CFLAGS -c -o "$BOOT_O" "$BOOT_SRC" > /tmp/xlang_parser_boot_gate.log 2>&1; then
  tail -n 12 /tmp/xlang_parser_boot_gate.log 2>/dev/null || true
  rm -f "$BOOT_O" /tmp/xlang_parser_boot_gate.log 2>/dev/null || true
  die "cc compile"
fi

if ! nm -g "$BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
  nm -g "$BOOT_O" 2>/dev/null | grep -E 'parse_into' || true
  rm -f "$BOOT_O" /tmp/xlang_parser_boot_gate.log 2>/dev/null || true
  die "missing global parse_into_buf"
fi

if ! nm -g "$BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parser_parse_into_buf$'; then
  rm -f "$BOOT_O" /tmp/xlang_parser_boot_gate.log 2>/dev/null || true
  die "missing global parser_parse_into_buf"
fi
SYM_OK=1

TEXT=$(objdump -h "$BOOT_O" 2>/dev/null | awk '/\.text/ {print $3; exit}')
TEXT_DEC=0
if [ -n "$TEXT" ]; then
  TEXT_DEC=$((16#$TEXT))
fi
if [ "$TEXT_DEC" -lt "$MIN_TEXT" ]; then
  rm -f "$BOOT_O" /tmp/xlang_parser_boot_gate.log 2>/dev/null || true
  die ".text=$TEXT_DEC < min=$MIN_TEXT"
fi
TEXT_OK=1
SKIP=0

echo "parser-parse-bootstrap-gate PASS: parse_into_buf .text=${TEXT_DEC}B"
rm -f "$BOOT_O" /tmp/xlang_parser_boot_gate.log 2>/dev/null || true
report_ok
exit 0

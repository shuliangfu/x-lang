#!/usr/bin/env bash
# parser_asm_thin_glue.o symbol integrity honesty gate.
#
# Honesty: soft XLANG_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL retired —
# missing baseline/symbols soft die→exit0 were portable false-green.
# Live authority: tests/baseline/parser-thin-glue-symbols.tsv +
# analysis/archive/phase/phase-parser-soft-fail0-honesty.md ## Gate.
#
# Report: baseline=/stretch=/glue=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
ENG_DOC="analysis/archive/eng/eng-quality-gate-v1.md"
BASELINE="${XLANG_PARSER_THIN_GLUE_SYMBOL_BASELINE:-tests/baseline/parser-thin-glue-symbols.tsv}"
THIN_SRC="compiler/seeds/parser_asm_thin_c.from_x.c"
GLUE_OBJ="compiler/parser_asm_thin_glue.o"
NM_LIST="/tmp/xlang_parser_thin_glue_syms.$$.txt"
PREFIX="xlang: [XLANG_PARSER_THIN_GLUE]"

BASELINE_OK=0
STRETCH_OK=0
GLUE_OK=0
SKIP=1

die() {
  echo "parser-thin-glue-symbol-integrity-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail baseline=${BASELINE_OK:-0} stretch=${STRETCH_OK:-0} glue=${GLUE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok baseline=${BASELINE_OK:-0} stretch=${STRETCH_OK:-0} glue=${GLUE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
[ -f "$ENG_DOC" ] || die "missing $ENG_DOC"
grep -qE '^## Gate' "$ENG_DOC" || die "eng doc missing ## Gate honesty section"
if [ -f analysis/eng-quality-gate-v1.md ]; then
  die "top-level analysis/eng-quality-gate-v1.md resurrected (live = archive/eng/)"
fi

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-thin-glue-symbol-integrity-gate: N/A on Darwin (Linux nm covers thin glue)"
  report_ok
  exit 0
fi


[ -f "$THIN_SRC" ] || die "missing $THIN_SRC"
command -v cc >/dev/null 2>&1 || die "need cc"
command -v nm >/dev/null 2>&1 || die "need nm"

if [ ! -f "$GLUE_OBJ" ] || [ "$THIN_SRC" -nt "$GLUE_OBJ" ]; then
  echo "parser-thin-glue-symbol-integrity-gate: cc -c $THIN_SRC -> $GLUE_OBJ"
  cc -Wall -Icompiler -Icompiler/include -Icompiler/src -Icompiler/src/lexer \
    -c -o "$GLUE_OBJ" "$THIN_SRC" || die "cc thin glue"
fi

nm -g --defined-only "$GLUE_OBJ" 2>/dev/null | awk '{print $3}' | sort -u >"$NM_LIST"

[ -f "$BASELINE" ] || { rm -f "$NM_LIST"; die "missing baseline $BASELINE"; }
BASELINE_OK=1

MIN_STRETCH=$(awk -F'\t' '$1=="min_stretch_defined" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)
MIN_GLUE=$(awk -F'\t' '$1=="min_glue_defined" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)

STRETCH_CNT=$(grep -c '^parser_asm_stretch_' "$NM_LIST" 2>/dev/null || echo 0)
GLUE_CNT=$(grep -c '_glue$' "$NM_LIST" 2>/dev/null || echo 0)
# Normalize possible "0\n0" from grep -c || echo
STRETCH_CNT=$(echo "$STRETCH_CNT" | head -1 | tr -d ' ')
GLUE_CNT=$(echo "$GLUE_CNT" | head -1 | tr -d ' ')

MISSING=0
if [ -n "$MIN_STRETCH" ] && [ "${STRETCH_CNT:-0}" -lt "$MIN_STRETCH" ] 2>/dev/null; then
  echo "parser-thin-glue-symbol-integrity-gate FAIL: stretch_defined=${STRETCH_CNT} < min ${MIN_STRETCH}" >&2
  MISSING=1
else
  STRETCH_OK=1
fi
if [ -n "$MIN_GLUE" ] && [ "${GLUE_CNT:-0}" -lt "$MIN_GLUE" ] 2>/dev/null; then
  echo "parser-thin-glue-symbol-integrity-gate FAIL: glue_defined=${GLUE_CNT} < min ${MIN_GLUE}" >&2
  MISSING=1
else
  GLUE_OK=1
fi

while IFS=$'\t' read -r kind sym _rest; do
  [ "$kind" = "symbol" ] || continue
  [ -n "$sym" ] || continue
  if ! grep -qx "$sym" "$NM_LIST" 2>/dev/null; then
    echo "parser-thin-glue-symbol-integrity-gate FAIL: missing symbol $sym" >&2
    MISSING=$((MISSING + 1))
  fi
done <"$BASELINE"

rm -f "$NM_LIST" 2>/dev/null || true

if [ "$MISSING" -gt 0 ]; then
  die "missing=${MISSING} stretch=${STRETCH_CNT} glue=${GLUE_CNT}"
fi

SKIP=0
echo "parser-thin-glue-symbol-integrity-gate OK (required symbols present, stretch=${STRETCH_CNT}, glue=${GLUE_CNT})"
report_ok
exit 0

#!/usr/bin/env bash
# mega single-item bisect honesty gate (track stub vs unexpected emit).
#
# Honesty: soft XLANG_PARSER_MEGA_BISECT_FAIL retired — unexpected large
# delta soft die→exit0 was portable false-green. Stub / compile-fail paths
# remain OK (NOT a mega promote knife; product still uses parser_x.o).
#
# Report: stub=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
# Non-goal: open mega emit / assemble full parser.x as product default.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_MEGA_BISECT]"
TARGET=${XLANG_PARSER_MEGA_BISECT_TARGET:-parse_into}
MIN_DELTA=${XLANG_PARSER_MEGA_BISECT_MIN_DELTA:-8192}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

STUB_OK=0
SKIP=1

die() {
  echo "parser-mega-bisect-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail stub=${STUB_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok stub=${STUB_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-mega-bisect-gate: N/A on Darwin (Linux covers mega bisect track)"
  report_ok
  exit 0
fi


COMP_IN="./xlang_asm"
if [ -n "${XLANG_PARSER_MEGA_BISECT_COMPILER:-}" ]; then
  case "${XLANG_PARSER_MEGA_BISECT_COMPILER}" in
    compiler/*) COMP_IN="./${XLANG_PARSER_MEGA_BISECT_COMPILER#compiler/}" ;;
    *) COMP_IN="${XLANG_PARSER_MEGA_BISECT_COMPILER}" ;;
  esac
fi
if [ ! -x "compiler/$COMP_IN" ] && [ ! -x "$COMP_IN" ]; then
  echo "parser-mega-bisect-gate: SKIP (no compiler/$COMP_IN)"
  report_ok
  exit 0
fi

text_bytes() {
  local f="$1"
  local h
  h=$(objdump -h "$f" 2>/dev/null | awk '/\.text/ {gsub(/\./,""); print $3; exit}')
  if [ -z "$h" ]; then
    echo 0
    return
  fi
  echo $((16#$h))
}

compile_parser_o() {
  local mega_bisect="$1"
  local out="/tmp/xlang_parser_mega_bisect_${mega_bisect:-base}.$$.o"
  local log="/tmp/xlang_parser_mega_bisect_${mega_bisect:-base}.log"
  local ec text
  rm -f "$out" "$log" 2>/dev/null || true
  set +e
  (
    cd compiler
    env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 \
      XLANG_ASM_ENTRY_EMIT_HEAVY=1 XLANG_ASM_WPO_DCE=0 \
      ${mega_bisect:+XLANG_ASM_PARSER_MEGA_BISECT=$mega_bisect} \
      "$COMP_IN" -backend asm -o "$out" $LIBROOT src/parser/parser.x
  ) > "$log" 2>&1
  ec=$?
  set -e
  text=0
  if [ -s "$out" ]; then
    text=$(text_bytes "$out")
  fi
  rm -f "$out" "$log" 2>/dev/null || true
  echo "$ec $text"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-mega-bisect-gate: baseline (no MEGA_BISECT) ..."
read -r BASE_EC BASE_TEXT <<<"$(compile_parser_o "")"
echo "parser-mega-bisect-gate: MEGA_BISECT=$TARGET ..."
read -r BISECT_EC BISECT_TEXT <<<"$(compile_parser_o "$TARGET")"

DELTA=$((BISECT_TEXT - BASE_TEXT))
echo "parser-mega-bisect-gate: baseline text=${BASE_TEXT}B bisect text=${BISECT_TEXT}B delta=${DELTA}B ec=${BISECT_EC}"

if [ "$BISECT_EC" -ne 0 ]; then
  STUB_OK=1
  SKIP=0
  echo "parser-mega-bisect-gate PASS (known: mega $TARGET compile fail ec=$BISECT_EC)"
  report_ok
  exit 0
fi

if [ "$DELTA" -lt "$MIN_DELTA" ]; then
  STUB_OK=1
  SKIP=0
  echo "parser-mega-bisect-gate PASS (mega $TARGET bisect delta=${DELTA}B < ${MIN_DELTA}B — still ret0/stub path)"
  report_ok
  exit 0
fi

die "unexpected mega $TARGET bisect emit delta=${DELTA}B >= ${MIN_DELTA}B (not a soft track; do not silent-promote)"

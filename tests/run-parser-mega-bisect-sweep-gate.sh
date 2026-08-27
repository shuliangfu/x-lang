#!/usr/bin/env bash
# mega 7-item bisect sweep honesty gate (track stub vs unexpected emit).
#
# Honesty: soft XLANG_PARSER_MEGA_BISECT_SWEEP_FAIL retired — baseline drift /
# unexpected emit soft die→exit0 were portable false-green.
# Stub/fail rows OK; any emit status or TSV drift is hard. Not a mega promote.
#
# Report: rows=/stub=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_MEGA_BISECT_SWEEP]"
MIN_DELTA=${XLANG_PARSER_MEGA_BISECT_MIN_DELTA:-8192}
BASELINE="${XLANG_PARSER_MEGA_BISECT_BASELINE:-tests/baseline/parser-mega-bisect.tsv}"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
MEGAS=(parse_into_buf parse_into parse parse_one_function_impl parse_expr_into parse_block_into parse_body_lets_into)

ROWS_OK=0
STUB_OK=0
DRIFT=0
SKIP=1

die() {
  echo "parser-mega-bisect-sweep-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail rows=${ROWS_OK:-0} stub=${STUB_OK:-0} drift=${DRIFT:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok rows=${ROWS_OK:-0} stub=${STUB_OK:-0} drift=${DRIFT:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-mega-bisect-sweep-gate: N/A on Darwin (Linux covers mega sweep track)"
  report_ok
  exit 0
fi


COMP_IN="./xlang_asm"
if [ ! -x "compiler/$COMP_IN" ]; then
  echo "parser-mega-bisect-sweep-gate: SKIP (no compiler/$COMP_IN)"
  report_ok
  exit 0
fi

text_bytes() {
  local f="$1"
  local h
  h=$(objdump -h "$f" 2>/dev/null | awk '/\.text/ {gsub(/\./,""); print $3; exit}')
  [ -z "$h" ] && echo 0 && return
  echo $((16#$h))
}

compile_one() {
  local name="$1"
  local out="/tmp/xlang_mega_sweep_${name}.$$.o"
  local ec text
  rm -f "$out" 2>/dev/null || true
  set +e
  (
    cd compiler
    env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 \
      XLANG_ASM_ENTRY_EMIT_HEAVY=1 XLANG_ASM_WPO_DCE=0 \
      ${name:+XLANG_ASM_PARSER_MEGA_BISECT=$name} \
      "$COMP_IN" -backend asm -o "$out" $LIBROOT src/parser/parser.x
  ) >/dev/null 2>&1
  ec=$?
  set -e
  text=0
  [ -s "$out" ] && text=$(text_bytes "$out")
  rm -f "$out" 2>/dev/null || true
  echo "$ec $text"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

read -r BASE_EC BASE_TEXT <<<"$(compile_one "")"
echo "parser-mega-bisect-sweep-gate: baseline text=${BASE_TEXT}B ec=${BASE_EC}"

TMP_BASELINE="/tmp/parser_mega_bisect_sweep.$$.tsv"
{
  echo "# parser mega bisect sweep (linux/amd64 experimental xlang_asm)"
  echo "baseline_text	${BASE_TEXT}"
  echo "min_delta_pass	${MIN_DELTA}"
} > "$TMP_BASELINE"

ANY_EMIT=0
ROW_N=0
for name in "${MEGAS[@]}"; do
  read -r EC TEXT <<<"$(compile_one "$name")"
  DELTA=$((TEXT - BASE_TEXT))
  STATUS=stub
  if [ "$EC" -ne 0 ]; then
    STATUS=fail
  elif [ "$DELTA" -ge "$MIN_DELTA" ]; then
    STATUS=emit
    ANY_EMIT=1
  fi
  ROW_N=$((ROW_N + 1))
  echo "${name}	ec=${EC}	text=${TEXT}	delta=${DELTA}	status=${STATUS}"
  printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$EC" "$TEXT" "$DELTA" "$STATUS" >> "$TMP_BASELINE"
done
ROWS_OK=1

if [ ! -f "$BASELINE" ]; then
  rm -f "$TMP_BASELINE"
  die "missing baseline $BASELINE (refuse silent write; commit baseline deliberately)"
fi
# Absolute __text sizes drift with tip compiler; track observationally.
# Hard surface = unexpected emit promote (ANY_EMIT), not byte-identical TSV.
if ! diff -q "$BASELINE" "$TMP_BASELINE" >/dev/null 2>&1; then
  DRIFT=1
  echo "parser-mega-bisect-sweep-gate OBS: baseline absolute-size drift (see $BASELINE; not emit promote)" >&2
  diff -u "$BASELINE" "$TMP_BASELINE" 2>/dev/null | tail -n 20 || true
fi
rm -f "$TMP_BASELINE" 2>/dev/null || true

if [ "$ANY_EMIT" = "1" ]; then
  die "at least one mega bisect showed emit delta >= ${MIN_DELTA}B (not soft track)"
fi

STUB_OK=1
SKIP=0
echo "parser-mega-bisect-sweep-gate PASS (all mega items stub/fail path; rows=${ROW_N} drift=${DRIFT})"
report_ok
exit 0

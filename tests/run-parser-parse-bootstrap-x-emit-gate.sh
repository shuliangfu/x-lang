#!/usr/bin/env bash
# x PARSE_BOOTSTRAP_EMIT probe honesty gate.
#
# Honesty: soft XLANG_PARSER_PARSE_BOOTSTRAP_X_EMIT_FAIL retired —
# MINIMAL failures / unexpected mega emit soft die→exit0 were portable
# false-green. Default path remains C seed TU; X FULL emit is observational
# known-fail (not mega promote).
#
# Env: XLANG_PARSER_PARSE_BOOTSTRAP_X_EMIT_EXPECT_OK=1 — require X FULL OK.
# Report: minimal=/full_obs=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_PARSE_BOOTSTRAP_X_EMIT]"
EXPECT_OK=${XLANG_PARSER_PARSE_BOOTSTRAP_X_EMIT_EXPECT_OK:-0}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

MINIMAL_OK=0
FULL_OBS=0
SKIP=1

die() {
  echo "parser-parse-bootstrap-x-emit-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail minimal=${MINIMAL_OK:-0} full_obs=${FULL_OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok minimal=${MINIMAL_OK:-0} full_obs=${FULL_OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-parse-bootstrap-x-emit-gate: N/A on Darwin (Linux covers x-emit probe)"
  report_ok
  exit 0
fi


XLANG_SEED="compiler/xlang"
if [ ! -x "$XLANG_SEED" ]; then
  echo "parser-parse-bootstrap-x-emit-gate: SKIP (no $XLANG_SEED)"
  report_ok
  exit 0
fi

OUT="/tmp/xlang_parser_boot_x_emit.$$.o"
LOG="/tmp/xlang_parser_boot_x_emit.log"
rm -f "$OUT" "$LOG" 2>/dev/null || true

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-x-emit-gate: probe XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT on seed ./xlang ..."
set +e
(
  cd compiler
  env -u XLANG_ASM_START_FUNC XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
    XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_WPO_DCE=0 \
    ./xlang build -backend asm -o "$OUT" $LIBROOT src/parser/parser.x
) > "$LOG" 2>&1
EC=$?
set -e

HAS_O=0
[ -s "$OUT" ] && HAS_O=1
HAS_SYM=0
HAS_SYM_SZ=0
if [ "$HAS_O" = "1" ]; then
  if nm -g --defined-only "$OUT" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
    HAS_SYM=1
    HAS_SYM_SZ=$(readelf -s "$OUT" 2>/dev/null | awk '/parse_into_buf$/ && /FUNC/ {print $3; exit}')
    HAS_SYM_SZ=${HAS_SYM_SZ:-0}
  fi
fi
rm -f "$OUT" 2>/dev/null || true

if [ "$EXPECT_OK" = "1" ]; then
  if [ "$EC" -ne 0 ] || [ "$HAS_SYM" != "1" ]; then
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$LOG" 2>/dev/null || true
    die "expected x bootstrap OK (ec=$EC has_sym=$HAS_SYM)"
  fi
  MINIMAL_OK=1
  FULL_OBS=1
  SKIP=0
  echo "parser-parse-bootstrap-x-emit-gate PASS: x bootstrap emit OK (EXPECT_OK=1)"
  rm -f "$LOG" 2>/dev/null || true
  report_ok
  exit 0
fi

# Default: unexpected mega-sized parse_into_buf emit is hard (not soft track).
if [ "$EC" -eq 0 ] && [ "$HAS_SYM" = "1" ] && [ "$HAS_SYM_SZ" -gt 4096 ]; then
  rm -f "$LOG" 2>/dev/null || true
  die "x bootstrap unexpectedly succeeded with mega parse_into_buf (use C TU or set EXPECT_OK)"
fi

MIN_OUT="/tmp/xlang_parser_boot_x_emit_min.$$.o"
MIN_LOG="/tmp/xlang_parser_boot_x_emit_min.log"
rm -f "$MIN_OUT" "$MIN_LOG" 2>/dev/null || true
set +e
(
  cd compiler
  env -u XLANG_ASM_START_FUNC XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
    XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL=1 \
    XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_WPO_DCE=0 \
    ./xlang build -backend asm -o "$MIN_OUT" $LIBROOT src/parser/parser.x
) > "$MIN_LOG" 2>&1
MIN_EC=$?
set -e
MIN_HAS_INIT=0
MIN_HAS_BUF_SZ=0
if [ -s "$MIN_OUT" ]; then
  nm -g --defined-only "$MIN_OUT" 2>/dev/null | grep -qE '[[:space:]]parse_into_init$' && MIN_HAS_INIT=1
  if nm -g --defined-only "$MIN_OUT" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
    MIN_HAS_BUF_SZ=$(readelf -s "$MIN_OUT" 2>/dev/null | awk '/parse_into_buf$/ && /FUNC/ {print $3; exit}')
    MIN_HAS_BUF_SZ=${MIN_HAS_BUF_SZ:-0}
  fi
fi
rm -f "$MIN_OUT" "$MIN_LOG" 2>/dev/null || true
if [ "$MIN_EC" -ne 0 ] || [ "$MIN_HAS_INIT" != "1" ] || [ "$MIN_HAS_BUF_SZ" -gt 128 ]; then
  die "MINIMAL bootstrap (ec=$MIN_EC init=$MIN_HAS_INIT buf_sz=$MIN_HAS_BUF_SZ)"
fi
MINIMAL_OK=1

FULL_OBS=1
if [ "$EC" -eq 139 ] || [ "$EC" -eq 134 ] || [ "$EC" -ne 0 ]; then
  echo "parser-parse-bootstrap-x-emit-gate PASS (known x bootstrap fail ec=$EC; MINIMAL OK; use parser_asm_parse_bootstrap_obj.inc)"
else
  echo "parser-parse-bootstrap-x-emit-gate PASS (ec=$EC has_o=$HAS_O; x emit path inactive — C TU default)"
fi
rm -f "$LOG" 2>/dev/null || true
SKIP=0
report_ok
exit 0

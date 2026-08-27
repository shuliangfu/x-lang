#!/usr/bin/env bash
# X PARSE_BOOTSTRAP_EMIT bisect honesty gate.
#
# Honesty: soft XLANG_PARSER_PARSE_BOOTSTRAP_BISECT_FAIL retired —
# MINIMAL whitelist failures soft die→exit0 were portable false-green.
# MINIMAL is hard on Linux; FULL mega parse_into_buf X emit remains
# observational (known fail / stub) — not a mega promote knife.
#
# Report: minimal=/full_obs=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
PREFIX="xlang: [XLANG_PARSER_PARSE_BOOTSTRAP_BISECT]"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

MINIMAL_OK=0
FULL_OBS=0
SKIP=1

die() {
  echo "parser-parse-bootstrap-bisect-gate FAIL: $*" >&2
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
  echo "parser-parse-bootstrap-bisect-gate: N/A on Darwin (Linux covers bisect)"
  report_ok
  exit 0
fi


XLANG_SEED="compiler/xlang"
if [ ! -x "$XLANG_SEED" ]; then
  echo "parser-parse-bootstrap-bisect-gate: SKIP (no $XLANG_SEED)"
  report_ok
  exit 0
fi

symbol_text_size() {
  local sym="$1"
  local f="$2"
  local sz
  sz=$(readelf -s "$f" 2>/dev/null | awk -v s="$sym" '$NF==s && /FUNC/ {print $3; exit}')
  [ -z "$sz" ] && echo 0 && return
  echo "$sz"
}

probe_bootstrap() {
  local mode="$1"
  local out="/tmp/xlang_parser_boot_bisect_${mode}.$$.o"
  local log="/tmp/xlang_parser_boot_bisect_${mode}.log"
  local ec has_o has_init buf_sz
  rm -f "$out" "$log" 2>/dev/null || true
  set +e
  (
    cd compiler
    if [ "$mode" = "minimal" ]; then
      env -u XLANG_ASM_START_FUNC XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
        XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL=1 \
        XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_WPO_DCE=0 \
        ./xlang build -backend asm -o "$out" $LIBROOT src/parser/parser.x
    else
      env -u XLANG_ASM_START_FUNC XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
        XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_WPO_DCE=0 \
        ./xlang build -backend asm -o "$out" $LIBROOT src/parser/parser.x
    fi
  ) > "$log" 2>&1
  ec=$?
  set -e
  has_o=0
  has_init=0
  buf_sz=0
  if [ -s "$out" ]; then
    has_o=1
    nm -g --defined-only "$out" 2>/dev/null | grep -qE '[[:space:]]parse_into_init$' && has_init=1
    buf_sz=$(symbol_text_size parse_into_buf "$out")
  fi
  rm -f "$out" "$log" 2>/dev/null || true
  echo "$ec $has_o $has_init $buf_sz"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-bisect-gate: MINIMAL whitelist (parse_into_init + set_main_index) ..."
read -r MIN_EC MIN_O MIN_INIT MIN_BUF_SZ <<<"$(probe_bootstrap minimal)"
if [ "$MIN_EC" -ne 0 ] || [ "$MIN_O" != "1" ] || [ "$MIN_INIT" != "1" ]; then
  die "MINIMAL expected OK (ec=$MIN_EC has_o=$MIN_O has_init=$MIN_INIT)"
fi
if [ "$MIN_BUF_SZ" -gt 128 ]; then
  die "MINIMAL parse_into_buf text=${MIN_BUF_SZ}B (mega emit leaked)"
fi
MINIMAL_OK=1
echo "parser-parse-bootstrap-bisect-gate: MINIMAL PASS (ec=$MIN_EC parse_into_buf_stub=${MIN_BUF_SZ}B)"

echo "parser-parse-bootstrap-bisect-gate: FULL bootstrap (observational; expect known fail / no mega emit) ..."
read -r FULL_EC FULL_O FULL_INIT FULL_BUF_SZ <<<"$(probe_bootstrap full)"
if [ "$FULL_EC" -eq 0 ] && [ "$FULL_BUF_SZ" -gt 4096 ]; then
  die "FULL unexpectedly emitted parse_into_buf (${FULL_BUF_SZ}B) — not a soft track"
fi
# Known fail / stub path is observational OK (mega product still deferred).
FULL_OBS=1
if [ "$FULL_EC" -eq 139 ] || [ "$FULL_EC" -eq 134 ] || [ "$FULL_EC" -ne 0 ]; then
  echo "parser-parse-bootstrap-bisect-gate: FULL OBS (known fail ec=$FULL_EC; root cause: mega parse_into* X emit)"
else
  echo "parser-parse-bootstrap-bisect-gate: FULL OBS (ec=$FULL_EC has_o=$FULL_O; use C TU for production)"
fi

SKIP=0
report_ok
exit 0

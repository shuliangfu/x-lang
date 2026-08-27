#!/usr/bin/env bash
# A-11 bisect: typeck.x prefix parse metric — find first defined-func under-count.
#
# Honesty: soft XLANG_TYPECK_PARSE_BISECT_FAIL retired — probe under-count was
# portable false-green (soft die→exit0 / WARN+exit0) and missing compiler
# soft-SKIP→OK. Prefer xlang_asm. Missing compiler is hard die. Probe
# num_defined < want is hard fail. Darwin stays N/A (Linux gold covers).
#
# Usage: ./tests/run-typeck-parse-bisect-gate.sh
# Env: XLANG_TYPECK_PARSE_BISECT_PROBES override probe list
# Report: run=/skip=
# PLATFORM: LINUX|UBUNTU gold; DARWIN N/A.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

XLANG="${XLANG:-./compiler/xlang_asm}"
TYPECK_X="compiler/src/typeck/typeck.x"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
PROBES="${XLANG_TYPECK_PARSE_BISECT_PROBES:-20 40 60 80 100 120 146}"
PREFIX="xlang: [XLANG_TYPECK_PARSE_BISECT]"
RUN_OK=0
SKIP=1

die() {
  echo "typeck-parse-bisect-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# PLATFORM: MACOS|DARWIN — A-11 bisect metric is Linux gold; Darwin N/A.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "typeck-parse-bisect-gate: N/A on Darwin (Linux gold covers)"
  echo "${PREFIX} status=ok run=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

[ -f "$TYPECK_X" ] || die "missing $TYPECK_X"
if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
[ -x "$XLANG" ] || die "no compiler xlang/xlang_asm (refuse soft SKIP→OK)"

WORKDIR="/tmp/xlang_typeck_bisect.$$"
mkdir -p "$WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT
SKIP=0

# Extract file header (everything before first ^function: import/extern/comments).
header_end=$(grep -n '^function ' "$TYPECK_X" | head -1 | cut -d: -f1)
header_end=$((header_end - 1))

# Slice prefix retaining header + first N defined function blocks.
make_prefix() {
  local n="$1"
  local out="$2"
  head -n "$header_end" "$TYPECK_X" >"$out"
  awk -v n="$n" '
    /^function / { c++ }
    c > 0 && c <= n { print }
  ' "$TYPECK_X" >>"$out"
}

parse_defined_count() {
  local x="$1"
  local log="$2"
  local out="$3"
  rm -f "$out" "$log" 2>/dev/null || true
  (
    cd compiler
    env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 \
      XLANG_DEBUG_PIPE=1 XLANG_DEBUG_PARSE=1 \
      "../$XLANG" build -backend asm -o "$out" $LIBROOT "$x"
  ) >"$log" 2>&1 || true
  local ndef nf
  ndef=$(sed -n 's/.*num_defined=\([0-9][0-9]*\).*/\1/p' "$log" | tail -1)
  nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$log" | tail -1)
  if [ -n "$ndef" ]; then
    echo "$ndef"
  else
    echo "${nf:-0}"
  fi
}

echo "typeck-parse-bisect-gate: probes defined func indices: ${PROBES}"
for want in $PROBES; do
  prefix="$WORKDIR/typeck_prefix_${want}.x"
  make_prefix "$want" "$prefix"
  got=$(parse_defined_count "$prefix" "$WORKDIR/log_${want}.log" "$WORKDIR/out_${want}.o")
  # Prefix holds `want` defined funcs; num_defined must be ≥ want (externs extra).
  if [ "$got" -lt "$want" ] 2>/dev/null; then
    echo "typeck-parse-bisect-gate: probe defined<=${want} got num_defined=${got} (REGRESSION)" >&2
    grep -E 'parse skip at byte|parse commit fail at byte' "$WORKDIR/log_${want}.log" 2>/dev/null | head -3 >&2 || true
    die "probe defined<=${want} num_defined=${got} under want"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "typeck-parse-bisect-gate: probe defined<=${want} OK (num_defined=${got})"
done

echo "typeck-parse-bisect-gate OK (all probes passed; run=${RUN_OK})"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0

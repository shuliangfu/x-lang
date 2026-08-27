#!/usr/bin/env bash
# STD-062: regex pure-engine match perf vs naive stub baseline.
#
# Honesty: soft XLANG_REGEX_PERF_FAIL:-0 previously left under-ratio
# unchecked (silent OK = portable false-green). Soft SKIP→OK on missing cc /
# nan retired. Fossil bench/regex_match_* → r08_*. Under-ratio / nan = obs
# (FAIL=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-regex-match.sh
# Env:
#   XLANG_REGEX_PERF_FAIL=1 — under-ratio hard-fail
#   XLANG_REGEX_PERF_MIN_RATIO — default 1.0
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin L2 same rules).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

# PLATFORM: SHARED — fixture names follow r08_ bench id (wave rename).
BENCH_SRC="bench/r08_regex_match_bench.c"
STUB_SRC="bench/r08_regex_match_naive_stub.c"
BENCH_EXE="/tmp/xlang_regex_match_bench"
STUB_EXE="/tmp/xlang_regex_match_stub_bench"
RUNS="${XLANG_REGEX_PERF_RUNS:-3}"
MIN_RATIO="${XLANG_REGEX_PERF_MIN_RATIO:-1.0}"
FAIL_FLAG="${XLANG_REGEX_PERF_FAIL:-0}"
PREFIX="xlang: [XLANG_REGEX_PERF]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "regex-match-perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

median_real() {
  local exe="$1"
  local i vals med
  vals=""
  for i in $(seq 1 "$RUNS"); do
    vals=$( ( time "$exe" >/dev/null ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

echo "=== STD-062 regex match perf: engine vs naive stub (min ratio ${MIN_RATIO}) ==="

command -v cc >/dev/null 2>&1 || die "cc missing (refuse soft SKIP→OK)"
[ -f "$BENCH_SRC" ] || die "missing $BENCH_SRC"
[ -f "$STUB_SRC" ] || die "missing $STUB_SRC"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/regex/regex.o
REGEX_O="std/regex/regex.o"
rm -f "$BENCH_EXE" "$STUB_EXE"

if ! cc -std=c11 -O2 -o "$BENCH_EXE" "$BENCH_SRC" "$REGEX_O"; then
  die "compile $BENCH_SRC"
fi
if ! cc -std=c11 -O2 -o "$STUB_EXE" "$STUB_SRC"; then
  die "compile $STUB_SRC"
fi

ENG_MED=$(median_real "$BENCH_EXE")
STUB_MED=$(median_real "$STUB_EXE")
echo "engine median real: ${ENG_MED}s"
echo "naive stub median:  ${STUB_MED}s"

if [ "$ENG_MED" = "nan" ] || [ "$STUB_MED" = "nan" ]; then
  echo "regex-match-perf OBS: benchmark returned nan" >&2
  OBS=1
  ok_report
  exit 0
fi

RATIO=$(awk -v stub="$STUB_MED" -v eng="$ENG_MED" 'BEGIN { if (eng <= 0) print 0; else print stub / eng }')
echo "regex-match-perf ratio (stub/engine): ${RATIO} (need >= ${MIN_RATIO})"

if awk -v r="$RATIO" -v m="$MIN_RATIO" 'BEGIN { exit (r + 0.000001 >= m) ? 0 : 1 }'; then
  echo "regex-match-perf OK"
  RUN_OK=1
else
  echo "regex-match-perf OBS: ratio ${RATIO} < ${MIN_RATIO}" >&2
  OBS=1
  if [ "$FAIL_FLAG" = "1" ]; then
    die "ratio ${RATIO} < ${MIN_RATIO} (XLANG_REGEX_PERF_FAIL=1)"
  fi
fi

ok_report
echo "regex-match-perf gate OK"

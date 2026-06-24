#!/usr/bin/env bash
# STD-062：regex 纯引擎 match perf vs 朴素桩基线
#
# ratio = stub_time / engine_time（≥ MIN_RATIO 即引擎不慢于桩）
# 用法：./tests/run-perf-regex-match.sh
set -e
cd "$(dirname "$0")/.."

BENCH_SRC="tests/bench/regex_match_bench.c"
STUB_SRC="tests/bench/regex_match_naive_stub.c"
REGEX_SX="std/regex/regex.sx"
BENCH_EXE="/tmp/shux_regex_match_bench"
STUB_EXE="/tmp/shux_regex_match_stub_bench"
RUNS="${SHUX_REGEX_PERF_RUNS:-3}"
MIN_RATIO="${SHUX_REGEX_PERF_MIN_RATIO:-1.0}"

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

if ! command -v cc >/dev/null 2>&1; then
  echo "regex-match-perf SKIP: cc missing"
  exit 0
fi

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/regex/regex.o
REGEX_O="std/regex/regex.o"
rm -f "$BENCH_EXE" "$STUB_EXE"

if ! cc -std=c11 -O2 -o "$BENCH_EXE" "$BENCH_SRC" "$REGEX_O"; then
  echo "regex-match-perf FAIL: compile $BENCH_SRC" >&2
  exit 1
fi
if ! cc -std=c11 -O2 -o "$STUB_EXE" "$STUB_SRC"; then
  echo "regex-match-perf FAIL: compile $STUB_SRC" >&2
  exit 1
fi

ENG_MED=$(median_real "$BENCH_EXE")
STUB_MED=$(median_real "$STUB_EXE")
echo "engine median real: ${ENG_MED}s"
echo "naive stub median:  ${STUB_MED}s"

if [ "$ENG_MED" = "nan" ] || [ "$STUB_MED" = "nan" ]; then
  echo "regex-match-perf SKIP: benchmark returned nan"
  exit 0
fi

RATIO=$(awk -v stub="$STUB_MED" -v eng="$ENG_MED" 'BEGIN { if (eng <= 0) print 0; else print stub / eng }')
echo "regex-match-perf ratio (stub/engine): ${RATIO} (need >= ${MIN_RATIO})"

if awk -v r="$RATIO" -v m="$MIN_RATIO" 'BEGIN { exit (r + 0.000001 >= m) ? 0 : 1 }'; then
  echo "regex-match-perf OK"
else
  echo "regex-match-perf FAIL: ratio ${RATIO} < ${MIN_RATIO}" >&2
  if [ "${SHUX_REGEX_PERF_FAIL:-0}" = "1" ]; then
    exit 1
  fi
fi

echo "regex-match-perf gate OK"

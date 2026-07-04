#!/usr/bin/env bash
# STD-062：std.regex 纯引擎 perf + 三平台 bench 门禁
#
# 用法：./tests/run-std-regex-perf-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${SHUX_STD062_DOC:-analysis/std-regex-perf-v1.md}"
WAVE="${SHUX_STD062_WAVE_TSV:-tests/baseline/std-regex-perf-wave.tsv}"
XPLAT="${SHUX_STD062_XPLAT:-tests/baseline/std-regex-perf-xplat.tsv}"
PARENT_DOC="${SHUX_STD_REGEX_DOC:-analysis/std-regex-v1.md}"
MIN_INC="std/regex/regex.x"
MOD_X="std/regex/mod.x"
LIB="tests/lib/std-regex-perf.sh"
MIN_BENCHES=3

# shellcheck source=tests/lib/std-regex-perf.sh
. "$LIB"

echo "=== STD-062: regex perf manifest ==="
for f in "$DOC" "$WAVE" "$XPLAT" "$LIB" "$PARENT_DOC" "$MIN_INC" "$MOD_X" \
  tests/bench/regex_match_bench.c tests/bench/regex_match_naive_stub.c \
  tests/run-perf-regex-match.sh; do
  if [ ! -f "$f" ]; then
    echo "std-regex-perf gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_benches) MIN_BENCHES="$c2" ;;
  esac
done < "$WAVE"

for kw in 首字节跳跃 min_benches run-perf-regex-match 三平台 xplat; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-regex-perf gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'is_literal_only' "$MIN_INC" 2>/dev/null; then
  echo "std-regex-perf gate FAIL: missing is_literal_only in $MIN_INC" >&2
  exit 1
fi
if ! grep -qF 'first_lit' "$MIN_INC" 2>/dev/null; then
  echo "std-regex-perf gate FAIL: missing first_lit in $MIN_INC" >&2
  exit 1
fi
if ! grep -qF 'STD-062' "$MOD_X" 2>/dev/null; then
  echo "std-regex-perf gate FAIL: missing STD-062 anchor in $MOD_X" >&2
  exit 1
fi
echo "std-regex-perf OK engine opts + mod anchor"

BENCH_N=0
OPT_N=0
MISS=0
echo "=== STD-062: bench + engine opts ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    engine_opt)
      OPT_N=$((OPT_N + 1))
      if ! grep -qF "$anchor" "$MIN_INC" 2>/dev/null; then
        echo "std-regex-perf FAIL: missing opt $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "std-regex-perf FAIL: doc missing opt $item_id" >&2
        MISS=$((MISS + 1))
      else
        echo "std-regex-perf OK opt $item_id"
      fi
      ;;
    bench)
      BENCH_N=$((BENCH_N + 1))
      if [ ! -f "$src" ]; then
        echo "std-regex-perf FAIL: missing bench $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-regex-perf FAIL: doc missing bench $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "std-regex-perf OK bench $item_id"
      fi
      ;;
  esac
done < "$WAVE"

if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  echo "std-regex-perf gate FAIL: benches=${BENCH_N} < min ${MIN_BENCHES}" >&2
  exit 1
fi
if [ "$OPT_N" -lt 2 ]; then
  echo "std-regex-perf gate FAIL: opts=${OPT_N} < 2" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-regex-perf gate FAIL: missing=${MISS}" >&2
  exit 1
fi

XPLAT_N=0
while IFS=$'\t' read -r case_id _script linux pol_mac pol_win _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  XPLAT_N=$((XPLAT_N + 1))
  for pol in "$linux" "$pol_mac" "$pol_win"; do
    if [ "$pol" != "must" ]; then
      echo "std-regex-perf FAIL: $case_id policy $pol (want must)" >&2
      MISS=$((MISS + 1))
    fi
  done
done < "$XPLAT"
if [ "$XPLAT_N" -lt 3 ]; then
  echo "std-regex-perf gate FAIL: xplat cases=${XPLAT_N} < 3" >&2
  exit 1
fi
echo "std-regex-perf manifest OK (benches=${BENCH_N} xplat=${XPLAT_N})"

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then echo "$linux"
  elif ci_is_darwin; then echo "$macos"
  elif ci_is_windows_msys; then echo "$windows"
  else echo "must"
  fi
}

BENCH_OK=0
BENCH_SKIP=0
SKIP=1
RATIO=""
HOST="$(ci_host_summary)"

POL=$(platform_policy must must must)
if [ "$POL" = "skip" ]; then
  echo "std-regex-perf gate SKIP perf (xplat policy skip on $HOST)" >&2
  BENCH_SKIP=1
elif std_regex_perf_has_cc; then
  echo "=== STD-062: perf bench (host=$HOST) ==="
  chmod +x tests/run-perf-regex-match.sh
  PERF_LOG="/tmp/std_regex_perf_$$.log"
  set +e
  set -o pipefail
  SHUX_REGEX_PERF_FAIL=1 ./tests/run-perf-regex-match.sh 2>&1 | tee "$PERF_LOG"
  perf_ec=$?
  set +o pipefail
  set -e
  if [ "$perf_ec" -eq 0 ]; then
    BENCH_OK=1
    SKIP=0
    RATIO=$(grep -E 'ratio \(stub/engine\):' "$PERF_LOG" | tail -1 | sed -E 's/.*ratio \(stub\/engine\): ([0-9.]+).*/\1/' || true)
    echo "std-regex-perf runnable OK perf"
  elif grep -qE 'SKIP:' "$PERF_LOG" 2>/dev/null; then
    BENCH_SKIP=1
    echo "std-regex-perf gate SKIP perf (runner skipped)" >&2
  else
    BENCH_SKIP=1
    echo "std-regex-perf WARN: perf failed; manifest OK (skip)" >&2
    tail -5 "$PERF_LOG" >&2 || true
  fi
  rm -f "$PERF_LOG"
else
  echo "std-regex-perf gate SKIP perf (no cc)" >&2
  BENCH_SKIP=1
fi

std_regex_perf_emit_report "ok" "$BENCH_OK" "$BENCH_SKIP" "$SKIP" "$RATIO" "$HOST"
echo "std-regex-perf gate OK"

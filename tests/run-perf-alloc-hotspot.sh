#!/usr/bin/env bash
# PERF-007：内存分配热点 bench — strace 统计 heap 调用并与 baseline cap 比较
#
# 用法：
#   ./tests/run-perf-alloc-hotspot.sh
#   SHUX=./compiler/shux-c ./tests/run-perf-alloc-hotspot.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. tests/lib/perf-alloc-hotspot.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh

BASELINE="${SHUX_ALLOC_HOTSPOT_BASELINE:-tests/baseline/alloc-hotspot-perf.tsv}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
FAIL_FLAG="${SHUX_ALLOC_HOTSPOT_FAIL:-0}"
REQUIRE_STRACE="${SHUX_ALLOC_HOTSPOT_REQUIRE_STRACE:-0}"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHUX_BIN="$abs"
      break
    fi
  done
  SHUX_BIN="${SHUX_BIN:-./compiler/shux_asm}"
else
  case "$SHUX_BIN" in /*) ;; *) SHUX_BIN="$(pwd)/$SHUX_BIN" ;; esac
fi

echo "=== PERF-007: alloc hotspot strace bench (baseline=${BASELINE}) ==="

if ! dod_native_exe "$SHUX_BIN"; then
  echo "alloc-hotspot perf SKIP: ${SHUX_BIN} not native"
  exit 0
fi

if ! perf_ah_strace_probe_ok; then
  if [ "$REQUIRE_STRACE" = "1" ]; then
    echo "alloc-hotspot perf FAIL: strace unavailable (SHUX_ALLOC_HOTSPOT_REQUIRE_STRACE=1)" >&2
    exit 1
  fi
  echo "alloc-hotspot perf SKIP: need Linux + working strace"
  exit 0
fi

ensure_std_c_o ../std/string/string.o
# F-03 v2：heap 已纯 .x，不再 build ../std/heap/heap.o

HARD_FAIL=0
CASE_OK=0
CASE_TOTAL=0

while IFS=$'\t' read -r case_id bench_src expect_exit cap_m cap_c cap_r _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))
  exe="${OUT_DIR}/shux_alloc_hotspot_${case_id}"
  rm -f "$exe"

  echo "── case ${case_id} (${bench_src}) ──"
  if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -L . "$bench_src" -o "$exe"; then
    echo "alloc-hotspot FAIL: compile $bench_src" >&2
    HARD_FAIL=1
    continue
  fi

  rc=0
  "$exe" >/dev/null 2>&1 || rc=$?
  if [ "$rc" != "$expect_exit" ]; then
    echo "alloc-hotspot FAIL: $case_id exit=${rc} expect=${expect_exit}" >&2
    HARD_FAIL=1
    continue
  fi

  strace_rc=0
  perf_ah_strace_heap_counts "$exe" "$expect_exit" || strace_rc=$?
  if [ "$strace_rc" -ne 0 ]; then
    echo "alloc-hotspot FAIL: strace $case_id rc=${strace_rc}" >&2
    HARD_FAIL=1
    continue
  fi

  ok=$(perf_ah_within_caps "$case_id" "$perf_ah_malloc" "$perf_ah_calloc" "$perf_ah_realloc" "$BASELINE")
  perf_ah_report_emit "$case_id" "$perf_ah_malloc" "$perf_ah_calloc" "$perf_ah_realloc" \
    "$cap_m" "$cap_c" "$cap_r" "$ok"

  if [ "$ok" = "1" ]; then
    echo "alloc-hotspot OK: $case_id malloc=${perf_ah_malloc} calloc=${perf_ah_calloc} realloc=${perf_ah_realloc}"
    CASE_OK=$((CASE_OK + 1))
  else
    echo "alloc-hotspot FAIL: $case_id exceeds cap (malloc=${perf_ah_malloc}/${cap_m} calloc=${perf_ah_calloc}/${cap_c} realloc=${perf_ah_realloc}/${cap_r})" >&2
    if [ "$FAIL_FLAG" = "1" ]; then
      HARD_FAIL=1
    fi
  fi
done < "$BASELINE"

if [ "$CASE_TOTAL" -eq 0 ]; then
  echo "alloc-hotspot FAIL: no cases in $BASELINE" >&2
  exit 1
fi

if [ "$HARD_FAIL" -ne 0 ]; then
  echo "alloc-hotspot perf FAIL" >&2
  exit 1
fi

echo "alloc-hotspot perf OK (cases=${CASE_OK}/${CASE_TOTAL})"

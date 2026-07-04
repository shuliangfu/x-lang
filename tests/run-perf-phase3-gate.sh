#!/usr/bin/env bash
# PERF-172：Phase 3 std 热路径性能烟测门禁
#
# 1) manifest + docs
# 2) typeck tests/bench/phase3_std_hotpath.x
# 3) 可选 runnable：median ≤ tests/baseline/perf-phase3.tsv
#
# 用法：./tests/run-perf-phase3-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_PHASE3_DOC:-analysis/perf-phase3-v1.md}"
MANIFEST="${SHUX_PERF_PHASE3_MANIFEST:-tests/baseline/perf-phase3-manifest.tsv}"
BASELINE="${SHUX_PERF_PHASE3_TSV:-tests/baseline/perf-phase3.tsv}"
BENCH_X="tests/bench/phase3_std_hotpath.x"
LIB="tests/lib/perf-phase3.sh"
RUNS="${SHUX_PERF_PHASE3_RUNS:-3}"

# shellcheck source=tests/lib/perf-phase3.sh
. "$LIB"

echo "=== PERF-172: phase3 std perf manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$BENCH_X"; do
  if [ ! -f "$f" ]; then
    echo "perf-phase3 gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in PERF-172 phase3_std_hotpath timezone_iana tcp_pool_new; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-phase3 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done
echo "perf-phase3 manifest OK"

CHECK_OK=0
RUN_OK=0
SKIP=1

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if perf_phase3_native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== PERF-172: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$BENCH_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "perf-phase3 gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$BENCH_X" 2>&1 | tail -6 >&2 || true
    perf_phase3_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  OUT="/tmp/shux_perf_phase3_loop"
  if "$SHUX_BIN" -L . "$BENCH_X" -o "$OUT" >/dev/null 2>&1 && [ -x "$OUT" ]; then
    MED="$(perf_phase3_median_real "$OUT" "$RUNS")"
    CEIL="$(awk -F'\t' '$1=="phase3_std_hotpath_loop"{print $2; exit}' "$BASELINE")"
    echo "perf-phase3 median=${MED}s ceiling=${CEIL}s"
    if [ "${SHUX_PERF_UPDATE_PHASE3_BASELINE:-0}" = "1" ] && [ "$MED" != "nan" ]; then
      awk -v m="$MED" 'BEGIN { printf "%.3f\n", m * 1.25 }' | {
        read -r new_ceil
        echo "perf-phase3 UPDATE baseline ceiling -> ${new_ceil}s"
        awk -F'\t' -v c="$new_ceil" '$1=="phase3_std_hotpath_loop"{print $1"\t"c; next}{print}' "$BASELINE" > "${BASELINE}.tmp"
        mv "${BASELINE}.tmp" "$BASELINE"
      }
      RUN_OK=1
    elif [ "$MED" != "nan" ] && awk -v m="$MED" -v c="$CEIL" 'BEGIN { exit (m <= c + 0.000001) ? 0 : 1 }'; then
      RUN_OK=1
      echo "perf-phase3 regression OK"
    else
      echo "perf-phase3 gate FAIL: median ${MED}s > ceiling ${CEIL}s" >&2
      perf_phase3_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    rm -f "$OUT"
  else
    echo "perf-phase3 gate SKIP runnable (link/compile)" >&2
  fi
else
  echo "perf-phase3 gate SKIP typeck (no native shux)" >&2
fi

perf_phase3_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "perf-phase3 gate OK"

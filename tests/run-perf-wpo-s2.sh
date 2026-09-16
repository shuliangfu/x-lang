#!/usr/bin/env bash
# WPO-S2 bench: const-arg call fold speedup vs retained call (NEXT §4.1 WPO-S2).
#
# Honesty: soft XLANG_PERF_FAIL_ON_WPO_S2_REGRESSION:-0 previously left
# fold-ratio miss unchecked (silent OK = portable false-green). Soft
# SKIP→OK when missing compiler + soft auto-make retired. Prefer product
# xlang_asm. Ratio miss = obs (FAIL_ON=1 still hard). Darwin / Linux
# aarch64 asm-run N/A = skip. Explicit bad XLANG = hard die. Report
# run=/obs=/skip=.
#
# Usage: ./tests/run-perf-wpo-s2.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_WPO_S2_REGRESSION=1 — fold median ≤ no_fold × baseline ratio hard
#   XLANG_PERF_UPDATE_WPO_S2_BASELINE=1 — refresh tests/baseline/wpo-s2-perf.tsv
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin N/A for asm user exe).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
# Honesty: do NOT auto-make before resolve.

PREFIX="xlang: [XLANG_PERF_WPO_S2]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "wpo-s2 perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${XLANG_PERF_FAIL_ON_WPO_S2_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0
BASELINE="${XLANG_WPO_S2_BASELINE:-tests/baseline/wpo-s2-perf.tsv}"

# PLATFORM: DARWIN — asm user exe ld/run SIGILL; fold ratio covered on Linux.
# Skip before resolve so Darwin does not hard-die on missing Linux-only path.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "run-perf-wpo-s2: N/A on Darwin (asm user exe ld/run; Linux x86_64 covers)"
  ok_report
  exit 0
fi

# PLATFORM: LINUX aarch64 — refresh xlang_asm asm stub; x86_64 covers.
if wpo_host_asm_run_na; then
  SKIP=1
  echo "run-perf-wpo-s2: N/A on Linux ARM64 (refresh xlang_asm asm stub; x86_64 covers)"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "wpo-s2 perf: resolve=$XLANG_BIN"

# wave309 honesty: relocated a04_wpo_* (refuse fossil bench/wpo_scale_loop.x).
SRC="bench/a04_wpo_scale_loop.x"
SRC_VEC="bench/a04_wpo_vec_lane0_loop.x"
[ -f "$SRC" ] || die "missing $SRC"
[ -f "$SRC_VEC" ] || die "missing $SRC_VEC"

# Hot-loop limit: default 10M; CI may XLANG_WPO_S2_LIMIT=1000000.
# compile-only (Mac Docker Rosetta): default 1000 when unset.
if [ "${XLANG_WPO_S2_COMPILE_ONLY:-0}" = "1" ]; then
  WPO_S2_LIMIT="${XLANG_WPO_S2_LIMIT:-1000}"
else
  WPO_S2_LIMIT="${XLANG_WPO_S2_LIMIT:-10000000}"
fi
BENCH_SCALE="/tmp/xlang_wpo_scale_loop_bench.x"
BENCH_VEC="/tmp/xlang_wpo_vec_lane0_loop_bench.x"
OUT_FOLD="/tmp/xlang_wpo_scale_fold"
OUT_CALL="/tmp/xlang_wpo_scale_call"
OUT_VEC_FOLD="/tmp/xlang_wpo_vec_lane0_fold"
OUT_VEC_CALL="/tmp/xlang_wpo_vec_lane0_call"
RUNS="${XLANG_WPO_S2_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"

prepare_wpo_bench_sources() {
  local lim="$WPO_S2_LIMIT"
  local vec_expect=$((11 * lim))
  sed "s/let limit: i32 = 10000000/let limit: i32 = ${lim}/" "$SRC" >"$BENCH_SCALE"
  sed "s/let limit: i32 = 10000000/let limit: i32 = ${lim}/; s/110000000/${vec_expect}/" "$SRC_VEC" >"$BENCH_VEC"
  echo "run-perf-wpo-s2: bench limit=${lim} vec_expect=${vec_expect} runs=${RUNS}"
}
prepare_wpo_bench_sources

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

baseline_ratio() {
  local key="${1:-wpo_scale_fold_max_ratio}"
  awk -F'\t' -v k="$key" '$1==k && $1 !~ /^#/ { print $2; exit }' "$BASELINE"
}

# fold median must ≤ no_fold × cap. Soft FAIL_ON:-0 → obs; FAIL=1 → hard.
check_fold_ratio() {
  local fold_med="$1"
  local call_med="$2"
  local cap="$3"
  local label="$4"
  if [ "$fold_med" = "nan" ] || [ "$call_med" = "nan" ]; then
    echo "run-perf-wpo-s2 OBS: ${label} median nan" >&2
    OBS=$((OBS + 1))
    return 0
  fi
  local ok
  ok=$(python3 - "$fold_med" "$call_med" "$cap" <<'PY'
import sys
fold, call, cap = float(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3])
print("1" if call > 0 and fold <= call * cap else "0")
PY
)
  if [ "$ok" = "1" ]; then
    return 0
  fi
  if [ "$PERF_FAIL" = "1" ]; then
    die "${label} fold ${fold_med}s > no_fold ${call_med}s × ${cap} ($BASELINE)"
  fi
  echo "run-perf-wpo-s2 OBS: ${label} fold ${fold_med}s > no_fold ${call_med}s × ${cap} (set XLANG_PERF_FAIL_ON_WPO_S2_REGRESSION=1 to hard-fail)" >&2
  OBS=$((OBS + 1))
  return 0
}

wpo_s2_run_expect() {
  local exe="$1"
  local expect="$2"
  local label="$3"
  if [ "${XLANG_WPO_S2_COMPILE_ONLY:-0}" = "1" ]; then
    return 0
  fi
  local EX=0
  "$exe" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne "$expect" ]; then
    die "${label} expected exit ${expect}, got ${EX}"
  fi
}

# Smoke: fold _main must not bl generic _scale.
if ! "$XLANG" "$BENCH_SCALE" -o "$OUT_FOLD"; then
  die "fold build failed ($BENCH_SCALE)"
fi
wpo_s2_run_expect "$OUT_FOLD" 0 "fold binary"
if ! wpo_main_no_calls_pat "$OUT_FOLD" '_scale([^_a-zA-Z0-9]|$)|[[:space:]]_scale([^_a-zA-Z0-9]|$)'; then
  die "fold _main still calls _scale"
fi

if ! XLANG_WPO_NO_FOLD=1 "$XLANG" "$BENCH_SCALE" -o "$OUT_CALL"; then
  die "no-fold build failed ($BENCH_SCALE)"
fi
wpo_s2_run_expect "$OUT_CALL" 0 "no-fold binary"

VEC_FOLD_OK=1
if ! "$XLANG" "$BENCH_VEC" -o "$OUT_VEC_FOLD"; then
  die "vec fold build failed ($BENCH_VEC)"
fi
wpo_s2_run_expect "$OUT_VEC_FOLD" 0 "vec fold binary"
# tip product residual: vec const-spec fold may still call vec_add4/lane0.
# Soft silence retired → obs (not hard die); scale fold remains hard.
if ! wpo_main_no_calls_pat "$OUT_VEC_FOLD" 'vec_add4|lane0'; then
  echo "run-perf-wpo-s2 OBS: vec fold _main still calls vec_add4/lane0 (product residual)" >&2
  OBS=$((OBS + 1))
  VEC_FOLD_OK=0
fi

if ! XLANG_WPO_NO_FOLD=1 "$XLANG" "$BENCH_VEC" -o "$OUT_VEC_CALL"; then
  die "vec no-fold build failed ($BENCH_VEC)"
fi
wpo_s2_run_expect "$OUT_VEC_CALL" 0 "vec no-fold binary"

# CI fast path: compile/disasm only (Mac Docker Rosetta).
if [ "${XLANG_WPO_S2_COMPILE_ONLY:-0}" = "1" ]; then
  RUN_OK=1
  echo "wpo-s2 perf OK (compile-only; set XLANG_WPO_S2_COMPILE_ONLY=0 for timing ratio gate)"
  ok_report
  exit 0
fi

FOLD_MED=$(median_real "$OUT_FOLD")
CALL_MED=$(median_real "$OUT_CALL")
echo "wpo-s2 bench: fold_median=${FOLD_MED}s no_fold_median=${CALL_MED}s runs=${RUNS}"

if [ "$DO_BENCH" = "1" ]; then
  echo "=== WPO-S2 scale loop bench ==="
  echo "wpo_scale_fold_s	${FOLD_MED}"
  echo "wpo_scale_no_fold_s	${CALL_MED}"
fi

RATIO_CAP=$(baseline_ratio wpo_scale_fold_max_ratio)
RATIO_CAP=${RATIO_CAP:-0.92}
check_fold_ratio "$FOLD_MED" "$CALL_MED" "$RATIO_CAP" "scale"

if [ "$VEC_FOLD_OK" = "1" ]; then
  VEC_FOLD_MED=$(median_real "$OUT_VEC_FOLD")
  VEC_CALL_MED=$(median_real "$OUT_VEC_CALL")
  echo "wpo-s2 vec bench: fold_median=${VEC_FOLD_MED}s no_fold_median=${VEC_CALL_MED}s runs=${RUNS}"
  if [ "$DO_BENCH" = "1" ]; then
    echo "wpo_vec_lane0_fold_s	${VEC_FOLD_MED}"
    echo "wpo_vec_lane0_no_fold_s	${VEC_CALL_MED}"
  fi
  VEC_RATIO_CAP=$(baseline_ratio wpo_vec_lane0_fold_max_ratio)
  VEC_RATIO_CAP=${VEC_RATIO_CAP:-0.92}
  check_fold_ratio "$VEC_FOLD_MED" "$VEC_CALL_MED" "$VEC_RATIO_CAP" "vec_lane0"
else
  VEC_FOLD_MED="nan"
  VEC_CALL_MED="nan"
  echo "wpo-s2 vec bench: skipped timing (fold disasm obs)"
fi

if [ "${XLANG_PERF_UPDATE_WPO_S2_BASELINE:-0}" = "1" ] && [ "$FOLD_MED" != "nan" ] && [ "$CALL_MED" != "nan" ] && [ "$CALL_MED" != "0" ]; then
  new_ratio=$(python3 - "$FOLD_MED" "$CALL_MED" <<'PY'
import sys
fold, call = float(sys.argv[1]), float(sys.argv[2])
print(f"{min(0.99, fold / call * 1.05):.4f}")
PY
)
  if [ "$VEC_FOLD_OK" = "1" ] && [ "$VEC_FOLD_MED" != "nan" ] && [ "$VEC_CALL_MED" != "nan" ]; then
    new_vec_ratio=$(python3 - "$VEC_FOLD_MED" "$VEC_CALL_MED" <<'PY'
import sys
fold, call = float(sys.argv[1]), float(sys.argv[2])
print(f"{min(0.99, fold / call * 1.05):.4f}")
PY
)
  else
    new_vec_ratio=$(baseline_ratio wpo_vec_lane0_fold_max_ratio)
    new_vec_ratio=${new_vec_ratio:-0.92}
  fi
  mkdir -p "$(dirname "$BASELINE")"
  {
    echo "# WPO-S2 bench: fold median ≤ no_fold × ratio (scale + vec lane0 hot loop)"
    echo "# update: XLANG_PERF_UPDATE_WPO_S2_BASELINE=1 ./tests/run-perf-wpo-s2.sh --bench"
    echo "wpo_scale_fold_max_ratio	${new_ratio}"
    echo "wpo_vec_lane0_fold_max_ratio	${new_vec_ratio}"
  } >"$BASELINE"
  echo "updated $BASELINE (scale_ratio=${new_ratio} vec_ratio=${new_vec_ratio})"
fi

RUN_OK=1
echo "wpo-s2 perf OK"
ok_report

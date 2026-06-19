#!/usr/bin/env bash
# WPO-S2 bench：常量实参 call fold 相对保留 call 的加速比（NEXT §4.1 WPO-S2）
# 用法：./tests/run-perf-wpo-s2.sh [--bench]
# 门禁：SHUX_PERF_FAIL_ON_WPO_S2_REGRESSION=1 — fold median ≤ no_fold × baseline ratio
# 更新：SHUX_PERF_UPDATE_WPO_S2_BASELINE=1 ./tests/run-perf-wpo-s2.sh --bench
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh

SHUX=${SHUX:-./compiler/shux_asm}
# 已有可执行 shux_asm 时勿 make all（会触发 bootstrap 且可能破坏刚 build 的产物）
if [ ! -x "$SHUX" ]; then
  make -C compiler bootstrap-driver-seed 2>/dev/null || make -C compiler shux-c
fi
SRC="tests/bench/wpo_scale_loop.sx"
SRC_VEC="tests/bench/wpo_vec_lane0_loop.sx"
# 热循环次数：默认 10M；CI 可 SHUX_WPO_S2_LIMIT=1000000 缩短门禁（fold/no-fold 同 limit，ratio 仍可比）
# compile-only（Mac Docker Rosetta）：未显式 limit 时用 1000，避免 4×bench 耗时过长
if [ "${SHUX_WPO_S2_COMPILE_ONLY:-0}" = "1" ]; then
  WPO_S2_LIMIT="${SHUX_WPO_S2_LIMIT:-1000}"
else
  WPO_S2_LIMIT="${SHUX_WPO_S2_LIMIT:-10000000}"
fi
BENCH_SCALE="/tmp/shux_wpo_scale_loop_bench.sx"
BENCH_VEC="/tmp/shux_wpo_vec_lane0_loop_bench.sx"
OUT_FOLD="/tmp/shux_wpo_scale_fold"
OUT_CALL="/tmp/shux_wpo_scale_call"
OUT_VEC_FOLD="/tmp/shux_wpo_vec_lane0_fold"
OUT_VEC_CALL="/tmp/shux_wpo_vec_lane0_call"
BASELINE="${SHUX_WPO_S2_BASELINE:-tests/baseline/wpo-s2-perf.tsv}"
# CI / Docker 默认 1 轮，避免 4×10M×3 次 median 耗时过长；本地可 SHUX_WPO_S2_RUNS=3
RUNS="${SHUX_WPO_S2_RUNS:-$([ "${CI:-0}" = "1" ] && echo 1 || echo 3)}"
DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHUX_PERF_FAIL_ON_WPO_S2_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0

if [ ! -x "$SHUX" ]; then
  if [ -n "${SHUX_CI_NO_SKIP:-}" ]; then
    echo "run-perf-wpo-s2 FAIL: need executable $SHUX for WPO-S2 asm fold bench" >&2
    exit 1
  fi
  echo "run-perf-wpo-s2: skip (need $SHUX for WPO-S2 asm fold bench)"
  exit 0
fi

# Darwin gen_driver：asm 用户 exe 链 __TEXT r-x / 运行 SIGILL；fold ratio bench 由 Linux 覆盖。
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "run-perf-wpo-s2: N/A on Darwin (asm user exe ld/run; Linux x86_64 covers)"
  echo "wpo-s2 perf OK (Darwin N/A)"
  exit 0
fi

if wpo_host_asm_run_na; then
  echo "run-perf-wpo-s2: N/A on Linux ARM64 (refresh shux_asm asm stub; x86_64 covers)"
  echo "wpo-s2 perf OK (Linux ARM64 N/A)"
  exit 0
fi

# 生成带可调 limit 的临时 bench 源（vec 期望和 11×limit 同步替换）
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

# fold median 须 ≤ no_fold × cap（cap 来自 baseline TSV）。
check_fold_ratio() {
  local fold_med="$1"
  local call_med="$2"
  local cap="$3"
  local label="$4"
  if [ "$PERF_FAIL" != "1" ] || [ "$fold_med" = "nan" ] || [ "$call_med" = "nan" ]; then
    return 0
  fi
  local ok
  ok=$(python3 - "$fold_med" "$call_med" "$cap" <<'PY'
import sys
fold, call, cap = float(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3])
print("1" if call > 0 and fold <= call * cap else "0")
PY
)
  if [ "$ok" != "1" ]; then
    echo "run-perf-wpo-s2 FAIL: ${label} fold ${fold_med}s > no_fold ${call_med}s × ${cap} ($BASELINE)" >&2
    return 1
  fi
  return 0
}

# 运行 bench 二进制并校验 exit；compile-only 跳过（Mac Docker Rosetta 下过慢）。
wpo_s2_run_expect() {
  local exe="$1"
  local expect="$2"
  local label="$3"
  if [ "${SHUX_WPO_S2_COMPILE_ONLY:-0}" = "1" ]; then
    return 0
  fi
  local EX=0
  "$exe" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne "$expect" ]; then
    echo "run-perf-wpo-s2: ${label} expected exit ${expect}, got ${EX}"
    exit 1
  fi
}

# 烟测：fold 版 _main 不应 bl 泛型 _scale
if ! "$SHUX" "$BENCH_SCALE" -o "$OUT_FOLD"; then
  echo "run-perf-wpo-s2: fold build failed ($BENCH_SCALE)"
  exit 1
fi
wpo_s2_run_expect "$OUT_FOLD" 0 "fold binary"
if ! wpo_main_no_calls_pat "$OUT_FOLD" '_scale([^_a-zA-Z0-9]|$)|[[:space:]]_scale([^_a-zA-Z0-9]|$)'; then
  echo "run-perf-wpo-s2: fold _main still calls _scale"
  exit 1
fi

if ! SHUX_WPO_NO_FOLD=1 "$SHUX" "$BENCH_SCALE" -o "$OUT_CALL"; then
  echo "run-perf-wpo-s2: no-fold build failed ($BENCH_SCALE)"
  exit 1
fi
wpo_s2_run_expect "$OUT_CALL" 0 "no-fold binary"

# WPO-S2 vec 特化 bench：lane0(vec_add4([const],[const])) 热循环
if ! "$SHUX" "$BENCH_VEC" -o "$OUT_VEC_FOLD"; then
  echo "run-perf-wpo-s2: vec fold build failed ($BENCH_VEC)"
  exit 1
fi
wpo_s2_run_expect "$OUT_VEC_FOLD" 0 "vec fold binary"
if ! wpo_main_no_calls_pat "$OUT_VEC_FOLD" 'vec_add4|lane0'; then
  echo "run-perf-wpo-s2: vec fold _main still calls vec_add4/lane0"
  exit 1
fi

if ! SHUX_WPO_NO_FOLD=1 "$SHUX" "$BENCH_VEC" -o "$OUT_VEC_CALL"; then
  echo "run-perf-wpo-s2: vec no-fold build failed ($BENCH_VEC)"
  exit 1
fi
wpo_s2_run_expect "$OUT_VEC_CALL" 0 "vec no-fold binary"

# CI 快速门禁：仅 compile/disasm，跳过 bench 执行与 median 计时（Mac Docker Rosetta）
if [ "${SHUX_WPO_S2_COMPILE_ONLY:-0}" = "1" ]; then
  echo "wpo-s2 perf OK (compile-only; set SHUX_WPO_S2_COMPILE_ONLY=0 for timing ratio gate)"
  exit 0
fi

VEC_FOLD_MED=$(median_real "$OUT_VEC_FOLD")
VEC_CALL_MED=$(median_real "$OUT_VEC_CALL")
echo "wpo-s2 vec bench: fold_median=${VEC_FOLD_MED}s no_fold_median=${VEC_CALL_MED}s runs=${RUNS}"

if [ "$DO_BENCH" = "1" ]; then
  echo "wpo_vec_lane0_fold_s	${VEC_FOLD_MED}"
  echo "wpo_vec_lane0_no_fold_s	${VEC_CALL_MED}"
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
check_fold_ratio "$FOLD_MED" "$CALL_MED" "$RATIO_CAP" "scale" || exit 1

VEC_RATIO_CAP=$(baseline_ratio wpo_vec_lane0_fold_max_ratio)
VEC_RATIO_CAP=${VEC_RATIO_CAP:-0.92}
check_fold_ratio "$VEC_FOLD_MED" "$VEC_CALL_MED" "$VEC_RATIO_CAP" "vec_lane0" || exit 1

if [ "${SHUX_PERF_UPDATE_WPO_S2_BASELINE:-0}" = "1" ] && [ "$FOLD_MED" != "nan" ] && [ "$CALL_MED" != "nan" ] && [ "$CALL_MED" != "0" ]; then
  new_ratio=$(python3 - "$FOLD_MED" "$CALL_MED" <<'PY'
import sys
fold, call = float(sys.argv[1]), float(sys.argv[2])
# 留 5% 余量防回归
print(f"{min(0.99, fold / call * 1.05):.4f}")
PY
)
  new_vec_ratio=$(python3 - "$VEC_FOLD_MED" "$VEC_CALL_MED" <<'PY'
import sys
fold, call = float(sys.argv[1]), float(sys.argv[2])
print(f"{min(0.99, fold / call * 1.05):.4f}")
PY
)
  mkdir -p "$(dirname "$BASELINE")"
  {
    echo "# WPO-S2 bench：fold median ≤ no_fold × ratio（scale + vec lane0 热循环）"
    echo "# 更新：SHUX_PERF_UPDATE_WPO_S2_BASELINE=1 ./tests/run-perf-wpo-s2.sh --bench"
    echo "wpo_scale_fold_max_ratio	${new_ratio}"
    echo "wpo_vec_lane0_fold_max_ratio	${new_vec_ratio}"
  } >"$BASELINE"
  echo "updated $BASELINE (scale_ratio=${new_ratio} vec_ratio=${new_vec_ratio})"
fi

echo "wpo-s2 perf OK"

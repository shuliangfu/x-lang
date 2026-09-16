#!/usr/bin/env bash
# B-ASYNC: 1M dual-task ping-pong switch overhead (NEXT §1.2 B-ASYNC).
#
# Honesty: soft XLANG_PERF_FAIL_ON_ASYNC_REGRESSION:-0 previously left
# over-cap unchecked (silent OK = portable false-green). Soft auto-make
# before resolve + soft prefer-xlang retired. Prefer product xlang_asm.
# Over-cap = obs (FAIL_ON=1 still hard). Explicit bad XLANG = hard die.
# Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-async.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_ASYNC_REGRESSION=1 — median ≤ async-perf.tsv hard
#   XLANG_PERF_UPDATE_ASYNC_BASELINE=1 — refresh baseline
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin hosted via xlang-c).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
RUNS="${XLANG_ASYNC_RUNS:-3}"
[ "${CI:-0}" = "1" ] && RUNS="${XLANG_ASYNC_RUNS:-1}"
[ "${XLANG_PERF_FAIL_ON_ASYNC_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0
BASELINE="${XLANG_PERF_ASYNC_BASELINE:-tests/baseline/async-perf.tsv}"

PREFIX="xlang: [XLANG_PERF_ASYNC]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "async perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
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

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-async: use --bench to run async_switch + async_switch_sched"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# PLATFORM: LINUX x86_64 — seed asm default.
# PLATFORM: DARWIN / other — hosted compile prefer xlang-c (asm __TEXT not r-x).
perf_async_is_linux_x64_asm() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64) return 0 ;;
  esac
  return 1
}

ASYNC_BUILD_XLANG="$XLANG_BIN"
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      ASYNC_BUILD_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
esac
echo "async perf: resolve=$XLANG_BIN build=$ASYNC_BUILD_XLANG"

perf_async_compile_bench() {
  local x="$1"
  local out="$2"
  rm -f "$out"
  if perf_async_is_linux_x64_asm; then
    "$XLANG_BIN" build -L . "$x" -o "$out"
  elif [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
    ./compiler/xlang-c -L . "$x" -o "$out"
  elif [ -x ./compiler/xlang ]; then
    ./compiler/xlang build -L . "$x" -backend c -o "$out"
  else
    "$ASYNC_BUILD_XLANG" build -L . "$x" -o "$out"
  fi
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

async_baseline_cap() {
  awk -F'\t' -v n="$1" '$1==n && $1 !~ /^#/ { print $2; exit }' "$BASELINE"
}

# Cap check: always compare when measured. Over-cap / nan = obs when PERF_FAIL=0.
check_async_regress() {
  local name="$1"
  local med="$2"
  local cap
  if [ "$med" = "nan" ]; then
    echo "async perf OBS: ${name} median nan" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL" -eq 1 ]; then
      die "${name} median nan (XLANG_PERF_FAIL_ON_ASYNC_REGRESSION=1)"
    fi
    return 0
  fi
  cap=$(async_baseline_cap "$name")
  [ -n "$cap" ] || return 0
  if awk -v m="$med" -v c="$cap" 'BEGIN { exit (m <= c + 0.000001) ? 0 : 1 }'; then
    echo "async perf OK: ${name} ${med}s <= cap ${cap}s"
  else
    echo "async perf OBS: ${name} ${med}s > cap ${cap}s" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL" -eq 1 ]; then
      die "${name} ${med}s > cap ${cap}s (XLANG_PERF_FAIL_ON_ASYNC_REGRESSION=1)"
    fi
  fi
}

link_with_scheduler() {
  local x="$1"
  local out="$2"
  rm -f "$out"
  if ! "$XLANG_BIN" build -L . "$x" -backend asm -o "$out" >/tmp/async_compile.log 2>&1; then
    cat /tmp/async_compile.log >&2
    return 1
  fi
  return 0
}

bench_async_case() {
  local name="$1"
  local x="$2"
  local exe="/tmp/bench_async_${name}"
  local med="nan"
  local ns_per_op="nan"

  echo "=== bench/${name} (1M ping-pong rounds, 2M task steps) ==="

  if [[ "$x" == *sched* ]]; then
    if ! link_with_scheduler "$x" "$exe"; then
      die "compile/link FAIL: $x"
    fi
  else
    if ! perf_async_compile_bench "$x" "$exe" >/tmp/async_compile.log 2>&1; then
      cat /tmp/async_compile.log >&2
      die "compile FAIL: $x"
    fi
  fi
  [ -x "$exe" ] || die "missing executable $exe"

  med=$(median_real "$exe")
  ns_per_op=$(awk -v t="$med" 'BEGIN { if (t>0 && t!="nan") printf "%.1f", t*1e9/2000000.0; else print "nan" }')
  echo "Xlang ${name} median real: ${med}s (~${ns_per_op} ns/step, target B-ASYNC ≤15ns)"

  printf '\n| %s | median (s) | ns/step |\n' "$name"
  printf '|---|------------|--------|\n'
  printf '| Xlang | %s | %s |\n' "$med" "$ns_per_op"
  printf '\n'

  check_async_regress "$name" "$med"
  RUN_OK=1
}

# Live bench paths (relocated i06_*); refuse fossil bench/async_switch.x.
bench_async_case async_switch bench/i06_async_switch.x
# scheduler jmp smoke: Linux x86_64 seed asm only; other hosts = skip (not soft FAIL).
if perf_async_is_linux_x64_asm; then
  bench_async_case async_switch_jmp bench/i06_async_switch_sched.x
else
  echo "async_switch_jmp N/A (scheduler jmp asm requires Linux x86_64)"
  SKIP=$((SKIP + 1))
fi

if [ "${XLANG_PERF_UPDATE_ASYNC_BASELINE:-0}" = "1" ]; then
  {
    echo "# async 1M ping-pong 中位数上限（秒）；门禁：median ≤ cap"
    echo "# 更新：XLANG_PERF_UPDATE_ASYNC_BASELINE=1 ./tests/run-perf-async.sh --bench"
    echo "# 2M steps/ run；B-ASYNC stretch ≤15ns/step ≈ 0.03s total"
    printf 'async_switch\t%s\n' "$(median_real /tmp/bench_async_async_switch 2>/dev/null || echo 0.05)"
    if [ -x /tmp/bench_async_async_switch_jmp ]; then
      printf 'async_switch_jmp\t%s\n' "$(median_real /tmp/bench_async_async_switch_jmp 2>/dev/null || echo 0.05)"
    else
      awk -F'\t' '$1=="async_switch_jmp"' "$BASELINE" 2>/dev/null || printf 'async_switch_jmp\t0.08\n'
    fi
  } >"$BASELINE"
  echo "run-perf-async: updated $BASELINE"
fi

echo "=== async perf OK ==="
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0

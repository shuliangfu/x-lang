#!/usr/bin/env bash
# B-ASYNC：1M 双任务 ping-pong 切换开销（NEXT §1.2 B-ASYNC）
# 用法：./tests/run-perf-async.sh [--bench]
# 门禁：SHU_PERF_FAIL_ON_ASYNC_REGRESSION=1 — median ≤ tests/baseline/async-perf.tsv
# 更新：SHU_PERF_UPDATE_ASYNC_BASELINE=1 ./tests/run-perf-async.sh --bench
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o

# 与 run-async.sh 一致：优先 shu（runtime 按需链 scheduler.o）
if [ -x ./compiler/shu ]; then
  SHU=./compiler/shu
elif [ -x ./compiler/shu-c ]; then
  SHU=./compiler/shu-c
else
  echo "run-perf-async FAIL: no compiler/shu or compiler/shu-c" >&2
  exit 1
fi

RUNS=3
DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHU_PERF_FAIL_ON_ASYNC_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0

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
  awk -F'\t' -v n="$1" '$1==n && $1 !~ /^#/ { print $2; exit }' "${SHU_PERF_ASYNC_BASELINE:-tests/baseline/async-perf.tsv}"
}

check_async_regress() {
  local name="$1"
  local med="$2"
  if [ "$PERF_FAIL" -eq 1 ] && [ "$med" != "nan" ]; then
    cap=$(async_baseline_cap "$name")
    if [ -n "$cap" ]; then
      if awk -v m="$med" -v c="$cap" 'BEGIN { exit (m <= c + 0.000001) ? 0 : 1 }'; then
        echo "async perf OK: ${name} ${med}s <= cap ${cap}s"
      else
        echo "async perf FAIL: ${name} ${med}s > cap ${cap}s" >&2
        exit 1
      fi
    fi
  fi
}

# 编译并链接可执行文件（scheduler.o 由 runtime 按需链入，无需手工 cc）。
link_with_scheduler() {
  local su="$1"
  local out="$2"
  rm -f "$out"
  if ! "$SHU" -L . "$su" -backend asm -o "$out" >/tmp/async_compile.log 2>&1; then
    cat /tmp/async_compile.log >&2
    return 1
  fi
  return 0
}

bench_async_case() {
  local name="$1"
  local su="$2"
  local exe="/tmp/bench_async_${name}"
  local med="nan"
  local ns_per_op="nan"

  echo "=== tests/bench/${name} (1M ping-pong rounds, 2M task steps) ==="

  if [[ "$su" == *sched* ]]; then
    if ! link_with_scheduler "$su" "$exe"; then
      echo "compile/link FAIL: $su" >&2
      return 1
    fi
  else
    if ! "$SHU" -L . "$su" -o "$exe" >/tmp/async_compile.log 2>&1; then
      cat /tmp/async_compile.log >&2
      return 1
    fi
  fi
  [ -x "$exe" ] || { echo "missing executable $exe" >&2; return 1; }

  med=$(median_real "$exe")
  ns_per_op=$(awk -v t="$med" 'BEGIN { if (t>0) printf "%.1f", t*1e9/2000000.0; else print "nan" }')
  echo "Shu ${name} median real: ${med}s (~${ns_per_op} ns/step, target B-ASYNC ≤15ns)"

  printf '\n| %s | median (s) | ns/step |\n' "$name"
  printf '|---|------------|--------|\n'
  printf '| Shu | %s | %s |\n' "$med" "$ns_per_op"
  printf '\n'

  check_async_regress "$name" "$med"
}

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-async: use --bench to run async_switch + async_switch_sched"
  exit 0
fi

bench_async_case async_switch tests/bench/async_switch.su
bench_async_case async_switch_jmp tests/bench/async_switch_sched.su

if [ "${SHU_PERF_UPDATE_ASYNC_BASELINE:-0}" = "1" ]; then
  echo "# async 1M ping-pong 中位数上限（秒）；门禁：median ≤ cap" >tests/baseline/async-perf.tsv
  echo "# 更新：SHU_PERF_UPDATE_ASYNC_BASELINE=1 ./tests/run-perf-async.sh --bench" >>tests/baseline/async-perf.tsv
  echo "async_switch	$(median_real /tmp/bench_async_async_switch 2>/dev/null || echo 0.05)" >>tests/baseline/async-perf.tsv
  echo "async_switch_jmp	$(median_real /tmp/bench_async_async_switch_jmp 2>/dev/null || echo 0.05)" >>tests/baseline/async-perf.tsv
fi

echo "=== async perf OK ==="

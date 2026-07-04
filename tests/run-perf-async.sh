#!/usr/bin/env bash
# B-ASYNC：1M 双任务 ping-pong 切换开销（NEXT §1.2 B-ASYNC）
# 用法：./tests/run-perf-async.sh [--bench]
# 门禁：SHUX_PERF_FAIL_ON_ASYNC_REGRESSION=1 — median ≤ tests/baseline/async-perf.tsv
# 更新：SHUX_PERF_UPDATE_ASYNC_BASELINE=1 ./tests/run-perf-async.sh --bench
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o

# 与 run-async.sh 一致：外部已设 SHU（CI macOS 传 shux-c）时保留；否则 shux 优先。
if [ -z "${SHUX:-}" ]; then
  if [ -x ./compiler/shux ]; then
    SHUX=./compiler/shux
  elif [ -x ./compiler/shux-c ]; then
    SHUX=./compiler/shux-c
  else
    echo "run-perf-async FAIL: no compiler/shux or compiler/shux-c" >&2
    exit 1
  fi
fi

# Linux x86_64 可用 seed asm；其它平台 shux-c/-backend c（Darwin asm 链接 __TEXT 非 r-x）。
perf_async_is_linux_x64_asm() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64) return 0 ;;
  esac
  return 1
}

# 编译 bench 可执行：x86_64 Linux 默认 asm；其它 host 用 shux-c 或 seed -backend c。
perf_async_compile_bench() {
  local x="$1"
  local out="$2"
  rm -f "$out"
  if perf_async_is_linux_x64_asm; then
    "$SHUX" -L . "$x" -o "$out"
  elif [ -x ./compiler/shux-c ]; then
    ./compiler/shux-c -L . "$x" -o "$out"
  elif [ -x ./compiler/shux ]; then
    ./compiler/shux -L . "$x" -backend c -o "$out"
  else
    "$SHUX" -L . "$x" -o "$out"
  fi
}

RUNS=3
DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHUX_PERF_FAIL_ON_ASYNC_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0

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
  awk -F'\t' -v n="$1" '$1==n && $1 !~ /^#/ { print $2; exit }' "${SHUX_PERF_ASYNC_BASELINE:-tests/baseline/async-perf.tsv}"
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
  local x="$1"
  local out="$2"
  rm -f "$out"
  if ! "$SHUX" -L . "$x" -backend asm -o "$out" >/tmp/async_compile.log 2>&1; then
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

  echo "=== tests/bench/${name} (1M ping-pong rounds, 2M task steps) ==="

  if [[ "$x" == *sched* ]]; then
    if ! link_with_scheduler "$x" "$exe"; then
      echo "compile/link FAIL: $x" >&2
      return 1
    fi
  else
    if ! perf_async_compile_bench "$x" "$exe" >/tmp/async_compile.log 2>&1; then
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

bench_async_case async_switch tests/bench/async_switch.x
# scheduler jmp 烟测仅 Linux x86_64 seed asm；macOS/ARM64/Windows 记 N/A。
if perf_async_is_linux_x64_asm; then
  bench_async_case async_switch_jmp tests/bench/async_switch_sched.x
else
  echo "async_switch_jmp N/A (scheduler jmp asm requires Linux x86_64)"
fi

if [ "${SHUX_PERF_UPDATE_ASYNC_BASELINE:-0}" = "1" ]; then
  echo "# async 1M ping-pong 中位数上限（秒）；门禁：median ≤ cap" >tests/baseline/async-perf.tsv
  echo "# 更新：SHUX_PERF_UPDATE_ASYNC_BASELINE=1 ./tests/run-perf-async.sh --bench" >>tests/baseline/async-perf.tsv
  echo "async_switch	$(median_real /tmp/bench_async_async_switch 2>/dev/null || echo 0.05)" >>tests/baseline/async-perf.tsv
  echo "async_switch_jmp	$(median_real /tmp/bench_async_async_switch_jmp 2>/dev/null || echo 0.05)" >>tests/baseline/async-perf.tsv
fi

echo "=== async perf OK ==="

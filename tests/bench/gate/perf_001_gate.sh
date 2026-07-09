#!/usr/bin/env bash
# perf_001_gate.sh — PERF-001 性能门禁：SHUX 自研后端中位数 ≤ C -O2
#
# 用法：
#   ./tests/bench/gate/perf_001_gate.sh [bench_name]
#   SHUX=./compiler/shux_asm ./tests/bench/gate/perf_001_gate.sh loop_i32
#
# 默认 bench_name=loop_i32（tests/bench/loop_i32.c + .x 同源）
# 时机：自举后激活硬门禁；自举前可运行供参考（ASM 后端 bug ①② 未修时结果不准）
# 规范来源：开发规范 v1 §4（PERF-001 门禁系统）
set -u
cd "$(dirname "$0")/../../.."  # 到项目根

BENCH="${1:-loop_i32}"
BENCH_DIR="tests/bench"
SHUX="${SHUX:-./compiler/shux_asm}"
WORKDIR="${TMPDIR:-/tmp}/shux_perf"
mkdir -p "$WORKDIR"

WARMUP=3
ROUNDS=20

# 平台检测：macOS arm64 有 CG002 限制
arch="$(uname -m 2>/dev/null)"
os="$(uname -s 2>/dev/null)"
if [ "$os" = "Darwin" ] && [ "$arch" = "arm64" ]; then
  echo "perf-001: SKIP on macOS arm64 (CG002 asm code_len=0 limitation)"
  echo "         请在 Linux x86_64 上运行"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  echo "perf-001: SKIP (no $SHUX)"
  exit 0
fi

c_src="$BENCH_DIR/${BENCH}.c"
x_src="$BENCH_DIR/${BENCH}.x"
if [ ! -f "$c_src" ] || [ ! -f "$x_src" ]; then
  echo "perf-001: SKIP (missing $c_src or $x_src)"
  exit 0
fi

# time_ms <bin> — 返回 wall time（毫秒）
time_ms() {
  local start end
  start=$(date +%s%3N 2>/dev/null)
  "$1" >/dev/null 2>&1
  end=$(date +%s%3N 2>/dev/null)
  echo $((end - start))
}

# sample <bin> — warmup + rounds 采样，输出时间序列
sample() {
  local bin="$1" i
  for i in $(seq 1 "$WARMUP"); do
    "$bin" >/dev/null 2>&1
  done
  local times=""
  for i in $(seq 1 "$ROUNDS"); do
    times="$times $(time_ms "$bin")"
  done
  echo "$times"
}

# stats <times> — 输出 "median p99"
stats() {
  local sorted n mid med p99_idx p99
  sorted=$(echo "$1" | tr ' ' '\n' | grep -v '^$' | sort -n)
  n=$(echo "$sorted" | wc -l | tr -d ' ')
  if [ "$n" -eq 0 ]; then echo "0 0"; return; fi
  mid=$(( (n + 1) / 2 ))
  med=$(echo "$sorted" | sed -n "${mid}p")
  p99_idx=$(( n * 99 / 100 + 1 ))
  if [ "$p99_idx" -gt "$n" ]; then p99_idx=$n; fi
  p99=$(echo "$sorted" | sed -n "${p99_idx}p")
  echo "${med:-0} ${p99:-0}"
}

# 编译 C
c_bin="$WORKDIR/${BENCH}.c.bin"
cc="${CC:-clang}"
command -v "$cc" >/dev/null 2>&1 || cc=gcc
if ! "$cc" -O2 -std=c11 -o "$c_bin" "$c_src" 2>/dev/null; then
  echo "perf-001: C compile failed"
  exit 2
fi

# 编译 SHUX（stdout drain 防 hang）
x_bin="$WORKDIR/${BENCH}.x.bin"
"$SHUX" -L . "$x_src" -o "$x_bin" 2>/dev/null | cat >/dev/null
if [ ! -x "$x_bin" ]; then
  echo "perf-001: SHUX compile failed"
  exit 2
fi

echo "=== PERF-001 Gate: $BENCH ==="
echo "    C: $c_bin"
echo "    X: $x_bin"
echo "    warmup=$WARMUP  rounds=$ROUNDS"

c_times=$(sample "$c_bin")
x_times=$(sample "$x_bin")

c_stats=$(stats "$c_times")
x_stats=$(stats "$x_times")

c_med=$(echo "$c_stats" | awk '{print $1}')
c_p99=$(echo "$c_stats" | awk '{print $2}')
x_med=$(echo "$x_stats" | awk '{print $1}')
x_p99=$(echo "$x_stats" | awk '{print $2}')

echo "    C  median=${c_med}ms  P99=${c_p99}ms"
echo "    X  median=${x_med}ms  P99=${x_p99}ms"

# 硬门禁：SHUX 中位数 ≤ C 中位数（开发规范 v1 §4）
if [ -z "$x_med" ] || [ -z "$c_med" ] || [ "$x_med" -eq 0 ] || [ "$c_med" -eq 0 ]; then
  echo "    [WARN] 采样为零，可能 DCE 抹除未用循环（反作弊防御失效）"
  exit 2
fi
if [ "$x_med" -le "$c_med" ]; then
  ratio=$(awk "BEGIN { printf \"%.2f\", $x_med / $c_med }")
  echo "    [PASS] X median ≤ C median (ratio=$ratio)"
  exit 0
else
  ratio=$(awk "BEGIN { printf \"%.2f\", $x_med / $c_med }")
  echo "    [FAIL] X median > C median (ratio=$ratio) — 硬门禁不通过"
  exit 1
fi

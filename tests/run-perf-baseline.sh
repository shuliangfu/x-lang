#!/usr/bin/env bash
# 阶段 8 性能基线：编译 perf-baseline 用例并以 time 多次运行，输出耗时便于对比与防回退
# 用法：./tests/run-perf-baseline.sh [--bench]  # --bench 额外跑 tests/bench（需本机 cc；zig 可选）
# 门禁：SHU_PERF_FAIL_ON_ZIG=1 时要求 default asm 中位数 ≤ Zig -O2（无 zig 则跳过该项）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# CI make all 产出 C-only shu；perf 编译统一用 shu-c。
PERF_COMPILE_SHU=./compiler/shu
if [ -x ./compiler/shu-c ]; then
  PERF_COMPILE_SHU=./compiler/shu-c
fi

PERF_SU="tests/perf-baseline/main.su"
OUT="/tmp/shu_perf_baseline"
RUNS=3
DO_BENCH=0
PERF_ZIG_FAILS=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHU_PERF_FAIL_ON_ZIG:-0}" = "1" ] && PERF_FAIL_ZIG=1 || PERF_FAIL_ZIG=0

# 从 time 输出提取 real 秒数（兼容 bash/zsh；BSD awk 无三参数 match，用 sed）
extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

# 多次运行取 real 中位数
median_real() {
  local exe="$1"
  local i vals med n
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

# 跑单个 bench 用例：name + .su/.c/.zig 基名（不含扩展名），打印 median 表
bench_case() {
  local name="$1"
  local base="$2"
  local su="${base}.su"
  local c="${base}.c"
  local zig="${base}.zig"
  local SHU_ASM_MED="nan"
  local SHU_C_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"
  local ASM_MED="nan"
  local tag="${name}_"

  echo "=== tests/bench/${name} ==="

  $PERF_COMPILE_SHU "$su" -o "/tmp/bench_shu_${tag}" 2>&1
  if [ -x "/tmp/bench_shu_${tag}" ]; then
    SHU_ASM_MED=$(median_real "/tmp/bench_shu_${tag}")
    echo "Shu (default asm) ${name} median real: ${SHU_ASM_MED}s"
  fi

  if [ "$PERF_COMPILE_SHU" != "./compiler/shu-c" ] \
    && $PERF_COMPILE_SHU "$su" -backend c -o "/tmp/bench_shu_c_${tag}" 2>&1 \
    && [ -x "/tmp/bench_shu_c_${tag}" ]; then
    SHU_C_MED=$(median_real "/tmp/bench_shu_c_${tag}")
    echo "Shu (-backend c) ${name} median real: ${SHU_C_MED}s"
  elif [ "$PERF_COMPILE_SHU" = "./compiler/shu-c" ] && [ "$SHU_ASM_MED" != "nan" ]; then
    SHU_C_MED="$SHU_ASM_MED"
  fi

  if [ -x compiler/shu_asm ]; then
    if compiler/shu_asm "$su" -o "/tmp/bench_asm_${tag}" 2>&1 && [ -x "/tmp/bench_asm_${tag}" ]; then
      ASM_MED=$(median_real "/tmp/bench_asm_${tag}")
      echo "Shu asm (shu_asm) ${name} median real: ${ASM_MED}s"
    fi
  fi

  if command -v cc >/dev/null 2>&1 && [ -f "$c" ]; then
    if cc -O2 "$c" -o "/tmp/bench_c_${tag}" 2>/dev/null && [ -x "/tmp/bench_c_${tag}" ]; then
      C_MED=$(median_real "/tmp/bench_c_${tag}")
      echo "C -O2 ${name} median real: ${C_MED}s"
    fi
  fi

  if command -v zig >/dev/null 2>&1 && [ -f "$zig" ]; then
    if zig build-exe -O2 "$zig" -femit-bin="/tmp/bench_zig_${tag}" 2>/dev/null && [ -x "/tmp/bench_zig_${tag}" ]; then
      ZIG_MED=$(median_real "/tmp/bench_zig_${tag}")
      echo "Zig -O2 ${name} median real: ${ZIG_MED}s"
    fi
  fi

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (default asm) | %s |\n' "$SHU_ASM_MED"
  printf '| Shu (-backend c) | %s |\n' "$SHU_C_MED"
  printf '| Shu asm (shu_asm) | %s |\n' "$ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  # P2 门禁：default asm 中位数须 ≤ Zig -O2（zig 不可用时跳过）
  if [ "$PERF_FAIL_ZIG" -eq 1 ] && [ "$ZIG_MED" != "nan" ] && [ "$SHU_ASM_MED" != "nan" ]; then
    if awk -v shu="$SHU_ASM_MED" -v zig="$ZIG_MED" 'BEGIN { exit (shu <= zig + 0.000001) ? 0 : 1 }'; then
      echo "perf gate OK: ${name} Shu asm ${SHU_ASM_MED}s <= Zig ${ZIG_MED}s"
    else
      echo "perf gate FAIL: ${name} Shu asm ${SHU_ASM_MED}s > Zig ${ZIG_MED}s" >&2
      PERF_ZIG_FAILS=$((PERF_ZIG_FAILS + 1))
    fi
  fi
}

echo "=== 性能基线（Shulang）==="
$PERF_COMPILE_SHU "$PERF_SU" -o "$OUT" 2>&1
if [ ! -f "$OUT" ]; then
  echo "编译失败，无产物" >&2
  exit 1
fi

echo "运行 $RUNS 次，取 real 时间："
for i in $(seq 1 "$RUNS"); do
  ( time "$OUT" ) 2>&1 | grep -E '^real' || true
done

if [ "$DO_BENCH" -eq 1 ]; then
  bench_case loop_i32 tests/bench/loop_i32
  bench_case mem_copy tests/bench/mem_copy
  bench_case struct_param tests/bench/struct_param
  bench_case call_boundary tests/bench/call_boundary
  echo "（完整说明见 analysis/perf-vs-zig-baseline.md；P0：loop_i32 + mem_copy + struct_param + call_boundary）"
  if [ "$PERF_FAIL_ZIG" -eq 1 ] && [ "$PERF_ZIG_FAILS" -gt 0 ]; then
    echo "perf baseline FAIL: ${PERF_ZIG_FAILS} case(s) slower than Zig -O2" >&2
    exit 1
  fi
fi

echo "=== perf baseline OK ==="

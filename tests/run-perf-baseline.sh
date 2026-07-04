#!/usr/bin/env bash
# 阶段 8 性能基线：编译 perf-baseline 用例并以 time 多次运行，输出耗时便于对比与防回退
# 用法：./tests/run-perf-baseline.sh [--bench]  # --bench 额外跑 tests/bench（需本机 cc；zig 可选）
# 门禁：
#   SHUX_PERF_FAIL_ON_ZIG=1 — default asm 中位数 ≤ Zig -O2（无 zig 则跳过该项）
#   SHUX_PERF_FAIL_ON_C_O3=1 — default asm 中位数 ≤ SHUX_PERF_C_O3_RATIO× C -O3（B-CMP/L2；无 cc 则跳过）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# PERF-001：Zig 编译参数与版本 pin 见 tests/lib/zig-baseline.sh
# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh"

# CI make all 产出 C-only shux；perf 编译统一用 shux-c。
PERF_COMPILE_SHUX=./compiler/shux
if [ -x ./compiler/shux-c ]; then
  PERF_COMPILE_SHUX=./compiler/shux-c
fi

PERF_X="tests/perf-baseline/main.x"
OUT="/tmp/shux_perf_baseline"
RUNS=${SHUX_PERF_BASELINE_RUNS:-3}
[ "${SHUX_PERF_FAIL_ON_C_O3:-0}" = "1" ] && RUNS=${SHUX_PERF_BASELINE_RUNS:-9}
DO_BENCH=0
PERF_ZIG_FAILS=0
PERF_C_O3_FAILS=0
PERF_BCMP_ASM_FAILS=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHUX_PERF_FAIL_ON_ZIG:-0}" = "1" ] && PERF_FAIL_ZIG=1 || PERF_FAIL_ZIG=0
[ "${SHUX_PERF_FAIL_ON_C_O3:-0}" = "1" ] && PERF_FAIL_C_O3=1 || PERF_FAIL_C_O3=0
[ "${SHUX_PERF_BCMP_ASM:-0}" = "1" ] && PERF_BCMP_ASM=1 || PERF_BCMP_ASM=0
C_O3_RATIO="${SHUX_PERF_C_O3_RATIO:-0.95}"
STRETCH_ASM_ONLY=0
[ "${SHUX_PERF_STRETCH_ASM_ONLY:-0}" = "1" ] && STRETCH_ASM_ONLY=1
# B-CMP 须与 C -O3 同级优化；默认 bench 仍 -O2（Zig 对照）。
SHUX_BENCH_OPT="${SHUX_BENCH_OPT:-2}"
[ "${SHUX_PERF_FAIL_ON_C_O3:-0}" = "1" ] && SHUX_BENCH_OPT=3

# B-CMP 用 cc 旗标与 invoke_cc -O3 对齐（march=native + NDEBUG）。
bcmp_cc_o3() {
  cc -std=gnu11 -O3 -march=native -mtune=native -DNDEBUG "$@"
}

# B-CMP：用 Shu 生成 .c 再最小 cc 链（与 C 参照同级，避免全量 std 链干扰 microbench）。
bcmp_compile_shu_codegen() {
  local x="$1"
  local out="$2"
  local tag="$3"
  local gen_c="/tmp/bench_shu_gen_${tag}.c"
  SHUX_DEBUG_C=1 "$PERF_COMPILE_SHUX" -O "$SHUX_BENCH_OPT" "$x" -o "/tmp/bench_shu_link_${tag}" >/dev/null 2>&1 || return 1
  if [ ! -f /tmp/shux_debug.c ]; then
    return 1
  fi
  grep -v 'shux_process' /tmp/shux_debug.c > "$gen_c"
  bcmp_cc_o3 "$gen_c" -o "$out"
}

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

# 跑单个 bench 用例：name + .x/.c/.zig 基名（不含扩展名），打印 median 表
bench_case() {
  local name="$1"
  local base="$2"
  local x="${base}.x"
  local c="${base}.c"
  local zig="${base}.zig"
  local SHUX_ASM_MED="nan"
  local SHUX_C_MED="nan"
  local C_MED="nan"
  local C_O3_MED="nan"
  local ZIG_MED="nan"
  local ASM_MED="nan"
  local tag="${name}_"

  echo "=== tests/bench/${name} ==="

  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$PERF_COMPILE_SHUX" = "./compiler/shux-c" ]; then
    if bcmp_compile_shu_codegen "$x" "/tmp/bench_shu_${tag}" "$tag" 2>&1; then
      :
    else
      $PERF_COMPILE_SHUX -O "$SHUX_BENCH_OPT" "$x" -o "/tmp/bench_shu_${tag}" 2>&1
    fi
  else
    $PERF_COMPILE_SHUX -O "$SHUX_BENCH_OPT" "$x" -o "/tmp/bench_shu_${tag}" 2>&1
  fi
  if [ -x "/tmp/bench_shu_${tag}" ]; then
    SHUX_ASM_MED=$(median_real "/tmp/bench_shu_${tag}")
    echo "Shu (-O${SHUX_BENCH_OPT}) ${name} median real: ${SHUX_ASM_MED}s"
  fi

  if [ "$PERF_COMPILE_SHUX" != "./compiler/shux-c" ] \
    && $PERF_COMPILE_SHUX -O "$SHUX_BENCH_OPT" "$x" -backend c -o "/tmp/bench_shu_c_${tag}" 2>&1 \
    && [ -x "/tmp/bench_shu_c_${tag}" ]; then
    SHUX_C_MED=$(median_real "/tmp/bench_shu_c_${tag}")
    echo "Shu (-backend c) ${name} median real: ${SHUX_C_MED}s"
  elif [ "$PERF_COMPILE_SHUX" = "./compiler/shux-c" ] && [ "$SHUX_ASM_MED" != "nan" ]; then
    SHUX_C_MED="$SHUX_ASM_MED"
  fi

  if [ -x compiler/shux_asm ]; then
    # B-CMP-ASM：Linux 上 nostdlib 静态链，避免全量 std 链拖慢 microbench（S4 freestanding）。
    asm_bcmp_env=()
    if [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
      asm_bcmp_env=(env SHUX_FREESTANDING=1)
    fi
    if "${asm_bcmp_env[@]}" compiler/shux_asm -O "$SHUX_BENCH_OPT" "$x" -o "/tmp/bench_asm_${tag}" 2>&1 \
      && [ -x "/tmp/bench_asm_${tag}" ]; then
      ASM_MED=$(median_real "/tmp/bench_asm_${tag}")
      if [ "${#asm_bcmp_env[@]}" -gt 0 ]; then
        echo "Shu asm (-O${SHUX_BENCH_OPT}, freestanding) ${name} median real: ${ASM_MED}s"
      else
        echo "Shu asm (-O${SHUX_BENCH_OPT}) ${name} median real: ${ASM_MED}s"
      fi
    fi
  fi

  if command -v cc >/dev/null 2>&1 && [ -f "$c" ]; then
    if cc -O2 "$c" -o "/tmp/bench_c_${tag}" 2>/dev/null && [ -x "/tmp/bench_c_${tag}" ]; then
      C_MED=$(median_real "/tmp/bench_c_${tag}")
      echo "C -O2 ${name} median real: ${C_MED}s"
    fi
    if bcmp_cc_o3 "$c" -o "/tmp/bench_c_o3_${tag}" 2>/dev/null && [ -x "/tmp/bench_c_o3_${tag}" ]; then
      C_O3_MED=$(median_real "/tmp/bench_c_o3_${tag}")
      echo "C -O3 ${name} median real: ${C_O3_MED}s"
    fi
  fi

  if command -v zig >/dev/null 2>&1 && [ -f "$zig" ]; then
    if zig_build_exe_o2 "$zig" "/tmp/bench_zig_${tag}" && [ -x "/tmp/bench_zig_${tag}" ]; then
      ZIG_MED=$(median_real "/tmp/bench_zig_${tag}")
      echo "Zig -O2 ${name} median real: ${ZIG_MED}s"
    fi
  fi

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (-O%s) | %s |\n' "$SHUX_BENCH_OPT" "$SHUX_ASM_MED"
  printf '| Shu (-backend c, -O%s) | %s |\n' "$SHUX_BENCH_OPT" "$SHUXXX_C_MED"
  printf '| Shu asm (-O%s) | %s |\n' "$SHUX_BENCH_OPT" "$ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| C -O3 | %s |\n' "$C_O3_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  # P2 门禁：default asm 中位数须 ≤ Zig -O2（zig 不可用时跳过）
  if [ "$PERF_FAIL_ZIG" -eq 1 ] && [ "$ZIG_MED" != "nan" ] && [ "$SHUX_ASM_MED" != "nan" ]; then
    if awk -v shux="$SHUX_ASM_MED" -v zig="$ZIG_MED" 'BEGIN { exit (shux <= zig + 0.000001) ? 0 : 1 }'; then
      echo "perf gate OK: ${name} Shu asm ${SHUX_ASM_MED}s <= Zig ${ZIG_MED}s"
    else
      echo "perf gate FAIL: ${name} Shu asm ${SHUX_ASM_MED}s > Zig ${ZIG_MED}s" >&2
      PERF_ZIG_FAILS=$((PERF_ZIG_FAILS + 1))
    fi
  fi

  # L2 B-CMP：Shu -O3 中位数须 ≤ ratio× C -O3（cc 不可用时跳过）
  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$C_O3_MED" != "nan" ] && [ "$SHUX_ASM_MED" != "nan" ]; then
    if awk -v shux="$SHUX_ASM_MED" -v c="$C_O3_MED" -v r="$C_O3_RATIO" 'BEGIN {
      slack = (r + 0 >= 0.999) ? 0.002 : 0
      exit (shux <= c * r + slack + 0.000001) ? 0 : 1
    }'; then
      echo "perf B-CMP OK: ${name} Shu -O${SHUX_BENCH_OPT} ${SHUX_ASM_MED}s <= ${C_O3_RATIO}× C-O3 ${C_O3_MED}s"
    else
      echo "perf B-CMP FAIL: ${name} Shu -O${SHUX_BENCH_OPT} ${SHUX_ASM_MED}s > ${C_O3_RATIO}× C-O3 ${C_O3_MED}s" >&2
      PERF_C_O3_FAILS=$((PERF_C_O3_FAILS + 1))
    fi
  fi

  # L2 B-CMP（shux_asm 原生后端）：须 ≤ ratio× C -O3（SHUX_PERF_BCMP_ASM=1 且 shux_asm 可用时）
  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$C_O3_MED" != "nan" ] && [ "$ASM_MED" != "nan" ]; then
    if awk -v shux="$ASM_MED" -v c="$C_O3_MED" -v r="$C_O3_RATIO" 'BEGIN {
      slack = (r + 0 >= 0.999) ? 0.002 : 0
      exit (shux <= c * r + slack + 0.000001) ? 0 : 1
    }'; then
      echo "perf B-CMP-ASM OK: ${name} shux_asm -O${SHUX_BENCH_OPT} ${ASM_MED}s <= ${C_O3_RATIO}× C-O3 ${C_O3_MED}s"
    else
      echo "perf B-CMP-ASM FAIL: ${name} shux_asm -O${SHUX_BENCH_OPT} ${ASM_MED}s > ${C_O3_RATIO}× C-O3 ${C_O3_MED}s" >&2
      PERF_BCMP_ASM_FAILS=$((PERF_BCMP_ASM_FAILS + 1))
    fi
  fi
}

echo "=== 性能基线（Shux）==="
$PERF_COMPILE_SHUX "$PERF_X" -o "$OUT" 2>&1
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
  echo "（完整说明见 analysis/perf-zig-baseline-v1.md；P0：loop_i32 + mem_copy + struct_param + call_boundary）"
  if [ "$PERF_FAIL_ZIG" -eq 1 ] && [ "$PERF_ZIG_FAILS" -gt 0 ]; then
    echo "perf baseline FAIL: ${PERF_ZIG_FAILS} case(s) slower than Zig -O2" >&2
    exit 1
  fi
  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$STRETCH_ASM_ONLY" -eq 0 ] && [ "$PERF_C_O3_FAILS" -gt 0 ]; then
    echo "perf baseline FAIL: ${PERF_C_O3_FAILS} case(s) slower than ${C_O3_RATIO}× C -O3 (B-CMP)" >&2
    exit 1
  fi
  if [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$PERF_BCMP_ASM_FAILS" -gt 0 ]; then
    echo "perf baseline FAIL: ${PERF_BCMP_ASM_FAILS} case(s) shux_asm slower than ${C_O3_RATIO}× C -O3 (B-CMP-ASM)" >&2
    exit 1
  fi
fi

echo "=== perf baseline OK ==="

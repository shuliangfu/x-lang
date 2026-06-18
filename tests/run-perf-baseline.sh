#!/usr/bin/env bash
# 阶段 8 性能基线：编译 perf-baseline 用例并以 time 多次运行，输出耗时便于对比与防回退
# 用法：./tests/run-perf-baseline.sh [--bench]  # --bench 额外跑 tests/bench（需本机 cc；zig 可选）
# 门禁：
#   SHU_PERF_FAIL_ON_ZIG=1 — default asm 中位数 ≤ Zig -O2（无 zig 则跳过该项）
#   SHU_PERF_FAIL_ON_C_O3=1 — default asm 中位数 ≤ SHU_PERF_C_O3_RATIO× C -O3（B-CMP/L2；无 cc 则跳过）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

# PERF-001：Zig 编译参数与版本 pin 见 tests/lib/zig-baseline.sh
# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh"

# CI make all 产出 C-only shu；perf 编译统一用 shu-c。
PERF_COMPILE_SHU=./compiler/shu
if [ -x ./compiler/shu-c ]; then
  PERF_COMPILE_SHU=./compiler/shu-c
fi

PERF_SU="tests/perf-baseline/main.su"
OUT="/tmp/shu_perf_baseline"
RUNS=${SHU_PERF_BASELINE_RUNS:-3}
[ "${SHU_PERF_FAIL_ON_C_O3:-0}" = "1" ] && RUNS=${SHU_PERF_BASELINE_RUNS:-9}
DO_BENCH=0
PERF_ZIG_FAILS=0
PERF_C_O3_FAILS=0
PERF_BCMP_ASM_FAILS=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHU_PERF_FAIL_ON_ZIG:-0}" = "1" ] && PERF_FAIL_ZIG=1 || PERF_FAIL_ZIG=0
[ "${SHU_PERF_FAIL_ON_C_O3:-0}" = "1" ] && PERF_FAIL_C_O3=1 || PERF_FAIL_C_O3=0
[ "${SHU_PERF_BCMP_ASM:-0}" = "1" ] && PERF_BCMP_ASM=1 || PERF_BCMP_ASM=0
C_O3_RATIO="${SHU_PERF_C_O3_RATIO:-0.95}"
STRETCH_ASM_ONLY=0
[ "${SHU_PERF_STRETCH_ASM_ONLY:-0}" = "1" ] && STRETCH_ASM_ONLY=1
# B-CMP 须与 C -O3 同级优化；默认 bench 仍 -O2（Zig 对照）。
SHU_BENCH_OPT="${SHU_BENCH_OPT:-2}"
[ "${SHU_PERF_FAIL_ON_C_O3:-0}" = "1" ] && SHU_BENCH_OPT=3

# B-CMP 用 cc 旗标与 invoke_cc -O3 对齐（march=native + NDEBUG）。
bcmp_cc_o3() {
  cc -std=gnu11 -O3 -march=native -mtune=native -DNDEBUG "$@"
}

# B-CMP：用 Shu 生成 .c 再最小 cc 链（与 C 参照同级，避免全量 std 链干扰 microbench）。
bcmp_compile_shu_codegen() {
  local su="$1"
  local out="$2"
  local tag="$3"
  local gen_c="/tmp/bench_shu_gen_${tag}.c"
  SHU_DEBUG_C=1 "$PERF_COMPILE_SHU" -O "$SHU_BENCH_OPT" "$su" -o "/tmp/bench_shu_link_${tag}" >/dev/null 2>&1 || return 1
  if [ ! -f /tmp/shu_debug.c ]; then
    return 1
  fi
  grep -v 'shulang_process' /tmp/shu_debug.c > "$gen_c"
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
  local C_O3_MED="nan"
  local ZIG_MED="nan"
  local ASM_MED="nan"
  local tag="${name}_"

  echo "=== tests/bench/${name} ==="

  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$PERF_COMPILE_SHU" = "./compiler/shu-c" ]; then
    if bcmp_compile_shu_codegen "$su" "/tmp/bench_shu_${tag}" "$tag" 2>&1; then
      :
    else
      $PERF_COMPILE_SHU -O "$SHU_BENCH_OPT" "$su" -o "/tmp/bench_shu_${tag}" 2>&1
    fi
  else
    $PERF_COMPILE_SHU -O "$SHU_BENCH_OPT" "$su" -o "/tmp/bench_shu_${tag}" 2>&1
  fi
  if [ -x "/tmp/bench_shu_${tag}" ]; then
    SHU_ASM_MED=$(median_real "/tmp/bench_shu_${tag}")
    echo "Shu (-O${SHU_BENCH_OPT}) ${name} median real: ${SHU_ASM_MED}s"
  fi

  if [ "$PERF_COMPILE_SHU" != "./compiler/shu-c" ] \
    && $PERF_COMPILE_SHU -O "$SHU_BENCH_OPT" "$su" -backend c -o "/tmp/bench_shu_c_${tag}" 2>&1 \
    && [ -x "/tmp/bench_shu_c_${tag}" ]; then
    SHU_C_MED=$(median_real "/tmp/bench_shu_c_${tag}")
    echo "Shu (-backend c) ${name} median real: ${SHU_C_MED}s"
  elif [ "$PERF_COMPILE_SHU" = "./compiler/shu-c" ] && [ "$SHU_ASM_MED" != "nan" ]; then
    SHU_C_MED="$SHU_ASM_MED"
  fi

  if [ -x compiler/shu_asm ]; then
    # B-CMP-ASM：Linux 上 nostdlib 静态链，避免全量 std 链拖慢 microbench（S4 freestanding）。
    asm_bcmp_env=()
    if [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
      asm_bcmp_env=(env SHU_FREESTANDING=1)
    fi
    if "${asm_bcmp_env[@]}" compiler/shu_asm -O "$SHU_BENCH_OPT" "$su" -o "/tmp/bench_asm_${tag}" 2>&1 \
      && [ -x "/tmp/bench_asm_${tag}" ]; then
      ASM_MED=$(median_real "/tmp/bench_asm_${tag}")
      if [ "${#asm_bcmp_env[@]}" -gt 0 ]; then
        echo "Shu asm (-O${SHU_BENCH_OPT}, freestanding) ${name} median real: ${ASM_MED}s"
      else
        echo "Shu asm (-O${SHU_BENCH_OPT}) ${name} median real: ${ASM_MED}s"
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
  printf '| Shu (-O%s) | %s |\n' "$SHU_BENCH_OPT" "$SHU_ASM_MED"
  printf '| Shu (-backend c, -O%s) | %s |\n' "$SHU_BENCH_OPT" "$SHU_C_MED"
  printf '| Shu asm (-O%s) | %s |\n' "$SHU_BENCH_OPT" "$ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| C -O3 | %s |\n' "$C_O3_MED"
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

  # L2 B-CMP：Shu -O3 中位数须 ≤ ratio× C -O3（cc 不可用时跳过）
  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$C_O3_MED" != "nan" ] && [ "$SHU_ASM_MED" != "nan" ]; then
    if awk -v shu="$SHU_ASM_MED" -v c="$C_O3_MED" -v r="$C_O3_RATIO" 'BEGIN {
      slack = (r + 0 >= 0.999) ? 0.002 : 0
      exit (shu <= c * r + slack + 0.000001) ? 0 : 1
    }'; then
      echo "perf B-CMP OK: ${name} Shu -O${SHU_BENCH_OPT} ${SHU_ASM_MED}s <= ${C_O3_RATIO}× C-O3 ${C_O3_MED}s"
    else
      echo "perf B-CMP FAIL: ${name} Shu -O${SHU_BENCH_OPT} ${SHU_ASM_MED}s > ${C_O3_RATIO}× C-O3 ${C_O3_MED}s" >&2
      PERF_C_O3_FAILS=$((PERF_C_O3_FAILS + 1))
    fi
  fi

  # L2 B-CMP（shu_asm 原生后端）：须 ≤ ratio× C -O3（SHU_PERF_BCMP_ASM=1 且 shu_asm 可用时）
  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$C_O3_MED" != "nan" ] && [ "$ASM_MED" != "nan" ]; then
    if awk -v shu="$ASM_MED" -v c="$C_O3_MED" -v r="$C_O3_RATIO" 'BEGIN {
      slack = (r + 0 >= 0.999) ? 0.002 : 0
      exit (shu <= c * r + slack + 0.000001) ? 0 : 1
    }'; then
      echo "perf B-CMP-ASM OK: ${name} shu_asm -O${SHU_BENCH_OPT} ${ASM_MED}s <= ${C_O3_RATIO}× C-O3 ${C_O3_MED}s"
    else
      echo "perf B-CMP-ASM FAIL: ${name} shu_asm -O${SHU_BENCH_OPT} ${ASM_MED}s > ${C_O3_RATIO}× C-O3 ${C_O3_MED}s" >&2
      PERF_BCMP_ASM_FAILS=$((PERF_BCMP_ASM_FAILS + 1))
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
    echo "perf baseline FAIL: ${PERF_BCMP_ASM_FAILS} case(s) shu_asm slower than ${C_O3_RATIO}× C -O3 (B-CMP-ASM)" >&2
    exit 1
  fi
fi

echo "=== perf baseline OK ==="

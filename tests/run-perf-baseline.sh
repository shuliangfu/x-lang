#!/usr/bin/env bash
# Phase-8 perf baseline: compile perf-baseline + optional microbench vs Zig/C.
#
# Honesty: soft XLANG_PERF_FAIL_ON_ZIG / FAIL_ON_C_O3:-0 previously left
# slower-than-Zig / slower-than-C-O3 unchecked (silent OK = portable
# false-green). Soft auto-make before resolve + soft prefer-xlang-c-only
# retired. Prefer product xlang_asm (Darwin hosted build may use xlang-c).
# Slower-than peer = obs (FAIL_ON=1 still hard). Explicit bad XLANG = hard
# die. Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-baseline.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_ZIG=1 — default compile median ≤ Zig -O2 hard
#   XLANG_PERF_FAIL_ON_C_O3=1 — ≤ XLANG_PERF_C_O3_RATIO× C -O3 hard
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# PERF-001: Zig compile flags / version pin.
# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh"
# Honesty: do NOT auto-make before resolve.

PREFIX="xlang: [XLANG_PERF_BASELINE]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "baseline perf FAIL: $*" >&2
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# PLATFORM: DARWIN — hosted microbench prefer xlang-c (asm __TEXT not r-x).
# PLATFORM: LINUX — product asm preferred; xlang-c still ok for B-CMP codegen path.
PERF_COMPILE_XLANG="$XLANG_BIN"
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      PERF_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
  *)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      # Keep historical B-CMP path via xlang-c when present; resolve still prefer asm.
      PERF_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
esac
echo "baseline perf: resolve=$XLANG_BIN compile=$PERF_COMPILE_XLANG"

PERF_X="tests/perf-baseline/main.x"
OUT="/tmp/xlang_perf_baseline"
RUNS=${XLANG_PERF_BASELINE_RUNS:-3}
[ "${XLANG_PERF_FAIL_ON_C_O3:-0}" = "1" ] && RUNS=${XLANG_PERF_BASELINE_RUNS:-9}
DO_BENCH=0
PERF_ZIG_FAILS=0
PERF_C_O3_FAILS=0
PERF_BCMP_ASM_FAILS=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${XLANG_PERF_FAIL_ON_ZIG:-0}" = "1" ] && PERF_FAIL_ZIG=1 || PERF_FAIL_ZIG=0
[ "${XLANG_PERF_FAIL_ON_C_O3:-0}" = "1" ] && PERF_FAIL_C_O3=1 || PERF_FAIL_C_O3=0
[ "${XLANG_PERF_BCMP_ASM:-0}" = "1" ] && PERF_BCMP_ASM=1 || PERF_BCMP_ASM=0
C_O3_RATIO="${XLANG_PERF_C_O3_RATIO:-0.95}"
STRETCH_ASM_ONLY=0
[ "${XLANG_PERF_STRETCH_ASM_ONLY:-0}" = "1" ] && STRETCH_ASM_ONLY=1
# B-CMP needs same opt level as C -O3; default bench still -O2 (Zig peer).
XLANG_BENCH_OPT="${XLANG_BENCH_OPT:-2}"
[ "${XLANG_PERF_FAIL_ON_C_O3:-0}" = "1" ] && XLANG_BENCH_OPT=3

bcmp_cc_o3() {
  cc -std=gnu11 -O3 -march=native -mtune=native -DNDEBUG "$@"
}

bcmp_compile_shu_codegen() {
  local x="$1"
  local out="$2"
  local tag="$3"
  local gen_c="/tmp/bench_shu_gen_${tag}.c"
  XLANG_DEBUG_C=1 "$PERF_COMPILE_XLANG" -O "$XLANG_BENCH_OPT" "$x" -o "/tmp/bench_shu_link_${tag}" >/dev/null 2>&1 || return 1
  if [ ! -f /tmp/xlang_debug.c ]; then
    return 1
  fi
  grep -v 'xlang_process' /tmp/xlang_debug.c > "$gen_c"
  bcmp_cc_o3 "$gen_c" -o "$out"
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

# Live bench paths (relocated r01_/m03_/r10_/a01_); refuse fossil bench/loop_i32.x etc.
bench_case() {
  local name="$1"
  local base="$2"
  local x="${base}.x"
  local c="${base}.c"
  local zig="${base}.zig"
  local XLANG_ASM_MED="nan"
  local XLANG_C_MED="nan"
  local C_MED="nan"
  local C_O3_MED="nan"
  local ZIG_MED="nan"
  local ASM_MED="nan"
  local tag="${name}_"

  echo "=== bench/${name} ==="
  [ -f "$x" ] || die "missing bench source $x (refuse fossil path)"

  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [[ "$PERF_COMPILE_XLANG" == *xlang-c ]]; then
    if bcmp_compile_shu_codegen "$x" "/tmp/bench_shu_${tag}" "$tag" 2>&1; then
      :
    else
      "$PERF_COMPILE_XLANG" -O "$XLANG_BENCH_OPT" "$x" -o "/tmp/bench_shu_${tag}" 2>&1
    fi
  else
    "$PERF_COMPILE_XLANG" -O "$XLANG_BENCH_OPT" "$x" -o "/tmp/bench_shu_${tag}" 2>&1
  fi
  if [ -x "/tmp/bench_shu_${tag}" ]; then
    XLANG_ASM_MED=$(median_real "/tmp/bench_shu_${tag}")
    echo "Xlang (-O${XLANG_BENCH_OPT}) ${name} median real: ${XLANG_ASM_MED}s"
  fi

  if [[ "$PERF_COMPILE_XLANG" != *xlang-c ]] \
    && "$PERF_COMPILE_XLANG" -O "$XLANG_BENCH_OPT" "$x" -backend c -o "/tmp/bench_shu_c_${tag}" 2>&1 \
    && [ -x "/tmp/bench_shu_c_${tag}" ]; then
    XLANG_C_MED=$(median_real "/tmp/bench_shu_c_${tag}")
    echo "Xlang (-backend c) ${name} median real: ${XLANG_C_MED}s"
  elif [[ "$PERF_COMPILE_XLANG" == *xlang-c ]] && [ "$XLANG_ASM_MED" != "nan" ]; then
    XLANG_C_MED="$XLANG_ASM_MED"
  fi

  if [ -x ./compiler/xlang_asm ] && dod_native_exe "$(pwd)/compiler/xlang_asm"; then
    # B-CMP-ASM: Linux nostdlib static to avoid full std chain drag (S4 freestanding).
    asm_bcmp_env=()
    if [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
      asm_bcmp_env=(env XLANG_FREESTANDING=1)
    fi
    if "${asm_bcmp_env[@]}" ./compiler/xlang_asm -O "$XLANG_BENCH_OPT" "$x" -o "/tmp/bench_asm_${tag}" 2>&1 \
      && [ -x "/tmp/bench_asm_${tag}" ]; then
      ASM_MED=$(median_real "/tmp/bench_asm_${tag}")
      if [ "${#asm_bcmp_env[@]}" -gt 0 ]; then
        echo "Xlang asm (-O${XLANG_BENCH_OPT}, freestanding) ${name} median real: ${ASM_MED}s"
      else
        echo "Xlang asm (-O${XLANG_BENCH_OPT}) ${name} median real: ${ASM_MED}s"
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
  printf '| Xlang (-O%s) | %s |\n' "$XLANG_BENCH_OPT" "$XLANG_ASM_MED"
  printf '| Xlang (-backend c, -O%s) | %s |\n' "$XLANG_BENCH_OPT" "$XLANG_C_MED"
  printf '| Xlang asm (-O%s) | %s |\n' "$XLANG_BENCH_OPT" "$ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| C -O3 | %s |\n' "$C_O3_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  # Zig peer: always compare when both measured. Slower = obs when FAIL_ON=0.
  if [ "$ZIG_MED" != "nan" ] && [ "$XLANG_ASM_MED" != "nan" ]; then
    if awk -v xlang="$XLANG_ASM_MED" -v zig="$ZIG_MED" 'BEGIN { exit (xlang <= zig + 0.000001) ? 0 : 1 }'; then
      echo "perf gate OK: ${name} Xlang ${XLANG_ASM_MED}s <= Zig ${ZIG_MED}s"
    else
      echo "perf baseline OBS: ${name} Xlang ${XLANG_ASM_MED}s > Zig ${ZIG_MED}s" >&2
      OBS=$((OBS + 1))
      PERF_ZIG_FAILS=$((PERF_ZIG_FAILS + 1))
    fi
  fi

  # B-CMP vs C -O3: always compare when both measured.
  if [ "$C_O3_MED" != "nan" ] && [ "$XLANG_ASM_MED" != "nan" ]; then
    if awk -v xlang="$XLANG_ASM_MED" -v c="$C_O3_MED" -v r="$C_O3_RATIO" 'BEGIN {
      slack = (r + 0 >= 0.999) ? 0.002 : 0
      exit (xlang <= c * r + slack + 0.000001) ? 0 : 1
    }'; then
      echo "perf B-CMP OK: ${name} Xlang -O${XLANG_BENCH_OPT} ${XLANG_ASM_MED}s <= ${C_O3_RATIO}× C-O3 ${C_O3_MED}s"
    else
      echo "perf baseline OBS: ${name} Xlang -O${XLANG_BENCH_OPT} ${XLANG_ASM_MED}s > ${C_O3_RATIO}× C-O3 ${C_O3_MED}s" >&2
      OBS=$((OBS + 1))
      PERF_C_O3_FAILS=$((PERF_C_O3_FAILS + 1))
    fi
  fi

  # B-CMP-ASM path (opt-in XLANG_PERF_BCMP_ASM=1).
  if [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$C_O3_MED" != "nan" ] && [ "$ASM_MED" != "nan" ]; then
    if awk -v xlang="$ASM_MED" -v c="$C_O3_MED" -v r="$C_O3_RATIO" 'BEGIN {
      slack = (r + 0 >= 0.999) ? 0.002 : 0
      exit (xlang <= c * r + slack + 0.000001) ? 0 : 1
    }'; then
      echo "perf B-CMP-ASM OK: ${name} xlang_asm -O${XLANG_BENCH_OPT} ${ASM_MED}s <= ${C_O3_RATIO}× C-O3 ${C_O3_MED}s"
    else
      echo "perf baseline OBS: ${name} xlang_asm -O${XLANG_BENCH_OPT} ${ASM_MED}s > ${C_O3_RATIO}× C-O3 ${C_O3_MED}s" >&2
      OBS=$((OBS + 1))
      PERF_BCMP_ASM_FAILS=$((PERF_BCMP_ASM_FAILS + 1))
    fi
  fi
}

echo "=== 性能基线（Xlang）==="
"$PERF_COMPILE_XLANG" "$PERF_X" -o "$OUT" 2>&1
if [ ! -f "$OUT" ]; then
  die "compile failed: no output $OUT"
fi
RUN_OK=1

echo "运行 $RUNS 次，取 real 时间："
for i in $(seq 1 "$RUNS"); do
  ( time "$OUT" ) 2>&1 | grep -E '^real' || true
done

if [ "$DO_BENCH" -eq 1 ]; then
  bench_case loop_i32 bench/r01_loop_i32
  bench_case mem_copy bench/m03_mem_copy
  bench_case struct_param bench/r10_struct_param
  bench_case call_boundary bench/a01_call_boundary
  echo "（完整说明见 analysis/archive/perf/perf-zig-baseline-v1.md；P0：r01/m03/r10/a01）"
  if [ "$PERF_FAIL_ZIG" -eq 1 ] && [ "$PERF_ZIG_FAILS" -gt 0 ]; then
    die "${PERF_ZIG_FAILS} case(s) slower than Zig -O2 (XLANG_PERF_FAIL_ON_ZIG=1)"
  fi
  if [ "$PERF_FAIL_C_O3" -eq 1 ] && [ "$STRETCH_ASM_ONLY" -eq 0 ] && [ "$PERF_C_O3_FAILS" -gt 0 ]; then
    die "${PERF_C_O3_FAILS} case(s) slower than ${C_O3_RATIO}× C -O3 (XLANG_PERF_FAIL_ON_C_O3=1)"
  fi
  if [ "$PERF_BCMP_ASM" -eq 1 ] && [ "$PERF_BCMP_ASM_FAILS" -gt 0 ]; then
    die "${PERF_BCMP_ASM_FAILS} case(s) xlang_asm slower than ${C_O3_RATIO}× C -O3 (B-CMP-ASM)"
  fi
fi

echo "=== perf baseline OK ==="
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0

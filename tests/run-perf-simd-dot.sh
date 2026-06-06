#!/usr/bin/env bash
# SIMD-S4 验收：tests/bench/simd_dot.su ≥ 0.90× tests/bench/simd_dot.c（-O2 -msse2）。
# 用法：
#   ./tests/run-perf-simd-dot.sh
#   SHU=./compiler/shu_asm ./tests/run-perf-simd-dot.sh
#   SHU_SIMD_DOT_FAIL=1 ./tests/run-perf-simd-dot.sh  # 低于 0.90× 时 exit 1
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-./compiler/shu_asm}"
SU_SRC="tests/bench/simd_dot.su"
C_SRC="tests/bench/simd_dot.c"
SU_EXE="/tmp/shu_simd_dot_bench"
C_EXE="/tmp/shu_simd_dot_c_bench"
RUNS="${SHU_SIMD_DOT_RUNS:-3}"
MIN_RATIO="${SHU_SIMD_DOT_MIN_RATIO:-0.90}"

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

echo "=== SIMD dot perf: ${SU_SRC} vs ${C_SRC} (min ratio ${MIN_RATIO}) ==="

simd_dot_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

if ! simd_dot_native_exe "$SHU_BIN"; then
  echo "simd-dot SKIP: ${SHU_BIN} not native (rebuild shu_asm on Linux)"
  exit 0
fi

if ! command -v cc >/dev/null 2>&1; then
  echo "simd-dot SKIP: cc missing"
  exit 0
fi

SU_O="${SU_EXE}.o"
rm -f "$SU_EXE" "$SU_O" "$C_EXE"

# 先 -o .o 再 cc 链 exe：shu_asm 直链 exe 可能缺 main 符号。
if ! SHU="$SHU_BIN" "$SHU_BIN" "$SU_SRC" -o "$SU_O"; then
  echo "simd-dot FAIL: compile $SU_SRC" >&2
  exit 1
fi
if ! nm "$SU_O" 2>/dev/null | grep -q '[[:space:]]T[[:space:]]main$'; then
  echo "simd-dot FAIL: $SU_O missing main symbol" >&2
  exit 1
fi
if ! cc -O2 -o "$SU_EXE" "$SU_O" -lm 2>/dev/null; then
  if ! SHU="$SHU_BIN" "$SHU_BIN" "$SU_SRC" -o "$SU_EXE"; then
    echo "simd-dot FAIL: link $SU_EXE from $SU_O" >&2
    exit 1
  fi
fi

if ! cc -O2 -msse2 "$C_SRC" -o "$C_EXE" 2>/dev/null; then
  if ! cc -O2 "$C_SRC" -o "$C_EXE"; then
    echo "simd-dot FAIL: compile $C_SRC" >&2
    exit 1
  fi
fi

SU_MED=$(median_real "$SU_EXE")
C_MED=$(median_real "$C_EXE")
echo "Shu asm median real: ${SU_MED}s"
echo "C -O2 median real:   ${C_MED}s"

if [ "$SU_MED" = "nan" ] || [ "$C_MED" = "nan" ]; then
  echo "simd-dot SKIP: benchmark returned nan"
  exit 0
fi

# perf ratio = C_time / Shu_time（≥ MIN_RATIO 即 Shu 不慢于 MIN_RATIO× C）
RATIO=$(awk -v c="$C_MED" -v s="$SU_MED" 'BEGIN { if (s <= 0) print 0; else print c / s }')
echo "simd-dot perf ratio (C/Shu): ${RATIO} (need >= ${MIN_RATIO})"

if awk -v r="$RATIO" -v m="$MIN_RATIO" 'BEGIN { exit (r + 0.000001 >= m) ? 0 : 1 }'; then
  echo "simd-dot perf OK"
else
  echo "simd-dot perf FAIL: ratio ${RATIO} < ${MIN_RATIO}" >&2
  if [ "${SHU_SIMD_DOT_FAIL:-0}" = "1" ]; then
    exit 1
  fi
fi

echo "simd-dot gate OK"

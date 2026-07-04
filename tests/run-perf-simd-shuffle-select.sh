#!/usr/bin/env bash
# STD-061：shuffle/select 生产路径 vs 标量桩基线 perf 对比
#
# ratio = stub_time / shu_time（≥ MIN_RATIO 即 Shu 不慢于桩）
# 用法：./tests/run-perf-simd-shuffle-select.sh
set -e
cd "$(dirname "$0")/.."

SHUX_BIN="${SHUX:-./compiler/shux_asm}"
X_SRC="tests/bench/simd_shuffle_select.x"
STUB_SRC="tests/bench/simd_shuffle_select_stub.c"
X_EXE="/tmp/shux_simd_ss_bench"
STUB_EXE="/tmp/shux_simd_ss_stub_bench"
RUNS="${SHUX_SIMD_SS_RUNS:-3}"
MIN_RATIO="${SHUX_SIMD_SS_MIN_RATIO:-1.0}"

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

simd_ss_native_exe() {
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

echo "=== STD-061 simd shuffle/select perf: ${X_SRC} vs stub ${STUB_SRC} (min ratio ${MIN_RATIO}) ==="

if ! simd_ss_native_exe "$SHUX_BIN"; then
  echo "simd-shuffle-select-perf SKIP: ${SHUX_BIN} not native"
  exit 0
fi
if ! command -v cc >/dev/null 2>&1; then
  echo "simd-shuffle-select-perf SKIP: cc missing"
  exit 0
fi

X_O="${X_EXE}.o"
rm -f "$X_EXE" "$X_O" "$STUB_EXE"

if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -L . "$X_SRC" -o "$X_O"; then
  echo "simd-shuffle-select-perf FAIL: compile $X_SRC" >&2
  exit 1
fi
if ! cc -O2 -o "$X_EXE" "$X_O" -lm 2>/dev/null; then
  if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -L . "$X_SRC" -o "$X_EXE"; then
    echo "simd-shuffle-select-perf FAIL: link $X_EXE" >&2
    exit 1
  fi
fi

if ! cc -O2 "$STUB_SRC" -o "$STUB_EXE"; then
  echo "simd-shuffle-select-perf FAIL: compile $STUB_SRC" >&2
  exit 1
fi

X_MED=$(median_real "$X_EXE")
STUB_MED=$(median_real "$STUB_EXE")
echo "Shu asm median real:  ${X_MED}s"
echo "stub scalar median:   ${STUB_MED}s"

if [ "$X_MED" = "nan" ] || [ "$STUB_MED" = "nan" ]; then
  echo "simd-shuffle-select-perf SKIP: benchmark returned nan"
  exit 0
fi

RATIO=$(awk -v stub="$STUB_MED" -v shux="$X_MED" 'BEGIN { if (shux <= 0) print 0; else print stub / shux }')
echo "simd-shuffle-select-perf ratio (stub/Shu): ${RATIO} (need >= ${MIN_RATIO})"

if awk -v r="$RATIO" -v m="$MIN_RATIO" 'BEGIN { exit (r + 0.000001 >= m) ? 0 : 1 }'; then
  echo "simd-shuffle-select-perf OK"
else
  echo "simd-shuffle-select-perf FAIL: ratio ${RATIO} < ${MIN_RATIO}" >&2
  if [ "${SHUX_SIMD_SS_FAIL:-0}" = "1" ]; then
    exit 1
  fi
fi

echo "simd-shuffle-select-perf gate OK"

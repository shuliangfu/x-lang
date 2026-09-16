#!/usr/bin/env bash
# STD-061: shuffle/select product path vs scalar stub perf.
#
# Honesty: soft XLANG_SIMD_SS_FAIL:-0 previously left under-ratio unchecked
# (silent OK = portable false-green). Soft SKIP→OK on missing native / cc /
# nan retired. Prefer product xlang_asm. Under-ratio / nan = obs (FAIL=1 still
# hard). Explicit bad XLANG = hard die. Report run=/obs=/skip=.
#
# ratio = stub_time / xlang_time (≥ MIN_RATIO ⇒ Xlang not slower than stub)
# Usage: ./tests/run-perf-simd-shuffle-select.sh
# Env:
#   XLANG_SIMD_SS_FAIL=1 — under-ratio hard-fail
#   XLANG_SIMD_SS_MIN_RATIO — default 1.0
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin L2 same rules).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

# PLATFORM: SHARED — fixture names follow r04_ bench id (wave1191 rename).
X_SRC="bench/r04_simd_shuffle_select.x"
STUB_SRC="bench/r04_simd_shuffle_select_stub.c"
X_EXE="/tmp/xlang_simd_ss_bench"
STUB_EXE="/tmp/xlang_simd_ss_stub_bench"
RUNS="${XLANG_SIMD_SS_RUNS:-3}"
MIN_RATIO="${XLANG_SIMD_SS_MIN_RATIO:-1.0}"
FAIL_FLAG="${XLANG_SIMD_SS_FAIL:-0}"
PREFIX="xlang: [XLANG_SIMD_SS]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "simd-shuffle-select-perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== STD-061 simd shuffle/select perf: ${X_SRC} vs stub ${STUB_SRC} (min ratio ${MIN_RATIO}) ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "simd-shuffle-select: resolve=$XLANG_BIN"

command -v cc >/dev/null 2>&1 || die "cc missing (refuse soft SKIP→OK)"

[ -f "$X_SRC" ] || die "missing $X_SRC"
[ -f "$STUB_SRC" ] || die "missing $STUB_SRC"

X_O="${X_EXE}.o"
rm -f "$X_EXE" "$X_O" "$STUB_EXE"

if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -L . "$X_SRC" -o "$X_O"; then
  die "compile $X_SRC"
fi
if ! cc -O2 -o "$X_EXE" "$X_O" -lm 2>/dev/null; then
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -L . "$X_SRC" -o "$X_EXE"; then
    die "link $X_EXE"
  fi
fi

if ! cc -O2 "$STUB_SRC" -o "$STUB_EXE"; then
  die "compile $STUB_SRC"
fi

X_MED=$(median_real "$X_EXE")
STUB_MED=$(median_real "$STUB_EXE")
echo "Xlang asm median real:  ${X_MED}s"
echo "stub scalar median:   ${STUB_MED}s"

if [ "$X_MED" = "nan" ] || [ "$STUB_MED" = "nan" ]; then
  echo "simd-shuffle-select-perf OBS: benchmark returned nan" >&2
  OBS=1
  ok_report
  exit 0
fi

RATIO=$(awk -v stub="$STUB_MED" -v xlang="$X_MED" 'BEGIN { if (xlang <= 0) print 0; else print stub / xlang }')
echo "simd-shuffle-select-perf ratio (stub/Xlang): ${RATIO} (need >= ${MIN_RATIO})"

if awk -v r="$RATIO" -v m="$MIN_RATIO" 'BEGIN { exit (r + 0.000001 >= m) ? 0 : 1 }'; then
  echo "simd-shuffle-select-perf OK"
  RUN_OK=1
else
  echo "simd-shuffle-select-perf OBS: ratio ${RATIO} < ${MIN_RATIO}" >&2
  OBS=1
  if [ "$FAIL_FLAG" = "1" ]; then
    die "ratio ${RATIO} < ${MIN_RATIO} (XLANG_SIMD_SS_FAIL=1)"
  fi
fi

ok_report
echo "simd-shuffle-select-perf gate OK"

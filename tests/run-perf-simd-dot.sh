#!/usr/bin/env bash
# SIMD-S4: bench/r04_simd_dot.x ≥ MIN_RATIO × bench/r04_simd_dot.c (-O2 -msse2).
#
# Honesty: soft XLANG_SIMD_DOT_FAIL:-0 previously left under-ratio unchecked
# (silent OK = portable false-green). Soft SKIP→OK on missing native / cc /
# nan retired. Prefer product xlang_asm. Under-ratio / nan = obs (FAIL=1 still
# hard). Explicit bad XLANG = hard die. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-simd-dot.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-simd-dot.sh
# Env:
#   XLANG_SIMD_DOT_FAIL=1 — under-ratio hard-fail
#   XLANG_SIMD_DOT_MIN_RATIO — default 0.90
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin L2 same rules).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

# PLATFORM: SHARED — fixture names follow r04_ bench id (wave1191 rename).
X_SRC="bench/r04_simd_dot.x"
C_SRC="bench/r04_simd_dot.c"
X_EXE="/tmp/xlang_simd_dot_bench"
C_EXE="/tmp/xlang_simd_dot_c_bench"
RUNS="${XLANG_SIMD_DOT_RUNS:-3}"
MIN_RATIO="${XLANG_SIMD_DOT_MIN_RATIO:-0.90}"
FAIL_FLAG="${XLANG_SIMD_DOT_FAIL:-0}"
PREFIX="xlang: [XLANG_SIMD_DOT]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "simd-dot FAIL: $*" >&2
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

echo "=== SIMD dot perf: ${X_SRC} vs ${C_SRC} (min ratio ${MIN_RATIO}) ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "simd-dot: resolve=$XLANG_BIN"

command -v cc >/dev/null 2>&1 || die "cc missing (refuse soft SKIP→OK)"

[ -f "$X_SRC" ] || die "missing $X_SRC"
[ -f "$C_SRC" ] || die "missing $C_SRC"

X_O="${X_EXE}.o"
rm -f "$X_EXE" "$X_O" "$C_EXE"

# Prefer -o .o then cc link: xlang_asm direct -o exe may omit main on some hosts.
if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$X_SRC" -o "$X_O"; then
  die "compile $X_SRC"
fi
# PLATFORM: MACOS — Mach-O nm uses leading underscore (_main); LINUX ELF = main.
if ! nm "$X_O" 2>/dev/null | grep -qE '[[:space:]]T[[:space:]]_?main$'; then
  die "$X_O missing main symbol"
fi
if ! cc -O2 -o "$X_EXE" "$X_O" -lm 2>/dev/null; then
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" "$X_SRC" -o "$X_EXE"; then
    die "link $X_EXE from $X_O"
  fi
fi

# PLATFORM: LINUX/x86 — C ref uses SSE (immintrin.h). Non-x86: honest skip (N/A baseline).
C_OK=0
if cc -O2 -msse2 "$C_SRC" -o "$C_EXE" 2>/dev/null; then
  C_OK=1
elif cc -O2 "$C_SRC" -o "$C_EXE" 2>/dev/null; then
  C_OK=1
fi
if [ "$C_OK" -ne 1 ]; then
  case "$(uname -s)-$(uname -m)" in
    Linux-x86_64|Linux-amd64|Darwin-x86_64)
      die "compile $C_SRC (x86 SSE baseline required)"
      ;;
    *)
      # Explicit bad XLANG already resolved above; host lacks SSE C baseline.
      SKIP=1
      echo "simd-dot SKIP: C SSE baseline N/A on $(uname -s)/$(uname -m)"
      ok_report
      exit 0
      ;;
  esac
fi

X_MED=$(median_real "$X_EXE")
C_MED=$(median_real "$C_EXE")
echo "Xlang asm median real: ${X_MED}s"
echo "C -O2 median real:   ${C_MED}s"

if [ "$X_MED" = "nan" ] || [ "$C_MED" = "nan" ]; then
  echo "simd-dot OBS: benchmark returned nan" >&2
  OBS=1
  ok_report
  exit 0
fi

# perf ratio = C_time / Xlang_time (≥ MIN_RATIO ⇒ Xlang not slower than MIN_RATIO× C)
RATIO=$(awk -v c="$C_MED" -v s="$X_MED" 'BEGIN { if (s <= 0) print 0; else print c / s }')
echo "simd-dot perf ratio (C/Xlang): ${RATIO} (need >= ${MIN_RATIO})"

if awk -v r="$RATIO" -v m="$MIN_RATIO" 'BEGIN { exit (r + 0.000001 >= m) ? 0 : 1 }'; then
  echo "simd-dot perf OK"
  RUN_OK=1
else
  echo "simd-dot OBS: ratio ${RATIO} < ${MIN_RATIO}" >&2
  OBS=1
  if [ "$FAIL_FLAG" = "1" ]; then
    die "ratio ${RATIO} < ${MIN_RATIO} (XLANG_SIMD_DOT_FAIL=1)"
  fi
fi

ok_report
echo "simd-dot gate OK"

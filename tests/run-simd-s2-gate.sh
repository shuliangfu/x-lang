#!/usr/bin/env bash
# SIMD-S2 gate: std.simd Vec4f/Vec8i true-link + run smoke.
# Must -o exe (not .o): compile-to-.o skips ld and false-greens UNDEF std_simd_*.
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm via dod_native_exe; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Report run=/obs=/skip=.
#
# Usage: ./tests/run-simd-s2-gate.sh
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Ubuntu x86_64 gold; Darwin same true-link path.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_S2_PREFIX:-xlang: [XLANG_SIMD_S2]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "simd-s2 gate FAIL: $*" >&2
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

echo "=== SIMD-S2: Vec4f / Vec8i true-link smoke ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

SMOKE_SRC="tests/simd/vec4f_vec8i_smoke.x"
SMOKE_EXE="/tmp/xlang_simd_s2_smoke"
rm -f "$SMOKE_EXE"
[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"

# Product CLI: -L . so import("std.simd") resolves; -o exe so ld sees UNDEF.
if ! "$XLANG_ABS" -L . "$SMOKE_SRC" -o "$SMOKE_EXE"; then
  die "compile/link $SMOKE_SRC"
fi

if [ ! -x "$SMOKE_EXE" ]; then
  die "missing exe $SMOKE_EXE"
fi

if command -v readelf >/dev/null 2>&1; then
  # readelf -S dual-line: `.text` on line 1, Size on next line col 1.
  if ! readelf -S "$SMOKE_EXE" 2>/dev/null | grep -qE '[[:space:]]\.text[[:space:]]'; then
    die "no .text in $SMOKE_EXE"
  fi
  TEXT_SIZE="$(readelf -S "$SMOKE_EXE" 2>/dev/null | awk '
    /[[:space:]]\.text[[:space:]]/ { getline; print $1; exit }
  ')"
  if [ -z "$TEXT_SIZE" ] || [ "$TEXT_SIZE" = "000000" ]; then
    die ".text size zero in $SMOKE_EXE"
  fi
  echo "simd-s2: .text present (size=$TEXT_SIZE)"
  RUN_OK=$((RUN_OK + 1))
elif command -v otool >/dev/null 2>&1; then
  if ! otool -l "$SMOKE_EXE" 2>/dev/null | grep -q '__TEXT'; then
    die "no __TEXT in $SMOKE_EXE"
  fi
  echo "simd-s2: __TEXT present (Mach-O)"
  RUN_OK=$((RUN_OK + 1))
else
  echo "simd-s2: no readelf/otool; section check observational"
  OBS=$((OBS + 1))
fi

set +e
"$SMOKE_EXE"
SMOKE_RC=$?
set -e
if [ "$SMOKE_RC" -ne 0 ]; then
  die "run exit $SMOKE_RC (expected 0)"
fi
echo "simd-s2: run=0"
RUN_OK=$((RUN_OK + 1))

echo "simd-s2 gate OK"
ok_report

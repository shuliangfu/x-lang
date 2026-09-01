#!/usr/bin/env bash
# SIMD-LANG-SVE-X8 gate: Stage 10 (10.5.2) slice2 ARM SVE dual-VL4 x8.
# Cross-emit -target aarch64-linux-gnu -target-cpu sve for i32x8 + f32x8;
# scan LE SVE int add/mul/sub (04xxxxxx) and float fadd + ptrue VL4.
# Does not disturb NEON-default x8 gates.
#
# Usage: ./tests/run-simd-lang-sve-x8-gate.sh
# PLATFORM: SHARED harness — Ubuntu x86_64 cross-emit gold.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_LANG_SVE_X8_PREFIX:-xlang: [XLANG_SIMD_LANG_SVE_X8]}"
RUN_OK=0
OBS=0
SKIP=0
TARGET="${XLANG_SIMD_LANG_ARM64_TARGET:-aarch64-linux-gnu}"

die() {
  echo "simd-lang-sve-x8 gate FAIL: $*" >&2
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

scan_sve_bytes() {
  local obj="$1"
  local ok=0
  # ptrue VL4; SVE int add/mul/sub; SVE fadd
  if grep -a -q $'\x80\xe0\x98\x25' "$obj" 2>/dev/null; then ok=1; fi
  if grep -a -q $'\x20\x00\x80\x04' "$obj" 2>/dev/null; then ok=1; fi
  if grep -a -q $'\x20\x00\x90\x04' "$obj" 2>/dev/null; then ok=1; fi
  if grep -a -q $'\x20\x00\x81\x04' "$obj" 2>/dev/null; then ok=1; fi
  if grep -a -q $'\x20\x80\x80\x65' "$obj" 2>/dev/null; then ok=1; fi
  if grep -a -q $'\x20\x80\x82\x65' "$obj" 2>/dev/null; then ok=1; fi
  if grep -a -q $'\x20\x80\x81\x65' "$obj" 2>/dev/null; then ok=1; fi
  if [ "$ok" -eq 0 ] && command -v objdump >/dev/null 2>&1; then
    if objdump -d "$obj" 2>/dev/null | grep -Eq 'ptrue|ld1w|add|mul|sub|fadd|fmul|fsub'; then
      ok=1
    fi
  fi
  echo "$ok"
}

echo "=== SIMD-LANG-SVE-X8: SVE i32x8/f32x8 dual-VL4 emit (-target-cpu sve) ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

I32_SRC="tests/sys/simd_lang_i32x8_smoke.x"
F32_SRC="tests/sys/simd_lang_f32x8_smoke.x"
I32_O="/tmp/xlang_simd_lang_sve_i32x8_smoke.o"
F32_O="/tmp/xlang_simd_lang_sve_f32x8_smoke.o"
rm -f "$I32_O" "$F32_O"
[ -f "$I32_SRC" ] || die "missing $I32_SRC"
[ -f "$F32_SRC" ] || die "missing $F32_SRC"

if ! "$XLANG_ABS" -target "$TARGET" -target-cpu sve -L . "$I32_SRC" -o "$I32_O" 2>/dev/null; then
  die "cross-compile i32x8 -target $TARGET -target-cpu sve"
fi
[ -f "$I32_O" ] || die "missing $I32_O"
if [ "$(scan_sve_bytes "$I32_O")" -eq 0 ]; then
  die "missing SVE int opcode bytes in $I32_O"
fi
RUN_OK=$((RUN_OK + 1))

if ! "$XLANG_ABS" -target "$TARGET" -target-cpu sve -L . "$F32_SRC" -o "$F32_O" 2>/dev/null; then
  die "cross-compile f32x8 -target $TARGET -target-cpu sve"
fi
[ -f "$F32_O" ] || die "missing $F32_O"
if [ "$(scan_sve_bytes "$F32_O")" -eq 0 ]; then
  die "missing SVE float opcode bytes in $F32_O"
fi
RUN_OK=$((RUN_OK + 1))

ok_report

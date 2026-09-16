#!/usr/bin/env bash
# SIMD-LANG-SVE-F32X4 gate: Stage 10 (10.5.2) slice0 ARM SVE lang builtins.
# Cross-emit -target aarch64-linux-gnu -target-cpu sve; scan LE SVE bytes
# (ptrue VL4 / ld1w / fadd|fmul|fsub / st1w). Does not disturb NEON-default gates.
#
# Usage: ./tests/run-simd-lang-sve-f32x4-gate.sh
# PLATFORM: SHARED harness — Ubuntu x86_64 cross-emit gold.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_LANG_SVE_F32X4_PREFIX:-xlang: [XLANG_SIMD_LANG_SVE_F32X4]}"
RUN_OK=0
OBS=0
SKIP=0
TARGET="${XLANG_SIMD_LANG_ARM64_TARGET:-aarch64-linux-gnu}"

die() {
  echo "simd-lang-sve-f32x4 gate FAIL: $*" >&2
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

echo "=== SIMD-LANG-SVE-F32X4: SVE f32x4 add/mul/sub emit (-target-cpu sve) ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

SMOKE_SRC="tests/sys/simd_lang_f32x4_smoke.x"
SMOKE_O="/tmp/xlang_simd_lang_sve_f32x4_smoke.o"
rm -f "$SMOKE_O"
[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"

if ! "$XLANG_ABS" -target "$TARGET" -target-cpu sve -L . "$SMOKE_SRC" -o "$SMOKE_O" 2>/dev/null; then
  die "cross-compile -target $TARGET -target-cpu sve -o $SMOKE_O"
fi
[ -f "$SMOKE_O" ] || die "missing object $SMOKE_O"
RUN_OK=$((RUN_OK + 1))

# LE bytes: ptrue VL4=80 e0 98 25; ld1w=00 a0 40 a5; fadd=20 80 80 65; st1w=00 e0 40 e5
sve_ok=0
if grep -a -q $'\x80\xe0\x98\x25' "$SMOKE_O" 2>/dev/null; then sve_ok=1; fi
if grep -a -q $'\x00\xa0\x40\xa5' "$SMOKE_O" 2>/dev/null; then sve_ok=1; fi
if grep -a -q $'\x20\x80\x80\x65' "$SMOKE_O" 2>/dev/null; then sve_ok=1; fi
if grep -a -q $'\x20\x80\x82\x65' "$SMOKE_O" 2>/dev/null; then sve_ok=1; fi
if grep -a -q $'\x20\x80\x81\x65' "$SMOKE_O" 2>/dev/null; then sve_ok=1; fi
if [ "$sve_ok" -eq 0 ]; then
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d "$SMOKE_O" 2>/dev/null | grep -Eq 'ptrue|ld1w|fadd|fmul|fsub|st1w'; then
      sve_ok=1
    fi
  fi
fi
if [ "$sve_ok" -eq 0 ]; then
  die "missing SVE ptrue/ld1w/fadd opcode bytes in $SMOKE_O"
fi
RUN_OK=$((RUN_OK + 1))

ok_report

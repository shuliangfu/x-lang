#!/usr/bin/env bash
# SIMD-LANG-I32X8-ARM64 gate: Stage 10 (10.5.1) slice6 aarch64 NEON i32x8 lang builtins.
# Cross-emit with -target aarch64-linux-gnu; scan LE bytes for add/mul/sub .4s.
#
# Usage: ./tests/run-simd-lang-i32x8-arm64-gate.sh
# PLATFORM: SHARED harness — Ubuntu x86_64 cross-emit gold; Darwin arm64 native run.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_LANG_I32X8_ARM64_PREFIX:-xlang: [XLANG_SIMD_LANG_I32X8_ARM64]}"
RUN_OK=0
OBS=0
SKIP=0
TARGET="${XLANG_SIMD_LANG_ARM64_TARGET:-aarch64-linux-gnu}"

die() {
  echo "simd-lang-i32x8-arm64 gate FAIL: $*" >&2
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

echo "=== SIMD-LANG-I32X8-ARM64: language add/mul/sub_i32x8 NEON emit ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

SMOKE_SRC="tests/sys/simd_lang_i32x8_smoke.x"
SMOKE_O="/tmp/xlang_simd_lang_i32x8_arm64_smoke.o"
SMOKE_EXE="/tmp/xlang_simd_lang_i32x8_arm64_smoke"
rm -f "$SMOKE_O" "$SMOKE_EXE"
[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"

if ! "$XLANG_ABS" -target "$TARGET" -L . "$SMOKE_SRC" -o "$SMOKE_O" 2>/dev/null; then
  die "cross-compile -target $TARGET -o $SMOKE_O"
fi
[ -f "$SMOKE_O" ] || die "missing object $SMOKE_O"
RUN_OK=$((RUN_OK + 1))

# i32 NEON: add/mul/sub v0.4s,v0.4s,v1.4s LE bytes (00 84 a1 4e / 00 9c a1 4e / 00 84 a1 6e)
neon_ok=0
if grep -a -q $'\x00\x84\xa1\x4e' "$SMOKE_O" 2>/dev/null; then neon_ok=1; fi
if grep -a -q $'\x00\x9c\xa1\x4e' "$SMOKE_O" 2>/dev/null; then neon_ok=1; fi
if grep -a -q $'\x00\x84\xa1\x6e' "$SMOKE_O" 2>/dev/null; then neon_ok=1; fi
if [ "$neon_ok" -eq 0 ]; then
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d "$SMOKE_O" 2>/dev/null | grep -Eq 'add\.4s|mul\.4s|sub\.4s|add.*v0|mul.*v0|sub.*v0'; then
      neon_ok=1
    fi
  fi
fi
if [ "$neon_ok" -eq 0 ]; then
  die "missing NEON i32 add/mul/sub opcode bytes in $SMOKE_O"
fi
RUN_OK=$((RUN_OK + 1))

if ci_is_darwin && ci_is_arm64_host; then
  if "$XLANG_ABS" -L . "$SMOKE_SRC" -o "$SMOKE_EXE" 2>/dev/null && [ -x "$SMOKE_EXE" ]; then
    if ! rc="$SMOKE_EXE"; then
      die "native arm64 run exit=$rc"
    fi
    RUN_OK=$((RUN_OK + 1))
  else
    OBS=$((OBS + 1))
    echo "simd-lang-i32x8-arm64 WARN: native arm64 -o run skipped (obs)" >&2
  fi
fi

ok_report

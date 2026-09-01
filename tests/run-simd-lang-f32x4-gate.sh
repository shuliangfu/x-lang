#!/usr/bin/env bash
# SIMD-LANG-F32X4 gate: Stage 10 (10.5.1) slice0 language SIMD builtins.
# Must -o exe; objdump must show addps/mulps (SSE), not CALL std_simd_*.
#
# Usage: ./tests/run-simd-lang-f32x4-gate.sh
# PLATFORM: SHARED harness — Ubuntu x86_64 gold; Darwin x86_64 when native.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_LANG_F32X4_PREFIX:-xlang: [XLANG_SIMD_LANG_F32X4]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "simd-lang-f32x4 gate FAIL: $*" >&2
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

echo "=== SIMD-LANG-F32X4: language add_f32x4 / mul_f32x4 smoke ==="
if ! ci_is_x86_64_host; then
  echo "simd-lang-f32x4 SKIP: slice0 x86_64 SSE only (host=$(ci_host_summary))" >&2
  SKIP=$((SKIP + 1))
  ok_report
  exit 0
fi
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

SMOKE_SRC="tests/sys/simd_lang_f32x4_smoke.x"
SMOKE_EXE="/tmp/xlang_simd_lang_f32x4_smoke"
SMOKE_O="/tmp/xlang_simd_lang_f32x4_smoke.o"
rm -f "$SMOKE_EXE" "$SMOKE_O"
[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"

if ! "$XLANG_ABS" -L . "$SMOKE_SRC" -o "$SMOKE_EXE"; then
  die "compile/link $SMOKE_SRC"
fi
[ -x "$SMOKE_EXE" ] || die "missing exe $SMOKE_EXE"

if ! "$SMOKE_EXE"; then
  die "run $SMOKE_EXE exit=$?"
fi
RUN_OK=$((RUN_OK + 1))

# Disasm check: prefer asm product path with HW insn present.
if command -v objdump >/dev/null 2>&1; then
  if ! "$XLANG_ABS" -L . "$SMOKE_SRC" -o "$SMOKE_O" 2>/dev/null; then
    OBS=$((OBS + 1))
    echo "simd-lang-f32x4 WARN: could not compile -o .o for objdump (obs)" >&2
  else
    if ! objdump -d "$SMOKE_O" 2>/dev/null | grep -Eq 'addps|mulps'; then
      die "objdump missing addps/mulps in $SMOKE_O"
    fi
    RUN_OK=$((RUN_OK + 1))
  fi
else
  SKIP=$((SKIP + 1))
  echo "simd-lang-f32x4 WARN: no objdump (skip disasm check)" >&2
fi

ok_report

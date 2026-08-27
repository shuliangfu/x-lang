#!/usr/bin/env bash
# SIMD-S4 gate: shuffle (pshufd) + select (pcmpgtd/pand/por); no objdump → compile smoke.
#
# Honesty: soft SKIP→OK when no native xlang retired; prefer-c / force -backend c
# on non-x86 (BLD001 host-cc-requires-allow false-red) retired — product asm -o.
# Prefer xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. Missing HW insn (non-strict / non-x86) = obs. Report run=/obs=/skip=.
#
# Usage: ./tests/run-simd-s4-gate.sh
# 2026-08-27: soft SKIP→OK / prefer-c →硬绿.
# PLATFORM: SHARED — Ubuntu x86_64 hard HW; Darwin/ARM observational HW.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_S4_PREFIX:-xlang: [XLANG_SIMD_S4]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "simd-s4 gate FAIL: $*" >&2
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

hw_check() {
  local disasm="$1" re="$2" label="$3" obj="$4"
  if echo "$disasm" | grep -qE "$re"; then
    echo "simd-s4: $label"
    RUN_OK=$((RUN_OK + 1))
  elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
    die "no match /$re/ in $obj ($label)"
  else
    echo "simd-s4 WARN: no match /$re/ in $label (obs)"
    OBS=$((OBS + 1))
  fi
}

echo "=== SIMD-S4: comptime shuffle + select smoke ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

VEC4F_SRC="tests/simd/vec4f_shuffle_smoke.x"
VEC8I_SRC="tests/simd/vec8i_shuffle_smoke.x"
VEC8I_SEL_SRC="tests/simd/vec8i_select_smoke.x"
VEC4F_SEL_SRC="tests/simd/vec4f_select_smoke.x"
AT_SRC="tests/simd/at_builtin_smoke.x"
DOT_SRC="bench/r04_simd_dot.x"
VEC4F_O="/tmp/xlang_simd_s4_vec4f.o"
VEC8I_O="/tmp/xlang_simd_s4_vec8i.o"
VEC8I_SEL_O="/tmp/xlang_simd_s4_vec8i_sel.o"
VEC4F_SEL_O="/tmp/xlang_simd_s4_vec4f_sel.o"
AT_O="/tmp/xlang_simd_s4_at.o"
DOT_O="/tmp/xlang_simd_s4_dot.o"
rm -f "$VEC4F_O" "$VEC8I_O" "$VEC8I_SEL_O" "$VEC4F_SEL_O" "$AT_O" "$DOT_O"

ARCH="$(uname -m 2>/dev/null || echo unknown)"

# Product asm -o *.o on all hosts. Prior -backend c on non-x86 hit BLD001
# host-cc-requires-allow (portable false-red). PLATFORM: SHARED.
simd_s4_compile() {
  local src="$1"
  local out="$2"
  [ -f "$src" ] || die "missing $src"
  "$XLANG_ABS" "$src" -o "$out"
}

for pair in \
  "$VEC4F_SRC|$VEC4F_O" \
  "$VEC8I_SRC|$VEC8I_O" \
  "$VEC8I_SEL_SRC|$VEC8I_SEL_O" \
  "$VEC4F_SEL_SRC|$VEC4F_SEL_O" \
  "$AT_SRC|$AT_O" \
  "$DOT_SRC|$DOT_O"
do
  src="${pair%%|*}"
  obj="${pair##*|}"
  if ! simd_s4_compile "$src" "$obj"; then
    die "compile $src"
  fi
  RUN_OK=$((RUN_OK + 1))
done

if [ ! -f "$VEC4F_O" ] || [ ! -f "$VEC8I_O" ] || [ ! -f "$VEC8I_SEL_O" ] || [ ! -f "$VEC4F_SEL_O" ] || [ ! -f "$AT_O" ] || [ ! -f "$DOT_O" ]; then
  die "missing object file"
fi

if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
  if command -v objdump >/dev/null 2>&1; then
    V4_DISAS="$(objdump -d "$VEC4F_O" 2>/dev/null || true)"
    V8_DISAS="$(objdump -d "$VEC8I_O" 2>/dev/null || true)"
    V8_SEL_DISAS="$(objdump -d "$VEC8I_SEL_O" 2>/dev/null || true)"
    V4_SEL_DISAS="$(objdump -d "$VEC4F_SEL_O" 2>/dev/null || true)"
    hw_check "$V4_DISAS" 'pshufd' 'vec4f_shuffle pshufd insn present' "$VEC4F_O"
    hw_check "$V8_DISAS" 'vpshufd|pshufd' 'vec8i_shuffle vpshufd/pshufd insn present' "$VEC8I_O"
    hw_check "$V8_SEL_DISAS" 'pcmpgtd|vpcmpgtd' 'vec8i_select pcmpgtd/vpcmpgtd insn present' "$VEC8I_SEL_O"
    # cmpps $6 / cmpnleps is the SSE mnemonic for cmpgtps (0F C2 /r /6).
    hw_check "$V4_SEL_DISAS" 'cmpgtps|vcmpgtps|cmpnleps|cmpps' 'vec4f_select cmpgtps/cmpnleps insn present' "$VEC4F_SEL_O"
  else
    echo "simd-s4: objdump missing; compile-only observational"
    OBS=$((OBS + 1))
  fi
else
  echo "simd-s4: non-x86_64 host ($ARCH)"
  if command -v otool >/dev/null 2>&1; then
    V4_DISAS="$(otool -tV "$VEC4F_O" 2>/dev/null || true)"
    V8_DISAS="$(otool -tV "$VEC8I_O" 2>/dev/null || true)"
    V8_SEL_DISAS="$(otool -tV "$VEC8I_SEL_O" 2>/dev/null || true)"
    V4_SEL_DISAS="$(otool -tV "$VEC4F_SEL_O" 2>/dev/null || true)"
    # Non-x86 HW is observational unless XLANG_SIMD_HW_STRICT=1 (parent std-simd
    # shuffle-select sets STRICT only on x86_64).
    hw_check "$V4_DISAS" 'mov\.s|ld1\.4s' 'vec4f_shuffle NEON ins/ld1 present' "$VEC4F_O"
    hw_check "$V8_DISAS" 'mov\.s|ld1\.4s' 'vec8i_shuffle NEON ins/ld1 present' "$VEC8I_O"
    hw_check "$V8_SEL_DISAS" 'cmgt|bsl\.16b|bit\.16b' 'vec8i_select cmgt/bsl present' "$VEC8I_SEL_O"
    hw_check "$V4_SEL_DISAS" 'fcmgt|bit\.16b' 'vec4f_select fcmgt/bit present' "$VEC4F_SEL_O"
  else
    echo "simd-s4: compile-only OK (otool missing; obs)"
    OBS=$((OBS + 1))
  fi
fi

echo "simd-s4 gate OK"
ok_report

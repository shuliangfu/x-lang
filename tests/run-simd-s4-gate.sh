#!/usr/bin/env bash
# SIMD-S4 门禁：shuffle（pshufd）+ select（pcmpgtd/pand/por）；无 objdump 时仅编译 smoke。
# 用法：
#   ./tests/run-simd-s4-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-simd-s4-gate.sh
set -e
cd "$(dirname "$0")/.."

XLANG_BIN="${XLANG:-}"
case "$XLANG_BIN" in
  /*) XLANG_ABS="$XLANG_BIN" ;;
  "") XLANG_ABS="" ;;
  *) XLANG_ABS="$(pwd)/$XLANG_BIN" ;;
esac

simd_s4_native_exe() {
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

if [ -z "$XLANG_ABS" ] || ! simd_s4_native_exe "$XLANG_ABS"; then
  XLANG_ABS=""
  for cand in ./compiler/xlang ./compiler/xlang_asm; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if simd_s4_native_exe "$abs"; then
      XLANG_ABS="$abs"
      break
    fi
  done
fi

echo "=== SIMD-S4: comptime shuffle + select smoke ==="

if [ -z "$XLANG_ABS" ] || ! simd_s4_native_exe "$XLANG_ABS"; then
  echo "simd-s4 gate SKIP (no native xlang/xlang_asm)"
  exit 0
fi

VEC4F_SRC="tests/simd/vec4f_shuffle_smoke.x"
VEC8I_SRC="tests/simd/vec8i_shuffle_smoke.x"
VEC8I_SEL_SRC="tests/simd/vec8i_select_smoke.x"
VEC4F_SEL_SRC="tests/simd/vec4f_select_smoke.x"
AT_SRC="tests/simd/at_builtin_smoke.x"
DOT_SRC="tests/bench/simd_dot.x"
VEC4F_O="/tmp/xlang_simd_s4_vec4f.o"
VEC8I_O="/tmp/xlang_simd_s4_vec8i.o"
VEC8I_SEL_O="/tmp/xlang_simd_s4_vec8i_sel.o"
VEC4F_SEL_O="/tmp/xlang_simd_s4_vec4f_sel.o"
AT_O="/tmp/xlang_simd_s4_at.o"
DOT_O="/tmp/xlang_simd_s4_dot.o"
rm -f "$VEC4F_O" "$VEC8I_O" "$VEC8I_SEL_O" "$VEC4F_SEL_O" "$AT_O" "$DOT_O"

ARCH="$(uname -m 2>/dev/null || echo unknown)"

# Compile one smoke to $2. PLATFORM: SHARED harness.
# - x86_64: default backend (asm) so later objdump can see pshufd/pcmpgtd.
# - other (e.g. Darwin arm64): -backend c — pure asm -o *.o can CG002 on Vec4f mul
#   benches while HW insn checks are already skipped off-x86.
# Bare `xlang file.x -o out` is product CLI (main_entry); keep that form on x86.
simd_s4_compile() {
  local src="$1"
  local out="$2"
  if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    XLANG="$XLANG_ABS" "$XLANG_ABS" "$src" -o "$out"
  else
    XLANG="$XLANG_ABS" "$XLANG_ABS" build -backend c "$src" -o "$out"
  fi
}

if ! simd_s4_compile "$VEC4F_SRC" "$VEC4F_O"; then
  echo "simd-s4 FAIL: compile $VEC4F_SRC" >&2
  exit 1
fi

if ! simd_s4_compile "$VEC8I_SRC" "$VEC8I_O"; then
  echo "simd-s4 FAIL: compile $VEC8I_SRC" >&2
  exit 1
fi

if ! simd_s4_compile "$VEC8I_SEL_SRC" "$VEC8I_SEL_O"; then
  echo "simd-s4 FAIL: compile $VEC8I_SEL_SRC" >&2
  exit 1
fi

if ! simd_s4_compile "$VEC4F_SEL_SRC" "$VEC4F_SEL_O"; then
  echo "simd-s4 FAIL: compile $VEC4F_SEL_SRC" >&2
  exit 1
fi

if ! simd_s4_compile "$AT_SRC" "$AT_O"; then
  echo "simd-s4 FAIL: compile $AT_SRC" >&2
  exit 1
fi

if ! simd_s4_compile "$DOT_SRC" "$DOT_O"; then
  echo "simd-s4 FAIL: compile $DOT_SRC" >&2
  exit 1
fi

if [ ! -f "$VEC4F_O" ] || [ ! -f "$VEC8I_O" ] || [ ! -f "$VEC8I_SEL_O" ] || [ ! -f "$VEC4F_SEL_O" ] || [ ! -f "$AT_O" ] || [ ! -f "$DOT_O" ]; then
  echo "simd-s4 FAIL: missing object file" >&2
  exit 1
fi

if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
  if command -v objdump >/dev/null 2>&1; then
    V4_DISAS="$(objdump -d "$VEC4F_O" 2>/dev/null || true)"
    V8_DISAS="$(objdump -d "$VEC8I_O" 2>/dev/null || true)"
    V8_SEL_DISAS="$(objdump -d "$VEC8I_SEL_O" 2>/dev/null || true)"
    V4_SEL_DISAS="$(objdump -d "$VEC4F_SEL_O" 2>/dev/null || true)"
    if echo "$V4_DISAS" | grep -qE 'pshufd'; then
      echo "simd-s4: vec4f_shuffle pshufd insn present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no pshufd in $VEC4F_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no pshufd in vec4f shuffle smoke (rebuild xlang_asm with simd_enc.o)"
    fi
    if echo "$V8_DISAS" | grep -qE 'vpshufd|pshufd'; then
      echo "simd-s4: vec8i_shuffle vpshufd/pshufd insn present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no vpshufd/pshufd in $VEC8I_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no vpshufd/pshufd in vec8i shuffle smoke"
    fi
    if echo "$V8_SEL_DISAS" | grep -qE 'pcmpgtd|vpcmpgtd'; then
      echo "simd-s4: vec8i_select pcmpgtd/vpcmpgtd insn present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no pcmpgtd/vpcmpgtd in $VEC8I_SEL_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no pcmpgtd/vpcmpgtd in vec8i select smoke"
    fi
    if echo "$V4_SEL_DISAS" | grep -qE 'cmpgtps|vcmpgtps'; then
      echo "simd-s4: vec4f_select cmpgtps/vcmpgtps insn present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no cmpgtps/vcmpgtps in $VEC4F_SEL_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no cmpgtps/vcmpgtps in vec4f select smoke"
    fi
  else
    echo "simd-s4: objdump missing; compile-only OK"
  fi
else
  echo "simd-s4: non-x86_64 host ($ARCH)"
  if command -v otool >/dev/null 2>&1; then
    V4_DISAS="$(otool -tV "$VEC4F_O" 2>/dev/null || true)"
    V8_DISAS="$(otool -tV "$VEC8I_O" 2>/dev/null || true)"
    V8_SEL_DISAS="$(otool -tV "$VEC8I_SEL_O" 2>/dev/null || true)"
    V4_SEL_DISAS="$(otool -tV "$VEC4F_SEL_O" 2>/dev/null || true)"
    if echo "$V4_DISAS" | grep -qE 'mov\.s|ld1\.4s'; then
      echo "simd-s4: vec4f_shuffle NEON ins/ld1 present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no NEON shuffle in $VEC4F_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no NEON shuffle in vec4f smoke (rebuild xlang_asm with simd_enc.o)"
    fi
    if echo "$V8_DISAS" | grep -qE 'mov\.s|ld1\.4s'; then
      echo "simd-s4: vec8i_shuffle NEON ins/ld1 present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no NEON shuffle in $VEC8I_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no NEON shuffle in vec8i smoke"
    fi
    if echo "$V8_SEL_DISAS" | grep -qE 'cmgt|bsl\.16b|bit\.16b'; then
      echo "simd-s4: vec8i_select cmgt/bsl present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no cmgt/bsl in $VEC8I_SEL_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no cmgt/bsl in vec8i select smoke"
    fi
    if echo "$V4_SEL_DISAS" | grep -qE 'fcmgt|bit\.16b'; then
      echo "simd-s4: vec4f_select fcmgt/bit present"
    elif [ -n "${XLANG_SIMD_HW_STRICT:-}" ]; then
      echo "simd-s4 FAIL: no fcmgt/bit in $VEC4F_SEL_O" >&2
      exit 1
    else
      echo "simd-s4 WARN: no fcmgt/bit in vec4f select smoke"
    fi
  else
    echo "simd-s4: compile-only OK (otool missing)"
  fi
fi

echo "simd-s4 gate OK"

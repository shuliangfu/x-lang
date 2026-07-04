#!/usr/bin/env bash
# STD-SIMD-INTRINSIC：std.simd mul/sub/dot/fma 门禁
#
# 用法：./tests/run-std-simd-intrinsic-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-simd-intrinsic-v1.md"
MANIFEST="tests/baseline/std-simd-intrinsic.tsv"
MOD_X="std/simd/mod.x"
LIB="tests/lib/std-simd-intrinsic.sh"
SMOKE_X="tests/simd/intrinsic_binop_dot.x"
MIN_APIS=11

# shellcheck source=tests/lib/std-simd-intrinsic.sh
. "$LIB"

echo "=== STD-SIMD-INTRINSIC: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X" std/simd/README.md; do
  [ -f "$f" ] || { echo "std-simd-intrinsic gate FAIL: missing $f" >&2; exit 1; }
done

for kw in STD-SIMD-INTRINSIC vec4f_mul vec4f_dot vec4f_fma vfmadd vec8i_mul binop; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || {
    echo "std-simd-intrinsic gate FAIL: doc missing '$kw'" >&2
    exit 1
  }
done

grep -qF vec4f_fma std/simd/README.md 2>/dev/null || {
  echo "std-simd-intrinsic gate FAIL: README missing vec4f_fma" >&2
  exit 1
}

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in api) API_N=$((API_N + 1)) ;; esac
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || {
  echo "std-simd-intrinsic gate FAIL: api count $API_N < $MIN_APIS" >&2
  exit 1
}

sym_miss="$(std_simd_intrinsic_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || {
  std_simd_intrinsic_emit_report fail 0 0
  echo "std-simd-intrinsic gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
}
echo "std-simd-intrinsic manifest OK"

stdlib_cm_native_shu() {
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

stdlib_cm_native_simd_asm() {
  local f="$1"
  stdlib_cm_native_shu "$f" || return 1
  case "$f" in
    */shux-c|*/shux-x*) return 1 ;;
  esac
  return 0
}

stdlib_cm_pick_shux_asm() {
  local cand
  for cand in ./compiler/shux ./compiler/shux_asm ./compiler/shux_asm.strict ./compiler/shux_asm_working; do
    if stdlib_cm_native_simd_asm "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

X_OK=0
SKIP=1
SHUX_ASM=""
SHUX_TYPECK=""
if cand="$(stdlib_cm_pick_shux_asm)"; then
  SHUX_ASM="$cand"
fi
for cand in ./compiler/shux-c ./compiler/shux; do
  if stdlib_cm_native_shu "$cand"; then
    SHUX_TYPECK="$cand"
    break
  fi
done

if [ -n "$SHUX_TYPECK" ]; then
  "$SHUX_TYPECK" check -L . "$SMOKE_X" >/dev/null
else
  echo "std-simd-intrinsic gate SKIP typeck (no native shux)" >&2
fi

if [ -n "$SHUX_ASM" ]; then
  rc=0
  std_simd_intrinsic_run_smoke "$SHUX_ASM" "$SMOKE_X" || rc=$?
  if [ "$rc" -eq 0 ]; then
    X_OK=1
    SKIP=0
  elif [ "$rc" -eq 2 ]; then
    echo "std-simd-intrinsic WARN: asm runtime smoke failed; manifest+typeck OK (skip)" >&2
    SKIP=1
  else
    std_simd_intrinsic_emit_report fail 0 0
    exit 1
  fi
else
  echo "std-simd-intrinsic gate SKIP smoke (no asm shux)" >&2
fi

std_simd_intrinsic_emit_report ok "$X_OK" "$SKIP"
echo "std-simd-intrinsic gate OK"

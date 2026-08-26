#!/usr/bin/env bash
# STD-SIMD-INTRINSIC：std.simd mul/sub/dot/fma 门禁（假权威诚实）。
#
# 用法：./tests/run-std-simd-intrinsic-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); intrinsic_binop_dot.x exit 0 hard-fail
# (no soft SKIP when native xlang present; smoke helper no longer swallows
# run≠0). Report check=/x=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang / soft SKIP on asm smoke fail / ## 3. 验证与门禁).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="analysis/archive/std/std-simd-intrinsic-v1.md"
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

# Product names are overload mul/dot/fma. Historical vec4f_mul is not a second export.
for kw in STD-SIMD-INTRINSIC mul dot fma vfmadd binop; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || {
    echo "std-simd-intrinsic gate FAIL: doc missing '$kw'" >&2
    exit 1
  }
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-simd-intrinsic gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

grep -qF fma std/simd/README.md 2>/dev/null || {
  echo "std-simd-intrinsic gate FAIL: README missing fma" >&2
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
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-simd-intrinsic gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || {
  echo "std-simd-intrinsic gate FAIL: api count $API_N < $MIN_APIS" >&2
  exit 1
}

sym_miss="$(std_simd_intrinsic_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || {
  std_simd_intrinsic_emit_report fail 0 0 0
  echo "std-simd-intrinsic gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
}
echo "std-simd-intrinsic manifest OK"

if [ "${XLANG_STD_SIMD_INTRINSIC_MANIFEST_ONLY:-0}" = "1" ]; then
  std_simd_intrinsic_emit_report ok 0 0 1
  echo "std-simd-intrinsic gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # SIMD Vec bodies need asm backend (xlang-c cannot emit C for Vec).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      case "$cand" in
        */xlang-c|*/xlang-x*) continue ;;
      esac
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
X_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-SIMD-INTRINSIC: smoke (XLANG=$XLANG_BIN; check observational; x hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-simd-intrinsic gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_simd_intrinsic_run_smoke "$XLANG_BIN" "$SMOKE_X" "binop"; then
    X_OK=1
    SKIP=0
  else
    std_simd_intrinsic_emit_report fail "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-simd-intrinsic gate FAIL: no native asm xlang" >&2
  std_simd_intrinsic_emit_report fail 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is x=.
echo "std-simd-intrinsic check_ok=${CHECK_OK} (observational)"
std_simd_intrinsic_emit_report ok "$CHECK_OK" "$X_OK" "$SKIP"
echo "std-simd-intrinsic gate OK"

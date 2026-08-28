#!/usr/bin/env bash
# STD-SIMD-INTRINSIC: std.simd mul/sub/dot/fma gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + check=/x=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native asm = hard die (refuse
# soft SKIP→OK / soft auto-make / prefer-c). Product intrinsic_binop_dot.x -o
# exit0 = hard run (run=1). check = obs. Report: run=/obs=/skip=.
# SIMD Vec bodies need asm backend (skip xlang-c).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-simd-intrinsic-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-simd-intrinsic gate FAIL: $*" >&2
  std_simd_intrinsic_emit_report fail "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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
      case "$abs" in
        */xlang-c|*/xlang-x*) return 1 ;;
      esac
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c / xlang-c (no Vec emit).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-simd-intrinsic-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-SIMD-INTRINSIC: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X" std/simd/README.md; do
  [ -f "$f" ] || die "missing $f"
done

# Product names are overload mul/dot/fma. Historical vec4f_mul is not a second export.
for kw in STD-SIMD-INTRINSIC mul dot fma vfmadd binop; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"
grep -qF fma std/simd/README.md 2>/dev/null || die "README missing fma"

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
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < $MIN_APIS"

sym_miss="$(std_simd_intrinsic_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-simd-intrinsic manifest OK"

if [ "${XLANG_STD_SIMD_INTRINSIC_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_simd_intrinsic_emit_report ok "$RUN_OK" "$OBS" "$SKIP"
  echo "std-simd-intrinsic gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-SIMD-INTRINSIC: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_simd_intrinsic_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-simd-intrinsic OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

if std_simd_intrinsic_run_smoke "$XLANG_BIN" "$SMOKE_X" "binop"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-simd-intrinsic OK: intrinsic_binop_dot"
else
  die "intrinsic_binop_dot.x exit!=0 (refuse soft SKIP→OK)"
fi

std_simd_intrinsic_emit_report ok "$RUN_OK" "$OBS" "$SKIP"
echo "std-simd-intrinsic gate OK"

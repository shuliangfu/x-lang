#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe rebuilds runtime_math_libm.o from cold seed
# only — 9.1 hollowed cold public wrappers, so math.o UNDEFs math_sqrt_c /
# math_tan_c / math_trunc_c. Prefer thin.x + FROM_X rest; smoke-gate
# (tip Cap asm currently miscompiles fdlibm sqrt/tan). Fallback: cold seed
# cc without FROM_X (restored bit-level / fdlibm twins in seed — not a new
# host-cc .c). No FORCE_CC. PLATFORM: SHARED — nm accepts optional Mach-O underscore; smoke links -lm (Linux).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

out=runtime_math_libm.o
x_src=src/asm/runtime_math_libm.x
seed=seeds/runtime_math_libm.from_x.c

_smoke_ok() {
  local o="$1" bin probe
  bin="$(mktemp "${TMPDIR:-/tmp}/cap_tip_math_smoke.XXXXXX")"
  probe="$(mktemp "${TMPDIR:-/tmp}/cap_tip_math_probe.XXXXXX.c")"
  cat > "$probe" <<'C'
#include <stdio.h>
double math_sqrt_c(double);
double math_trunc_c(double);
double math_tan_c(double);
int main(void) {
  if (math_sqrt_c(4.0) != 2.0) return 1;
  if (math_sqrt_c(9.0) != 3.0) return 2;
  if (math_trunc_c(2.3) != 2.0) return 3;
  if (math_tan_c(0.0) != 0.0) return 4;
  return 0;
}
C
  if ! cc -o "$bin" "$probe" "$o" -lm 2>/dev/null; then
    rm -f "$bin" "$probe"
    return 1
  fi
  set +e
  "$bin" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$bin" "$probe"
  [ "$ec" = "0" ]
}

need_rebuild=0
if [ ! -s "$out" ]; then
  need_rebuild=1
else
  for s in math_sqrt_c math_tan_c math_trunc_c; do
    if ! nm -gU "$out" 2>/dev/null | grep -qE "T _?${s}\$"; then
      need_rebuild=1
      break
    fi
  done
  if [ "$need_rebuild" = "0" ] && ! _smoke_ok "$out"; then
    need_rebuild=1
  fi
fi
if [ "$need_rebuild" = "0" ]; then
  echo "cap_tip_ensure_math: $out already has smoke-ok public math_*_c" >&2
  exit 0
fi

[ -f "$seed" ] || { echo "cap_tip_ensure_math: missing $seed" >&2; exit 1; }

_xl=""
if [ -x ./xlang.product_legacy_bak ]; then
  _xl=./xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  _xl="$XLANG"
elif [ -x ./xlang ]; then
  _xl=./xlang
fi

thin_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_math_thin.XXXXXX.o")"
rest_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_math_rest.XXXXXX.o")"
cold_o="$(mktemp "${TMPDIR:-/tmp}/cap_tip_math_cold.XXXXXX.o")"
cleanup() { rm -f "$thin_o" "$rest_o" "$cold_o"; }
trap cleanup EXIT

merged=0
if [ -n "$_xl" ] && [ -f "$x_src" ]; then
  if XLANG_PREFER_ASM_O=1 "$_xl" -backend asm -c "$x_src" -o "$thin_o" 2>/dev/null \
    && nm -gU "$thin_o" 2>/dev/null | grep -qE 'T _?math_sqrt_c$' \
    && cc -c -I. -Iinclude -Isrc -Isrc/asm -DXLANG_RUNTIME_MATH_LIBM_FROM_X \
         -o "$rest_o" "$seed" 2>/dev/null \
    && ld -r -o "$out" "$thin_o" "$rest_o" 2>/dev/null \
    && _smoke_ok "$out"; then
    merged=1
    echo "cap_tip_ensure_math: OK thin+rest $out (smoke)" >&2
  else
    echo "cap_tip_ensure_math: thin+rest smoke failed; falling back to cold seed" >&2
  fi
fi

if [ "$merged" = "0" ]; then
  # Cold seed (no FROM_X): restored public bit-level/fdlibm twins.
  if ! cc -c -I. -Iinclude -Isrc -Isrc/asm -o "$cold_o" "$seed" 2>/dev/null \
    || ! ld -r -o "$out" "$cold_o" 2>/dev/null; then
    # ld -r single input still ok; or cp
    cp -f "$cold_o" "$out" 2>/dev/null || {
      echo "cap_tip_ensure_math: cold seed compile failed" >&2
      exit 1
    }
  fi
  for s in math_sqrt_c math_tan_c math_trunc_c; do
    nm -gU "$out" 2>/dev/null | grep -qE "T _?${s}\$" \
      || { echo "cap_tip_ensure_math: cold $out missing $s" >&2; exit 1; }
  done
  _smoke_ok "$out" || { echo "cap_tip_ensure_math: cold smoke failed" >&2; exit 1; }
  echo "cap_tip_ensure_math: OK cold-seed $out (smoke)" >&2
fi

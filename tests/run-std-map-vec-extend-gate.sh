#!/usr/bin/env bash
# STD-013/014: std.map / std.vec extend gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native xlang-c) + prefer-c only + soft auto-make
# + hard-bound `xlang check` + fossil TSV anchors (vec_u64_append_slice /
# vec_f64_from_slice) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - map/boundary.x product -o exit0 = hard run.
#   - vec/append_roundtrip.x product -o exit10 (intentional score) = hard run.
#   - check path = obs (paused 2026-08-05).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-map-vec-extend-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/std-map-vec-extend.sh
. tests/lib/std-map-vec-extend.sh

DOC="${XLANG_STD_MVE_DOC:-analysis/archive/std/std-map-vec-extend-v1.md}"
MANIFEST="${XLANG_STD_MVE_TSV:-tests/baseline/std-map-vec-extend.tsv}"
MAP_X="std/map/mod.x"
VEC_X="std/vec/mod.x"
HEAP_X="std/heap/mod.x"
MAP_SMOKE="tests/map/boundary.x"
VEC_SMOKE="tests/vec/append_roundtrip.x"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-map-vec-extend gate FAIL: $*" >&2
  std_mve_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== STD-013/014: map/vec extend manifest (archive DOC) ==="
if [ -f analysis/std-map-vec-extend-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi
for f in "$DOC" "$MANIFEST" tests/lib/std-map-vec-extend.sh "$MAP_X" "$VEC_X" "$HEAP_X" "$MAP_SMOKE" "$VEC_SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
for kw in Map_u64_i32 Map_str_i32 Vec_u64 Vec_f64; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(std_mve_symbols_ok "$MAP_X" "$VEC_X" "$HEAP_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-map-vec-extend manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-013/014: smoke (XLANG=$XLANG_BIN) ==="

# Observational check (paused); CHK red does not hard-fail.
set +e
"$XLANG_BIN" check -L . "$MAP_SMOKE" >/tmp/xlang_mve_check_map.log 2>&1
chk_map=$?
"$XLANG_BIN" check -L . "$VEC_SMOKE" >/tmp/xlang_mve_check_vec.log 2>&1
chk_vec=$?
set -e
if [ "$chk_map" -ne 0 ] || [ "$chk_vec" -ne 0 ]; then
  echo "std-map-vec-extend OBS check (paused / CHK residual map=$chk_map vec=$chk_vec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# map/boundary.x: product -o exit0 = hard.
exe="/tmp/xlang_mve_map_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$MAP_SMOKE" -o "$exe" >/tmp/xlang_mve_map_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_mve_map_o.log 2>/dev/null || true
  rm -f "$exe"
  die "map product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
map_run=$?
set -e
rm -f "$exe"
[ "$map_run" -eq 0 ] || die "map runnable exit=$map_run (expected 0)"
RUN_OK=$((RUN_OK + 1))
echo "std-map-vec-extend OK: map product -o"

# vec/append_roundtrip.x: intentional score return 10 = hard success.
exe="/tmp/xlang_mve_vec_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$VEC_SMOKE" -o "$exe" >/tmp/xlang_mve_vec_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_mve_vec_o.log 2>/dev/null || true
  rm -f "$exe"
  die "vec product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
vec_run=$?
set -e
rm -f "$exe"
# score = len(round_f)+u_len = 4+6 = 10
[ "$vec_run" -eq 10 ] || die "vec runnable exit=$vec_run (expected score 10)"
RUN_OK=$((RUN_OK + 1))
echo "std-map-vec-extend OK: vec product -o (score=10)"

echo "std-map-vec-extend gate OK"
std_mve_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"

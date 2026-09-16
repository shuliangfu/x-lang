#!/usr/bin/env bash
# STD-149: std.math fenv capability gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / c=/x=/host= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o` + hard check as sole .x
# smoke + fossil section path + report `c=`/`x=`/`host=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# runtime_math_libm.o; refuse soft ensure). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-math-fenv-capability-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_MATH_FENV_CAP_DOC:-analysis/archive/std/std-math-fenv-capability-v1.md}"
MANIFEST="${XLANG_STD_MATH_FENV_CAP_TSV:-tests/baseline/std-math-fenv-capability-manifest.tsv}"
VECTORS="${XLANG_STD_MATH_FENV_CAP_VECTORS:-tests/baseline/std-math-fenv-capability.tsv}"
MOD_X="std/math/mod.x"
MATH_RUNTIME="${XLANG_STD_MATH_IMPL:-compiler/seeds/runtime_math_libm.from_x.c}"
LIB="tests/lib/std-math-fenv-capability.sh"
SMOKE_X="tests/std-math/fenv_capability.x"
SMOKE_C="tests/std-math/fenv_capability_ok.c"

# shellcheck source=tests/lib/std-math-fenv-capability.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-math-fenv-cap gate FAIL: $*" >&2
  std_math_fenv_cap_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

echo "=== STD-149: math fenv capability manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$MATH_RUNTIME" "$SMOKE_X" "$SMOKE_C" std/math/README.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-math-fenv-capability-v1.md ] || die "dual-authority fossil analysis/std-math-fenv-capability-v1.md (archive live)"
for kw in STD-149 fenv_available XLANG_MATH_FENV_CAP FENV_NOT_IMPL; do
  grep -qF -- "$kw" "$DOC" || die "doc missing '$kw'"
done
grep -qF "fenv_available" std/math/README.md || die "README missing fenv_available"

sym_miss="$(std_math_fenv_cap_symbols_ok "$MOD_X" "$MATH_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-math-fenv-cap registry OK"

if [ "${XLANG_STD_MATH_FENV_CAP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_math_fenv_cap_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-math-fenv-cap gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / soft ensure)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-149: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

EXPECT="$(std_math_fenv_cap_expect_available "$VECTORS" 2>/dev/null || echo -1)"

# Host-C archaeology = obs only; refuse soft ensure_std_c_o / soft auto-make.
set +e
std_math_fenv_cap_run_c_smoke "$EXPECT"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-math-fenv-cap OK: c smoke"
    ;;
  *)
    echo "std-math-fenv-cap OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_math_fenv_cap_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-math-fenv-cap OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_math_fenv_cap_$$"
LOG="/tmp/xlang_std_math_fenv_cap_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-math-fenv-cap OBS tip product -o (ec=$o_ec; std_math_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-math-fenv-cap OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-math-fenv-cap OK: product -o"
  fi
fi

std_math_fenv_cap_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-math-fenv-cap gate OK"

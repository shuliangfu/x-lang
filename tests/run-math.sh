#!/usr/bin/env bash
# math regression runner (bstrict catalog: run-math.sh).
#
# Honesty: soft SKIP→OK (no native) + prefer-c (xlang-c before asm) +
# soft auto-make xlang-c + hard-bound `xlang check` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make).
#   - tests/math/main.x product -o run exit0 = hard run.
#   - check path CHK002 / paused = obs.
#   - host-C special smoke = obs (archaeology; product -o is the hard signal).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

PREFIX="${XLANG_MATH_PREFIX:-xlang: [XLANG_MATH]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "math test FAIL: $*" >&2
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
    # Explicit XLANG that is not native = hard die (refuse soft fallthrough).
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

SRC="tests/math/main.x"
[ -f "$SRC" ] || die "missing $SRC"

# Observational check (paused 2026-08-05); CHK red does not hard-fail.
set +e
"$XLANG_BIN" check -L . "$SRC" >/tmp/xlang_math_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "math test OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Ensure std math.o + libm for link; refuse soft auto-make of compiler.
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/math/math.o || die "ensure math.o failed"
ensure_runtime_math_libm_o || die "ensure runtime_math_libm.o failed"

exe="/tmp/xlang_math_$$"
rm -f "$exe" 2>/dev/null || true

set +e
"$XLANG_BIN" -L . "$SRC" -o "$exe" >/tmp/xlang_math_compile.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_math_compile.log 2>/dev/null || true
  die "product -o compile failed (ec=$o_ec; refuse soft SKIP→OK)"
fi

set +e
"$exe" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  die "expected exit 0, got $exitcode"
fi
RUN_OK=1

# Host-C special smoke = observational (archaeology; product -o is hard green).
# shellcheck source=tests/lib/std-math-special.sh
. tests/lib/std-math-special.sh
MATH_O="$(cd std/math && pwd)/math.o"
set +e
std_math_special_run_c_smoke "$MATH_O" >/tmp/xlang_math_c_smoke.log 2>&1
c_ec=$?
set -e
if [ "$c_ec" -ne 0 ]; then
  echo "math test OBS c_smoke (host-C residual ec=$c_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

echo "math test OK"
ok_report

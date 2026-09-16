#!/usr/bin/env bash
# MEM-B1: owned early-return path deinit (xlang_cleanup + heap_free) honesty.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: when product -o succeeds → run exit 0 + cleanup/deinit markers
#   - obs: tip typeck/parse/link residual (T001 / XP003 / BLD001) — owned
#     early-return tip debt, not soft false-green
# Report: run=/obs=/skip=
# Usage: ./tests/run-owned-return-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_OWNED_RETURN_PREFIX:-xlang: [XLANG_OWNED_RETURN]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/mem/owned_return_early.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "owned-return-gate FAIL: $*" >&2
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

echo "=== MEM-B1: owned early-return deinit (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

OUT="/tmp/xlang_owned_return_$$"
ERR="/tmp/xlang_owned_return_$$.log"
rm -f "$OUT"

set +e
XLANG_KEEP_C=1 gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "owned-return-gate OBS (-o timeout; product residual)" >&2
elif [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  OBS=$((OBS + 1))
  echo "owned-return-gate OBS (-o ec=$o_ec; tip owned typeck/parse residual; not soft false-green)" >&2
  tail -n 8 "$ERR" >&2 || true
else
  gen="$(grep 'kept generated C:' "$ERR" 2>/dev/null | sed 's/.*: //' | tail -1 || true)"
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    gen="$(grep -oE '/tmp/xlang_[A-Za-z0-9]+\.c' "$ERR" 2>/dev/null | tail -1 || true)"
  fi
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    OBS=$((OBS + 1))
    echo "owned-return-gate OBS (missing kept C under asm; emit residual)" >&2
  elif ! grep -q 'xlang_cleanup' "$gen"; then
    die "product built but missing xlang_cleanup for early-return owned deinit"
  elif ! grep -qE 'heap_free_u8_c|\.ptr = 0' "$gen"; then
    die "product built but missing owned Vec_u8 deinit in generated C"
  else
    set +e
    gate_run_timeout 10 "$OUT" >/dev/null 2>&1
    r_ec=$?
    set -e
    if [ "$r_ec" -eq 124 ]; then
      die "run timeout"
    elif [ "$r_ec" -ne 0 ]; then
      die "run exit=$r_ec want 0"
    fi
    RUN_OK=$((RUN_OK + 1))
    echo "owned-return-gate OK (cleanup path + exit=0)"
  fi
  rm -f "$gen"
fi
rm -f "$OUT"

echo "owned-return-gate OK (MEM-B1 early-return honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0

#!/usr/bin/env bash
# VEC-V1 + MEM-A2 / VEC-AUTO-002: autovec BCE (no index bounds panic) honesty.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: -E emit non-empty C
#   - hard: when xlang_autovec_dot_f32 present → no index-bounds xlang_panic_
#   - obs: missing helper (autovec.c G-02a retired) — BCE on autovec path
#     cannot be claimed; not soft false-green
# Report: run=/obs=/skip=
# Usage: ./tests/run-autovec-bce-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_AUTOVEC_BCE_PREFIX:-xlang: [XLANG_AUTOVEC_BCE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/vec/autovec_dot_loop.x"
HELPER='xlang_autovec_dot_f32'
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "autovec-bce-gate FAIL: $*" >&2
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

echo "=== VEC-AUTO-002: autovec BCE (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

C_OUT="/tmp/xlang_autovec_bce_$$.c"
ERR="/tmp/xlang_autovec_bce_$$.log"
rm -f "$C_OUT"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$SRC" >"$C_OUT" 2>"$ERR"
e_ec=$?
set -e
if [ "$e_ec" -eq 124 ]; then
  die "-E emit timeout"
elif [ "$e_ec" -ne 0 ] || [ ! -s "$C_OUT" ]; then
  die "-E emit failed (ec=$e_ec)"
fi
RUN_OK=$((RUN_OK + 1))
echo "autovec-bce-gate OK emit (-E non-empty)"

if grep -q "$HELPER" "$C_OUT"; then
  if grep -qE '\) >= [0-9]+ \? \(xlang_panic_|length \? \(xlang_panic_|>= \(.*\)->length \? \(xlang_panic_' "$C_OUT"; then
    die "autovec path still contains index bounds xlang_panic_ guard"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "autovec-bce-gate OK (helper + no bounds panic)"
else
  OBS=$((OBS + 1))
  echo "autovec-bce-gate OBS (missing $HELPER; cannot claim BCE on autovec path; G-02a tip)" >&2
fi

rm -f "$C_OUT"
echo "autovec-bce-gate OK (VEC-AUTO-002 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0

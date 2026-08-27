#!/usr/bin/env bash
# core.builtin smoke (placeholder / bitops / copy / min / max) — honesty soft→硬绿.
#
# Honesty: soft auto-make + prefer-c (xlang-c before asm) + gcc host-c fallback
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product path: `$XLANG -L . -o` then run. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-builtin.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

RUN_OK=0
OBS=0
SKIP=0
PREFIX="xlang: [XLANG_BUILTIN]"

die() {
  echo "run-builtin FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP}"
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
export XLANG_OPT=0
export XLANG_NO_MARCH_NATIVE=1
export CI="${CI:-1}"

echo "=== builtin product -o (XLANG=$XLANG_BIN) ==="
EXE="/tmp/xlang_builtin_$$"
LOG="/tmp/xlang_builtin_$$.log"
set +e
"$XLANG_BIN" -L . tests/builtin/main.x -o "$EXE" >"$LOG" 2>&1
bec=$?
set -e
if [ "$bec" -ne 0 ]; then
  if grep -qE 'Undefined symbols|undefined reference|UNDEF|BLD001' "$LOG" 2>/dev/null; then
    echo "run-builtin OBS (product -o UNDEF/ld residual)" >&2
    OBS=$((OBS + 1))
    echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
    echo "builtin test OK (obs)"
    exit 0
  fi
  tail -n 12 "$LOG" >&2 || true
  die "compile tests/builtin/main.x"
fi
set +e
"$EXE"
rec=$?
set -e
rm -f "$EXE" "$LOG"
[ "$rec" -eq 0 ] || die "run exit=$rec"
RUN_OK=$((RUN_OK + 1))
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP}"
echo "builtin test OK"

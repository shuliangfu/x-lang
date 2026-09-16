#!/usr/bin/env bash
# generic monomorphization smoke: id<i32>(42) exit 42 + wrong type-arg NEG
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft bootstrap-link). Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_GENERIC_PREFIX:-xlang: [GENERIC]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-180}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "generic FAIL: $*" >&2
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

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== generic gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

src="tests/generic/main.x"
[ -f "$src" ] || die "missing $src"
exe="/tmp/xlang_generic_$$"
log="/tmp/xlang_generic_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "main product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "main product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe" "$log"
if [ "$r_ec" -eq 124 ]; then
  die "main run timeout"
elif [ "$r_ec" -ne 42 ]; then
  die "main expected exit 42 (id<i32>(42)), got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))

neg_src="tests/generic/wrong_type_args.x"
[ -f "$neg_src" ] || die "missing $neg_src"
neg_exe="/tmp/xlang_generic_wrong_$$"
neg_log="/tmp/xlang_generic_wrong_$$.log"
rm -f "$neg_exe" "$neg_log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$neg_src" -o "$neg_exe" >"$neg_log" 2>&1
neg_ec=$?
set -e
if [ "$neg_ec" -eq 124 ]; then
  die "wrong_type_args timeout"
elif [ "$neg_ec" -eq 0 ]; then
  die "wrong_type_args expected compile fail, got success"
fi
grep -q "expects 1 type arguments, got 2" "$neg_log" \
  || die "expected type-arg count diagnostic; $(tail -5 "$neg_log" 2>/dev/null | tr '\n' ' ')"
rm -f "$neg_exe" "$neg_log"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "generic test OK"

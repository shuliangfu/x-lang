#!/usr/bin/env bash
# json regression runner (bstrict catalog: run-json.sh).
#
# Honesty: soft SKIP→OK (no native) + prefer-c (xlang-c before asm) +
# soft auto-make xlang-c retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make).
#   - tests/json/main.x product -o run exit0 = hard run.
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

PREFIX="${XLANG_JSON_PREFIX:-xlang: [XLANG_JSON]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "json test FAIL: $*" >&2
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

# Ensure std json.o for link; refuse soft auto-make of the compiler itself.
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/json/json.o || die "ensure json.o failed"

SRC="tests/json/main.x"
[ -f "$SRC" ] || die "missing $SRC"
exe="/tmp/xlang_json_$$"
rm -f "$exe" 2>/dev/null || true

set +e
"$XLANG_BIN" -L . "$SRC" -o "$exe" >/tmp/xlang_json_compile.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_json_compile.log 2>/dev/null || true
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
echo "json test OK"
ok_report

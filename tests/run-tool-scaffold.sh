#!/usr/bin/env bash
# TOOL-006: project template compile+run smoke (expect exit 42).
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
# shellcheck source=tests/lib/tool-scaffold.sh
. tests/lib/tool-scaffold.sh

PREFIX="${XLANG_SCAFFOLD_PREFIX:-xlang: [TOOL-SCAFFOLD]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
EXPECT_EXIT="${XLANG_SCAFFOLD_EXPECT_EXIT:-42}"
RUN_OK=0
OBS=0
SKIP=0
WORKDIR="/tmp/xlang_scaffold_test_$$"
EXE="$WORKDIR/app"

die() {
  echo "tool-scaffold FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
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

echo "=== tool-scaffold gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

tool_scaffold_copy_to "$WORKDIR" || die "copy template project-hello failed"

log="/tmp/xlang_scaffold_build_$$.log"
rm -f "$EXE" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$WORKDIR/main.x" -o "$EXE" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "template product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$EXE" ]; then
  die "template product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$EXE" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$log"
if [ "$r_ec" -eq 124 ]; then
  die "template run timeout"
elif [ "$r_ec" -ne "$EXPECT_EXIT" ]; then
  die "expected exit $EXPECT_EXIT, got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))

echo "tool-scaffold report template=project-hello exit=${r_ec} runnable=OK"
ok_report
echo "scaffold test OK"

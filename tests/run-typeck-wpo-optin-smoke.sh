#!/usr/bin/env bash
# typeck_wpo opt-in link smoke: after opt-in, struct_mk must pass.
#
# Honesty: soft SKIP→OK when no xlang_asm + bare Darwin "N/A" exit0
# (false authority) retired. Prefer product xlang_asm. Explicit bad
# XLANG / missing native on Linux = hard die (refuse soft SKIP→OK).
# Darwin / non-Linux = skip= (platform N/A, not soft green). Rebuild
# of xlang_asm is the gate under test (not soft auto-make of a missing
# compiler). Report: run=/obs=/skip=
# Usage: ./tests/run-typeck-wpo-optin-smoke.sh
# Pre: compiler/xlang_asm already bootstrapped on Linux.
# PLATFORM: LINUX|UBUNTU archaeology — Darwin skip=; Ubuntu gold.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_TYPECK_WPO_PREFIX:-xlang: [TYPECK_WPO_OPTIN]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-180}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "typeck-wpo-optin FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

# PLATFORM: LINUX|UBUNTU — opt-in link path is Linux gold only.
if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  SKIP=$((SKIP + 1))
  echo "typeck-wpo-optin: skip= (platform N/A on $(uname -s); not soft SKIP→OK)" >&2
  ok_report
  exit 0
fi

if [ -n "${XLANG:-}" ]; then
  case "$XLANG" in
    /*) abs="$XLANG" ;;
    *) abs="$(pwd)/$XLANG" ;;
  esac
  dod_native_exe "$abs" || die "XLANG=$XLANG is not a native exe (refuse soft SKIP→OK)"
fi

if ! dod_native_exe ./compiler/xlang_asm; then
  die "no compiler/xlang_asm (refuse soft SKIP→OK / soft auto-make)"
fi

chmod +x compiler/scripts/build_xlang_asm.sh
SMK="tests/boundary/struct_mk_let_inline.x"
[ -f "$SMK" ] || die "missing $SMK"

# Second build triggers typeck_wpo opt-in link (same path as gen1 rebuild).
# PLATFORM: LINUX|UBUNTU — this rebuild IS the gate (not soft auto-make).
(
  cd compiler
  rm -f build_asm/typeck_strict_link_partial.o build_asm/typeck_strict_link_export.txt \
    build_asm/typeck_wpo_helpers_partial.o build_asm/typeck_wpo_helpers_export.txt
  XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 XLANG=./xlang ./scripts/build_xlang_asm.sh > /tmp/typeck_wpo_smoke.log 2>&1
)

if ! grep -qE 'typeck_wpo_helpers|whole typeck.o \(selfhosted|seed typeck.o' /tmp/typeck_wpo_smoke.log; then
  die "log missing typeck_wpo opt-in link path"
fi

if ! grep -q 'STRICT_LINK_BUILD_ASM_TYPECK_WPO=1' /tmp/typeck_wpo_smoke.log; then
  die "log missing STRICT_LINK_BUILD_ASM_TYPECK_WPO=1"
fi
RUN_OK=$((RUN_OK + 1))

rm -f /tmp/typeck_wpo_smki
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" ./compiler/xlang_asm "$SMK" -o /tmp/typeck_wpo_smki >/tmp/typeck_wpo_smki.log 2>&1
RC=$?
set -e
if [ "$RC" -eq 124 ]; then
  die "struct_mk -o timeout"
elif [ "$RC" -ne 0 ] || [ ! -x /tmp/typeck_wpo_smki ]; then
  die "struct_mk compile rc=$RC; $(tail -5 /tmp/typeck_wpo_smki.log 2>/dev/null | tr '\n' ' ')"
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" /tmp/typeck_wpo_smki >/dev/null 2>&1
RC=$?
set -e
rm -f /tmp/typeck_wpo_smki /tmp/typeck_wpo_smki.log
if [ "$RC" -eq 124 ]; then
  die "struct_mk run timeout"
elif [ "$RC" -ne 10 ]; then
  die "struct_mk run rc=$RC (expected 10)"
fi
RUN_OK=$((RUN_OK + 1))

if nm compiler/xlang_asm 2>/dev/null | grep -qE ' T check_block$'; then
  cb_src=$(nm compiler/xlang_asm 2>/dev/null | grep ' T check_block$' | awk '{print $1}')
  echo "typeck-wpo-optin OK (struct_mk 10; check_block T @ $cb_src from typeck.o partial)"
else
  echo "typeck-wpo-optin OK (struct_mk 10)"
fi

ok_report

#!/usr/bin/env bash
# LANG-003: generic monomorph smoke (single-module + multi-file).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c (xlang-c before
# xlang_asm) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG = hard die. Missing native = hard die (generic
# hooks are the live face). Multi-file runs on resolved product path
# (not force-xlang-c). Report run=/multi=/skip=.
#
# Usage: ./tests/run-lang-generic.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/lang-generic.sh
. tests/lib/lang-generic.sh

PREFIX="xlang: [XLANG_LANG_GENERIC]"
RUN_OK=0
MULTI_OK=0
SKIP=0

die() {
  echo "lang-generic FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} multi=${MULTI_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} multi=${MULTI_OK} skip=${SKIP} host=$(ci_host_summary)"
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

echo "=== LANG-003: generic smoke (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-generic.sh tests/run-multi-file-generic.sh
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-generic.sh
RUN_OK=1

# Multi-file on resolved product path (prefer asm); refuse force-xlang-c.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-multi-file-generic.sh; then
  MULTI_OK=1
else
  die "multi-file generic"
fi

ok_report
echo "lang-generic OK"

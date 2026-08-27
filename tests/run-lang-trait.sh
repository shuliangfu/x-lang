#!/usr/bin/env bash
# LANG-004: trait/interface smoke (method call + typeck negative).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c (xlang-c before
# xlang_asm) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG = hard die. Missing native = hard die (trait hooks
# are the live face). Report run=/neg=/skip=.
#
# Usage: ./tests/run-lang-trait.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/lang-trait.sh
. tests/lib/lang-trait.sh

PREFIX="xlang: [XLANG_LANG_TRAIT]"
RUN_OK=0
NEG_OK=0
SKIP=0

die() {
  echo "lang-trait FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} neg=${NEG_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} neg=${NEG_OK} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== LANG-004: trait smoke (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-trait.sh
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-trait.sh
RUN_OK=1

# impl missing-method negative (not covered by run-trait.sh).
err=$("$XLANG_BIN" build tests/trait/impl_missing_method.x -o /tmp/xlang_trait_miss 2>&1) || true
echo "$err" | grep -q "missing method" || die "expected missing method error, got: $err"
NEG_OK=1
echo "lang-trait OK impl_missing_method"

ok_report
echo "lang-trait OK"

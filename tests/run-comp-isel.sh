#!/usr/bin/env bash
# COMP-006: instruction-selection asm smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no native xlang_asm retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing
# native = hard die (isel hooks are the live face). Report run=/skip=.
#
# Usage: ./tests/run-comp-isel.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-isel.sh
. tests/lib/comp-isel.sh

PREFIX="xlang: [XLANG_COMP_ISEL]"
RUN_OK=0
SKIP=0

die() {
  echo "comp-isel FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
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
    # Explicit XLANG that is missing or wrong-ABI = hard die (refuse soft SKIP→OK).
    return 1
  fi
  # Prefer product asm. PLATFORM: SHARED — product path honesty; Ubuntu gold.
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

echo "=== COMP-006: isel smoke (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-asm-binop-var.sh tests/run-asm-binop-index-lit.sh \
  tests/run-asm-binop-field-index.sh tests/run-asm-binop-nested-var.sh \
  tests/run-asm-binop-div-index.sh
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-asm-binop-var.sh
echo "comp-isel OK var_fast"
RUN_OK=$((RUN_OK + 1))

XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-asm-binop-index-lit.sh
echo "comp-isel OK index_lit"
RUN_OK=$((RUN_OK + 1))

# COMP-014 P0 sample smokes (field / nested / div-index)
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-asm-binop-field-index.sh
echo "comp-isel OK field_index_p0"
RUN_OK=$((RUN_OK + 1))

XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-asm-binop-nested-var.sh
echo "comp-isel OK nested_var_p0"
RUN_OK=$((RUN_OK + 1))

XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-asm-binop-div-index.sh
echo "comp-isel OK div_index_p0"
RUN_OK=$((RUN_OK + 1))

echo "comp-isel OK"
ok_report

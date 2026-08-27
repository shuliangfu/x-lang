#!/usr/bin/env bash
# COMP-005: register-allocation strategy light smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no native xlang_asm retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing
# native = hard die (regalloc hooks are the live face). Non-arm64 block_var
# disasm = skip= (platform N/A, not soft SKIP→OK). Report run=/skip=.
#
# Usage: ./tests/run-comp-regalloc.sh
# PLATFORM: SHARED archaeology (arm64 disasm optional).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-regalloc.sh
. tests/lib/comp-regalloc.sh

PREFIX="xlang: [XLANG_COMP_REGALLOC]"
RUN_OK=0
SKIP=0

die() {
  echo "comp-regalloc FAIL: $*" >&2
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

XLANG_ASM="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ASM"
export XLANG_LINK_XLANG="$XLANG_ASM"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

echo "=== COMP-005: regalloc smoke (XLANG=$XLANG_ASM) ==="
chmod +x tests/run-asm-binop-var.sh tests/run-asm-binop-block-var.sh
XLANG="$XLANG_ASM" XLANG_LINK_XLANG="$XLANG_ASM" ./tests/run-asm-binop-var.sh
echo "comp-regalloc OK var_fast"
RUN_OK=$((RUN_OK + 1))

if comp_regalloc_disasm_host; then
  XLANG="$XLANG_ASM" XLANG_LINK_XLANG="$XLANG_ASM" ./tests/run-asm-binop-block-var.sh
  echo "comp-regalloc OK block_var"
  RUN_OK=$((RUN_OK + 1))
else
  # PLATFORM: SHARED — block_var disasm is arm64-host N/A, not soft SKIP→OK.
  echo "comp-regalloc SKIP block_var disasm (non-arm64 host; platform N/A)"
  SKIP=$((SKIP + 1))
fi

echo "comp-regalloc OK"
ok_report

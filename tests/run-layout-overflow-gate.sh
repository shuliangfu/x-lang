#!/usr/bin/env bash
# P1-4: layout overflow / repr(C) smoke gate — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: layout arith header + typeck.x layout authority + manifest
#   - hard: delegate run-repr-c-layout-gate.sh with XLANG_REPR_C_LAYOUT_FAIL=1
#     (#[repr(C)] smoke exit 43; child already prefers asm)
# Report: run=/obs=/skip=
# Usage: ./tests/run-layout-overflow-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_LAYOUT_OVERFLOW_PREFIX:-xlang: [XLANG_LAYOUT_OVERFLOW]}"
HEADER="compiler/include/xlang_layout_arith.h"
# typeck.c deleted; layout authority lives in typeck.x (compute_struct_layouts / §11.1 padding).
TYPECK="compiler/src/typeck/typeck.x"
MANIFEST="tests/baseline/layout-overflow.tsv"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "layout-overflow FAIL: $*" >&2
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

echo "=== P1-4: layout overflow manifest ==="
for f in "$HEADER" "$TYPECK" "$MANIFEST"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qF "xlang_layout_iadd_overflow" "$HEADER" 2>/dev/null; then
  die "header missing xlang_layout_iadd_overflow"
fi
if ! grep -qE "compute_struct_layouts|struct_layouts|隐式 padding" "$TYPECK" 2>/dev/null; then
  die "typeck.x missing struct layout / padding authority"
fi
echo "layout-overflow manifest OK"
RUN_OK=$((RUN_OK + 1))

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== layout-overflow: repr(C) product smoke (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-repr-c-layout-gate.sh
set +e
XLANG_REPR_C_LAYOUT_FAIL=1 XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  ./tests/run-repr-c-layout-gate.sh
prc=$?
set -e
case "$prc" in
  0)
    echo "layout-overflow OK repr-c-layout"
    RUN_OK=$((RUN_OK + 1))
    ;;
  *)
    die "repr-c-layout hard (ec=$prc; refuse soft FAIL→OK)"
    ;;
esac

ok_report
echo "layout-overflow gate OK"

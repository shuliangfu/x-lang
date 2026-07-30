#!/usr/bin/env bash
# bootstrap_verify_bstrict.sh — B-strict self-host verify body (11.0.3 · wave720)
#
# Authority (G.7):
#   Single implementation of check-7.2-bstrict / bootstrap-verify-bstrict /
#   bootstrap-verify *bodies*. Makefile keeps bootstrap-driver-bstrict as
#   prereq for the make-graph path; xlang-build.sh calls this script directly
#   (no make -C bootstrap-verify).
#
# Flow (matches historical Makefile check-7.2-bstrict):
#   1) Optional ensure: bootstrap_driver_bstrict.sh (seed + refresh leaf)
#   2) verify-selfhost-stage2-bstrict.sh (stage1/stage2 binaries)
#   3) Per-stage smoke: lexer / typeck / vec-map-heap / parser-typeck dogfood
#
# Usage (cwd = compiler/):
#   ./scripts/bootstrap_verify_bstrict.sh
#
# Env:
#   MAKE — make binary (default: make)
#   TARGET — product binary name (default: xlang)
#   XLANG_VERIFY_ENSURE_BSTRICT — if stages missing, run
#     bootstrap_driver_bstrict.sh first.
#     wave880: when unset, MAKELEVEL set → 0 (make-graph already has
#     bootstrap-driver-bstrict prereq); else → 1 (direct xlang-build).
#     Explicit XLANG_VERIFY_ENSURE_BSTRICT=0|1 always wins.
#   XLANG_STAGE2_* — forwarded to verify-selfhost-stage2-bstrict.sh
#
# PLATFORM: SHARED shell orchestration.
# Wave: 720 Track MG · pairs with Makefile thin leaves + xlang-build direct call.
# Wave: 880 B7B — drop Makefile ENSURE=0 / MAKE/TARGET inject; shell owns defaults.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
TARGET="${TARGET:-xlang}"
# wave880: make-graph path → ENSURE=0; direct call → ENSURE=1.
if [ -z "${XLANG_VERIFY_ENSURE_BSTRICT+set}" ]; then
  if [ -n "${MAKELEVEL:-}" ]; then
    XLANG_VERIFY_ENSURE_BSTRICT=0
  else
    XLANG_VERIFY_ENSURE_BSTRICT=1
  fi
fi

log() { echo "bootstrap-verify-bstrict: $*" >&2; }

# Step 0: ensure B-strict product path exists (xlang_asm / stages come from verify).
if [ ! -x "./$TARGET" ] && [ ! -x ./xlang_asm ]; then
  if [ "$XLANG_VERIFY_ENSURE_BSTRICT" = "1" ]; then
    log "no ./$TARGET / xlang_asm → bootstrap_driver_bstrict.sh"
    MAKE="$MAKE" TARGET="$TARGET" XLANG_BSTRICT_ENSURE_SEED=1 \
      sh scripts/bootstrap_driver_bstrict.sh
  else
    log "missing ./$TARGET and xlang_asm (run bootstrap-driver-bstrict first)"
    exit 1
  fi
elif [ "$XLANG_VERIFY_ENSURE_BSTRICT" = "1" ] && [ ! -x ./xlang_asm ]; then
  # Product may exist from g05; still need bstrict refresh for asm stages.
  log "xlang_asm missing → bootstrap_driver_bstrict.sh"
  MAKE="$MAKE" TARGET="$TARGET" XLANG_BSTRICT_ENSURE_SEED=0 \
    sh scripts/bootstrap_driver_bstrict.sh
fi

# Step 1: stage2 dogfood (produces xlang_asm_stage1 / xlang_asm2 when needed)
# wave893: body authority = scripts/verify-selfhost-stage2-bstrict.sh (G.7).
# Root compiler/verify-selfhost-stage2-bstrict.sh is a thin shim only.
if [ ! -f ./scripts/verify-selfhost-stage2-bstrict.sh ]; then
  log "missing ./scripts/verify-selfhost-stage2-bstrict.sh"
  exit 1
fi
bash ./scripts/verify-selfhost-stage2-bstrict.sh

# Step 2: historical check-7.2-bstrict per-stage suite
ROOT="$(pwd)/.."
CDIR="$(pwd)"
for ST in xlang_asm_stage1 xlang_asm2; do
  if [ ! -x "$CDIR/$ST" ]; then
    log "check-7.2-bstrict: $ST missing"
    exit 1
  fi
  (
    cd "$ROOT" &&
      XLANG="$CDIR/$ST" ./tests/run-lexer.sh &&
      XLANG="$CDIR/$ST" ./tests/run-typeck.sh &&
      XLANG="$CDIR/$ST" ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh &&
      XLANG="$CDIR/$ST" ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
  ) || {
    log "check-7.2-bstrict FAIL: $ST"
    exit 1
  }
done

echo "check-7.2-bstrict OK (xlang_asm gen1/gen2: stage2 + lexer + typeck + vec/map/heap + parser/typeck dogfood)"
echo "bootstrap-verify-bstrict OK"
echo "bootstrap-verify OK (B-strict primary; seed path: make bootstrap-verify-seed)"

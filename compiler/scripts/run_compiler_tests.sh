#!/usr/bin/env bash
# run_compiler_tests.sh — compiler test_c / test_x / test orchestration (11.0.3 · wave720)
#
# Authority (G.7):
#   Single implementation of Makefile test / test_c / test_x *bodies*.
#   Makefile keeps product prereqs (TARGET / XLANG_C / STD_AND_PANIC_O /
#   bootstrap-driver-seed) for the make-graph path; xlang-build.sh calls this
#   script directly (no make -C for test*).
#   Does NOT re-list STD_AND_PANIC_O or cold-build object graphs (G.7).
#
# Usage (cwd = compiler/):
#   ./scripts/run_compiler_tests.sh c
#   ./scripts/run_compiler_tests.sh x
#   ./scripts/run_compiler_tests.sh all
#
# Env:
#   TARGET — product binary name (default: xlang)
#   XLANG_C — C frontend binary (default: xlang-c)
#   MAKE — make binary (default: make)
#   XLANG_TEST_ENSURE — if products missing, run make for them
#     wave880: when unset, MAKELEVEL set → 0 (make-graph prereqs already
#     built); else → 1 (direct xlang-build / standalone call). Explicit
#     XLANG_TEST_ENSURE=0|1 always wins.
#   XLANG_TEST_ENSURE_SEED — test_x: if ./$TARGET missing, make
#     bootstrap-driver-seed (default same as XLANG_TEST_ENSURE)
#
# PLATFORM: SHARED shell orchestration; nested tests/run-all-*.sh may still
# call make for product rebuild (stage 11.2.3 inventory — not this wave).
# Wave: 720 Track MG · pairs with Makefile thin leaves + xlang-build direct call.
# Wave: 880 B7B — drop Makefile ENSURE=0 / TARGET inject; shell owns defaults.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-}"
TARGET="${TARGET:-xlang}"
XLANG_C="${XLANG_C:-xlang-c}"
MAKE="${MAKE:-make}"
# wave880: make-graph path (MAKELEVEL set) already has product prereqs →
# default ENSURE=0 so Makefile thin-call needs no XLANG_TEST_ENSURE=0 inject.
# Direct xbuild / standalone keeps ENSURE=1 (auto-build missing products).
if [ -z "${XLANG_TEST_ENSURE+set}" ]; then
  if [ -n "${MAKELEVEL:-}" ]; then
    XLANG_TEST_ENSURE=0
  else
    XLANG_TEST_ENSURE=1
  fi
fi
XLANG_TEST_ENSURE_SEED="${XLANG_TEST_ENSURE_SEED:-$XLANG_TEST_ENSURE}"

log() { echo "run_compiler_tests(${MODE}): $*" >&2; }

case "$MODE" in
  c|x|all) ;;
  *)
    echo "usage: $0 c|x|all" >&2
    exit 2
    ;;
esac

run_c() {
  # Historical make prereqs: $(TARGET) $(XLANG_C) $(STD_AND_PANIC_O).
  # Spot-check products only — do not re-list STD_AND_PANIC_O (G.7).
  if [ ! -x "./$TARGET" ] || [ ! -x "./$XLANG_C" ]; then
    if [ "$XLANG_TEST_ENSURE" = "1" ]; then
      log "product missing → make all / $XLANG_C (whitelist ensure)"
      "$MAKE" -q all 2>/dev/null || "$MAKE" all
      "$MAKE" -q "$XLANG_C" 2>/dev/null || "$MAKE" "$XLANG_C" || true
    fi
  fi
  if [ ! -x "./$TARGET" ] || [ ! -x "./$XLANG_C" ]; then
    log "missing ./$TARGET or ./$XLANG_C (build products first)"
    exit 1
  fi
  if [ ! -f ../tests/run-all-c.sh ]; then
    log "tests/run-all-c.sh missing"
    exit 1
  fi
  (cd .. && chmod +x tests/run-all-c.sh && ./tests/run-all-c.sh)
  echo "Test C OK"
}

run_x() {
  # Historical prereq: bootstrap-driver-seed (full cold graph stays Makefile).
  if [ ! -x "./$TARGET" ]; then
    if [ "$XLANG_TEST_ENSURE_SEED" = "1" ]; then
      log "./$TARGET missing → make bootstrap-driver-seed"
      "$MAKE" bootstrap-driver-seed
    else
      log "missing ./$TARGET (run make bootstrap-driver-seed first)"
      exit 1
    fi
  fi
  if [ -f ../tests/run-lsp.sh ]; then
    (cd .. && chmod +x tests/run-lsp.sh && ./tests/run-lsp.sh)
  fi
  if [ -f ../tests/run-all-x.sh ]; then
    (cd .. && chmod +x tests/run-all-x.sh && ./tests/run-all-x.sh)
  fi
  echo "Test X OK"
}

case "$MODE" in
  c) run_c ;;
  x) run_x ;;
  all)
    run_c
    run_x
    echo "Test all OK"
    ;;
esac

#!/usr/bin/env bash
# bootstrap_driver_bstrict.sh — B-strict post-seed orchestration (11.0.3 · wave719)
#
# Authority (G.7):
#   Single implementation of the bootstrap-driver-bstrict *body* after
#   bootstrap-driver-seed has produced ./$TARGET. Makefile target keeps
#   bootstrap-driver-seed as prereq and thin-calls this script; xlang-build.sh
#   calls this script directly (no make -C bootstrap-driver-bstrict).
#
#   migrate companions: scripts/migrate_x_objs.sh (wave735 · G.7);
#   migrate *_gen.c: scripts/ensure_migrate_gen.sh (wave736 · G.7);
#   *_gen.c production still Makefile residual until 11.3.
#   refresh gate body is scripts/refresh_xlang_asm_gate.sh (wave734 · G.7);
#   product relink inside that script is g05 (zero make for the link step).
#
# Usage (cwd = compiler/):
#   ./scripts/bootstrap_driver_bstrict.sh
#
# Env:
#   MAKE   — make binary (default: make); residual seed + gen.c leaves
#   TARGET — product binary name (default: xlang)
#   XLANG_BSTRICT_NO_REPLACE — if set, refresh gate leaves $(TARGET) unchanged
#     (passed through to refresh_xlang_asm_gate.sh)
#   XLANG_BSTRICT_ENSURE_SEED=1 — if ./$TARGET missing, run
#     `make bootstrap-driver-seed` (default on for direct xlang-build calls;
#     Makefile path already has seed as prereq so usually unused)
#
# PLATFORM: SHARED shell orchestration; leaf recipes carry platform ABI.
# Wave: 719 Track MG · wave734 refresh · wave735 migrate · wave736 migrate-gen.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
TARGET="${TARGET:-xlang}"
# Direct shell entry (xlang-build) should cold-build seed if missing; Makefile
# path already ensures bootstrap-driver-seed prereq.
XLANG_BSTRICT_ENSURE_SEED="${XLANG_BSTRICT_ENSURE_SEED:-1}"

log() { echo "bootstrap-driver-bstrict: $*" >&2; }

if [ ! -x "./$TARGET" ]; then
  if [ "${XLANG_BSTRICT_ENSURE_SEED}" = "1" ]; then
    log "./$TARGET missing → make bootstrap-driver-seed"
    "$MAKE" bootstrap-driver-seed
  else
    log "missing executable ./$TARGET (run make bootstrap-driver-seed first)"
    exit 1
  fi
fi

# Same endpoint as Ubuntu gold: refresh-xlang-asm-gate overlays xlang_asm from
# seed+migrate. build_xlang_asm is the intermediate experimental chain; Darwin
# ld rejects multiple defs (-multiply_defined deprecated) unlike Linux
# --allow-multiple-definition — experimental may fail, then fall back to seed.
if XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 XLANG="./$TARGET" ./scripts/build_xlang_asm.sh; then
  :
elif [ -x "./$TARGET" ]; then
  log "WARN build_xlang_asm intermediate failed; seed ./$TARGET OK → refresh gate (same final as Ubuntu)"
  cp -f "./$TARGET" xlang_asm
else
  log "xlang_asm build failed (see build_xlang_asm.sh log)"
  exit 1
fi

if [ ! -f xlang_asm ]; then
  log "xlang_asm missing after build/seed fallback"
  exit 1
fi

# G.7: refresh body is shell (wave734); migrate via migrate_x_objs.sh (wave735);
# ensure_migrate_gen.sh owns parser/typeck/codegen *_gen.c (wave736).
# Residual make only for missing *_gen.c inside migrate. No dual overlay recipe.
# shellcheck disable=SC2086
MAKE="$MAKE" TARGET="$TARGET" \
  XLANG_BSTRICT_NO_REPLACE="${XLANG_BSTRICT_NO_REPLACE:-}" \
  sh scripts/refresh_xlang_asm_gate.sh

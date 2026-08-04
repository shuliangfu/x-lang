#!/usr/bin/env bash
# refresh_xlang_asm_gate.sh — body of make refresh-xlang-asm-gate (11.1.6 · wave734/735)
#
# Authority (G.7):
#   Single implementation of the P0 asm gate that aligns xlang_asm with
#   seed + migrate-x companions after a product relink.
#
#   Steps (same semantics as the former Makefile recipe):
#     1) migrate-x-objs  — scripts/migrate_x_objs.sh (wave735; gen.c residual make)
#     2) g05 relink      — G05_SYNC_ASM=0 prepare_and_relink (zero make for link)
#     3) overlay         — cp ./$TARGET → xlang_asm
#     4) optional        — if XLANG_BSTRICT_NO_REPLACE unset, cp xlang_asm → $TARGET
#                          (historical B-strict release default; no-op after step 3
#                           when TARGET was the relink product, kept for parity)
#
# Usage (cwd = compiler/):
#   sh scripts/refresh_xlang_asm_gate.sh
#   ./xbuild refresh-gate          # repo root (via xlang-build.sh)
#   make refresh-xlang-asm-gate    # thin Makefile leaf → this script
#
# Env:
#   MAKE     — make binary for residual gen.c leaves inside migrate (default: make)
#   TARGET   — product binary name (default: xlang)
#   CC/CFLAGS/PYTHON — forwarded to migrate_x_objs.sh when set
#   XLANG_BSTRICT_NO_REPLACE — if set, do not re-copy xlang_asm → $TARGET
#   XLANG_REFRESH_SKIP_MIGRATE=1 — skip migrate_x_objs.sh (caller already did)
#   XLANG_REFRESH_SKIP_RELINK=1  — skip g05 relink (caller already did)
#
# PLATFORM: SHARED shell orchestration; leaf .o recipes carry platform ABI.
# Wave: 734 Track MG · wave735 migrate shell · pairs with Makefile thin leaf.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
TARGET="${TARGET:-xlang}"
XLANG_REFRESH_SKIP_MIGRATE="${XLANG_REFRESH_SKIP_MIGRATE:-0}"
XLANG_REFRESH_SKIP_RELINK="${XLANG_REFRESH_SKIP_RELINK:-0}"

log() { echo "refresh-xlang-asm-gate: $*" >&2; }

# --- 1) migrate-x companions (G.7: migrate_x_objs.sh; gen.c still Makefile) ---
if [ "$XLANG_REFRESH_SKIP_MIGRATE" != "1" ]; then
  log "migrate-x-objs via scripts/migrate_x_objs.sh"
  # shellcheck disable=SC2086
  MAKE="$MAKE" CC="${CC:-}" CFLAGS="${CFLAGS:-}" PYTHON="${PYTHON:-}" \
    sh scripts/migrate_x_objs.sh all
else
  log "skip migrate-x-objs (XLANG_REFRESH_SKIP_MIGRATE=1)"
fi

# --- 2) product relink via g05 (zero make for the link step) ---
if [ "$XLANG_REFRESH_SKIP_RELINK" != "1" ]; then
  log "relink via g05_prepare_and_relink (G05_SYNC_ASM=0)"
  G05_SYNC_ASM=0 sh scripts/g05_prepare_and_relink.sh
else
  log "skip g05 relink (XLANG_REFRESH_SKIP_RELINK=1)"
fi

if [ ! -x "./$TARGET" ] && [ ! -f "./$TARGET" ]; then
  log "missing ./$TARGET after migrate/relink"
  exit 1
fi

# --- 3) align xlang_asm with seed+migrate product ---
cp -f "./$TARGET" xlang_asm
echo "refresh-xlang-asm-gate OK (xlang_asm <- seed+migrate-x-objs)"

# --- 4) historical NO_REPLACE / release-default copy (parity with old recipe) ---
if [ -n "${XLANG_BSTRICT_NO_REPLACE:-}" ]; then
  echo "bootstrap-driver-bstrict OK (xlang_asm=seed+parser_x; $TARGET unchanged)"
else
  cp -f xlang_asm "./$TARGET"
  echo "bootstrap-driver-bstrict OK (xlang_asm -> $TARGET, release default B-strict)"
fi

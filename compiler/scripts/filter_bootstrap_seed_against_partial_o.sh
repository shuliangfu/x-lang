#!/usr/bin/env bash
# filter_bootstrap_seed_against_partial_o.sh — named authority for class-G
# filters that omit only seed_host/asm_backend_partial.o symbols:
#   build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o
#   build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o
#   build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o
#
# Thin wrapper over filter_o_export_against_deps.sh (G.7). Makefile recipes and
# g05_ensure Darwin product path both invoke this script — no third nm/ld copy.
#
# Usage (cwd = compiler/):
#   sh scripts/filter_bootstrap_seed_against_partial_o.sh SRC.o OUT.o STEM
#
# STEM is intermediate file tag (e.g. bootstrap_seed_user_asm_seed_bridge).
#
# PLATFORM: SHARED — Darwin product link lists these filtered.o in g05_relink_env;
# Linux product link uses unfiltered USER_ASM .o (still OK to build for cold seed).

set -euo pipefail

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

if [ "$#" -lt 3 ]; then
  echo "usage: filter_bootstrap_seed_against_partial_o.sh SRC.o OUT.o STEM" >&2
  exit 2
fi

SRC_O="$1"
OUT_O="$2"
STEM="$3"
PARTIAL="${4:-build_asm/seed_host/asm_backend_partial.o}"

exec sh scripts/filter_o_export_against_deps.sh \
  --src "$SRC_O" \
  --out "$OUT_O" \
  --stem "$STEM" \
  --omit "$PARTIAL"

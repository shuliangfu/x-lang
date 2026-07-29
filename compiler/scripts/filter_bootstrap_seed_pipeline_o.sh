#!/usr/bin/env bash
# filter_bootstrap_seed_pipeline_o.sh — named authority for
#   build_asm/bootstrap_seed_pipeline_filtered.o
#
# Thin wrapper over filter_o_export_against_deps.sh (G.7 single implementation).
# Historical omit set: typeck_x / codegen_x / seed_host partial / strict_minimal.
#
# Usage (cwd = compiler/):
#   sh scripts/filter_bootstrap_seed_pipeline_o.sh
#   sh scripts/filter_bootstrap_seed_pipeline_o.sh [pipeline_x.o] [out.o]
#
# PLATFORM: SHARED — Darwin product link primary; Linux hygiene OK.

set -euo pipefail

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

SRC_O="${1:-pipeline_x.o}"
OUT_O="${2:-build_asm/bootstrap_seed_pipeline_filtered.o}"

exec sh scripts/filter_o_export_against_deps.sh \
  --src "$SRC_O" \
  --out "$OUT_O" \
  --stem bootstrap_seed_pipeline \
  --require-keep \
  --omit typeck_x.o \
  --omit codegen_x.o \
  --omit build_asm/seed_host/asm_backend_partial.o \
  --omit build_asm/pipeline_glue_strict_minimal.o

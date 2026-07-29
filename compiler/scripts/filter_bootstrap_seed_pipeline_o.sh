#!/usr/bin/env bash
# filter_bootstrap_seed_pipeline_o.sh — pure-shell authority for
#   build_asm/bootstrap_seed_pipeline_filtered.o
#
# Purpose:
#   Darwin product g05 links filtered pipeline_x (omit symbols also defined in
#   typeck_x / codegen_x / seed_host partial / pipeline_glue_strict_minimal) so
#   ld does not dual-define. Historically this was only a Makefile recipe and
#   g05_ensure called `make -s` (11.0.2 product-path make leak).
#
# Authority (G.7 single path):
#   This script is the only implementation. compiler/Makefile recipe and
#   g05_ensure_relink_prereqs.sh both invoke it. Do not re-copy nm/ld filter
#   logic into a third place.
#
# Semantics match historical Makefile recipe (bootstrap_seed_pipeline_filtered.o):
#   nm pipeline_x.o [TDS] minus dep [TDS] → keep list → ld -r partial export.
#
# Usage (cwd = compiler/):
#   sh scripts/filter_bootstrap_seed_pipeline_o.sh
#   # or with explicit paths:
#   sh scripts/filter_bootstrap_seed_pipeline_o.sh [pipeline_x.o] [out.o]
#
# Exit: 0 success; 1 missing input / ld failure
#
# PLATFORM: SHARED — Darwin product link primary consumer; Linux may still
# build the object (g05 hygiene) though product link uses bare pipeline_x.o.

set -euo pipefail

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

SRC_O="${1:-pipeline_x.o}"
OUT_O="${2:-build_asm/bootstrap_seed_pipeline_filtered.o}"

if [ ! -f "$SRC_O" ]; then
  echo "filter_bootstrap_seed_pipeline_o: missing $SRC_O" >&2
  exit 1
fi

mkdir -p build_asm
all_syms=build_asm/bootstrap_seed_pipeline.syms
keep_syms=build_asm/bootstrap_seed_pipeline.keep
omit_syms=build_asm/bootstrap_seed_pipeline.omit
ver_file="${OUT_O}.ver"

: >"$omit_syms"
# PLATFORM: SHARED — same omit set as historical Makefile (class G filter).
# Missing deps are skipped (cold partial trees); present deps always contribute.
for dep_o in \
  typeck_x.o \
  codegen_x.o \
  build_asm/seed_host/asm_backend_partial.o \
  build_asm/pipeline_glue_strict_minimal.o
do
  if [ -f "$dep_o" ]; then
    nm "$dep_o" 2>/dev/null | awk '/ [TDS] / { s=$3; sub(/^_/, "", s); print s }' >>"$omit_syms" || true
  fi
done
sort -u "$omit_syms" -o "$omit_syms"

nm "$SRC_O" 2>/dev/null | awk '/ [TDS] / { s=$3; sub(/^_/, "", s); print s }' | sort -u >"$all_syms"
# keep list always with leading _ for Darwin -exported_symbols_list (Makefile parity)
comm -23 "$all_syms" "$omit_syms" | sed 's/^/_/' >"$keep_syms"

if [ ! -s "$keep_syms" ]; then
  echo "filter_bootstrap_seed_pipeline_o: empty keep list for $SRC_O" >&2
  exit 1
fi

uname_s="$(uname -s 2>/dev/null || echo unknown)"
echo "filter_bootstrap_seed_pipeline_o: $SRC_O → $OUT_O (keep=$(wc -l <"$keep_syms" | tr -d ' ') syms; host=$uname_s)"

# PLATFORM: MACOS|DARWIN — ld64/lld -exported_symbols_list
# PLATFORM: LINUX — GNU ld --version-script (keep names with leading _)
if [ "$uname_s" = "Darwin" ]; then
  ld -r -exported_symbols_list "$keep_syms" -o "$OUT_O" "$SRC_O"
else
  {
    printf '{ global:\n'
    sed 's/.*/  &;/' "$keep_syms"
    printf '  *;\n};\n'
  } >"$ver_file"
  ld -r --version-script="$ver_file" -o "$OUT_O" "$SRC_O"
fi

exit 0

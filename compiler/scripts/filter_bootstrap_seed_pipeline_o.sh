#!/usr/bin/env bash
# filter_bootstrap_seed_pipeline_o.sh — named authority for
#   build_asm/bootstrap_seed_pipeline_filtered.o
#
# Thin wrapper over filter_o_export_against_deps.sh (G.7 single implementation).
# Historical omit set: typeck_x / codegen_x / seed_host partial / strict_minimal.
#
# wave835/921 (G.7 有则补全; not physical delete):
#   Makefile residual leaf uses FORCE + this script only (no pipeline_x /
#   partial / strict_minimal make-graph prereq). wave921: 1 per-leaf recipe →
#   1 multi-target $(FILTER_PIPELINE_OBJS) in mk/driver_seed_r_lists.mk.
#     - ensure OUT → try-heat pipeline_x + strict_minimal, mtime skip, filter
#     - positional [pipeline_x.o] [out.o] still works (g05)
#     - XLANG_FILTER_FORCE=1 always refilters
#   PLATFORM: SHARED — cheap mtime skip on every FORCE recipe run.
#
# wave863 (G.7 有则补全; not physical delete):
#   Makefile filter recipes drop multi-token CFLAGS=/PIPELINE_GEN_CFLAGS= inject.
#   try-heat (wave862) shell-loads export-try-heat-cflags when unset — do NOT
#   pass empty CFLAGS= (set-but-empty blocks shell-load).
#
# Usage (cwd = compiler/):
#   bash scripts/filter_bootstrap_seed_pipeline_o.sh ensure [OUT.o]
#   bash scripts/filter_bootstrap_seed_pipeline_o.sh --check
#   bash scripts/filter_bootstrap_seed_pipeline_o.sh [pipeline_x.o] [out.o]
#
# PLATFORM: SHARED — Darwin product link primary; Linux hygiene OK.

set -euo pipefail

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_self="$_script_dir/$(basename "$0")"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

TAG="filter_bootstrap_seed_pipeline"
DEFAULT_SRC="pipeline_x.o"
DEFAULT_OUT="build_asm/bootstrap_seed_pipeline_filtered.o"
STEM="bootstrap_seed_pipeline"
PARTIAL="build_asm/seed_host/asm_backend_partial.o"
STRICT="build_asm/pipeline_glue_strict_minimal.o"
OMIT_TYPECK="typeck_x.o"
OMIT_CODEGEN="codegen_x.o"

usage() {
  echo "usage: $TAG ensure [OUT.o] | --check | [pipeline_x.o] [out.o]" >&2
  exit 2
}

need_rebuild() {
  local src="$1" out="$2"
  if [ -n "${XLANG_FILTER_FORCE:-}" ]; then
    return 0
  fi
  if [ ! -f "$out" ]; then
    return 0
  fi
  if [ -f "$src" ] && [ "$src" -nt "$out" ]; then
    return 0
  fi
  # Omit peers that affect keep-set (historical Makefile prereqs + typeck/codegen).
  for _peer in "$PARTIAL" "$STRICT" "$OMIT_TYPECK" "$OMIT_CODEGEN"; do
    if [ -f "$_peer" ] && [ "$_peer" -nt "$out" ]; then
      return 0
    fi
  done
  return 1
}

run_filter() {
  local src="$1" out="$2"
  if [ ! -f "$src" ]; then
    echo "$TAG: missing SRC $src" >&2
    exit 1
  fi
  # PLATFORM: SHARED — bash required (arrays); Ubuntu dash rejects OMITS=().
  # wave304: omit strict_minimal only when residual .o still on disk (seed retired).
  local -a _omits=(
    --omit "$OMIT_TYPECK"
    --omit "$OMIT_CODEGEN"
    --omit "$PARTIAL"
  )
  if [ -f "$STRICT" ]; then
    _omits+=(--omit "$STRICT")
  fi
  exec bash scripts/filter_o_export_against_deps.sh \
    --src "$src" \
    --out "$out" \
    --stem "$STEM" \
    --require-keep \
    "${_omits[@]}"
}

ensure_try_heat() {
  local o="$1"
  if [ ! -f scripts/ensure_host_cc_seed_o.sh ]; then
    return 0
  fi
  # wave863: pass CC only. try-heat loads CFLAGS/PIPELINE_GEN via export leaf
  # when unset (wave862). Empty CFLAGS= would block that load.
  if ! CC="${CC:-}" \
    bash scripts/ensure_host_cc_seed_o.sh try-heat "$o" 2>/dev/null; then
    _rc=$?
    if [ "$_rc" -eq 3 ]; then
      return 0
    fi
    if [ ! -f "$o" ]; then
      echo "$TAG: try-heat failed for $o (rc=$_rc)" >&2
      exit 1
    fi
  fi
}

do_ensure() {
  local out="${1:-$DEFAULT_OUT}"
  local src="$DEFAULT_SRC"
  case "$out" in
    "$DEFAULT_OUT"|bootstrap_seed_pipeline_filtered.o) ;;
    *)
      echo "$TAG: ensure: unexpected OUT $out (want $DEFAULT_OUT)" >&2
      exit 3
      ;;
  esac
  # Normalize short name
  out="$DEFAULT_OUT"
  # Cheap path: SRC present and OUT fresh → no try-heat (FORCE recipes).
  if [ -f "$src" ] && ! need_rebuild "$src" "$out"; then
    echo "$TAG: skip up-to-date $out"
    exit 0
  fi
  # Only heat when missing. XLANG_FILTER_FORCE must not re-try-heat existing
  # pipeline_x (large leaf; hung Ubuntu L2 sample).
  if [ ! -f "$src" ]; then
    ensure_try_heat "$src"
  fi
  # wave304 G.7 8.3.6: strict_minimal seed shell retired — do not try-heat a
  # deleted seed. Omit only when residual .o still exists on disk.
  # PLATFORM: SHARED freestanding shell retire.
  if [ -f seeds/pipeline_glue_strict_minimal.from_x.c ] && [ ! -f "$STRICT" ]; then
    ensure_try_heat "$STRICT"
  fi
  if [ ! -f "$src" ]; then
    echo "$TAG: missing $src (build pipeline_x first)" >&2
    exit 1
  fi
  if ! need_rebuild "$src" "$out"; then
    echo "$TAG: skip up-to-date $out"
    exit 0
  fi
  _filter_omit=(
    --omit "$OMIT_TYPECK"
    --omit "$OMIT_CODEGEN"
    --omit "$PARTIAL"
  )
  if [ -f "$STRICT" ]; then
    _filter_omit+=(--omit "$STRICT")
  fi
  bash scripts/filter_o_export_against_deps.sh \
    --src "$src" \
    --out "$out" \
    --stem "$STEM" \
    --require-keep \
    "${_filter_omit[@]}"
}

do_check() {
  if ! grep -q 'need_rebuild\|XLANG_FILTER_FORCE' "$_self"; then
    echo "$TAG --check: must own need_rebuild / FILTER_FORCE mtime policy (wave835)" >&2
    exit 1
  fi
  if ! grep -q 'try-heat' "$_self"; then
    echo "$TAG --check: must try-heat pipeline_x / strict_minimal (wave835)" >&2
    exit 1
  fi
  if ! grep -q 'filter_o_export_against_deps' "$_self"; then
    echo "$TAG --check: must call filter_o_export_against_deps (G.7)" >&2
    exit 1
  fi
  if ! grep -q -- '--require-keep' "$_self"; then
    echo "$TAG --check: pipeline filter must require-keep" >&2
    exit 1
  fi
  echo "$TAG --check OK (COUNT=1 wave835/921 FORCE thin multi-target; not physical delete)"
}

if [ "$#" -ge 1 ]; then
  case "$1" in
    ensure)
      do_ensure "${2:-$DEFAULT_OUT}"
      exit 0
      ;;
    --check)
      do_check
      exit 0
      ;;
    -h|--help)
      usage
      ;;
  esac
fi

SRC_O="${1:-$DEFAULT_SRC}"
OUT_O="${2:-$DEFAULT_OUT}"
if ! need_rebuild "$SRC_O" "$OUT_O"; then
  echo "$TAG: skip up-to-date $OUT_O"
  exit 0
fi
run_filter "$SRC_O" "$OUT_O"

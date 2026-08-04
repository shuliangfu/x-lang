#!/usr/bin/env bash
# ensure_pipeline_glue_types.sh — body of build_asm/pipeline_glue_types.inc extract
# (11.3.1 · wave833 FORCE dep-thin)
#
# Authority (G.7):
#   Single shell body for the Makefile leaf that materializes glue type/extern
#   headers from pipeline_gen.c via extract_pipeline_glue_types.pl.
#   Makefile prereqs are FORCE + this script only (no make-graph edge on
#   pipeline_gen.c / extract.pl). Shell owns mtime + FORCE policy.
#   Extract algorithm stays in extract_pipeline_glue_types.pl (not reimplemented).
#   i64 ABI guard stays in check_pipeline_gen_expr_i64_abi.sh (called here).
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_pipeline_glue_types.sh
#   bash scripts/ensure_pipeline_glue_types.sh --check
#   make build_asm/pipeline_glue_types.inc   # thin FORCE leaf
#
# Env:
#   XLANG_GLUE_TYPES_FORCE=1 — always re-extract (ignore mtime skip)
#
# PLATFORM: SHARED — same extract + ABI guard on Darwin/Linux/Windows MSYS2.
# Wave: 833 Track MG · pairs with Makefile FORCE leaf. NOT physical delete.

set -euo pipefail
cd "$(dirname "$0")/.."

GEN="pipeline_gen.c"
OUT="build_asm/pipeline_glue_types.inc"
EXTRACT="scripts/extract_pipeline_glue_types.pl"
CHECK_ABI="scripts/check_pipeline_gen_expr_i64_abi.sh"
FORCE="${XLANG_GLUE_TYPES_FORCE:-0}"
MODE="${1:-ensure}"
TAG="ensure-pipeline-glue-types"

log() { echo "${TAG}: $*" >&2; }

need_rebuild() {
  # PLATFORM: SHARED — portable mtime via shell -nt (GNU/BSD make-independent).
  if [ "$FORCE" = "1" ]; then
    return 0
  fi
  if [ ! -s "$OUT" ]; then
    return 0
  fi
  if [ ! -f "$GEN" ]; then
    return 0
  fi
  if [ "$GEN" -nt "$OUT" ]; then
    return 0
  fi
  if [ -f "$EXTRACT" ] && [ "$EXTRACT" -nt "$OUT" ]; then
    return 0
  fi
  return 1
}

run_extract() {
  if [ ! -f "$EXTRACT" ]; then
    log "FAIL missing $EXTRACT"
    return 1
  fi
  # Always run ABI guard before extract so glue never sees int32_t Expr.int_val
  # (P0-4 / i64-ctfe; G.7 single authority = check_pipeline_gen_expr_i64_abi.sh).
  if [ -f "$CHECK_ABI" ]; then
    chmod +x "$CHECK_ABI" 2>/dev/null || true
    bash "$CHECK_ABI"
  else
    log "FAIL missing $CHECK_ABI"
    return 1
  fi
  if [ ! -s "$GEN" ]; then
    log "FAIL missing or empty $GEN after ABI guard"
    return 1
  fi
  mkdir -p build_asm
  local tmp="${OUT}.tmp.$$"
  if ! perl "$EXTRACT" "$GEN" >"$tmp"; then
    rm -f "$tmp"
    log "FAIL extract perl exit"
    return 1
  fi
  if [ ! -s "$tmp" ]; then
    rm -f "$tmp"
    log "FAIL empty extract output"
    return 1
  fi
  mv -f "$tmp" "$OUT"
  log "extract OK -> $OUT ($(wc -c <"$OUT" | tr -d ' ') bytes)"
  return 0
}

ensure() {
  if need_rebuild; then
    if [ "$FORCE" = "1" ]; then
      log "FORCE re-extract (XLANG_GLUE_TYPES_FORCE=1)"
    else
      log "stale or missing $OUT — extract"
    fi
    run_extract
    return $?
  fi
  log "up-to-date $OUT (set XLANG_GLUE_TYPES_FORCE=1 to re-extract)"
  return 0
}

self_check() {
  # Static honesty — no extract / no ABI side effects.
  local fail=0
  if [ ! -f scripts/ensure_pipeline_glue_types.sh ]; then
    echo "${TAG} --check: missing self" >&2
    fail=1
  fi
  if ! grep -q 'XLANG_GLUE_TYPES_FORCE' scripts/ensure_pipeline_glue_types.sh; then
    echo "${TAG} --check: must own GLUE_TYPES_FORCE policy" >&2
    fail=1
  fi
  if ! grep -q 'need_rebuild' scripts/ensure_pipeline_glue_types.sh; then
    echo "${TAG} --check: must own need_rebuild mtime policy" >&2
    fail=1
  fi
  if ! grep -q 'extract_pipeline_glue_types\.pl' scripts/ensure_pipeline_glue_types.sh; then
    echo "${TAG} --check: must call extract_pipeline_glue_types.pl" >&2
    fail=1
  fi
  if ! grep -q 'check_pipeline_gen_expr_i64_abi' scripts/ensure_pipeline_glue_types.sh; then
    echo "${TAG} --check: must call i64 ABI guard" >&2
    fail=1
  fi
  if [ ! -f "$EXTRACT" ]; then
    echo "${TAG} --check: missing extract pl" >&2
    fail=1
  fi
  if [ ! -f "$CHECK_ABI" ]; then
    echo "${TAG} --check: missing ABI check script" >&2
    fail=1
  fi
  if [ "$fail" -ne 0 ]; then
    echo "${TAG} --check: FAIL" >&2
    return 1
  fi
  echo "${TAG} --check: OK" >&2
  return 0
}

case "$MODE" in
  --check|check)
    self_check
    ;;
  ensure|"")
    ensure
    ;;
  *)
    log "unknown mode: $MODE (use ensure or --check)"
    exit 2
    ;;
esac

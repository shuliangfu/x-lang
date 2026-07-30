#!/usr/bin/env bash
# ensure_ast_gen2.sh — body of ast_gen2.c pin / force -E (11.3.1 · wave830)
#
# Authority (G.7):
#   Single implementation of ast_gen2.c production for typeck/codegen single-TU
#   compile (ast_ast_* prototypes via fix_slim_arena_gen_c.pl).
#   Makefile thin leaf FORCE-calls this script (0× make for the gen body except
#   residual make of missing xlang-c for force -E).
#   Distinct from product frontend *_gen.c (ensure_migrate_gen.sh) — no
#   seeds/*_gen.linux.x86_64.c pin; authority is the committed local pin +
#   optional -E from src/ast/ast.x.
#   .o compile remains ensure_gen_x_o / try-heat → try-gen-c-to-o (wave782/796).
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_ast_gen2.sh
#   bash scripts/ensure_ast_gen2.sh --check
#   make ast_gen2.c   # thin FORCE leaf
#
# Env:
#   XLANG_FORCE_REGEN_GEN=1 — force -E regen (ignore local pin)
#   MAKE — residual make for missing xlang-c only
#   XLANG_C — binary name (default xlang-c)
#
# PLATFORM: SHARED shell orchestration; committed pin is host-portable C.
# wave830 (G.7 无才新增): FORCE dep-thin — Makefile prereqs FORCE+script only;
#   shell owns pin/FORCE_REGEN policy. NOT physical delete.
# Wave: 830 Track MG · pairs with ensure_gen_x_o (ast_gen2.o) + Makefile thin leaf.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
XLANG_C="${XLANG_C:-xlang-c}"
XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}"
MODE="${1:-ensure}"

log() { echo "ensure-ast-gen2: $*" >&2; }

bytes_of() {
  # PLATFORM: SHARED — Darwin wc -c pads; tr -d spaces
  wc -c < "$1" | tr -d ' '
}

ensure_xlang_c() {
  if [ -x "./$XLANG_C" ] || [ -f "./$XLANG_C" ]; then
    return 0
  fi
  log "residual make $XLANG_C (missing binary for force -E)"
  MAKEFLAGS= "$MAKE" "$XLANG_C"
}

# Run -E -E-extern from src/ast/ast.x, then fix_slim_arena (injects ast_ast_*).
# PLATFORM: SHARED — same -L src/ast path on macOS/Ubuntu/Windows.
regen_ast_gen2() {
  local tmp="ast_gen2.c.tmp.$$"
  rm -f "$tmp"
  ensure_xlang_c
  log "ast_gen2.c: ./$XLANG_C -L src/ast -E -E-extern src/ast/ast.x"
  if ! "./$XLANG_C" -L src/ast -E -E-extern src/ast/ast.x >"$tmp"; then
    rm -f "$tmp"
    log "ast_gen2.c: FAIL xlang-c -E"
    return 1
  fi
  if [ ! -s "$tmp" ]; then
    rm -f "$tmp"
    log "ast_gen2.c: FAIL empty -E output"
    return 1
  fi
  mv -f "$tmp" ast_gen2.c
  if [ -f scripts/fix_slim_arena_gen_c.pl ]; then
    perl scripts/fix_slim_arena_gen_c.pl ast_gen2.c
  fi
  log "ast_gen2.c: regen OK ($(bytes_of ast_gen2.c) bytes)"
  return 0
}

ensure_ast_gen2() {
  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    regen_ast_gen2
    return $?
  fi
  if [ -s ast_gen2.c ]; then
    log "ast_gen2.c: pinned ($(bytes_of ast_gen2.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
    return 0
  fi
  # Cold / empty pin: must -E (no seeds/ast_gen2.linux.* pin authority).
  regen_ast_gen2
}

self_check() {
  # Static honesty — no compile / no -E.
  local fail=0
  if [ ! -f scripts/ensure_ast_gen2.sh ]; then
    echo "ensure_ast_gen2 --check: missing self" >&2
    fail=1
  fi
  if ! grep -q 'XLANG_FORCE_REGEN_GEN' scripts/ensure_ast_gen2.sh; then
    echo "ensure_ast_gen2 --check: must own FORCE_REGEN policy" >&2
    fail=1
  fi
  if ! grep -q 'fix_slim_arena_gen_c.pl' scripts/ensure_ast_gen2.sh; then
    echo "ensure_ast_gen2 --check: must call fix_slim_arena_gen_c.pl" >&2
    fail=1
  fi
  if ! grep -q 'src/ast/ast.x' scripts/ensure_ast_gen2.sh; then
    echo "ensure_ast_gen2 --check: must reference src/ast/ast.x" >&2
    fail=1
  fi
  if [ "$fail" -ne 0 ]; then
    return 1
  fi
  echo "ensure_ast_gen2.sh --check OK (wave830 FORCE thin; not physical delete)"
  return 0
}

case "$MODE" in
  ensure|ast_gen2|ast_gen2.c|"")
    ensure_ast_gen2
    ;;
  --check|check)
    self_check
    ;;
  -h|--help|help)
    cat <<'EOF'
Usage: ensure_ast_gen2.sh [ensure|ast_gen2|--check]
  ensure (default) — pin if non-empty; else -E + fix_slim
  XLANG_FORCE_REGEN_GEN=1 — force -E regen
Env: MAKE XLANG_C XLANG_FORCE_REGEN_GEN
EOF
    ;;
  *)
    echo "ensure_ast_gen2: unknown mode '$MODE' (ensure|ast_gen2|--check)" >&2
    exit 2
    ;;
esac

#!/usr/bin/env bash
# regen_lsp_gens_x.sh — force-refresh LSP/archaeology *_gen.c set (regen-lsp-gens-x)
#
# Authority (G.7 有则补全 / 无才新增):
#   Single implementation for Makefile phony regen-lsp-gens-x.
#   Historic dual body lived inline in Makefile:
#     require ./$(XLANG_X)
#     rm -f lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
#     $(MAKE) those four file targets
#     echo OK
#
#   What this owns:
#     1) Gate: product xlang-x binary must exist (cold: bootstrap-driver-seed)
#     2) Delete the four local *_gen.c so ensure leaves re-run seed/pin/-E policy
#     3) Invoke make on the four file targets (gen *body* stays ensure_*.sh;
#        residual make graph for FORCE thin leaves is intentional)
#     4) Print historic OK line for make / CI consumers
#
#   Why shell-primary (not physical delete)?
#     Individual gen leaf recipes + ensure bodies + seed pins still form residual
#     make graph; this is only the force-refresh orchestration body.
#
#   Related but NOT the same as:
#     - ensure_lsp_pipeline_gen.sh (single-file gen body authority)
#     - ensure_archaeology_gen.sh (lsp_io_std_heap_gen body)
#     - bootstrap-pipeline / ensure pipeline_gen only
#   Do not reimplement gen pin/-E policy here — call make → ensure.
#
# Usage (cwd = compiler/):
#   bash scripts/regen_lsp_gens_x.sh
#   bash scripts/regen_lsp_gens_x.sh --check
#
# Env:
#   XLANG_X — product binary name (default: xlang-x)
#   MAKE    — make program (default: make)
#
# wave873 (G.7 有则补全): Makefile fat body → this script (thin-call only).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; gen policy stays ensure shells.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
XLANG_X="${XLANG_X:-xlang-x}"
MAKE="${MAKE:-make}"

log() { echo "regen-lsp-gens-x: $*" >&2; }
fail() { echo "regen-lsp-gens-x: FAIL: $*" >&2; exit 1; }

GENS=(
  lsp_io_gen.c
  lsp_gen.c
  lsp_diag_gen.c
  lsp_io_std_heap_gen.c
)

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  _rec=$(awk '
    /^regen-lsp-gens-x:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'regen_lsp_gens_x\.sh' <<<"$_rec"; then
    fail "regen-lsp-gens-x must thin-call regen_lsp_gens_x.sh (wave873)"
  fi
  # Dual body: inline XLANG_X gate / rm gens / make gen targets / OK line.
  # Thin-call may pass MAKE="$(MAKE)" XLANG_X="$(XLANG_X)" — that alone is OK.
  if grep -qE 'lsp_io_gen\.c|lsp_diag_gen\.c|lsp_io_std_heap_gen\.c|lsp_gen\.c' <<<"$_rec"; then
    fail "regen-lsp-gens-x must not keep dual gen file list body (wave873; shell owns)"
  fi
  if grep -qE 'rm -f|regen-lsp-gens-x OK|bootstrap-driver-seed|请先 make' <<<"$_rec"; then
    fail "regen-lsp-gens-x must not keep dual rm/gate/OK body (wave873)"
  fi
  echo "regen_lsp_gens_x: --check OK (wave873; shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ -n "$MODE" ] && [ "$MODE" != "--run" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Product path (force-refresh four LSP/archaeology gens)
# ---------------------------------------------------------------------------
if [ ! -f "./$XLANG_X" ]; then
  fail "missing ./$XLANG_X (run make bootstrap-driver-seed first)"
fi

rm -f "${GENS[@]}"
# Residual make graph: each file target thin-calls ensure_*.sh (wave829/837/740).
# shellcheck disable=SC2086 # MAKE may be multi-token (e.g. make -j1)
$MAKE "${GENS[@]}"

echo "regen-lsp-gens-x OK"

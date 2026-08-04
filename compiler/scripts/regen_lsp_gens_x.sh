#!/usr/bin/env bash
# regen_lsp_gens_x.sh — force-refresh LSP/archaeology *_gen.c set (regen-lsp-gens-x)
#
# Authority (G.7 有则补全 / 无才新增):
#   Single implementation for historic Makefile phony regen-lsp-gens-x.
#   Historic dual body lived inline in Makefile:
#     require ./$(XLANG_X)
#     rm -f lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c
#     $(MAKE) those four file targets
#     echo OK
#
#   What this owns:
#     1) Gate: product xlang-x binary must exist (cold: bootstrap-driver-seed)
#     2) Delete the four local *_gen.c so ensure leaves re-run seed/pin/-E policy
#     3) Shell-primary ensure (wave952 · 0-make post-delete):
#          ensure_lsp_pipeline_gen.sh lsp          → three product LSP gens
#          ensure_archaeology_gen.sh lsp_io_std_heap → lsp_io_std_heap_gen.c
#        Gen *body* authority stays ensure_*.sh (wave739/740); this is only
#        force-refresh orchestration (wave930 twin in build_xlang_asm).
#     4) Print historic OK line for CI consumers
#
#   Escape: XLANG_REGEN_LSP_VIA_MAKE=1 + Makefile present → $MAKE four gens
#   (parity / mid-migration hosts only; not the default product path).
#
#   Related but NOT the same as:
#     - ensure_lsp_pipeline_gen.sh (single-file gen body authority)
#     - ensure_archaeology_gen.sh (lsp_io_std_heap_gen body)
#     - bootstrap-pipeline / ensure pipeline_gen only
#   Do not reimplement gen pin/-E policy here — call ensure (or make escape).
#
# Usage (cwd = compiler/):
#   bash scripts/regen_lsp_gens_x.sh
#   bash scripts/regen_lsp_gens_x.sh --check
#
# Env:
#   XLANG_X — product binary name (default: xlang-x)
#   MAKE    — make program (default: make); only for XLANG_REGEN_LSP_VIA_MAKE escape
#   XLANG_REGEN_LSP_VIA_MAKE=1 — escape product path to make (needs Makefile)
#
# wave873 (G.7 有则补全): Makefile fat body → this script (thin-call only).
# wave952 (G.7 post-delete): product path 0-make via ensure_*.sh (not $MAKE gens).
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
  # wave952 post_ship: Makefile physically deleted (wave941). Shell body is
  # authority; require shell-primary ensure path, not MF thin-call inventory.
  if [ ! -f "$MF" ]; then
    if ! grep -q 'ensure_lsp_pipeline_gen\.sh' "$0"; then
      fail "regen must shell-call ensure_lsp_pipeline_gen.sh (wave952 post_ship)"
    fi
    if ! grep -q 'ensure_archaeology_gen\.sh' "$0"; then
      fail "regen must shell-call ensure_archaeology_gen.sh (wave952 post_ship)"
    fi
    if ! grep -q 'XLANG_REGEN_LSP_VIA_MAKE' "$0"; then
      fail "regen must document XLANG_REGEN_LSP_VIA_MAKE escape (wave952)"
    fi
    # Default product path must not be an unguarded bare $MAKE gens edge.
    if grep -E '^[[:space:]]*\$MAKE[[:space:]]+"\$\{GENS' "$0" 2>/dev/null | grep -q .; then
      # Accept only if gated by VIA_MAKE earlier in the same control block.
      if ! grep -q 'XLANG_REGEN_LSP_VIA_MAKE' "$0"; then
        fail "regen must not residual bare make gens without VIA_MAKE gate (wave952)"
      fi
    fi
    if ! grep -q 'wave952' "$0"; then
      fail "regen must document wave952 shell-primary ensure"
    fi
    echo "regen_lsp_gens_x: --check OK (wave952 post_ship; shell ensure; 0-make)"
    exit 0
  fi
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
  # wave952 honesty: product path must shell-call ensure (even while MF exists).
  if ! grep -q 'ensure_lsp_pipeline_gen\.sh' "$0"; then
    fail "regen must shell-call ensure_lsp_pipeline_gen.sh (wave952)"
  fi
  if ! grep -q 'ensure_archaeology_gen\.sh' "$0"; then
    fail "regen must shell-call ensure_archaeology_gen.sh (wave952)"
  fi
  if ! grep -q 'XLANG_REGEN_LSP_VIA_MAKE' "$0"; then
    fail "regen must document XLANG_REGEN_LSP_VIA_MAKE escape (wave952)"
  fi
  echo "regen_lsp_gens_x: --check OK (wave873 thin + wave952 shell ensure; not physical delete)"
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
  # wave952: post-delete hint → ./xbuild (not make)
  fail "missing ./$XLANG_X (run: ./xbuild bootstrap-driver-seed)"
fi

rm -f "${GENS[@]}"

# wave952: shell-primary (0-make post-delete). wave930 twin in build_xlang_asm.
# Escape: XLANG_REGEN_LSP_VIA_MAKE=1 + Makefile present (parity only).
if [ "${XLANG_REGEN_LSP_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
  log "ensure gens via make escape (XLANG_REGEN_LSP_VIA_MAKE=1)"
  # shellcheck disable=SC2086 # MAKE may be multi-token (e.g. make -j1)
  $MAKE "${GENS[@]}"
else
  log "ensure gens via ensure_lsp_pipeline_gen + ensure_archaeology_gen (wave952 0-make)"
  bash scripts/ensure_lsp_pipeline_gen.sh lsp
  bash scripts/ensure_archaeology_gen.sh lsp_io_std_heap
fi

echo "regen-lsp-gens-x OK"

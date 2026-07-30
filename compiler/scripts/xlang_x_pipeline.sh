#!/usr/bin/env bash
# xlang_x_pipeline.sh — archaeology xlang-x-pipeline body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target xlang-x-pipeline:
#     1) force pipeline_x.o rebuild (PIPELINE_X_FORCE_COMPILE=1)
#     2) migrate-x-objs + satellite .o + build-seed-asm-host
#     3) force target_cpu / simd_enc / simd_loop (gen_driver may lag)
#     4) host-cc link TARGET_x with USE_X_PIPELINE|TYPECK|CODEGEN
#
#   Object lists stay mk expansion (pipeline_x_objs.mk; wave817). Shell never
#   hardcodes a second PIPELINE_X_* inventory — Makefile thin-call exports
#   expanded bags as XXP_* env vars.
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_x_pipeline.sh
#   bash scripts/xlang_x_pipeline.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   TARGET              — product binary basename (default: xlang)
#   TARGET_X            — .x-pipeline binary (default: ${TARGET}_x)
#   CC / CFLAGS         — host C compiler + flags
#   MAKE                — make binary (for residual ensure edges)
#   XXP_BASE_OBJS       — expanded $(PIPELINE_X_BASE_OBJS)
#   XXP_FRONTEND_OBJS   — expanded $(PIPELINE_X_FRONTEND_OBJS)
#   XXP_LINK_OBJS       — expanded $(PIPELINE_X_LINK_OBJS)
#   XXP_SATELLITE_OBJS  — expanded $(PIPELINE_X_SATELLITE_OBJS)
#   XXP_LSP_DIAG        — expanded $(LSP_DIAG_LINK_O) + sizes.o
#   XXP_LIBS            — expanded $(PIPELINE_LIBS) (Linux -lpthread; else empty)
#
# wave845 (G.7 有则补全): Makefile fat multi-make + $(CC) link → this script.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
TARGET_X="${TARGET_X:-${TARGET}_x}"
CC="${CC:-cc}"
CFLAGS="${CFLAGS:-}"
MAKE="${MAKE:-make}"

log() { echo "xlang-x-pipeline: $*" >&2; }
fail() { echo "xlang-x-pipeline: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Makefile thin-call only (wave845): scan *recipe* lines (tab-indented) only —
  # comments between targets must not false-positive on "$(CC)" prose.
  _rec=$(awk '
    /^xlang-x-pipeline:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'xlang_x_pipeline\.sh' <<<"$_rec"; then
    fail "xlang-x-pipeline must thin-call xlang_x_pipeline.sh (wave845)"
  fi
  # Dual body: multi-make ensure ladder must not remain in recipe (shell owns).
  # Note: thin-call may export CC="$(CC)" — do not grep bare $(CC) alone.
  if grep -qE 'PIPELINE_X_FORCE_COMPILE=1|@\$\(MAKE\).*migrate-x-objs|@\$\(MAKE\).*pipeline_x\.o|@\$\(MAKE\).*build-seed-asm-host|@\$\(MAKE\) -B src/driver/target_cpu' <<<"$_rec"; then
    fail "xlang-x-pipeline must not keep dual multi-make ensure body (wave845; shell owns)"
  fi
  # Dual host-cc link line (primary archaeology product)
  if grep -qE '\$\(CC\).*DXLANG_USE_X_PIPELINE|\$\(CC\).* -o \$\(TARGET\)_x|DXLANG_USE_X_PIPELINE.*-o \$\(TARGET\)_x' <<<"$_rec"; then
    fail "xlang-x-pipeline must not keep dual \$(CC) link body (wave845; shell owns link)"
  fi
  log "CHECK OK (wave845 xlang-x-pipeline shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ "$MODE" != "" ]; then
  case "$MODE" in
    -h|--help)
      echo "usage: $0 [--check]" >&2
      exit 0
      ;;
    *)
      echo "usage: $0 [--check]" >&2
      exit 2
      ;;
  esac
fi

# ---------------------------------------------------------------------------
# Preflight: link env from Makefile thin-call (G.7: bags stay mk expansion)
# ---------------------------------------------------------------------------
if [ -z "${XXP_BASE_OBJS:-}" ]; then
  fail "XXP_BASE_OBJS required (Makefile thin-call must export expanded \$(PIPELINE_X_BASE_OBJS))"
fi
if [ -z "${XXP_FRONTEND_OBJS:-}" ]; then
  fail "XXP_FRONTEND_OBJS required (Makefile thin-call must export expanded \$(PIPELINE_X_FRONTEND_OBJS))"
fi
if [ -z "${XXP_LINK_OBJS:-}" ]; then
  fail "XXP_LINK_OBJS required (Makefile thin-call must export expanded \$(PIPELINE_X_LINK_OBJS))"
fi
if [ -z "${XXP_SATELLITE_OBJS:-}" ]; then
  fail "XXP_SATELLITE_OBJS required (Makefile thin-call must export expanded \$(PIPELINE_X_SATELLITE_OBJS))"
fi
if [ -z "${XXP_LSP_DIAG:-}" ]; then
  fail "XXP_LSP_DIAG required (Makefile thin-call must export \$(LSP_DIAG_LINK_O) + sizes.o)"
fi
# XXP_LIBS may be empty (non-Linux) — OK

# ---------------------------------------------------------------------------
# Ensure ladder (same order as pre-wave845 Makefile body)
# PLATFORM: SHARED — residual make edges for individual .o still via ensure/try-heat
# ---------------------------------------------------------------------------
log "force pipeline_x.o (PIPELINE_X_FORCE_COMPILE=1)"
# shellcheck disable=SC2086
$MAKE pipeline_x.o PIPELINE_X_FORCE_COMPILE=1

log "migrate-x-objs + satellites + build-seed-asm-host"
# shellcheck disable=SC2086
$MAKE migrate-x-objs $XXP_SATELLITE_OBJS build-seed-asm-host

log "force target_cpu / simd_enc / simd_loop (-B)"
# shellcheck disable=SC2086
$MAKE -B src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o

# ---------------------------------------------------------------------------
# host-cc link TARGET_x (archaeology .x pipeline binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this archaeology path
# ---------------------------------------------------------------------------
log "link ./$TARGET_X"
# shellcheck disable=SC2086
$CC $CFLAGS -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN \
  -o "./$TARGET_X" \
  $XXP_BASE_OBJS pipeline_x.o $XXP_FRONTEND_OBJS $XXP_LINK_OBJS \
  $XXP_LSP_DIAG $XXP_LIBS
echo "xlang_x built; use ./$TARGET_X -x -E <file.x> to test .x pipeline"
echo "xlang-x-pipeline OK ($TARGET_X)"

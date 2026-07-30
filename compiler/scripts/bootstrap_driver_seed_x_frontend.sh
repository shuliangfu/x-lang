#!/usr/bin/env bash
# bootstrap_driver_seed_x_frontend.sh — archaeology experiment binary
# $(TARGET)_x_frontend body (stage 10.4: .x typeck/codegen, no pipeline_x.o)
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target bootstrap-driver-seed-x-frontend:
#     host-cc link $(TARGET)_x_frontend with expanded bag from mk
#
#   Object lists stay mk expansion (archaeology_experiment_objs.mk
#   DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS + DRIVER_SUBCMD + PIPELINE_LIBS +
#   driver_x/preprocess_x/LSP_DIAG). Shell never hardcodes a second full link
#   inventory — Makefile thin-call exports expanded bags as BXF_* env vars.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_driver_seed_x_frontend.sh
#   bash scripts/bootstrap_driver_seed_x_frontend.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   CC                   — host C compiler
#   OUT / TARGET_OUT     — output binary (default: xlang_x_frontend)
#   BXF_LINK_CFLAGS      — expanded CFLAGS + -DXLANG_USE_X_* experiment defines
#   BXF_LINK_OBJS        — full expanded object bag for the link line
#
# wave848 (G.7 有则补全): Makefile fat $(CC) link → this script.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
OUT="${OUT:-${TARGET_OUT:-xlang_x_frontend}}"
CC="${CC:-cc}"

log() { echo "bootstrap-driver-seed-x-frontend: $*" >&2; }
fail() { echo "bootstrap-driver-seed-x-frontend: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Makefile thin-call only (wave848): scan *recipe* lines (tab-indented) only —
  # comments between targets must not false-positive on "$(CC)" prose.
  _rec=$(awk '
    /^bootstrap-driver-seed-x-frontend:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'bootstrap_driver_seed_x_frontend\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-seed-x-frontend must thin-call bootstrap_driver_seed_x_frontend.sh (wave848)"
  fi
  # Dual body: host-cc link line must not remain in recipe (shell owns).
  # Note: thin-call may export CC="$(CC)" — require -o shape / experiment defines.
  if grep -qE '\$\(CC\).* -o |\$\(CC\).*DXLANG_USE_X_TYPECK|\$\(CC\).*DRIVER_SEED_X_FRONTEND' <<<"$_rec"; then
    fail "bootstrap-driver-seed-x-frontend must not keep dual \$(CC) link body (wave848; shell owns link)"
  fi
  log "CHECK OK (wave848 bootstrap-driver-seed-x-frontend shell-primary; not physical delete)"
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
if [ -z "${BXF_LINK_CFLAGS:-}" ]; then
  fail "BXF_LINK_CFLAGS required (Makefile thin-call must export expanded link CFLAGS + defines)"
fi
if [ -z "${BXF_LINK_OBJS:-}" ]; then
  fail "BXF_LINK_OBJS required (Makefile thin-call must export expanded link bag)"
fi

# ---------------------------------------------------------------------------
# host-cc link $(TARGET)_x_frontend (stage 10.4 experiment binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $BXF_LINK_CFLAGS -o "./$OUT" $BXF_LINK_OBJS
echo "bootstrap-driver-seed-x-frontend OK (./$OUT: .x typeck/codegen, no pipeline_x.o)"

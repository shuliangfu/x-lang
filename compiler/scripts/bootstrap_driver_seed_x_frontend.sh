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
#   inventory — wave856: LINK_OBJS via make export-bxf-link-objs when unset;
#   wave857: LINK_CFLAGS via make export-bxf-link-cflags when unset.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_driver_seed_x_frontend.sh
#   bash scripts/bootstrap_driver_seed_x_frontend.sh --check
#
# Env (product path; shell defaults own when Makefile thin-call drops inject):
#   CC                   — host C compiler (default: cc)
#   TARGET               — product name for OUT default (default: xlang)
#   OUT / TARGET_OUT     — output binary (default: ${TARGET}_x_frontend)
#   BXF_LINK_CFLAGS      — expanded CFLAGS + -DXLANG_USE_X_* experiment defines
#   BXF_LINK_OBJS        — optional; default loads via export-bxf-link-objs
#                          (wave856; mk bag needs make expansion)
#   MAKE                 — residual make for LINK_OBJS export leaf (wave856)
#
# wave848 (G.7 有则补全): Makefile fat $(CC) link → this script.
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave880: drop Makefile multi-token MAKE/CC/OUT inject; shell defaults own OUT.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
OUT="${OUT:-${TARGET_OUT:-${TARGET}_x_frontend}}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"

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
  # wave856: Makefile must not re-export multi-token LINK bag (shell loads export leaf).
  if grep -qE 'BXF_LINK_OBJS=' <<<"$_rec"; then
    fail "bootstrap-driver-seed-x-frontend must not export BXF_LINK_OBJS (wave856; shell loads export leaf)"
  fi
  if grep -qE 'BXF_LINK_CFLAGS=' <<<"$_rec"; then
    fail "bootstrap-driver-seed-x-frontend must not export BXF_LINK_CFLAGS (wave857; shell loads export leaf)"
  fi
  if ! grep -qE '^export-bxf-link-objs:' "$MF"; then
    fail "Makefile must define export-bxf-link-objs (wave856)"
  fi
  if ! grep -qE '^export-bxf-link-cflags:' "$MF"; then
    fail "Makefile must define export-bxf-link-cflags (wave857)"
  fi
  log "CHECK OK (wave848+856+857 bootstrap-driver-seed-x-frontend shell-primary; LINK_OBJS+CFLAGS export leaves; not physical delete)"
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
# wave856: full LINK bag needs make expansion (nested $(...) / Darwin filters).
# G.7 有则补全 on bootstrap_driver_seed_export-*-link pattern — shell loads via
# make export leaf when env unset; Makefile recipes drop multi-token BXF_LINK_OBJS=.
# PLATFORM: SHARED — KEY=value from export target; no second .o inventory.
_load_link_objs_via_make() {
  # $1 = make export target (export-*-link-objs)
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BXF_LINK_OBJS:-}" ]; then
  BXF_LINK_OBJS=$(_load_link_objs_via_make export-bxf-link-objs) \
    || fail "failed to expand export-bxf-link-objs (wave856 LINK_OBJS shell-load)"
fi
if [ -z "${BXF_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from export-bxf-link-objs (wave856)"
fi

# wave857: composed LINK_CFLAGS need make expansion (DRIVER_SEED_LINK_FLAGS /
# ASM_GLUE / MAIN_LINK / platform ifeq). G.7 有则补全 on wave856 export-leaf pattern.
# PLATFORM: SHARED — KEY=value from export target; no second flag inventory.
_load_link_cflags_via_make() {
  # $1 = make export target (export-*-link-cflags)
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BXF_LINK_CFLAGS:-}" ]; then
  BXF_LINK_CFLAGS=$(_load_link_cflags_via_make export-bxf-link-cflags) \
    || fail "failed to expand export-bxf-link-cflags (wave857 LINK_CFLAGS shell-load)"
fi
if [ -z "${BXF_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from export-bxf-link-cflags (wave857)"
fi

# ---------------------------------------------------------------------------
# host-cc link $(TARGET)_x_frontend (stage 10.4 experiment binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $BXF_LINK_CFLAGS -o "./$OUT" $BXF_LINK_OBJS
echo "bootstrap-driver-seed-x-frontend OK (./$OUT: .x typeck/codegen, no pipeline_x.o)"

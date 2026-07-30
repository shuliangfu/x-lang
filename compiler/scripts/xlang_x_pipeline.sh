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
#   hardcodes a second PIPELINE_X_* inventory —
#   wave859: XXP_* bags via make export-xxp-link-bags when unset
#   (LINK needs nested $(USER_ASM_LINK) + PIPELINE_LIBS platform ifeq).
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_x_pipeline.sh
#   bash scripts/xlang_x_pipeline.sh --check
#
# Env (product path):
#   TARGET              — product binary basename (default: xlang)
#   TARGET_X            — .x-pipeline binary (default: ${TARGET}_x)
#   CC / CFLAGS         — host C compiler + flags
#                         CFLAGS default: load via export-try-heat-cflags when
#                         unset (wave865; G.7 有则补全 on wave862)
#   MAKE                — make binary (for residual ensure edges + export leaf)
#   XXP_BASE_OBJS       — optional; default loads via export-xxp-link-bags
#   XXP_FRONTEND_OBJS   — optional; default loads via export-xxp-link-bags
#   XXP_LINK_OBJS       — optional; default loads via export-xxp-link-bags
#   XXP_SATELLITE_OBJS  — optional; default loads via export-xxp-link-bags
#   XXP_LSP_DIAG        — optional; default loads via export-xxp-link-bags
#   XXP_LIBS            — optional; default loads via export-xxp-link-bags
#                          (may be empty on non-Linux)
#
# wave845 (G.7 有则补全): Makefile fat multi-make + $(CC) link → this script.
# wave859: XXP_* shell-load via make export leaf (G.7; not physical delete).
# wave865: CFLAGS shell-load via export-try-heat-cflags (no multi-token CFLAGS=).
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
TARGET_X="${TARGET_X:-${TARGET}_x}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"
# wave865: product CFLAGS need make expansion (OPT/-I); recipe no longer injects.
if [ -z "${CFLAGS+x}" ]; then
  _raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-try-heat-cflags 2>/dev/null || true)
  while IFS= read -r _line || [ -n "${_line:-}" ]; do
    case "$_line" in
      CFLAGS=*) CFLAGS=${_line#CFLAGS=} ;;
    esac
  done <<<"${_raw:-}"
fi
CFLAGS="${CFLAGS:-}"

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
  # wave859: Makefile must not re-export multi-token XXP bags (shell loads export leaf).
  if grep -qE 'XXP_BASE_OBJS=|XXP_FRONTEND_OBJS=|XXP_LINK_OBJS=|XXP_SATELLITE_OBJS=|XXP_LSP_DIAG=|XXP_LIBS=' <<<"$_rec"; then
    fail "xlang-x-pipeline must not export XXP_* bags (wave859; shell loads export-xxp-link-bags)"
  fi
  # wave865: no multi-token CFLAGS="$(CFLAGS)" on recipe (shell loads export leaf).
  if grep -qE 'CFLAGS="\$\(CFLAGS\)"' <<<"$_rec"; then
    fail "xlang-x-pipeline must not export CFLAGS= (wave865; shell loads export-try-heat-cflags)"
  fi
  if ! grep -qE '^export-xxp-link-bags:' "$MF"; then
    fail "Makefile must define export-xxp-link-bags (wave859)"
  fi
  if ! grep -qE '^export-try-heat-cflags:' "$MF"; then
    fail "Makefile must define export-try-heat-cflags (wave865)"
  fi
  log "CHECK OK (wave845+859+865 xlang-x-pipeline shell-primary; XXP bags + CFLAGS export leaf; not physical delete)"
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
# Preflight: XXP bags from make export leaf when unset (wave859; G.7)
# PIPELINE_X_LINK_OBJS needs nested $(USER_ASM_LINK); PIPELINE_LIBS platform ifeq.
# PLATFORM: SHARED — KEY=value from export target; no second .o inventory.
# ---------------------------------------------------------------------------
_load_xxp_bags_via_make() {
  local raw line
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-xxp-link-bags) || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      XXP_BASE_OBJS=*) XXP_BASE_OBJS=${line#XXP_BASE_OBJS=} ;;
      XXP_FRONTEND_OBJS=*) XXP_FRONTEND_OBJS=${line#XXP_FRONTEND_OBJS=} ;;
      XXP_LINK_OBJS=*) XXP_LINK_OBJS=${line#XXP_LINK_OBJS=} ;;
      XXP_SATELLITE_OBJS=*) XXP_SATELLITE_OBJS=${line#XXP_SATELLITE_OBJS=} ;;
      XXP_LSP_DIAG=*) XXP_LSP_DIAG=${line#XXP_LSP_DIAG=} ;;
      XXP_LIBS=*) XXP_LIBS=${line#XXP_LIBS=} ;;
    esac
  done <<<"$raw"
  return 0
}

# Load when any required bag missing, or XXP_LIBS completely unset (empty OK on non-Linux).
if [ -z "${XXP_BASE_OBJS:-}" ] || [ -z "${XXP_FRONTEND_OBJS:-}" ] || \
   [ -z "${XXP_LINK_OBJS:-}" ] || [ -z "${XXP_SATELLITE_OBJS:-}" ] || \
   [ -z "${XXP_LSP_DIAG:-}" ] || [ -z "${XXP_LIBS+x}" ]; then
  _load_xxp_bags_via_make \
    || fail "failed to expand export-xxp-link-bags (wave859 XXP shell-load)"
fi
if [ -z "${XXP_BASE_OBJS:-}" ]; then
  fail "empty XXP_BASE_OBJS from export-xxp-link-bags (wave859)"
fi
if [ -z "${XXP_FRONTEND_OBJS:-}" ]; then
  fail "empty XXP_FRONTEND_OBJS from export-xxp-link-bags (wave859)"
fi
if [ -z "${XXP_LINK_OBJS:-}" ]; then
  fail "empty XXP_LINK_OBJS from export-xxp-link-bags (wave859)"
fi
if [ -z "${XXP_SATELLITE_OBJS:-}" ]; then
  fail "empty XXP_SATELLITE_OBJS from export-xxp-link-bags (wave859)"
fi
if [ -z "${XXP_LSP_DIAG:-}" ]; then
  fail "empty XXP_LSP_DIAG from export-xxp-link-bags (wave859)"
fi
# XXP_LIBS may be empty (non-Linux) — OK; ensure variable is set for set -u
: "${XXP_LIBS:=}"

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

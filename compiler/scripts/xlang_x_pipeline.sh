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
#   wave859: XXP_* bags when unset (was make export-xxp-link-bags)
#   wave946: catalog-primary from PIPELINE_X_* / LSP_DIAG_LINK_O / PIPELINE_LIBS
#   wave947: ensure ladder shell-primary (try-heat / migrate / build_seed_asm_host;
#            was $MAKE residual after Makefile delete)
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_x_pipeline.sh
#   bash scripts/xlang_x_pipeline.sh --check
#
# Env (product path):
#   TARGET              — product binary basename (default: xlang)
#   TARGET_X            — .x-pipeline binary (default: ${TARGET}_x)
#   CC / CFLAGS         — host C compiler + flags
#                         CFLAGS default: catalog-primary when unset (wave943)
#   MAKE                — residual escape only (XLANG_XXP_ENSURE_VIA_MAKE=1 + MF)
#   XXP_BASE_OBJS       — optional; default: PIPELINE_X_BASE_OBJS via catalog
#   XXP_FRONTEND_OBJS   — optional; default: PIPELINE_X_FRONTEND_OBJS via catalog
#   XXP_LINK_OBJS       — optional; default: PIPELINE_X_LINK_OBJS via catalog
#   XXP_SATELLITE_OBJS  — optional; default: PIPELINE_X_SATELLITE_OBJS via catalog
#   XXP_LSP_DIAG        — optional; default: LSP_DIAG_LINK_O via catalog
#   XXP_LIBS            — optional; default: PIPELINE_LIBS via catalog (empty OK)
#   XLANG_XXP_ENSURE_VIA_MAKE=1 — escape ensure ladder to make (needs Makefile)
#
# wave845 (G.7 有则补全): Makefile fat multi-make + $(CC) link → this script.
# wave859: XXP_* shell-load (was make export leaf).
# wave865/943: CFLAGS catalog-primary.
# wave946: XXP bags catalog-primary (Makefile physically deleted wave941).
# wave947: ensure ladder 0-make (try-heat / migrate_x_objs / build_seed_asm_host).
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
TARGET_X="${TARGET_X:-${TARGET}_x}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"
# wave943: catalog-primary CFLAGS load (was make export-try-heat-cflags).
# Makefile physically deleted in wave941; catalog is the single authority.
# XLANG_CATALOG_CACHE_FILE lets the parent bootstrap pass a pre-warmed cache.
# PLATFORM: SHARED — same KEY=VALUE semantics on Darwin/Linux/Windows MSYS2.
if [ -z "${CFLAGS+x}" ]; then
  if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
    CFLAGS=$(sed -n "s|^CFLAGS=||p" "${XLANG_CATALOG_CACHE_FILE}" | tail -n 1)
  else
    CFLAGS=$(bash scripts/driver_seed_obj_catalog.sh --shell 2>/dev/null \
      | sed -n "s|^CFLAGS=||p" | tail -n 1)
  fi
fi
CFLAGS="${CFLAGS:-}"

log() { echo "xlang-x-pipeline: $*" >&2; }
fail() { echo "xlang-x-pipeline: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave947: post-delete honesty — script body must own ensure ladder without
  # bare $MAKE product edges (escape only via XLANG_XXP_ENSURE_VIA_MAKE).
  # PLATFORM: SHARED — same grep on this file on Darwin/Linux/Windows MSYS2.
  _self=$(cat scripts/xlang_x_pipeline.sh 2>/dev/null || cat "$0")
  # Product ensure path must be shell-primary. Escape may still mention $MAKE
  # only under XLANG_XXP_ENSURE_VIA_MAKE (parity); that is not the default path.
  if ! printf '%s\n' "$_self" | grep -qE 'ensure_host_cc_seed_o\.sh try-heat pipeline_x\.o'; then
    fail "ensure ladder must force pipeline_x.o via try-heat (wave947; G.7 wave929 twin)"
  fi
  if ! printf '%s\n' "$_self" | grep -qE 'migrate_x_objs\.sh'; then
    fail "ensure ladder must call migrate_x_objs.sh (wave947)"
  fi
  if ! printf '%s\n' "$_self" | grep -qE 'build_seed_asm_host\.sh'; then
    fail "ensure ladder must call build_seed_asm_host.sh (wave947)"
  fi
  if ! printf '%s\n' "$_self" | grep -qE 'XLANG_XXP_ENSURE_VIA_MAKE'; then
    fail "ensure ladder must gate any make escape with XLANG_XXP_ENSURE_VIA_MAKE (wave947)"
  fi
  # Default product path must not be an unguarded top-level $MAKE ensure edge.
  # Count unguarded: lines that are `$MAKE …` after a non-escape assignment are
  # still allowed inside the escape branch only (checked by presence of gate).
  if [ ! -f "$MF" ]; then
    log "CHECK OK (wave947; Makefile deleted; ensure ladder shell-primary + catalog bags)"
    exit 0
  fi
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
  log "CHECK OK (wave845+859+865+947 xlang-x-pipeline shell-primary ensure + bags)"
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
# Preflight: XXP bags (wave946 catalog-primary; G.7 有则补全 on wave859/926)
# Map mk/catalog keys → XXP_* env used by this archaeology link body.
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
# Escape: XLANG_XXP_LINK_VIA_MAKE=1 + Makefile present (parity only).
# ---------------------------------------------------------------------------
_load_xxp_bags() {
  local raw line
  if [ "${XLANG_XXP_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
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
  else
    if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
      raw=$(cat "${XLANG_CATALOG_CACHE_FILE}")
    else
      raw=$(bash scripts/driver_seed_obj_catalog.sh --shell 2>/dev/null) || return 1
    fi
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in
        PIPELINE_X_BASE_OBJS=*) XXP_BASE_OBJS=${line#PIPELINE_X_BASE_OBJS=} ;;
        PIPELINE_X_FRONTEND_OBJS=*) XXP_FRONTEND_OBJS=${line#PIPELINE_X_FRONTEND_OBJS=} ;;
        PIPELINE_X_LINK_OBJS=*) XXP_LINK_OBJS=${line#PIPELINE_X_LINK_OBJS=} ;;
        PIPELINE_X_SATELLITE_OBJS=*) XXP_SATELLITE_OBJS=${line#PIPELINE_X_SATELLITE_OBJS=} ;;
        LSP_DIAG_LINK_O=*) XXP_LSP_DIAG=${line#LSP_DIAG_LINK_O=} ;;
        PIPELINE_LIBS=*) XXP_LIBS=${line#PIPELINE_LIBS=} ;;
      esac
    done <<<"$raw"
  fi
  return 0
}

# Load when any required bag missing, or XXP_LIBS completely unset (empty OK on non-Linux).
if [ -z "${XXP_BASE_OBJS:-}" ] || [ -z "${XXP_FRONTEND_OBJS:-}" ] || \
   [ -z "${XXP_LINK_OBJS:-}" ] || [ -z "${XXP_SATELLITE_OBJS:-}" ] || \
   [ -z "${XXP_LSP_DIAG:-}" ] || [ -z "${XXP_LIBS+x}" ]; then
  _load_xxp_bags \
    || fail "failed to expand XXP bags (wave946 catalog PIPELINE_X_* / PIPELINE_LIBS)"
fi
if [ -z "${XXP_BASE_OBJS:-}" ]; then
  fail "empty XXP_BASE_OBJS from catalog PIPELINE_X_BASE_OBJS (wave946)"
fi
if [ -z "${XXP_FRONTEND_OBJS:-}" ]; then
  fail "empty XXP_FRONTEND_OBJS from catalog PIPELINE_X_FRONTEND_OBJS (wave946)"
fi
if [ -z "${XXP_LINK_OBJS:-}" ]; then
  fail "empty XXP_LINK_OBJS from catalog PIPELINE_X_LINK_OBJS (wave946)"
fi
if [ -z "${XXP_SATELLITE_OBJS:-}" ]; then
  fail "empty XXP_SATELLITE_OBJS from catalog PIPELINE_X_SATELLITE_OBJS (wave946)"
fi
if [ -z "${XXP_LSP_DIAG:-}" ]; then
  fail "empty XXP_LSP_DIAG from catalog LSP_DIAG_LINK_O (wave946)"
fi
# XXP_LIBS may be empty (non-Linux) — OK; ensure variable is set for set -u.
: "${XXP_LIBS:=}"

# ---------------------------------------------------------------------------
# Ensure ladder (same order as pre-wave845 Makefile body)
# wave947: shell-primary — no bare $MAKE (Makefile deleted wave941).
# G.7 有则补全: try-heat / migrate_x_objs / build_seed_asm_host already own
# the leaf bodies (wave735/789/929 twins). Escape: XLANG_XXP_ENSURE_VIA_MAKE=1
# + Makefile present only (parity / archaeology debug).
# PLATFORM: SHARED — same shell edges on Darwin/Linux/Windows MSYS2.
# ---------------------------------------------------------------------------
_xxp_ensure_via_make=0
if [ "${XLANG_XXP_ENSURE_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
  _xxp_ensure_via_make=1
fi

if [ "$_xxp_ensure_via_make" = "1" ]; then
  log "ensure via make escape (XLANG_XXP_ENSURE_VIA_MAKE=1)"
  # shellcheck disable=SC2086
  $MAKE pipeline_x.o PIPELINE_X_FORCE_COMPILE=1
  # shellcheck disable=SC2086
  $MAKE migrate-x-objs $XXP_SATELLITE_OBJS build-seed-asm-host
  # shellcheck disable=SC2086
  $MAKE -B src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
else
  # 1) force pipeline_x.o — twin of build_xlang_asm wave929 try-heat path
  log "force pipeline_x.o via try-heat (PIPELINE_X_FORCE_COMPILE=1)"
  if [ ! -f scripts/ensure_host_cc_seed_o.sh ]; then
    fail "missing scripts/ensure_host_cc_seed_o.sh (wave947 ensure ladder)"
  fi
  PIPELINE_X_FORCE_COMPILE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat pipeline_x.o \
    || fail "try-heat pipeline_x.o failed (wave947)"

  # 2) migrate companion frontend .o (parser/typeck/codegen _x)
  log "migrate-x-objs via migrate_x_objs.sh"
  if [ ! -f scripts/migrate_x_objs.sh ]; then
    fail "missing scripts/migrate_x_objs.sh (wave947 ensure ladder)"
  fi
  bash scripts/migrate_x_objs.sh all \
    || fail "migrate_x_objs.sh failed (wave947)"

  # 3) satellite .o bag (catalog PIPELINE_X_SATELLITE_OBJS → XXP_SATELLITE_OBJS)
  log "satellites via try-heat ($XXP_SATELLITE_OBJS)"
  # shellcheck disable=SC2086
  for _sat in $XXP_SATELLITE_OBJS; do
    [ -z "$_sat" ] && continue
    bash scripts/ensure_host_cc_seed_o.sh try-heat "$_sat" \
      || fail "try-heat satellite $_sat failed (wave947)"
  done

  # 4) seed asm host partials (backend_enc_* for pipeline_x consumers)
  log "build-seed-asm-host via build_seed_asm_host.sh"
  if [ ! -f scripts/build_seed_asm_host.sh ]; then
    fail "missing scripts/build_seed_asm_host.sh (wave947 ensure ladder)"
  fi
  bash scripts/build_seed_asm_host.sh \
    || fail "build_seed_asm_host.sh failed (wave947)"

  # 5) force target_cpu / simd_enc / simd_loop (gen_driver may lag; historical -B)
  log "force target_cpu / simd_enc / simd_loop (XLANG_HOST_CC_SEED_FORCE=1)"
  for _force_o in \
    src/driver/target_cpu.o \
    src/asm/simd_enc.o \
    src/asm/simd_loop.o
  do
    XLANG_HOST_CC_SEED_FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat "$_force_o" \
      || fail "try-heat force $_force_o failed (wave947)"
  done
fi

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

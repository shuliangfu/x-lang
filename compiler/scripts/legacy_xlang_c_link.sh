#!/usr/bin/env bash
# legacy_xlang_c_link.sh — archaeology XLANG_LEGACY_C_FRONTEND=1 host-cc link of xlang-c
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target $(XLANG_C) under
#   XLANG_LEGACY_C_FRONTEND=1 (wave858). Default product path stays:
#     $(XLANG_C): bootstrap_xlangc → cp (non-LEGACY).
#
#   Object list authority: mk/driver_seed_composites.mk LEGACY_XLANG_C_* (wave822).
#   wave858: LINK_OBJS via make export-legacy-xlang-c-link-objs when unset;
#            LINK_CFLAGS reuses export-relink-product-link-cflags (same formula as
#            product archaeology — G.7 no dual flag inventory).
#   wave926: catalog-primary LINK bag (0-make when MF present still optional).
#   wave961: catalog-primary + --check post_ship when Makefile absent (wave941
#            phys-del). XLANG_LEGACY_LINK_VIA_MAKE=1 + MF escapes only.
#
# Usage (cwd = compiler/):
#   bash scripts/legacy_xlang_c_link.sh
#   bash scripts/legacy_xlang_c_link.sh --check
#
# Env:
#   OUT / XLANG_C   — output binary (default: xlang-c)
#   CC              — host C compiler
#   LEGACY_LINK_OBJS — optional; default: catalog --link-objs-export legacy-xlang-c
#                      (wave926/961; same bag as historic export-legacy-xlang-c-link-objs)
#   LEGACY_LINK_CFLAGS — optional; default: catalog --link-cflags-export relink-product
#                      (wave926/961; CFLAGS reuse product archaeology)
#   XLANG_LEGACY_LINK_VIA_MAKE=1 — escape LINK bag load to make export (needs MF)
#   MAKE            — residual make for VIA_MAKE escape only
#
# wave858: Makefile multi-token $(CC) … LEGACY_XLANG_C_* body → this script.
# wave880: drop Makefile multi-token MAKE/CC/OUT inject; shell defaults own OUT.
# wave926: catalog --link-objs-export legacy-xlang-c + --link-cflags-export relink-product.
# wave961: --check post_ship when Makefile absent (wave941 phys-del);
#          VIA_MAKE gated on MF present.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; archaeology host-cc link only.
set -euo pipefail
# wave961/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

MODE="${1:-run}"
OUT="${OUT:-${XLANG_C:-xlang-c}}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"

log() { echo "legacy-xlang-c-link: $*" >&2; }
fail() { echo "legacy-xlang-c-link: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave961 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own host-cc link + LEGACY LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export legacy-xlang-c\|link-objs-export legacy-xlang-c' "$_SCRIPT_SELF"; then
      fail "legacy_xlang_c_link must catalog-load LEGACY LINK_OBJS (wave961 post_ship)"
    fi
    if ! grep -q 'link-cflags-export relink-product\|--link-cflags-export relink-product' "$_SCRIPT_SELF"; then
      fail "legacy_xlang_c_link must catalog-load relink-product LINK_CFLAGS (wave961 post_ship)"
    fi
    if ! grep -q 'XLANG_LEGACY_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "legacy_xlang_c_link must document XLANG_LEGACY_LINK_VIA_MAKE escape (wave961)"
    fi
    # Product body still owns host-cc link.
    if ! grep -qE '\$CC.*LEGACY_LINK|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "legacy_xlang_c_link must own host-cc link body (wave858/961)"
    fi
    if ! grep -q 'wave961\|wave858\|wave926' "$_SCRIPT_SELF"; then
      fail "legacy_xlang_c_link must document wave858/926/961 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave961; LEGACY bag authority)"
    fi
    if [ ! -f mk/driver_seed_composites.mk ]; then
      fail "missing mk/driver_seed_composites.mk (wave822 LEGACY authority)"
    fi
    if ! grep -qE '^LEGACY_XLANG_C_PREREQS[[:space:]]*[:?]?=' mk/driver_seed_composites.mk; then
      fail "mk/driver_seed_composites.mk must define LEGACY_XLANG_C_PREREQS (wave822)"
    fi
    log "CHECK OK (wave961 post_ship; catalog LEGACY bag; shell-primary; 0-make)"
    exit 0
  fi
  # Recipe lines under XLANG_LEGACY_C_FRONTEND=1 XLANG_C target: shell thin-call only.
  # Scan for dual multi-token $(CC) … LEGACY_XLANG_C_LINK body in recipe tabs.
  if grep -nE $'^\t\$\(CC\).*LEGACY_XLANG_C_LINK' "$MF" 2>/dev/null | grep -q .; then
    fail "Makefile must not keep dual \$(CC) LEGACY_XLANG_C_LINK body (wave858; shell owns link)"
  fi
  if grep -nE $'^\t\$\(CC\).*DRIVER_SEED_LINK_FLAGS.*LEGACY_XLANG_C' "$MF" 2>/dev/null | grep -q .; then
    fail "Makefile must not keep dual \$(CC) LEGACY link body (wave858; shell owns link)"
  fi
  # Thin-call present when LEGACY path is active (recipe invokes this script).
  if ! grep -q 'legacy_xlang_c_link\.sh' "$MF"; then
    fail "Makefile must thin-call legacy_xlang_c_link.sh (wave858)"
  fi
  if ! grep -qE '^export-legacy-xlang-c-link-objs:' "$MF"; then
    fail "Makefile must define export-legacy-xlang-c-link-objs (wave858)"
  fi
  if ! grep -qE '^export-relink-product-link-cflags:' "$MF"; then
    fail "Makefile must define export-relink-product-link-cflags (wave857; CFLAGS reuse)"
  fi
  if [ ! -f mk/driver_seed_composites.mk ]; then
    fail "missing mk/driver_seed_composites.mk (wave822 LEGACY authority)"
  fi
  if ! grep -qE '^LEGACY_XLANG_C_PREREQS[[:space:]]*[:?]?=' mk/driver_seed_composites.mk; then
    fail "mk/driver_seed_composites.mk must define LEGACY_XLANG_C_PREREQS (wave822)"
  fi
  # wave961 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export legacy-xlang-c' "$_SCRIPT_SELF"; then
    fail "legacy_xlang_c_link must catalog-load LEGACY LINK_OBJS (wave961)"
  fi
  if ! grep -q 'XLANG_LEGACY_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "legacy_xlang_c_link must document XLANG_LEGACY_LINK_VIA_MAKE escape (wave961)"
  fi
  log "CHECK OK (wave858+926+961 legacy xlang-c shell-primary; catalog LEGACY bag; not physical delete)"
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
# wave926/961: full LEGACY link bag via shell catalog (0 make; replaces wave858
# make export leaves). G.7 有则补全 on catalog --link-objs/cflags-export.
# XLANG_LEGACY_LINK_VIA_MAKE=1 + Makefile present escapes to make export (parity).
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
# ---------------------------------------------------------------------------
_load_link_objs() {
  local raw line val
  if [ "${XLANG_LEGACY_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-legacy-xlang-c-link-objs) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-objs-export legacy-xlang-c 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

_load_link_cflags() {
  local raw line val
  if [ "${XLANG_LEGACY_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-relink-product-link-cflags) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-cflags-export relink-product 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${LEGACY_LINK_OBJS:-}" ]; then
  LEGACY_LINK_OBJS=$(_load_link_objs) \
    || fail "failed to expand legacy-xlang-c link-objs (wave961 catalog)"
fi
if [ -z "${LEGACY_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from legacy-xlang-c link-objs (wave961)"
fi

# CFLAGS formula identical to product archaeology relink-product bag.
# G.7: reuse catalog bag — do not invent a second flag inventory for LEGACY.
if [ -z "${LEGACY_LINK_CFLAGS:-}" ]; then
  LEGACY_LINK_CFLAGS=$(_load_link_cflags) \
    || fail "failed to expand relink-product link-cflags (wave961 CFLAGS reuse)"
fi
if [ -z "${LEGACY_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from relink-product link-cflags (wave961)"
fi

# ---------------------------------------------------------------------------
# host-cc link archaeology xlang-c (LEGACY C frontend)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT (LEGACY C frontend archaeology)"
# shellcheck disable=SC2086
$CC $LEGACY_LINK_CFLAGS -o "./$OUT" $LEGACY_LINK_OBJS
echo "legacy-xlang-c-link OK ($OUT)"

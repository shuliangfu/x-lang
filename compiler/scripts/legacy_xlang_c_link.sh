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
#
# Usage (cwd = compiler/):
#   bash scripts/legacy_xlang_c_link.sh
#   bash scripts/legacy_xlang_c_link.sh --check
#
# Env:
#   OUT / XLANG_C   — output binary (default: xlang-c)
#   CC              — host C compiler
#   LEGACY_LINK_OBJS — optional; default loads via export-legacy-xlang-c-link-objs
#   LEGACY_LINK_CFLAGS — optional; default loads via export-relink-product-link-cflags
#   MAKE            — residual make for export leaves
#
# wave858: Makefile multi-token $(CC) … LEGACY_XLANG_C_* body → this script.
# wave880: drop Makefile multi-token MAKE/CC/OUT inject; shell defaults own OUT.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; archaeology host-cc link only.
set -euo pipefail
cd "$(dirname "$0")/.."

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
  [ -f "$MF" ] || fail "missing $MF"
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
  log "CHECK OK (wave858 legacy xlang-c shell-primary; LINK_OBJS export leaf; CFLAGS reuse product; not physical delete)"
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
# wave926: full LEGACY link bag via shell catalog (0 make; replaces wave858
# make export leaves). G.7 有则补全 on catalog --link-objs/cflags-export.
# XLANG_LEGACY_LINK_VIA_MAKE=1 escapes to make export (parity / debug).
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
# ---------------------------------------------------------------------------
_load_link_objs() {
  local raw line val
  if [ "${XLANG_LEGACY_LINK_VIA_MAKE:-0}" = "1" ]; then
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
  if [ "${XLANG_LEGACY_LINK_VIA_MAKE:-0}" = "1" ]; then
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
    || fail "failed to expand legacy-xlang-c link-objs (wave926 catalog)"
fi
if [ -z "${LEGACY_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from legacy-xlang-c link-objs (wave926)"
fi

# CFLAGS formula identical to product archaeology relink-product bag.
# G.7: reuse catalog bag — do not invent a second flag inventory for LEGACY.
if [ -z "${LEGACY_LINK_CFLAGS:-}" ]; then
  LEGACY_LINK_CFLAGS=$(_load_link_cflags) \
    || fail "failed to expand relink-product link-cflags (wave926 CFLAGS reuse)"
fi
if [ -z "${LEGACY_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from relink-product link-cflags (wave926)"
fi

# ---------------------------------------------------------------------------
# host-cc link archaeology xlang-c (LEGACY C frontend)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT (LEGACY C frontend archaeology)"
# shellcheck disable=SC2086
$CC $LEGACY_LINK_CFLAGS -o "./$OUT" $LEGACY_LINK_OBJS
echo "legacy-xlang-c-link OK ($OUT)"

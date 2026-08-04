#!/usr/bin/env bash
# xlang_x.sh — product binary xlang-x body (host-cc relink)
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target xlang-x:
#     1) preflight required driver/lsp satellite .o (seed must exist)
#     2) host-cc link ./xlang-x with expanded bag from mk via catalog
#
#   Object lists stay mk expansion (driver_seed_composites / user_asm /
#   link_picks / subcmd). Shell never hardcodes a second full link inventory —
#   wave856: LINK_OBJS via make export-xlang-x-link-objs when unset;
#   wave857: LINK_CFLAGS via make export-relink-product-link-cflags when unset
#   (same formula as RXL product link flags);
#   wave956: catalog-primary (0-make post-delete):
#     --link-objs-export xlang-x + --link-cflags-export relink-product
#     XLANG_XXL_LINK_VIA_MAKE=1 + MF escapes to historic make export.
#
#   Seed-gate REQUIRED bag authority: mk/driver_seed_composites.mk
#   XLANG_X_REQUIRED_OBJS (wave854 list → mk; wave855 shell loads mk —
#   Makefile must not re-export multi-token XXL_REQUIRED_OBJS).
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_x.sh
#   bash scripts/xlang_x.sh --check
#
# Env (product path):
#   XLANG_X / TARGET_OUT — output binary (default: xlang-x)
#   CC                   — host C compiler
#   XXL_LINK_CFLAGS      — optional; default: catalog --link-cflags-export
#                          relink-product (wave956; same formula as historic
#                          export-relink-product-link-cflags / RXL)
#   XXL_LINK_OBJS        — optional; default: catalog --link-objs-export xlang-x
#                          (wave956; mk XLANG_X_LINK_OBJS via catalog)
#   XXL_REQUIRED_OBJS    — optional override; default loads XLANG_X_REQUIRED_OBJS
#                          from mk (wave855; not a second list authority)
#   XLANG_XXL_LINK_VIA_MAKE=1 — escape LINK bag load to make export (needs MF)
#   MAKE                 — residual make for VIA_MAKE escape only
#
# wave846 (G.7 有则补全): Makefile fat test + $(CC) link → this script.
# wave855: seed-gate REQUIRED loads from mk (G.7; not physical delete).
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave956: catalog-primary LINK bag (0-make post-delete); --check post_ship when
#   Makefile absent (wave941 phys-del). XLANG_XXL_LINK_VIA_MAKE + MF escape only.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
# wave956/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

MODE="${1:-run}"
OUT="${XLANG_X:-${TARGET_OUT:-xlang-x}}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"

log() { echo "xlang-x: $*" >&2; }
fail() { echo "xlang-x: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave956 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own seed-gate + host-cc link + XXL LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export xlang-x\|link-objs-export xlang-x' "$_SCRIPT_SELF"; then
      fail "xlang_x must catalog-load XXL LINK_OBJS (wave956 post_ship)"
    fi
    if ! grep -q 'link-cflags-export relink-product\|--link-cflags-export relink-product' "$_SCRIPT_SELF"; then
      fail "xlang_x must catalog-load XXL LINK_CFLAGS (wave956 post_ship)"
    fi
    if ! grep -q 'XLANG_XXL_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "xlang_x must document XLANG_XXL_LINK_VIA_MAKE escape (wave956)"
    fi
    # Product body still owns seed gate + host-cc link.
    if ! grep -q 'XXL_REQUIRED_OBJS\|XLANG_X_REQUIRED_OBJS' "$_SCRIPT_SELF"; then
      fail "xlang_x must own seed-gate REQUIRED bag (wave855/956)"
    fi
    if ! grep -qE '\$CC.*XXL_LINK|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "xlang_x must own host-cc link body (wave846/956)"
    fi
    if ! grep -q 'wave956\|wave846' "$_SCRIPT_SELF"; then
      fail "xlang_x must document wave846/956 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave956; XXL bag authority)"
    fi
    if [ ! -f mk/driver_seed_composites.mk ]; then
      fail "missing mk/driver_seed_composites.mk (wave855 XLANG_X_REQUIRED_OBJS)"
    fi
    if ! grep -qE '^XLANG_X_REQUIRED_OBJS[[:space:]]*=' mk/driver_seed_composites.mk; then
      fail "mk/driver_seed_composites.mk must define XLANG_X_REQUIRED_OBJS (wave855)"
    fi
    log "CHECK OK (wave956 post_ship; catalog XXL bag; shell-primary; 0-make)"
    exit 0
  fi
  # Makefile thin-call only (wave846): scan *recipe* lines (tab-indented) only —
  # comments between targets must not false-positive on "$(CC)" prose.
  _rec=$(awk '
    /^xlang-x:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'xlang_x\.sh' <<<"$_rec"; then
    fail "xlang-x must thin-call xlang_x.sh (wave846)"
  fi
  # Dual body: host-cc link line must not remain in recipe (shell owns).
  # Note: thin-call may export CC="$(CC)" — require -o $@ / multi-obj shape.
  if grep -qE '\$\(CC\).*DRIVER_SEED_LINK_FLAGS|\$\(CC\).* -o \$@|\$\(CC\).* -o \$\@' <<<"$_rec"; then
    fail "xlang-x must not keep dual \$(CC) link body (wave846; shell owns link)"
  fi
  # Dual seed gate: long test -f ladder must not remain in recipe.
  if grep -qE 'test -f driver_x\.o && test -f lsp_x\.o' <<<"$_rec"; then
    fail "xlang-x must not keep dual test -f seed gate body (wave846; shell owns preflight)"
  fi
  # wave855: Makefile must not re-export multi-token REQUIRED bag (shell loads mk).
  if grep -qE 'XXL_REQUIRED_OBJS=' <<<"$_rec"; then
    fail "xlang-x must not export XXL_REQUIRED_OBJS (wave855; shell loads mk)"
  fi
  # wave856: Makefile must not re-export multi-token LINK bag (shell loads export leaf).
  if grep -qE 'XXL_LINK_OBJS=' <<<"$_rec"; then
    fail "xlang-x must not export XXL_LINK_OBJS (wave856; shell loads export leaf)"
  fi
  if grep -qE 'XXL_LINK_CFLAGS=' <<<"$_rec"; then
    fail "xlang-x must not export XXL_LINK_CFLAGS (wave857; shell loads export leaf)"
  fi
  if ! grep -qE '^export-xlang-x-link-objs:' "$MF"; then
    fail "Makefile must define export-xlang-x-link-objs (wave856)"
  fi
  if ! grep -qE '^export-relink-product-link-cflags:' "$MF"; then
    fail "Makefile must define export-relink-product-link-cflags (wave857)"
  fi
  if [ ! -f mk/driver_seed_composites.mk ]; then
    fail "missing mk/driver_seed_composites.mk (wave855 REQUIRED authority)"
  fi
  if ! grep -qE '^XLANG_X_REQUIRED_OBJS[[:space:]]*=' mk/driver_seed_composites.mk; then
    fail "mk/driver_seed_composites.mk must define XLANG_X_REQUIRED_OBJS (wave855)"
  fi
  # wave956 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export xlang-x' "$_SCRIPT_SELF"; then
    fail "xlang_x must catalog-load XXL LINK_OBJS (wave956)"
  fi
  if ! grep -q 'XLANG_XXL_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "xlang_x must document XLANG_XXL_LINK_VIA_MAKE escape (wave956)"
  fi
  log "CHECK OK (wave846+855+856+857+956 xlang-x shell-primary; catalog XXL bag; not physical delete)"
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
# Preflight: XXL LINK bag via shell catalog (0-make post-delete)
# ---------------------------------------------------------------------------
# wave956: full LINK bag via shell catalog (0 make; replaces wave856/857 make
# export leaves). G.7 有则补全 on catalog --link-objs/cflags-export (wave926).
# XLANG_XXL_LINK_VIA_MAKE=1 + Makefile present escapes to make export (parity).
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
_mk_assign_val() {
  # First KEY = value line from mk (strip comments / trailing space).
  # $1 = key, $2 = mk path
  local key="$1"
  local mk="$2"
  local line
  line=$(grep -E "^${key}[[:space:]]*=" "$mk" 2>/dev/null | head -1 | sed "s/^${key}[[:space:]]*=[[:space:]]*//;s/#.*//;s/[[:space:]]*$//")
  printf '%s' "$line"
}

_load_link_objs() {
  local raw line val
  if [ "${XLANG_XXL_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-xlang-x-link-objs) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-objs-export xlang-x 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${XXL_LINK_OBJS:-}" ]; then
  XXL_LINK_OBJS=$(_load_link_objs) \
    || fail "failed to expand xlang-x link-objs (wave956 catalog)"
fi
if [ -z "${XXL_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from xlang-x link-objs (wave956)"
fi

# wave956: composed LINK_CFLAGS via shell catalog (same formula as historic
# export-relink-product-link-cflags: CFLAGS + DRIVER_SEED_LINK_FLAGS +
# ASM_GLUE_DUP_LDFLAGS + MAIN_LINK_FLAGS). bag name "relink-product".
# PLATFORM: SHARED — KEY=value from catalog; no second flag inventory.
_load_link_cflags() {
  local raw line val
  if [ "${XLANG_XXL_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
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

if [ -z "${XXL_LINK_CFLAGS:-}" ]; then
  XXL_LINK_CFLAGS=$(_load_link_cflags) \
    || fail "failed to expand relink-product link-cflags (wave956 catalog)"
fi
if [ -z "${XXL_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from relink-product link-cflags (wave956)"
fi
if [ -z "${XXL_REQUIRED_OBJS:-}" ]; then
  _COMP_MK=mk/driver_seed_composites.mk
  [ -f "$_COMP_MK" ] || fail "missing $_COMP_MK (wave855 REQUIRED authority)"
  XXL_REQUIRED_OBJS=$(_mk_assign_val XLANG_X_REQUIRED_OBJS "$_COMP_MK")
fi
if [ -z "${XXL_REQUIRED_OBJS:-}" ]; then
  fail "failed to load XLANG_X_REQUIRED_OBJS from mk/driver_seed_composites.mk (wave855)"
fi

# ---------------------------------------------------------------------------
# Seed gate (same contract as pre-wave846 Makefile test -f ladder)
# PLATFORM: SHARED — missing satellites mean bootstrap-driver-seed not done
# ---------------------------------------------------------------------------
missing=0
# shellcheck disable=SC2086
for o in $XXL_REQUIRED_OBJS; do
  if [ ! -f "$o" ]; then
    log "missing required object: $o"
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  # wave956: 0-make post-delete — point at shell seed, not deleted Makefile target.
  fail "missing driver/lsp satellite .o — run: bash scripts/bootstrap_driver_seed.sh"
fi

# ---------------------------------------------------------------------------
# host-cc link ./xlang-x (product archaeology full-driver binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $XXL_LINK_CFLAGS -o "./$OUT" $XXL_LINK_OBJS
echo "xlang-x OK"

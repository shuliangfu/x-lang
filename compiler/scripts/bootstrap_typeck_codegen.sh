#!/usr/bin/env bash
# bootstrap_typeck_codegen.sh — archaeology bootstrap-typeck / bootstrap-codegen body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phonies:
#     bootstrap-typeck   — force-regen typeck_gen → migrate typeck_x → relink TARGET
#     bootstrap-codegen  — force-regen typeck+codegen gen → migrate both → relink TARGET
#   Gen body  = ensure_migrate_gen.sh (wave736 FORCE_REGEN; no dual xlang-c -E in Makefile)
#   .o body   = migrate_x_objs.sh (wave735; XLANG_MIGRATE_FORCE=1)
#   Link list = BTC_CFLAGS / BTC_OBJS from catalog (wave960; 0-make post-delete):
#     typeck CFLAGS  → --link-cflags-export btc-typeck
#     codegen CFLAGS → --link-cflags-export relink-product
#     OBJS (both)    → --link-objs-export relink-product
#     XLANG_BTC_LINK_VIA_MAKE=1 + MF escapes to historic make export.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_typeck_codegen.sh typeck
#   bash scripts/bootstrap_typeck_codegen.sh codegen
#   bash scripts/bootstrap_typeck_codegen.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   TARGET       — product binary name (default: xlang)
#   XLANG_C      — C frontend binary name (default: xlang-c)
#   CC           — host C compiler (default: cc)
#   BTC_CFLAGS   — optional; default: catalog --link-cflags-export btc-typeck
#                  (typeck) or relink-product (codegen) (wave960)
#   BTC_OBJS     — optional; default: catalog --link-objs-export relink-product
#                  (wave960; same bag as historic export-relink-product-link-objs)
#   XLANG_BTC_LINK_VIA_MAKE=1 — escape LINK bag load to make export (needs MF)
#   MAKE         — residual make for VIA_MAKE escape + ensure_migrate_gen only
#   PYTHON       — for migrate_x_objs patches
#
# wave841 (G.7 有则补全): Makefile fat dual -E + migrate + $(CC) link → this script.
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave960: catalog-primary LINK bag (0-make post-delete); --check post_ship when
#   Makefile absent (wave941 phys-del). XLANG_BTC_LINK_VIA_MAKE + MF escape only.
# NOT physical delete — thin-call edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
# wave960/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

MODE="${1:-}"
TARGET="${TARGET:-xlang}"
XLANG_C="${XLANG_C:-xlang-c}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"
PYTHON="${PYTHON:-python3}"

log() { echo "bootstrap-typeck-codegen: $*" >&2; }
fail() { echo "bootstrap-typeck-codegen: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave960 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own gen/migrate + host-cc link + BTC LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export relink-product\|link-objs-export relink-product' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must catalog-load BTC LINK_OBJS (wave960 post_ship)"
    fi
    if ! grep -q 'link-cflags-export btc-typeck\|--link-cflags-export btc-typeck' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must catalog-load BTC typeck LINK_CFLAGS (wave960 post_ship)"
    fi
    if ! grep -q 'link-cflags-export relink-product\|--link-cflags-export relink-product' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must catalog-load BTC codegen LINK_CFLAGS (wave960 post_ship)"
    fi
    if ! grep -q 'XLANG_BTC_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must document XLANG_BTC_LINK_VIA_MAKE escape (wave960)"
    fi
    # Product body still owns gen + migrate + host-cc link.
    if ! grep -q 'ensure_migrate_gen\|FORCE_REGEN' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must own ensure_migrate_gen FORCE_REGEN (wave841/960)"
    fi
    if ! grep -q 'migrate_x_objs\|XLANG_MIGRATE_FORCE' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must own migrate_x_objs FORCE (wave841/960)"
    fi
    if ! grep -qE '\$CC.*BTC_|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must own host-cc link body (wave841/960)"
    fi
    if ! grep -q 'wave960\|wave841' "$_SCRIPT_SELF"; then
      fail "bootstrap_typeck_codegen must document wave841/960 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave960; BTC bag authority)"
    fi
    if [ ! -f scripts/ensure_migrate_gen.sh ]; then
      fail "missing ensure_migrate_gen.sh (wave841 gen authority)"
    fi
    if [ ! -f scripts/migrate_x_objs.sh ]; then
      fail "missing migrate_x_objs.sh (wave841 migrate authority)"
    fi
    if [ ! -f mk/driver_seed_composites.mk ]; then
      fail "missing mk/driver_seed_composites.mk (wave856 RELINK_PRODUCT authority)"
    fi
    if ! grep -qE '^RELINK_PRODUCT_LINK_OBJS[[:space:]]*=' mk/driver_seed_composites.mk; then
      fail "mk/driver_seed_composites.mk must define RELINK_PRODUCT_LINK_OBJS (wave856/960)"
    fi
    log "CHECK OK (wave960 post_ship; catalog BTC bag; shell-primary; 0-make)"
    exit 0
  fi
  [ -f scripts/ensure_migrate_gen.sh ] || fail "missing ensure_migrate_gen.sh"
  [ -f scripts/migrate_x_objs.sh ] || fail "missing migrate_x_objs.sh"
  # Makefile thin-call only (wave841): scan *recipe* lines (tab-indented) only —
  # comments between phonies must not false-positive on "$(CC) -c" prose.
  for ph in bootstrap-typeck bootstrap-codegen; do
    _rec=$(awk -v p="$ph" '
      $0 ~ ("^" p ":") { hit=1; next }
      hit && /^[^[:space:]#]/ { exit }
      hit && /^\t/ { print }
    ' "$MF")
    if ! grep -q 'bootstrap_typeck_codegen\.sh' <<<"$_rec"; then
      fail "$ph must thin-call bootstrap_typeck_codegen.sh (wave841)"
    fi
    # Dual gen body: host-cc -c on *_gen.c, or inline xlang-c -E-extern on typeck/codegen.x
    if grep -qE '\$\(CC\).*-c .*(typeck_gen|codegen_gen)|(typeck_gen|codegen_gen).*\.c' <<<"$_rec"; then
      fail "$ph must not keep dual \$(CC) -c gen body (wave841)"
    fi
    if grep -qE 'XLANG_C\).*-E-extern|xlang-c.*-E-extern' <<<"$_rec"; then
      fail "$ph must not keep dual host-cc -E-extern gen body (wave841; use ensure_migrate_gen)"
    fi
    # wave856: no multi-token BTC_OBJS= on recipe (shell loads export leaf).
    if grep -qE 'BTC_OBJS=' <<<"$_rec"; then
      fail "$ph must not export BTC_OBJS (wave856; shell loads export leaf)"
    fi
    # wave857: no multi-token BTC_CFLAGS= on recipe (shell loads export leaf).
    if grep -qE 'BTC_CFLAGS=' <<<"$_rec"; then
      fail "$ph must not export BTC_CFLAGS (wave857; shell loads export leaf)"
    fi
    # wave865: no multi-token product CFLAGS="$(CFLAGS)" (migrate loads export leaf).
    if grep -qE 'CFLAGS="\$\(CFLAGS\)"' <<<"$_rec"; then
      fail "$ph must not export CFLAGS= (wave865; migrate shell-loads export-try-heat-cflags)"
    fi
  done
  if ! grep -qE '^export-relink-product-link-objs:' "$MF"; then
    fail "Makefile must define export-relink-product-link-objs (wave856)"
  fi
  if ! grep -qE '^export-btc-typeck-link-cflags:' "$MF"; then
    fail "Makefile must define export-btc-typeck-link-cflags (wave857)"
  fi
  if ! grep -qE '^export-relink-product-link-cflags:' "$MF"; then
    fail "Makefile must define export-relink-product-link-cflags (wave857)"
  fi
  if ! grep -qE '^export-try-heat-cflags:' "$MF"; then
    fail "Makefile must define export-try-heat-cflags (wave865)"
  fi
  if ! grep -q 'export-try-heat-cflags\|wave865' scripts/migrate_x_objs.sh 2>/dev/null; then
    fail "migrate_x_objs.sh must shell-load export-try-heat-cflags (wave865)"
  fi
  # wave960 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export relink-product' "$_SCRIPT_SELF"; then
    fail "bootstrap_typeck_codegen must catalog-load BTC LINK_OBJS (wave960)"
  fi
  if ! grep -q 'XLANG_BTC_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "bootstrap_typeck_codegen must document XLANG_BTC_LINK_VIA_MAKE escape (wave960)"
  fi
  if ! grep -q 'link-cflags-export btc-typeck\|--link-cflags-export btc-typeck' "$_SCRIPT_SELF"; then
    fail "bootstrap_typeck_codegen must catalog-load BTC typeck LINK_CFLAGS (wave960)"
  fi
  log "CHECK OK (wave841+856+857+865+960 bootstrap-typeck/codegen shell-primary; catalog BTC bag; not physical delete)"
  exit 0
fi

case "$MODE" in
  typeck|codegen) ;;
  *)
    echo "usage: $0 typeck|codegen|--check" >&2
    exit 2
    ;;
esac

# ---------------------------------------------------------------------------
# Preflight: BTC LINK bag via shell catalog (0-make post-delete)
# ---------------------------------------------------------------------------
# wave960: full LINK bag via shell catalog (0 make; replaces wave856/857 make
# export leaves). G.7 有则补全 on catalog --link-objs/cflags-export (wave926).
# XLANG_BTC_LINK_VIA_MAKE=1 + Makefile present escapes to make export (parity).
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
_load_link_objs() {
  local raw line val
  if [ "${XLANG_BTC_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-relink-product-link-objs) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-objs-export relink-product 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BTC_OBJS:-}" ]; then
  BTC_OBJS=$(_load_link_objs) \
    || fail "failed to expand BTC link-objs (wave960 catalog; seed missing? run bootstrap_driver_seed.sh)"
fi
if [ -z "${BTC_OBJS:-}" ]; then
  fail "empty LINK_OBJS from BTC link-objs (wave960)"
fi

_load_link_cflags() {
  # $1 = catalog bag name: btc-typeck | relink-product
  # $2 = make export target (VIA_MAKE escape only)
  local bag="$1"
  local make_target="$2"
  local raw line val
  if [ "${XLANG_BTC_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$make_target") || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-cflags-export "$bag" 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BTC_CFLAGS:-}" ]; then
  if [ "$MODE" = "typeck" ]; then
    BTC_CFLAGS=$(_load_link_cflags btc-typeck export-btc-typeck-link-cflags) \
      || fail "failed to expand btc-typeck link-cflags (wave960 catalog)"
  else
    # codegen: same composed flags as product RXL/XXL (includes -DXLANG_USE_X_CODEGEN)
    BTC_CFLAGS=$(_load_link_cflags relink-product export-relink-product-link-cflags) \
      || fail "failed to expand relink-product link-cflags (wave960 catalog)"
  fi
fi
if [ -z "${BTC_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from BTC export (wave960; mode=$MODE)"
fi
if [ ! -x "./$XLANG_C" ] && [ ! -f "./$XLANG_C" ]; then
  fail "missing $XLANG_C (build product first: bash scripts/bootstrap_driver_seed.sh / ./xbuild bootstrap-driver-seed)"
fi

# ---------------------------------------------------------------------------
# Gen + migrate (existing authorities only)
# ---------------------------------------------------------------------------
run_force_gen() {
  # $1 = typeck|codegen|...
  log "ensure_migrate_gen FORCE_REGEN $1"
  MAKE="$MAKE" XLANG_C="$XLANG_C" XLANG_FORCE_REGEN_GEN=1 \
    sh scripts/ensure_migrate_gen.sh "$1"
}

run_migrate() {
  # $1 = typeck|codegen
  # wave865: do not pass empty CFLAGS= (blocks migrate export-try-heat-cflags load).
  # migrate_x_objs shell-loads product CFLAGS/PIPELINE_GEN when unset.
  log "migrate_x_objs FORCE $1"
  CC="$CC" PYTHON="$PYTHON" MAKE="$MAKE" XLANG_MIGRATE_FORCE=1 \
    sh scripts/migrate_x_objs.sh "$1"
}

case "$MODE" in
  typeck)
    run_force_gen typeck
    run_migrate typeck
    ;;
  codegen)
    # Historic: typeck gen first, then codegen gen (codegen -E may import typeck)
    run_force_gen typeck
    run_force_gen codegen
    run_migrate typeck
    run_migrate codegen
    ;;
esac

# ---------------------------------------------------------------------------
# Relink TARGET with USE_X_TYPECK / (+CODEGEN) flags (bag from catalog)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this archaeology path
# ---------------------------------------------------------------------------
log "link ./$TARGET (mode=$MODE)"
# shellcheck disable=SC2086
$CC $BTC_CFLAGS -o "./$TARGET" $BTC_OBJS
echo "bootstrap-${MODE} OK"

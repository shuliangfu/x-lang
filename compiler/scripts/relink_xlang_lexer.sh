#!/usr/bin/env bash
# relink_xlang_lexer.sh — fast product relink after lexer_x.o only
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target relink-xlang-lexer:
#     1) preflight seed gate (.o that must already exist)
#     2) host-cc link ./$(TARGET) with expanded bag from mk via catalog
#     3) sync copies → XLANG_C + bootstrap_xlangc (historical product contract)
#
#   Object lists stay mk expansion (composites / user_asm / link_picks /
#   subcmd / PIPELINE_LIBS). Shell never hardcodes a second full link inventory —
#   wave856: LINK_OBJS via make export-relink-product-link-objs when unset;
#   wave857: LINK_CFLAGS via make export-relink-product-link-cflags when unset;
#   wave958: catalog-primary (0-make post-delete):
#     --link-objs-export relink-product + --link-cflags-export relink-product
#     XLANG_RXL_LINK_VIA_MAKE=1 + MF escapes to historic make export.
#
#   Seed-gate REQUIRED bag authority: mk/driver_seed_composites.mk
#   RELINK_XLANG_REQUIRED_OBJS (wave854 list → mk; wave855 shell loads mk —
#   Makefile must not re-export multi-token RXL_REQUIRED_OBJS).
#
# Usage (cwd = compiler/):
#   bash scripts/relink_xlang_lexer.sh
#   bash scripts/relink_xlang_lexer.sh --check
#
# Env (product path):
#   TARGET / TARGET_OUT  — output binary (default: xlang)
#   XLANG_C              — sync destination (default: xlang-c)
#   BOOTSTRAP_XLANGC     — second sync destination (default: bootstrap_xlangc)
#   CC                   — host C compiler
#   RXL_LINK_CFLAGS      — optional; default: catalog --link-cflags-export
#                          relink-product (wave958; same formula as historic
#                          export-relink-product-link-cflags)
#   RXL_LINK_OBJS        — optional; default: catalog --link-objs-export
#                          relink-product (wave958; mk RELINK_PRODUCT_LINK_OBJS)
#   RXL_REQUIRED_OBJS    — optional override; default loads RELINK_XLANG_REQUIRED_OBJS
#                          from mk (wave855; not a second list authority)
#   XLANG_RXL_LINK_VIA_MAKE=1 — escape LINK bag load to make export (needs MF)
#   MAKE                 — residual make for VIA_MAKE escape only
#
# wave849 (G.7 有则补全): Makefile fat test + $(MAKE) glue + $(CC) link + cp → this script.
# wave855: seed-gate REQUIRED loads from mk (G.7; not physical delete).
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave958: catalog-primary LINK bag (0-make post-delete); --check post_ship when
#   Makefile absent (wave941 phys-del). XLANG_RXL_LINK_VIA_MAKE + MF escape only.
# NOT physical delete — prereq make-graph (lexer_x.o / FILTERED / GLUE) + thin edges +
# B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
# wave958/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

MODE="${1:-run}"
OUT="${TARGET:-${TARGET_OUT:-xlang}}"
XLANG_C="${XLANG_C:-xlang-c}"
BOOTSTRAP_XLANGC="${BOOTSTRAP_XLANGC:-bootstrap_xlangc}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"

log() { echo "relink-xlang-lexer: $*" >&2; }
fail() { echo "relink-xlang-lexer: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave958 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own seed-gate + host-cc link + sync + RXL LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export relink-product\|link-objs-export relink-product' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must catalog-load RXL LINK_OBJS (wave958 post_ship)"
    fi
    if ! grep -q 'link-cflags-export relink-product\|--link-cflags-export relink-product' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must catalog-load RXL LINK_CFLAGS (wave958 post_ship)"
    fi
    if ! grep -q 'XLANG_RXL_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must document XLANG_RXL_LINK_VIA_MAKE escape (wave958)"
    fi
    # Product body still owns seed gate + host-cc link + cp sync.
    if ! grep -q 'RXL_REQUIRED_OBJS\|RELINK_XLANG_REQUIRED_OBJS' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must own seed-gate REQUIRED bag (wave855/958)"
    fi
    if ! grep -qE '\$CC.*RXL_LINK|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must own host-cc link body (wave849/958)"
    fi
    if ! grep -q 'cp -f' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must own product alias cp sync (wave849/958)"
    fi
    if ! grep -q 'wave958\|wave849' "$_SCRIPT_SELF"; then
      fail "relink_xlang_lexer must document wave849/958 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave958; RXL bag authority)"
    fi
    if [ ! -f mk/driver_seed_composites.mk ]; then
      fail "missing mk/driver_seed_composites.mk (wave855 RELINK_XLANG_REQUIRED_OBJS)"
    fi
    if ! grep -qE '^RELINK_XLANG_REQUIRED_OBJS[[:space:]]*=' mk/driver_seed_composites.mk; then
      fail "mk/driver_seed_composites.mk must define RELINK_XLANG_REQUIRED_OBJS (wave855)"
    fi
    log "CHECK OK (wave958 post_ship; catalog RXL bag; shell-primary; 0-make)"
    exit 0
  fi
  # Makefile thin-call only (wave849): scan *recipe* lines (tab-indented) only —
  # comments between targets must not false-positive on "$(CC)" prose.
  _rec=$(awk '
    /^relink-xlang-lexer:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'relink_xlang_lexer\.sh' <<<"$_rec"; then
    fail "relink-xlang-lexer must thin-call relink_xlang_lexer.sh (wave849)"
  fi
  # Dual body: host-cc link line must not remain in recipe (shell owns).
  # Note: thin-call may export CC="$(CC)" — require -o $(TARGET) / multi-obj shape.
  if grep -qE '\$\(CC\).*DRIVER_SEED_LINK_FLAGS|\$\(CC\).* -o \$\(TARGET\)|\$\(CC\).*RELINK_XLANG_PIPELINE' <<<"$_rec"; then
    fail "relink-xlang-lexer must not keep dual \$(CC) link body (wave849; shell owns link)"
  fi
  # Dual seed gate: long test -f ladder must not remain in recipe.
  if grep -qE 'test -f driver_x\.o && test -f pipeline_x\.o' <<<"$_rec"; then
    fail "relink-xlang-lexer must not keep dual test -f seed gate body (wave849; shell owns preflight)"
  fi
  # wave855: Makefile must not re-export multi-token REQUIRED bag (shell loads mk).
  if grep -qE 'RXL_REQUIRED_OBJS=' <<<"$_rec"; then
    fail "relink-xlang-lexer must not export RXL_REQUIRED_OBJS (wave855; shell loads mk)"
  fi
  # wave856: Makefile must not re-export multi-token LINK bag (shell loads export leaf).
  if grep -qE 'RXL_LINK_OBJS=' <<<"$_rec"; then
    fail "relink-xlang-lexer must not export RXL_LINK_OBJS (wave856; shell loads export leaf)"
  fi
  # wave857: Makefile must not re-export multi-token LINK_CFLAGS (shell loads export leaf).
  if grep -qE 'RXL_LINK_CFLAGS=' <<<"$_rec"; then
    fail "relink-xlang-lexer must not export RXL_LINK_CFLAGS (wave857; shell loads export leaf)"
  fi
  if ! grep -qE '^export-relink-product-link-objs:' "$MF"; then
    fail "Makefile must define export-relink-product-link-objs (wave856)"
  fi
  if ! grep -qE '^export-relink-product-link-cflags:' "$MF"; then
    fail "Makefile must define export-relink-product-link-cflags (wave857)"
  fi
  if [ ! -f mk/driver_seed_composites.mk ]; then
    fail "missing mk/driver_seed_composites.mk (wave855 REQUIRED authority)"
  fi
  if ! grep -qE '^RELINK_XLANG_REQUIRED_OBJS[[:space:]]*=' mk/driver_seed_composites.mk; then
    fail "mk/driver_seed_composites.mk must define RELINK_XLANG_REQUIRED_OBJS (wave855)"
  fi
  # wave958 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export relink-product' "$_SCRIPT_SELF"; then
    fail "relink_xlang_lexer must catalog-load RXL LINK_OBJS (wave958)"
  fi
  if ! grep -q 'XLANG_RXL_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "relink_xlang_lexer must document XLANG_RXL_LINK_VIA_MAKE escape (wave958)"
  fi
  # Dual cp sync of product aliases must not remain in recipe.
  if grep -qE 'cp -f \$\(TARGET\) \$\(XLANG_C\)|cp -f \$\(TARGET\) bootstrap_xlangc' <<<"$_rec"; then
    fail "relink-xlang-lexer must not keep dual cp sync body (wave849; shell owns sync)"
  fi
  log "CHECK OK (wave849+855+856+857+958 relink-xlang-lexer shell-primary; catalog RXL bag; not physical delete)"
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
# Preflight: RXL LINK bag via shell catalog (0-make post-delete)
# ---------------------------------------------------------------------------
# wave958: full LINK bag via shell catalog (0 make; replaces wave856/857 make
# export leaves). G.7 有则补全 on catalog --link-objs/cflags-export (wave926).
# XLANG_RXL_LINK_VIA_MAKE=1 + Makefile present escapes to make export (parity).
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
  if [ "${XLANG_RXL_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
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

if [ -z "${RXL_LINK_OBJS:-}" ]; then
  RXL_LINK_OBJS=$(_load_link_objs) \
    || fail "failed to expand relink-product link-objs (wave958 catalog)"
fi
if [ -z "${RXL_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from relink-product link-objs (wave958)"
fi

# wave958: composed LINK_CFLAGS via shell catalog (same formula as historic
# export-relink-product-link-cflags: CFLAGS + DRIVER_SEED_LINK_FLAGS +
# ASM_GLUE_DUP_LDFLAGS + MAIN_LINK_FLAGS). bag name "relink-product".
# PLATFORM: SHARED — KEY=value from catalog; no second flag inventory.
_load_link_cflags() {
  local raw line val
  if [ "${XLANG_RXL_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
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

if [ -z "${RXL_LINK_CFLAGS:-}" ]; then
  RXL_LINK_CFLAGS=$(_load_link_cflags) \
    || fail "failed to expand relink-product link-cflags (wave958 catalog)"
fi
if [ -z "${RXL_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from relink-product link-cflags (wave958)"
fi
if [ -z "${RXL_REQUIRED_OBJS:-}" ]; then
  _COMP_MK=mk/driver_seed_composites.mk
  [ -f "$_COMP_MK" ] || fail "missing $_COMP_MK (wave855 REQUIRED authority)"
  RXL_REQUIRED_OBJS=$(_mk_assign_val RELINK_XLANG_REQUIRED_OBJS "$_COMP_MK")
fi
if [ -z "${RXL_REQUIRED_OBJS:-}" ]; then
  fail "failed to load RELINK_XLANG_REQUIRED_OBJS from mk/driver_seed_composites.mk (wave855)"
fi

# ---------------------------------------------------------------------------
# Seed gate (same contract as pre-wave849 Makefile test -f ladder)
# PLATFORM: SHARED — missing satellites mean bootstrap / seed-host not done
# ---------------------------------------------------------------------------
missing=0
# shellcheck disable=SC2086
for o in $RXL_REQUIRED_OBJS; do
  if [ ! -f "$o" ]; then
    log "missing required object: $o"
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  # wave958 post_ship: no make bootstrap-driver-seed; shell authority.
  fail "missing seed objects — run: bash scripts/bootstrap_driver_seed.sh"
fi

# ---------------------------------------------------------------------------
# host-cc link ./$(TARGET) (product binary; lexer_x.o already rebuilt by ensure)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $RXL_LINK_CFLAGS -o "./$OUT" $RXL_LINK_OBJS

# Historical product contract: keep xlang-c / bootstrap_xlangc in sync with TARGET
# PLATFORM: SHARED — plain file copies after host-cc link
cp -f "./$OUT" "./$XLANG_C"
cp -f "./$OUT" "./$BOOTSTRAP_XLANGC"
echo "relink-xlang-lexer OK (lexer_x.o only; xlang-c synced)"

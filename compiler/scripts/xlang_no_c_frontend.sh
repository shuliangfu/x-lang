#!/usr/bin/env bash
# xlang_no_c_frontend.sh — archaeology product binary xlang-no-c-frontend body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target xlang-no-c-frontend:
#     1) preflight required driver/pipeline satellite .o (seed must exist)
#     2) host-cc link ./xlang-no-c-frontend with expanded bag from mk via catalog
#
#   Object lists stay mk expansion (archaeology_experiment_objs.mk
#   DRIVER_NO_C_FRONTEND_OBJS + DRIVER_SUBCMD + PIPELINE_LIBS). Shell never
#   hardcodes a second full link inventory —
#   wave856: LINK_OBJS via make export-xnc-link-objs when unset;
#   wave857: LINK_CFLAGS via make export-xnc-link-cflags when unset;
#   wave957: catalog-primary (0-make post-delete):
#     --link-objs-export xnc + --link-cflags-export xnc
#     XLANG_XNC_LINK_VIA_MAKE=1 + MF escapes to historic make export.
#
#   Seed-gate REQUIRED bag authority: mk/archaeology_experiment_objs.mk
#   XLANG_NO_C_FRONTEND_REQUIRED_OBJS (wave854 list → mk; wave855 shell loads
#   mk — Makefile must not re-export multi-token XNC_REQUIRED_OBJS).
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_no_c_frontend.sh
#   bash scripts/xlang_no_c_frontend.sh --check
#
# Env (product path):
#   CC                   — host C compiler
#   OUT / TARGET_OUT     — output binary (default: xlang-no-c-frontend)
#   XNC_LINK_CFLAGS      — optional; default: catalog --link-cflags-export xnc
#                          (wave957; same formula as historic export-xnc-link-cflags:
#                          CFLAGS + DRIVER_SEED_LINK_FLAGS + MAIN_LINK_FLAGS)
#   XNC_LINK_OBJS        — optional; default: catalog --link-objs-export xnc
#                          (wave957; mk XLANG_NO_C_FRONTEND_LINK_OBJS via catalog)
#   XNC_REQUIRED_OBJS    — optional override; default loads
#                          XLANG_NO_C_FRONTEND_REQUIRED_OBJS from mk (wave855)
#   XLANG_XNC_LINK_VIA_MAKE=1 — escape LINK bag load to make export (needs MF)
#   MAKE                 — residual make for VIA_MAKE escape only
#
# wave847 (G.7 有则补全): Makefile fat test + $(CC) link → this script.
# wave855: seed-gate REQUIRED loads from mk (G.7; not physical delete).
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave926: catalog-primary LINK bag (parity with make export; VIA_MAKE escape).
# wave957: catalog-primary LINK bag (0-make post-delete); --check post_ship when
#   Makefile absent (wave941 phys-del). XLANG_XNC_LINK_VIA_MAKE + MF escape only.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
# wave957/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

MODE="${1:-run}"
OUT="${OUT:-${TARGET_OUT:-xlang-no-c-frontend}}"
CC="${CC:-cc}"
MAKE="${MAKE:-make}"

log() { echo "xlang-no-c-frontend: $*" >&2; }
fail() { echo "xlang-no-c-frontend: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave957 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own seed-gate + host-cc link + XNC LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export xnc\|link-objs-export xnc' "$_SCRIPT_SELF"; then
      fail "xlang_no_c_frontend must catalog-load XNC LINK_OBJS (wave957 post_ship)"
    fi
    if ! grep -q 'link-cflags-export xnc\|--link-cflags-export xnc' "$_SCRIPT_SELF"; then
      fail "xlang_no_c_frontend must catalog-load XNC LINK_CFLAGS (wave957 post_ship)"
    fi
    if ! grep -q 'XLANG_XNC_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "xlang_no_c_frontend must document XLANG_XNC_LINK_VIA_MAKE escape (wave957)"
    fi
    # Product body still owns seed gate + host-cc link.
    if ! grep -q 'XNC_REQUIRED_OBJS\|XLANG_NO_C_FRONTEND_REQUIRED_OBJS' "$_SCRIPT_SELF"; then
      fail "xlang_no_c_frontend must own seed-gate REQUIRED bag (wave855/957)"
    fi
    if ! grep -qE '\$CC.*XNC_LINK|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "xlang_no_c_frontend must own host-cc link body (wave847/957)"
    fi
    if ! grep -q 'wave957\|wave847' "$_SCRIPT_SELF"; then
      fail "xlang_no_c_frontend must document wave847/957 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave957; XNC bag authority)"
    fi
    if [ ! -f mk/archaeology_experiment_objs.mk ]; then
      fail "missing mk/archaeology_experiment_objs.mk (wave855 REQUIRED authority)"
    fi
    if ! grep -qE '^XLANG_NO_C_FRONTEND_REQUIRED_OBJS[[:space:]]*=' mk/archaeology_experiment_objs.mk; then
      fail "mk/archaeology_experiment_objs.mk must define XLANG_NO_C_FRONTEND_REQUIRED_OBJS (wave855)"
    fi
    log "CHECK OK (wave957 post_ship; catalog XNC bag; shell-primary; 0-make)"
    exit 0
  fi
  # Makefile thin-call only (wave847): scan *recipe* lines (tab-indented) only —
  # comments between targets must not false-positive on "$(CC)" prose.
  _rec=$(awk '
    /^xlang-no-c-frontend:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'xlang_no_c_frontend\.sh' <<<"$_rec"; then
    fail "xlang-no-c-frontend must thin-call xlang_no_c_frontend.sh (wave847)"
  fi
  # Dual body: host-cc link line must not remain in recipe (shell owns).
  # Note: thin-call may export CC="$(CC)" — require -o $@ / multi-obj shape.
  if grep -qE '\$\(CC\).*DRIVER_SEED_LINK_FLAGS|\$\(CC\).* -o \$@|\$\(CC\).* -o \$\@' <<<"$_rec"; then
    fail "xlang-no-c-frontend must not keep dual \$(CC) link body (wave847; shell owns link)"
  fi
  # Dual seed gate: long test -f ladder must not remain in recipe.
  if grep -qE 'test -f driver_x\.o && test -f pipeline_x\.o' <<<"$_rec"; then
    fail "xlang-no-c-frontend must not keep dual test -f seed gate body (wave847; shell owns preflight)"
  fi
  # wave855: Makefile must not re-export multi-token REQUIRED bag (shell loads mk).
  if grep -qE 'XNC_REQUIRED_OBJS=' <<<"$_rec"; then
    fail "xlang-no-c-frontend must not export XNC_REQUIRED_OBJS (wave855; shell loads mk)"
  fi
  # wave856: Makefile must not re-export multi-token LINK bag (shell loads export leaf).
  if grep -qE 'XNC_LINK_OBJS=' <<<"$_rec"; then
    fail "xlang-no-c-frontend must not export XNC_LINK_OBJS (wave856; shell loads export leaf)"
  fi
  if grep -qE 'XNC_LINK_CFLAGS=' <<<"$_rec"; then
    fail "xlang-no-c-frontend must not export XNC_LINK_CFLAGS (wave857; shell loads export leaf)"
  fi
  if ! grep -qE '^export-xnc-link-objs:' "$MF"; then
    fail "Makefile must define export-xnc-link-objs (wave856)"
  fi
  if ! grep -qE '^export-xnc-link-cflags:' "$MF"; then
    fail "Makefile must define export-xnc-link-cflags (wave857)"
  fi
  if [ ! -f mk/archaeology_experiment_objs.mk ]; then
    fail "missing mk/archaeology_experiment_objs.mk (wave855 REQUIRED authority)"
  fi
  if ! grep -qE '^XLANG_NO_C_FRONTEND_REQUIRED_OBJS[[:space:]]*=' mk/archaeology_experiment_objs.mk; then
    fail "mk/archaeology_experiment_objs.mk must define XLANG_NO_C_FRONTEND_REQUIRED_OBJS (wave855)"
  fi
  # wave957 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export xnc' "$_SCRIPT_SELF"; then
    fail "xlang_no_c_frontend must catalog-load XNC LINK_OBJS (wave957)"
  fi
  if ! grep -q 'XLANG_XNC_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "xlang_no_c_frontend must document XLANG_XNC_LINK_VIA_MAKE escape (wave957)"
  fi
  log "CHECK OK (wave847+855+856+857+957 xlang-no-c-frontend shell-primary; catalog XNC bag; not physical delete)"
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
# Preflight: XNC LINK bag via shell catalog (0-make post-delete)
# ---------------------------------------------------------------------------
# wave957: full LINK bag via shell catalog (0 make; replaces wave856/857 make
# export leaves; wave926 already catalog-primary). G.7 有则补全 on catalog
# --link-objs/cflags-export xnc. XLANG_XNC_LINK_VIA_MAKE=1 + Makefile present
# escapes to make export (parity / debug).
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
  if [ "${XLANG_XNC_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-xnc-link-objs) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-objs-export xnc 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${XNC_LINK_OBJS:-}" ]; then
  XNC_LINK_OBJS=$(_load_link_objs) \
    || fail "failed to expand xnc link-objs (wave957 catalog)"
fi
if [ -z "${XNC_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from xnc link-objs (wave957)"
fi

# wave957: composed LINK_CFLAGS via shell catalog (same formula as historic
# export-xnc-link-cflags: CFLAGS + DRIVER_SEED_LINK_FLAGS + MAIN_LINK_FLAGS).
# bag name "xnc". PLATFORM: SHARED — KEY=value from catalog; no second flag inventory.
_load_link_cflags() {
  local raw line val
  if [ "${XLANG_XNC_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-xnc-link-cflags) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-cflags-export xnc 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${XNC_LINK_CFLAGS:-}" ]; then
  XNC_LINK_CFLAGS=$(_load_link_cflags) \
    || fail "failed to expand xnc link-cflags (wave957 catalog)"
fi
if [ -z "${XNC_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from xnc link-cflags (wave957)"
fi
if [ -z "${XNC_REQUIRED_OBJS:-}" ]; then
  _ARCH_MK=mk/archaeology_experiment_objs.mk
  [ -f "$_ARCH_MK" ] || fail "missing $_ARCH_MK (wave855 REQUIRED authority)"
  XNC_REQUIRED_OBJS=$(_mk_assign_val XLANG_NO_C_FRONTEND_REQUIRED_OBJS "$_ARCH_MK")
fi
if [ -z "${XNC_REQUIRED_OBJS:-}" ]; then
  fail "failed to load XLANG_NO_C_FRONTEND_REQUIRED_OBJS from mk/archaeology_experiment_objs.mk (wave855)"
fi

# ---------------------------------------------------------------------------
# Seed gate (same contract as pre-wave847 Makefile test -f ladder)
# PLATFORM: SHARED — missing satellites mean bootstrap-driver-seed not done
# ---------------------------------------------------------------------------
missing=0
# shellcheck disable=SC2086
for o in $XNC_REQUIRED_OBJS; do
  if [ ! -f "$o" ]; then
    log "missing required object: $o"
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  # wave957 post_ship: no make bootstrap-driver-seed; shell authority.
  fail "missing driver/pipeline satellite .o — run: bash scripts/bootstrap_driver_seed.sh"
fi

# ---------------------------------------------------------------------------
# host-cc link ./xlang-no-c-frontend (archaeology no-C-frontend binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $XNC_LINK_CFLAGS -o "./$OUT" $XNC_LINK_OBJS
echo "xlang-no-c-frontend OK (try: ./$OUT -E examples/hello.x)"

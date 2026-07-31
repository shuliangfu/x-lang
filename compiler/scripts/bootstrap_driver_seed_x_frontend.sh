#!/usr/bin/env bash
# bootstrap_driver_seed_x_frontend.sh — archaeology experiment binary
# $(TARGET)_x_frontend body (stage 10.4: .x typeck/codegen, no pipeline_x.o)
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target bootstrap-driver-seed-x-frontend:
#     host-cc link $(TARGET)_x_frontend with expanded bag from mk via catalog
#
#   Object lists stay mk expansion (archaeology_experiment_objs.mk
#   DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS + DRIVER_SUBCMD + PIPELINE_LIBS +
#   driver_x/preprocess_x/LSP_DIAG). Shell never hardcodes a second full link
#   inventory —
#   wave856: LINK_OBJS via make export-bxf-link-objs when unset;
#   wave857: LINK_CFLAGS via make export-bxf-link-cflags when unset;
#   wave959: catalog-primary (0-make post-delete):
#     --link-objs-export bxf + --link-cflags-export bxf
#     XLANG_BXF_LINK_VIA_MAKE=1 + MF escapes to historic make export.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_driver_seed_x_frontend.sh
#   bash scripts/bootstrap_driver_seed_x_frontend.sh --check
#
# Env (product path; shell defaults own when Makefile thin-call drops inject):
#   CC                   — host C compiler (default: cc)
#   TARGET               — product name for OUT default (default: xlang)
#   OUT / TARGET_OUT     — output binary (default: ${TARGET}_x_frontend)
#   BXF_LINK_CFLAGS      — optional; default: catalog --link-cflags-export bxf
#                          (wave959; same formula as historic export-bxf-link-cflags:
#                          CFLAGS + -DXLANG_USE_X_DRIVER -DXLANG_USE_X_TYPECK
#                          -DXLANG_USE_X_CODEGEN)
#   BXF_LINK_OBJS        — optional; default: catalog --link-objs-export bxf
#                          (wave959; mk DRIVER_SEED_X_FRONTEND_LINK_OBJS)
#   XLANG_BXF_LINK_VIA_MAKE=1 — escape LINK bag load to make export (needs MF)
#   MAKE                 — residual make for VIA_MAKE escape only
#
# wave848 (G.7 有则补全): Makefile fat $(CC) link → this script.
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave880: drop Makefile multi-token MAKE/CC/OUT inject; shell defaults own OUT.
# wave959: catalog-primary LINK bag (0-make post-delete); --check post_ship when
#   Makefile absent (wave941 phys-del). XLANG_BXF_LINK_VIA_MAKE + MF escape only.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
# wave959/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

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
  # wave959 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own host-cc link + BXF LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export bxf\|link-objs-export bxf' "$_SCRIPT_SELF"; then
      fail "bootstrap_driver_seed_x_frontend must catalog-load BXF LINK_OBJS (wave959 post_ship)"
    fi
    if ! grep -q 'link-cflags-export bxf\|--link-cflags-export bxf' "$_SCRIPT_SELF"; then
      fail "bootstrap_driver_seed_x_frontend must catalog-load BXF LINK_CFLAGS (wave959 post_ship)"
    fi
    if ! grep -q 'XLANG_BXF_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "bootstrap_driver_seed_x_frontend must document XLANG_BXF_LINK_VIA_MAKE escape (wave959)"
    fi
    # Product body still owns host-cc link.
    if ! grep -qE '\$CC.*BXF_LINK|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "bootstrap_driver_seed_x_frontend must own host-cc link body (wave848/959)"
    fi
    if ! grep -q 'wave959\|wave848' "$_SCRIPT_SELF"; then
      fail "bootstrap_driver_seed_x_frontend must document wave848/959 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave959; BXF bag authority)"
    fi
    if [ ! -f mk/archaeology_experiment_objs.mk ]; then
      fail "missing mk/archaeology_experiment_objs.mk (wave852 BXF LINK authority)"
    fi
    if ! grep -qE '^DRIVER_SEED_X_FRONTEND_LINK_OBJS[[:space:]]*=' mk/archaeology_experiment_objs.mk; then
      fail "mk/archaeology_experiment_objs.mk must define DRIVER_SEED_X_FRONTEND_LINK_OBJS (wave852)"
    fi
    log "CHECK OK (wave959 post_ship; catalog BXF bag; shell-primary; 0-make)"
    exit 0
  fi
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
  if [ ! -f mk/archaeology_experiment_objs.mk ]; then
    fail "missing mk/archaeology_experiment_objs.mk (wave852 BXF LINK authority)"
  fi
  if ! grep -qE '^DRIVER_SEED_X_FRONTEND_LINK_OBJS[[:space:]]*=' mk/archaeology_experiment_objs.mk; then
    fail "mk/archaeology_experiment_objs.mk must define DRIVER_SEED_X_FRONTEND_LINK_OBJS (wave852)"
  fi
  # wave959 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export bxf' "$_SCRIPT_SELF"; then
    fail "bootstrap_driver_seed_x_frontend must catalog-load BXF LINK_OBJS (wave959)"
  fi
  if ! grep -q 'XLANG_BXF_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "bootstrap_driver_seed_x_frontend must document XLANG_BXF_LINK_VIA_MAKE escape (wave959)"
  fi
  log "CHECK OK (wave848+856+857+959 bootstrap-driver-seed-x-frontend shell-primary; catalog BXF bag; not physical delete)"
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
# Preflight: BXF LINK bag via shell catalog (0-make post-delete)
# ---------------------------------------------------------------------------
# wave959: full LINK bag via shell catalog (0 make; replaces wave856/857 make
# export leaves). G.7 有则补全 on catalog --link-objs/cflags-export bxf.
# XLANG_BXF_LINK_VIA_MAKE=1 + Makefile present escapes to make export (parity).
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
_load_link_objs() {
  local raw line val
  if [ "${XLANG_BXF_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-bxf-link-objs) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-objs-export bxf 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BXF_LINK_OBJS:-}" ]; then
  BXF_LINK_OBJS=$(_load_link_objs) \
    || fail "failed to expand bxf link-objs (wave959 catalog; seed missing? run bootstrap_driver_seed.sh)"
fi
if [ -z "${BXF_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from bxf link-objs (wave959)"
fi

_load_link_cflags() {
  local raw line val
  if [ "${XLANG_BXF_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-bxf-link-cflags) || return 1
  else
    raw=$(bash scripts/driver_seed_obj_catalog.sh --link-cflags-export bxf 2>/dev/null) || return 1
  fi
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BXF_LINK_CFLAGS:-}" ]; then
  BXF_LINK_CFLAGS=$(_load_link_cflags) \
    || fail "failed to expand bxf link-cflags (wave959 catalog)"
fi
if [ -z "${BXF_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from bxf link-cflags (wave959)"
fi

# ---------------------------------------------------------------------------
# host-cc link $(TARGET)_x_frontend (stage 10.4 experiment binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $BXF_LINK_CFLAGS -o "./$OUT" $BXF_LINK_OBJS
echo "bootstrap-driver-seed-x-frontend OK (./$OUT: .x typeck/codegen, no pipeline_x.o)"

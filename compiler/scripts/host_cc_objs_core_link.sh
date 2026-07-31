#!/usr/bin/env bash
# host_cc_objs_core_link.sh — archaeology XLANG_HOST_CC_OBJS_CORE=1 host-cc link of xlang
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target $(TARGET) under
#   XLANG_HOST_CC_OBJS_CORE=1 (wave891). Default product path stays:
#     $(TARGET) → scripts/g05_prepare_and_relink.sh (wave786 B7D).
#
#   Object list authority: mk/objs_core.mk OBJS=$(OBJS_CORE) (wave820).
#   wave891: LINK_OBJS via make export-objs-core-link-objs when unset;
#            CFLAGS via export-try-heat-cflags (product CFLAGS only — matches
#            historic bare `$(CC) $(CFLAGS) -o $@ $^ $(WIN_LDFLAGS)`).
#            WIN_LDFLAGS via uname (PE multi-def; empty on POSIX).
#   wave937: catalog-primary LINK bag / CFLAGS (0-make when MF present optional).
#   wave962: catalog-primary + --check post_ship when Makefile absent (wave941
#            phys-del). XLANG_OBJS_CORE_LINK_VIA_MAKE=1 + MF escapes only.
#
# Usage (cwd = compiler/):
#   bash scripts/host_cc_objs_core_link.sh
#   bash scripts/host_cc_objs_core_link.sh --check
#
# Env:
#   OUT / TARGET    — output binary (default: xlang)
#   CC              — host C compiler (resolve_host_cc when unset)
#   HOST_CC_LINK_OBJS — optional; default: catalog --link-objs-export objs-core
#                      (wave937/962; same bag as historic export-objs-core-link-objs)
#   HOST_CC_CFLAGS  — optional; default: catalog --cflags-export (wave937/962)
#   HOST_CC_WIN_LDFLAGS — optional; default uname PE multi-def
#   XLANG_OBJS_CORE_LINK_VIA_MAKE=1 — escape LINK bag / CFLAGS to make export (needs MF)
#   MAKE            — residual make for VIA_MAKE escape only
#
# wave891: Makefile bare `$(CC) $(CFLAGS) -o $@ $^ $(WIN_LDFLAGS)` → this script.
# wave937: catalog --link-objs-export objs-core + --cflags-export.
# wave962: --check post_ship when Makefile absent (wave941 phys-del);
#          VIA_MAKE gated on MF present (already wave937 product path).
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; archaeology incomplete link only
# (expect UNDEF residual; not product). WIN_LDFLAGS is PLATFORM: WINDOWS|PE.
set -euo pipefail
# wave962/945: absolute self path — relative $0 breaks after cd to compiler/.
# PLATFORM: SHARED — post_ship --check greps this file; must not use post-cd $0.
_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_SCRIPT_SELF="${_SCRIPT_DIR}/$(basename "$0")"
cd "${_SCRIPT_DIR}/.."

MODE="${1:-run}"
OUT="${OUT:-${TARGET:-xlang}}"
MAKE="${MAKE:-make}"

# shellcheck source=scripts/resolve_host_cc.sh
. scripts/resolve_host_cc.sh
CC="$(xlang_resolve_host_cc)"

log() { echo "host-cc-objs-core-link: $*" >&2; }
fail() { echo "host-cc-objs-core-link: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  # wave962 post_ship: Makefile physically deleted (wave941). Shell + catalog
  # own host-cc link + OBJS_CORE LINK bag; MF thin-call inventory N/A.
  if [ ! -f "$MF" ]; then
    # Grep absolute self (wave945: relative $0 breaks after cd to compiler/).
    if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export objs-core\|link-objs-export objs-core' "$_SCRIPT_SELF"; then
      fail "host_cc_objs_core_link must catalog-load OBJS_CORE LINK_OBJS (wave962 post_ship)"
    fi
    if ! grep -q 'cflags-export\|--cflags-export' "$_SCRIPT_SELF"; then
      fail "host_cc_objs_core_link must catalog-load CFLAGS (wave962 post_ship)"
    fi
    if ! grep -q 'XLANG_OBJS_CORE_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
      fail "host_cc_objs_core_link must document XLANG_OBJS_CORE_LINK_VIA_MAKE escape (wave962)"
    fi
    # Product body still owns host-cc link.
    if ! grep -qE '\$CC.*HOST_CC|host-cc link|link \./' "$_SCRIPT_SELF"; then
      fail "host_cc_objs_core_link must own host-cc link body (wave891/962)"
    fi
    if ! grep -q 'wave962\|wave891\|wave937' "$_SCRIPT_SELF"; then
      fail "host_cc_objs_core_link must document wave891/937/962 shell-primary"
    fi
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      fail "missing scripts/driver_seed_obj_catalog.sh (wave962; OBJS_CORE bag authority)"
    fi
    if [ ! -f mk/objs_core.mk ]; then
      fail "missing mk/objs_core.mk (wave820 OBJS_CORE authority)"
    fi
    if ! grep -qE '^OBJS_CORE[[:space:]]*[:?]?=' mk/objs_core.mk; then
      fail "mk/objs_core.mk must define OBJS_CORE (wave820)"
    fi
    log "CHECK OK (wave962 post_ship; catalog OBJS_CORE bag; shell-primary; 0-make)"
    exit 0
  fi
  # No bare tab $(CC) recipe residual (HOST_CC was the last one).
  if grep -nE $'^\t\$\(CC\)' "$MF" 2>/dev/null | grep -q .; then
    fail "Makefile must not keep bare \$(CC) recipe body (wave891; shell owns HOST_CC link)"
  fi
  if ! grep -q 'host_cc_objs_core_link\.sh' "$MF"; then
    fail "Makefile must thin-call host_cc_objs_core_link.sh (wave891)"
  fi
  if ! grep -qE '^export-objs-core-link-objs:' "$MF"; then
    fail "Makefile must define export-objs-core-link-objs (wave891)"
  fi
  if ! grep -q 'XLANG_HOST_CC_OBJS_CORE' "$MF"; then
    fail "Makefile must keep XLANG_HOST_CC_OBJS_CORE escape flag (wave786/891)"
  fi
  if [ ! -f mk/objs_core.mk ]; then
    fail "missing mk/objs_core.mk (wave820 OBJS_CORE authority)"
  fi
  if ! grep -qE '^OBJS_CORE[[:space:]]*[:?]?=' mk/objs_core.mk; then
    fail "mk/objs_core.mk must define OBJS_CORE (wave820)"
  fi
  # wave962 honesty: product path catalog-primary even while MF present.
  if ! grep -q 'driver_seed_obj_catalog\|--link-objs-export objs-core' "$_SCRIPT_SELF"; then
    fail "host_cc_objs_core_link must catalog-load OBJS_CORE LINK_OBJS (wave962)"
  fi
  if ! grep -q 'XLANG_OBJS_CORE_LINK_VIA_MAKE' "$_SCRIPT_SELF"; then
    fail "host_cc_objs_core_link must document XLANG_OBJS_CORE_LINK_VIA_MAKE escape (wave962)"
  fi
  log "CHECK OK (wave891+937+962 HOST_CC_OBJS_CORE shell-primary; catalog OBJS_CORE bag; not physical delete)"
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
# wave937/962: full OBJS bag via shell catalog (0 make; replaces wave891 make
# export leaves). G.7 有则补全 on catalog --link-objs/cflags-export.
# XLANG_OBJS_CORE_LINK_VIA_MAKE=1 + Makefile present escapes to make export.
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
# ---------------------------------------------------------------------------
_load_link_objs_via_make() {
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

_load_cflags_via_make() {
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      CFLAGS=*) val=${line#CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

# PLATFORM: WINDOWS|PE — multi-def for weak→strong stubs; POSIX empty.
_default_win_ldflags() {
  local os un
  os="${OS:-}"
  un="$(uname -s 2>/dev/null || echo Unknown)"
  case "${os}${un}" in
    Windows_NT*|MINGW*|MSYS*|CYGWIN*)
      printf '%s' '-Wl,--allow-multiple-definition'
      ;;
    *)
      printf '%s' ''
      ;;
  esac
}

if [ -z "${HOST_CC_LINK_OBJS:-}" ]; then
  # wave937/962: shell-primary via catalog --link-objs-export objs-core.
  # XLANG_OBJS_CORE_LINK_VIA_MAKE=1 + MF escapes to make (parity / debug).
  if [ "${XLANG_OBJS_CORE_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    HOST_CC_LINK_OBJS=$(_load_link_objs_via_make export-objs-core-link-objs) \
      || fail "failed to expand export-objs-core-link-objs (wave891 LINK_OBJS shell-load)"
  else
    HOST_CC_LINK_OBJS=$(bash scripts/driver_seed_obj_catalog.sh --link-objs-export objs-core 2>/dev/null \
      | sed -n 's/^LINK_OBJS=//p' | head -1) \
      || fail "failed to expand catalog --link-objs-export objs-core (wave962)"
  fi
fi
if [ -z "${HOST_CC_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from objs-core (wave891/937/962)"
fi

if [ -z "${HOST_CC_CFLAGS:-}" ]; then
  # wave937/962: shell-primary via catalog --cflags-export.
  if [ "${XLANG_OBJS_CORE_LINK_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    HOST_CC_CFLAGS=$(_load_cflags_via_make export-try-heat-cflags) \
      || fail "failed to expand export-try-heat-cflags (wave891 CFLAGS shell-load)"
  else
    HOST_CC_CFLAGS=$(bash scripts/driver_seed_obj_catalog.sh --cflags-export 2>/dev/null \
      | sed -n 's/^CFLAGS=//p' | head -1) \
      || fail "failed to expand catalog --cflags-export (wave962)"
  fi
fi
# CFLAGS may be empty in extreme override; still allow link (host default).

if [ -z "${HOST_CC_WIN_LDFLAGS+set}" ]; then
  HOST_CC_WIN_LDFLAGS="$(_default_win_ldflags)"
fi

# ---------------------------------------------------------------------------
# host-cc link archaeology incomplete OBJS_CORE → TARGET
# PLATFORM: SHARED — host CC links expanded .o; product path is g05
# Expect UNDEF residual — archaeology escape only (wave786).
# ---------------------------------------------------------------------------
log "link ./$OUT (HOST_CC_OBJS_CORE archaeology; expect UNDEF residual)"
# shellcheck disable=SC2086
$CC $HOST_CC_CFLAGS -o "./$OUT" $HOST_CC_LINK_OBJS $HOST_CC_WIN_LDFLAGS
echo "host-cc-objs-core-link OK ($OUT)"

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
#
# Usage (cwd = compiler/):
#   bash scripts/host_cc_objs_core_link.sh
#   bash scripts/host_cc_objs_core_link.sh --check
#
# Env:
#   OUT / TARGET    — output binary (default: xlang)
#   CC              — host C compiler (resolve_host_cc when unset)
#   HOST_CC_LINK_OBJS — optional; default loads via export-objs-core-link-objs
#   HOST_CC_CFLAGS  — optional; default loads via export-try-heat-cflags CFLAGS=
#   HOST_CC_WIN_LDFLAGS — optional; default uname PE multi-def
#   MAKE            — residual make for export leaves
#
# wave891: Makefile bare `$(CC) $(CFLAGS) -o $@ $^ $(WIN_LDFLAGS)` → this script.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; archaeology incomplete link only
# (expect UNDEF residual; not product). WIN_LDFLAGS is PLATFORM: WINDOWS|PE.
set -euo pipefail
cd "$(dirname "$0")/.."

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
  [ -f "$MF" ] || fail "missing $MF"
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
  log "CHECK OK (wave891 HOST_CC_OBJS_CORE shell-primary; LINK_OBJS export leaf; CFLAGS try-heat; not physical delete)"
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
# wave891: full OBJS bag needs make expansion (LEGACY ifeq in objs_core.mk).
# G.7 有则补全 on export-*-link-objs pattern (wave856/858).
# PLATFORM: SHARED — KEY=value from export target; no second .o inventory.
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
  HOST_CC_LINK_OBJS=$(_load_link_objs_via_make export-objs-core-link-objs) \
    || fail "failed to expand export-objs-core-link-objs (wave891 LINK_OBJS shell-load)"
fi
if [ -z "${HOST_CC_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from export-objs-core-link-objs (wave891)"
fi

if [ -z "${HOST_CC_CFLAGS:-}" ]; then
  HOST_CC_CFLAGS=$(_load_cflags_via_make export-try-heat-cflags) \
    || fail "failed to expand export-try-heat-cflags (wave891 CFLAGS shell-load)"
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

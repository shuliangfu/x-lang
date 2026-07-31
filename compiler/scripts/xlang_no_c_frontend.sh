#!/usr/bin/env bash
# xlang_no_c_frontend.sh — archaeology product binary xlang-no-c-frontend body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target xlang-no-c-frontend:
#     1) preflight required driver/pipeline satellite .o (seed must exist)
#     2) host-cc link ./xlang-no-c-frontend with expanded bag from mk
#
#   Object lists stay mk expansion (archaeology_experiment_objs.mk
#   DRIVER_NO_C_FRONTEND_OBJS + DRIVER_SUBCMD + PIPELINE_LIBS). Shell never
#   hardcodes a second full link inventory — wave856: LINK_OBJS via make
#   export-xnc-link-objs when unset; wave857: LINK_CFLAGS via export-xnc-link-cflags.
#
#   Seed-gate REQUIRED bag authority: mk/archaeology_experiment_objs.mk
#   XLANG_NO_C_FRONTEND_REQUIRED_OBJS (wave854 list → mk; wave855 shell loads
#   mk — Makefile must not re-export multi-token XNC_REQUIRED_OBJS).
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_no_c_frontend.sh
#   bash scripts/xlang_no_c_frontend.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   CC                   — host C compiler
#   OUT / TARGET_OUT     — output binary (default: xlang-no-c-frontend)
#   XNC_LINK_CFLAGS      — expanded CFLAGS + DRIVER_SEED_LINK_FLAGS + MAIN_LINK_FLAGS
#   XNC_LINK_OBJS        — optional; default loads via export-xnc-link-objs
#                          (wave856; mk bag needs make expansion)
#   XNC_REQUIRED_OBJS    — optional override; default loads
#                          XLANG_NO_C_FRONTEND_REQUIRED_OBJS from mk (wave855)
#   MAKE                 — residual make for LINK_OBJS export leaf (wave856)
#
# wave847 (G.7 有则补全): Makefile fat test + $(CC) link → this script.
# wave855: seed-gate REQUIRED loads from mk (G.7; not physical delete).
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# wave880: drop Makefile multi-token MAKE/CC/OUT inject; shell defaults own OUT.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

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
  [ -f "$MF" ] || fail "missing $MF"
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
  log "CHECK OK (wave847+855+856+857 xlang-no-c-frontend shell-primary; REQUIRED from mk; LINK_OBJS+CFLAGS export leaves; not physical delete)"
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
# Preflight: link env from Makefile thin-call (G.7: LINK bags stay mk expansion)
# wave855: seed-gate REQUIRED loads from mk (fixed multi-token; no make export).
# PLATFORM: SHARED — pure text parse of archaeology_experiment_objs.mk; no make.
# ---------------------------------------------------------------------------
_mk_assign_val() {
  # First KEY = value line from mk (strip comments / trailing space).
  # $1 = key, $2 = mk path
  local key="$1"
  local mk="$2"
  local line
  line=$(grep -E "^${key}[[:space:]]*=" "$mk" 2>/dev/null | head -1 | sed "s/^${key}[[:space:]]*=[[:space:]]*//;s/#.*//;s/[[:space:]]*$//")
  printf '%s' "$line"
}

# wave926: full LINK bag via shell catalog (0 make; replaces wave856/857
# make export leaves). G.7 有则补全 on catalog --link-objs/cflags-export.
# XLANG_XNC_LINK_VIA_MAKE=1 escapes to make export (parity / debug).
# PLATFORM: SHARED — KEY=value from catalog; no second .o inventory.
_load_link_objs() {
  local raw line val
  if [ "${XLANG_XNC_LINK_VIA_MAKE:-0}" = "1" ]; then
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
    || fail "failed to expand xnc link-objs (wave926 catalog)"
fi
if [ -z "${XNC_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from xnc link-objs (wave926)"
fi

# wave926: composed LINK_CFLAGS via shell catalog (replaces wave857 make export).
# G.7 有则补全 on catalog --link-cflags-export xnc.
# PLATFORM: SHARED — KEY=value from catalog; no second flag inventory.
_load_link_cflags() {
  local raw line val
  if [ "${XLANG_XNC_LINK_VIA_MAKE:-0}" = "1" ]; then
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
    || fail "failed to expand xnc link-cflags (wave926 catalog)"
fi
if [ -z "${XNC_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from xnc link-cflags (wave926)"
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
  fail "missing driver/pipeline satellite .o — run: make bootstrap-driver-seed"
fi

# ---------------------------------------------------------------------------
# host-cc link ./xlang-no-c-frontend (archaeology no-C-frontend binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $XNC_LINK_CFLAGS -o "./$OUT" $XNC_LINK_OBJS
echo "xlang-no-c-frontend OK (try: ./$OUT -E examples/hello.x)"

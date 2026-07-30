#!/usr/bin/env bash
# xlang_x.sh — product binary xlang-x body (host-cc relink)
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target xlang-x:
#     1) preflight required driver/lsp satellite .o (seed must exist)
#     2) host-cc link ./xlang-x with expanded bag from mk
#
#   Object lists stay mk expansion (driver_seed_composites / user_asm /
#   link_picks / subcmd). Shell never hardcodes a second full link inventory —
#   Makefile thin-call exports expanded LINK bag as XXL_LINK_* env vars.
#
#   Seed-gate REQUIRED bag authority: mk/driver_seed_composites.mk
#   XLANG_X_REQUIRED_OBJS (wave854 list → mk; wave855 shell loads mk —
#   Makefile must not re-export multi-token XXL_REQUIRED_OBJS).
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_x.sh
#   bash scripts/xlang_x.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   XLANG_X / TARGET_OUT — output binary (default: xlang-x)
#   CC                   — host C compiler
#   XXL_LINK_CFLAGS      — expanded CFLAGS + DRIVER_SEED_LINK_FLAGS +
#                          ASM_GLUE_DUP_LDFLAGS + MAIN_LINK_FLAGS
#   XXL_LINK_OBJS        — full expanded object bag for the link line
#   XXL_REQUIRED_OBJS    — optional override; default loads XLANG_X_REQUIRED_OBJS
#                          from mk (wave855; not a second list authority)
#
# wave846 (G.7 有则补全): Makefile fat test + $(CC) link → this script.
# wave855: seed-gate REQUIRED loads from mk (G.7; not physical delete).
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
OUT="${XLANG_X:-${TARGET_OUT:-xlang-x}}"
CC="${CC:-cc}"

log() { echo "xlang-x: $*" >&2; }
fail() { echo "xlang-x: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
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
  if [ ! -f mk/driver_seed_composites.mk ]; then
    fail "missing mk/driver_seed_composites.mk (wave855 REQUIRED authority)"
  fi
  if ! grep -qE '^XLANG_X_REQUIRED_OBJS[[:space:]]*=' mk/driver_seed_composites.mk; then
    fail "mk/driver_seed_composites.mk must define XLANG_X_REQUIRED_OBJS (wave855)"
  fi
  log "CHECK OK (wave846+855 xlang-x shell-primary; REQUIRED from mk; not physical delete)"
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
# PLATFORM: SHARED — pure text parse of composites.mk; no make.
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

if [ -z "${XXL_LINK_CFLAGS:-}" ]; then
  fail "XXL_LINK_CFLAGS required (Makefile thin-call must export expanded link CFLAGS)"
fi
if [ -z "${XXL_LINK_OBJS:-}" ]; then
  fail "XXL_LINK_OBJS required (Makefile thin-call must export expanded link bag)"
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
  fail "missing driver/lsp satellite .o — run: make bootstrap-driver-seed"
fi

# ---------------------------------------------------------------------------
# host-cc link ./xlang-x (product archaeology full-driver binary)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this path
# ---------------------------------------------------------------------------
log "link ./$OUT"
# shellcheck disable=SC2086
$CC $XXL_LINK_CFLAGS -o "./$OUT" $XXL_LINK_OBJS
echo "xlang-x OK"

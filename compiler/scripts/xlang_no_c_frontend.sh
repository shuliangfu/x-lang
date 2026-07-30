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
#   hardcodes a second full link inventory — Makefile thin-call exports
#   expanded bags as XNC_* env vars.
#
# Usage (cwd = compiler/):
#   bash scripts/xlang_no_c_frontend.sh
#   bash scripts/xlang_no_c_frontend.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   CC                   — host C compiler
#   OUT / TARGET_OUT     — output binary (default: xlang-no-c-frontend)
#   XNC_LINK_CFLAGS      — expanded CFLAGS + DRIVER_SEED_LINK_FLAGS + MAIN_LINK_FLAGS
#   XNC_LINK_OBJS        — full expanded object bag for the link line
#   XNC_REQUIRED_OBJS    — satellite .o that must exist before link
#                          (historical seed gate; not a second list authority)
#
# wave847 (G.7 有则补全): Makefile fat test + $(CC) link → this script.
# NOT physical delete — prereq make-graph + thin edges + B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
OUT="${OUT:-${TARGET_OUT:-xlang-no-c-frontend}}"
CC="${CC:-cc}"

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
  log "CHECK OK (wave847 xlang-no-c-frontend shell-primary; not physical delete)"
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
# Preflight: link env from Makefile thin-call (G.7: bags stay mk expansion)
# ---------------------------------------------------------------------------
if [ -z "${XNC_LINK_CFLAGS:-}" ]; then
  fail "XNC_LINK_CFLAGS required (Makefile thin-call must export expanded link CFLAGS)"
fi
if [ -z "${XNC_LINK_OBJS:-}" ]; then
  fail "XNC_LINK_OBJS required (Makefile thin-call must export expanded link bag)"
fi
if [ -z "${XNC_REQUIRED_OBJS:-}" ]; then
  fail "XNC_REQUIRED_OBJS required (Makefile thin-call must export seed gate .o list)"
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

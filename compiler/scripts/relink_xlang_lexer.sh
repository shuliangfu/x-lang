#!/usr/bin/env bash
# relink_xlang_lexer.sh — fast product relink after lexer_x.o only
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile target relink-xlang-lexer:
#     1) preflight seed gate (.o that must already exist)
#     2) host-cc link ./$(TARGET) with expanded bag from mk
#     3) sync copies → XLANG_C + bootstrap_xlangc (historical product contract)
#
#   Object lists stay mk expansion (composites / user_asm / link_picks /
#   subcmd / PIPELINE_LIBS). Shell never hardcodes a second full link inventory —
#   Makefile thin-call exports expanded bags as RXL_* env vars.
#
# Usage (cwd = compiler/):
#   bash scripts/relink_xlang_lexer.sh
#   bash scripts/relink_xlang_lexer.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   TARGET / TARGET_OUT  — output binary (default: xlang)
#   XLANG_C              — sync destination (default: xlang-c)
#   BOOTSTRAP_XLANGC     — second sync destination (default: bootstrap_xlangc)
#   CC                   — host C compiler
#   RXL_LINK_CFLAGS      — expanded CFLAGS + DRIVER_SEED_LINK_FLAGS +
#                          ASM_GLUE_DUP_LDFLAGS + MAIN_LINK_FLAGS
#   RXL_LINK_OBJS        — full expanded object bag for the link line
#   RXL_REQUIRED_OBJS    — satellite .o that must exist before link
#                          (historical seed gate; not a second list authority)
#
# wave849 (G.7 有则补全): Makefile fat test + $(MAKE) glue + $(CC) link + cp → this script.
# NOT physical delete — prereq make-graph (lexer_x.o / FILTERED / GLUE) + thin edges +
# B2 + mk lists remain.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
OUT="${TARGET:-${TARGET_OUT:-xlang}}"
XLANG_C="${XLANG_C:-xlang-c}"
BOOTSTRAP_XLANGC="${BOOTSTRAP_XLANGC:-bootstrap_xlangc}"
CC="${CC:-cc}"

log() { echo "relink-xlang-lexer: $*" >&2; }
fail() { echo "relink-xlang-lexer: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
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
  # Dual cp sync of product aliases must not remain in recipe.
  if grep -qE 'cp -f \$\(TARGET\) \$\(XLANG_C\)|cp -f \$\(TARGET\) bootstrap_xlangc' <<<"$_rec"; then
    fail "relink-xlang-lexer must not keep dual cp sync body (wave849; shell owns sync)"
  fi
  log "CHECK OK (wave849 relink-xlang-lexer shell-primary; not physical delete)"
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
if [ -z "${RXL_LINK_CFLAGS:-}" ]; then
  fail "RXL_LINK_CFLAGS required (Makefile thin-call must export expanded link CFLAGS)"
fi
if [ -z "${RXL_LINK_OBJS:-}" ]; then
  fail "RXL_LINK_OBJS required (Makefile thin-call must export expanded link bag)"
fi
if [ -z "${RXL_REQUIRED_OBJS:-}" ]; then
  fail "RXL_REQUIRED_OBJS required (Makefile thin-call must export seed gate .o list)"
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
  fail "missing seed objects — need: make build-seed-asm-host + make bootstrap-driver-seed"
fi

# ---------------------------------------------------------------------------
# host-cc link ./$(TARGET) (product binary; lexer_x.o already rebuilt by make)
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

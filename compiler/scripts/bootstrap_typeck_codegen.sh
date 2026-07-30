#!/usr/bin/env bash
# bootstrap_typeck_codegen.sh — archaeology bootstrap-typeck / bootstrap-codegen body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phonies:
#     bootstrap-typeck   — force-regen typeck_gen → migrate typeck_x → relink TARGET
#     bootstrap-codegen  — force-regen typeck+codegen gen → migrate both → relink TARGET
#   Gen body  = ensure_migrate_gen.sh (wave736 FORCE_REGEN; no dual xlang-c -E in Makefile)
#   .o body   = migrate_x_objs.sh (wave735; XLANG_MIGRATE_FORCE=1)
#   Link list = Makefile env BTC_CFLAGS / BTC_OBJS (expands mk composites; no second .o inventory)
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
#   BTC_CFLAGS   — full CFLAGS + -DXLANG_USE_X_* + ASM_GLUE/MAIN_LINK flags (required for link)
#   BTC_OBJS     — expanded link object bag (required for link; from mk composites)
#   MAKE         — residual make for missing XLANG_C only (ensure_migrate_gen)
#   PYTHON       — for migrate_x_objs patches
#
# wave841 (G.7 有则补全): Makefile fat dual -E + migrate + $(CC) link → this script.
# NOT physical delete — thin-call edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

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
  [ -f "$MF" ] || fail "missing $MF"
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
  done
  log "CHECK OK (wave841 bootstrap-typeck/codegen shell-primary; not physical delete)"
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
# Preflight: link env from Makefile thin-call (G.7: lists stay mk expansions)
# ---------------------------------------------------------------------------
if [ -z "${BTC_CFLAGS:-}" ] || [ -z "${BTC_OBJS:-}" ]; then
  fail "BTC_CFLAGS and BTC_OBJS required (Makefile thin-call must export expanded link bag)"
fi
if [ ! -x "./$XLANG_C" ] && [ ! -f "./$XLANG_C" ]; then
  fail "missing $XLANG_C (build product first: make bootstrap_xlangc / bootstrap-driver-seed)"
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
  log "migrate_x_objs FORCE $1"
  CC="$CC" CFLAGS="${CFLAGS:-}" PYTHON="$PYTHON" MAKE="$MAKE" XLANG_MIGRATE_FORCE=1 \
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
# Relink TARGET with USE_X_TYPECK / (+CODEGEN) flags (bag from Makefile)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this archaeology path
# ---------------------------------------------------------------------------
log "link ./$TARGET (mode=$MODE)"
# shellcheck disable=SC2086
$CC $BTC_CFLAGS -o "./$TARGET" $BTC_OBJS
echo "bootstrap-${MODE} OK"

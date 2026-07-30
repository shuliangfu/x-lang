#!/usr/bin/env bash
# bootstrap_typeck_codegen.sh — archaeology bootstrap-typeck / bootstrap-codegen body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phonies:
#     bootstrap-typeck   — force-regen typeck_gen → migrate typeck_x → relink TARGET
#     bootstrap-codegen  — force-regen typeck+codegen gen → migrate both → relink TARGET
#   Gen body  = ensure_migrate_gen.sh (wave736 FORCE_REGEN; no dual xlang-c -E in Makefile)
#   .o body   = migrate_x_objs.sh (wave735; XLANG_MIGRATE_FORCE=1)
#   Link list = BTC_CFLAGS via export-btc-typeck-link-cflags / export-relink-product-link-cflags
#               (wave857; mode-dependent); BTC_OBJS via export-relink-product-link-objs
#               when unset (wave856; expands mk composites; no second .o inventory)
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
#   BTC_CFLAGS   — optional; default loads via export-btc-typeck-link-cflags (typeck)
#                  or export-relink-product-link-cflags (codegen) (wave857)
#   BTC_OBJS     — optional; default loads via export-relink-product-link-objs (wave856)
#   MAKE         — residual make for LINK_OBJS export leaf + ensure_migrate_gen
#   PYTHON       — for migrate_x_objs patches
#
# wave841 (G.7 有则补全): Makefile fat dual -E + migrate + $(CC) link → this script.
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
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
    # wave856: no multi-token BTC_OBJS= on recipe (shell loads export leaf).
    if grep -qE 'BTC_OBJS=' <<<"$_rec"; then
      fail "$ph must not export BTC_OBJS (wave856; shell loads export leaf)"
    fi
    # wave857: no multi-token BTC_CFLAGS= on recipe (shell loads export leaf).
    if grep -qE 'BTC_CFLAGS=' <<<"$_rec"; then
      fail "$ph must not export BTC_CFLAGS (wave857; shell loads export leaf)"
    fi
    # wave865: no multi-token product CFLAGS="$(CFLAGS)" (migrate loads export leaf).
    if grep -qE 'CFLAGS="\$\(CFLAGS\)"' <<<"$_rec"; then
      fail "$ph must not export CFLAGS= (wave865; migrate shell-loads export-try-heat-cflags)"
    fi
  done
  if ! grep -qE '^export-relink-product-link-objs:' "$MF"; then
    fail "Makefile must define export-relink-product-link-objs (wave856)"
  fi
  if ! grep -qE '^export-btc-typeck-link-cflags:' "$MF"; then
    fail "Makefile must define export-btc-typeck-link-cflags (wave857)"
  fi
  if ! grep -qE '^export-relink-product-link-cflags:' "$MF"; then
    fail "Makefile must define export-relink-product-link-cflags (wave857)"
  fi
  if ! grep -qE '^export-try-heat-cflags:' "$MF"; then
    fail "Makefile must define export-try-heat-cflags (wave865)"
  fi
  if ! grep -q 'export-try-heat-cflags\|wave865' scripts/migrate_x_objs.sh 2>/dev/null; then
    fail "migrate_x_objs.sh must shell-load export-try-heat-cflags (wave865)"
  fi
  log "CHECK OK (wave841+856+857+865 bootstrap-typeck/codegen shell-primary; LINK+CFLAGS export leaves; not physical delete)"
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
# wave856: full LINK bag needs make expansion (nested $(...) / Darwin filters).
# G.7 有则补全 on bootstrap_driver_seed_export-*-link pattern — shell loads via
# make export leaf when env unset; Makefile recipes drop multi-token BTC_OBJS=.
# PLATFORM: SHARED — KEY=value from export target; no second .o inventory.
_load_link_objs_via_make() {
  # $1 = make export target (export-*-link-objs)
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

if [ -z "${BTC_OBJS:-}" ]; then
  BTC_OBJS=$(_load_link_objs_via_make export-relink-product-link-objs) \
    || fail "failed to expand export-relink-product-link-objs (wave856 LINK_OBJS shell-load)"
fi
if [ -z "${BTC_OBJS:-}" ]; then
  fail "empty LINK_OBJS from export-relink-product-link-objs (wave856)"
fi

# wave857: composed LINK_CFLAGS need make expansion (DRIVER_SEED_LINK_FLAGS /
# ASM_GLUE / MAIN_LINK / platform ifeq). G.7 有则补全 on wave856 export-leaf pattern.
# PLATFORM: SHARED — KEY=value from export target; no second flag inventory.
_load_link_cflags_via_make() {
  # $1 = make export target (export-*-link-cflags)
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BTC_CFLAGS:-}" ]; then
  if [ "$MODE" = "typeck" ]; then
    BTC_CFLAGS=$(_load_link_cflags_via_make export-btc-typeck-link-cflags) \
      || fail "failed to expand export-btc-typeck-link-cflags (wave857 LINK_CFLAGS shell-load)"
  else
    # codegen: same composed flags as product RXL/XXL (includes -DXLANG_USE_X_CODEGEN)
    BTC_CFLAGS=$(_load_link_cflags_via_make export-relink-product-link-cflags) \
      || fail "failed to expand export-relink-product-link-cflags (wave857 LINK_CFLAGS shell-load)"
  fi
fi
if [ -z "${BTC_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from export leaf (wave857; mode=$MODE)"
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
  # wave865: do not pass empty CFLAGS= (blocks migrate export-try-heat-cflags load).
  # migrate_x_objs shell-loads product CFLAGS/PIPELINE_GEN when unset.
  log "migrate_x_objs FORCE $1"
  CC="$CC" PYTHON="$PYTHON" MAKE="$MAKE" XLANG_MIGRATE_FORCE=1 \
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

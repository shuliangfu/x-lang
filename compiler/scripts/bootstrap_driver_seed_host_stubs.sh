#!/usr/bin/env bash
# bootstrap_driver_seed_host_stubs.sh — §5b #9 asm_full_link_stubs body (11.0.3)
#
# Authority (G.7):
#   - CC / CFLAGS / OUT / HOST_DIR / SCAN_BASE composed from
#     driver_seed_obj_catalog.sh (shell-primary parse of mk lists; wave941).
#     Pre-wave941 these came from Makefile export leaf
#     bootstrap-driver-seed-export-host-stubs; the catalog is now the single
#     authority (CC/CFLAGS/USER_ASM_SEED_HOST_*/DRIVER_SEED_HOST_STUBS_SCAN_BASE
#     are all catalog keys sourced from mk/*.mk).
#   - This script never hardcodes USER_ASM_SEED_OBJS or platform glue paths.
#   - Optional scan peers under HOST_DIR (asm_full.o, asm_backend_partial.o)
#     are fixed relative names — same logic as the pre-wave723 Makefile recipe.
#
# Usage (compiler directory):
#   ./scripts/bootstrap_driver_seed_host_stubs.sh
#
# Env:
#   XLANG_CATALOG_CACHE_FILE — optional pre-warmed catalog KEY= blob (parent
#     bootstrap_driver_seed.sh warms one; reuses avoid re-parsing 17 mk files).
#
# PLATFORM: SHARED — gen_asm_full_link_stubs.pl emits weak stubs on ELF and
#            non-weak on MinGW; scan/base composition is catalog-owned.
# Wave: 723 Track MG · 941 shell-primary catalog (drop make export leaf).

set -euo pipefail
cd "$(dirname "$0")/.."

# wave941: compose SEED_STUBS_* from catalog (replaces make export leaf).
# Catalog keys (all from mk/*.mk via driver_seed_obj_catalog.sh --shell):
#   CC, CFLAGS, USER_ASM_SEED_HOST_STUBS, USER_ASM_SEED_HOST_DIR,
#   DRIVER_SEED_HOST_STUBS_SCAN_BASE.
# XLANG_CATALOG_CACHE_FILE lets the parent bootstrap pass a pre-warmed cache
# so this script does not re-parse all mk files (Windows MinGW: ~3min/call).
# PLATFORM: SHARED — same KEY=VALUE semantics on Darwin/Linux/Windows MSYS2.
_cat_query() {
  # $1 = key. Reuse cache file if present; else fall back to catalog --shell.
  if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
    sed -n "s|^$1=||p" "${XLANG_CATALOG_CACHE_FILE}" | tail -n 1
  else
    bash scripts/driver_seed_obj_catalog.sh --shell 2>/dev/null \
      | sed -n "s|^$1=||p" | tail -n 1
  fi
}

SEED_STUBS_CC=$(_cat_query CC)
SEED_STUBS_CFLAGS=$(_cat_query CFLAGS)
SEED_STUBS_OUT=$(_cat_query USER_ASM_SEED_HOST_STUBS)
SEED_STUBS_HOST_DIR=$(_cat_query USER_ASM_SEED_HOST_DIR)
SEED_STUBS_SCAN_BASE=$(_cat_query DRIVER_SEED_HOST_STUBS_SCAN_BASE)
SEED_STUBS_GEN_C="${SEED_STUBS_HOST_DIR}/asm_full_link_stubs.c"
SEED_STUBS_PERL="scripts/gen_asm_full_link_stubs.pl"

if [ -z "$SEED_STUBS_CC" ] || [ -z "$SEED_STUBS_OUT" ] || [ -z "$SEED_STUBS_HOST_DIR" ] \
  || [ -z "$SEED_STUBS_GEN_C" ] || [ -z "$SEED_STUBS_SCAN_BASE" ] || [ -z "$SEED_STUBS_PERL" ]; then
  echo "bootstrap_driver_seed_host_stubs: incomplete catalog (CC/OUT/HOST_DIR/SCAN_BASE empty)" >&2
  exit 1
fi

if [ ! -f "$SEED_STUBS_PERL" ]; then
  echo "bootstrap_driver_seed_host_stubs: missing generator $SEED_STUBS_PERL" >&2
  exit 1
fi

mkdir -p "$SEED_STUBS_HOST_DIR"

# Word-split SCAN_BASE intentionally (Makefile space-separated expansion).
# Optional peers: asm_full.o / asm_backend_partial.o under HOST_DIR if present
# (same order as pre-wave723 recipe: full, then partial, then base).
# Drop missing paths (wave309 ASM_GLUE_STANDALONE_O empty; never nm retired
# pipeline_glue_standalone.o). PLATFORM: SHARED.
# shellcheck disable=SC2086
_scan="$SEED_STUBS_SCAN_BASE"
if [ -f "$SEED_STUBS_HOST_DIR/asm_full.o" ]; then
  _scan="$SEED_STUBS_HOST_DIR/asm_full.o $_scan"
fi
if [ -f "$SEED_STUBS_HOST_DIR/asm_backend_partial.o" ]; then
  _scan="$SEED_STUBS_HOST_DIR/asm_backend_partial.o $_scan"
fi
_scan_present=""
for _so in $_scan; do
  if [ -f "$_so" ]; then
    _scan_present="${_scan_present} ${_so}"
  else
    echo "bootstrap_driver_seed_host_stubs: scan skip missing ${_so}" >&2
  fi
done
_scan="${_scan_present# }"
if [ -z "$_scan" ]; then
  echo "bootstrap_driver_seed_host_stubs: no present scan objs" >&2
  exit 1
fi

n_scan=$(printf '%s\n' "$_scan" | wc -w | tr -d ' ')
echo "bootstrap-driver-seed: host-stubs → $SEED_STUBS_OUT  (scan $n_scan objs via catalog)" >&2

# shellcheck disable=SC2086
perl "$SEED_STUBS_PERL" "$SEED_STUBS_GEN_C" $_scan
if [ ! -s "$SEED_STUBS_GEN_C" ]; then
  echo "bootstrap_driver_seed_host_stubs: generator produced empty $SEED_STUBS_GEN_C" >&2
  exit 1
fi

# shellcheck disable=SC2086
"$SEED_STUBS_CC" $SEED_STUBS_CFLAGS -c -o "$SEED_STUBS_OUT" "$SEED_STUBS_GEN_C"

echo "bootstrap_driver_seed_host_stubs: OK $SEED_STUBS_OUT" >&2

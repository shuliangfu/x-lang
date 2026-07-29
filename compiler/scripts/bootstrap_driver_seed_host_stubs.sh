#!/usr/bin/env bash
# bootstrap_driver_seed_host_stubs.sh — §5b #9 asm_full_link_stubs body (11.0.3)
#
# Authority (G.7):
#   - CC / CFLAGS / OUT / HOST_DIR / SCAN_BASE live ONLY in compiler/Makefile
#     (export leaf bootstrap-driver-seed-export-host-stubs).
#   - This script never hardcodes USER_ASM_SEED_OBJS or platform glue paths.
#   - Optional scan peers under HOST_DIR (asm_full.o, asm_backend_partial.o)
#     are fixed relative names — same logic as the pre-wave723 Makefile recipe.
#
# Usage (compiler directory):
#   ./scripts/bootstrap_driver_seed_host_stubs.sh
#
# Env:
#   MAKE — make binary (default: make)
#
# PLATFORM: SHARED — gen_asm_full_link_stubs.pl emits weak stubs on ELF and
#            non-weak on MinGW; scan/base composition is Makefile-owned.
# Wave: 723 Track MG · pairs with Makefile export + thin host-stubs leaf.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
export_target="bootstrap-driver-seed-export-host-stubs"

# Makefile single authority. Clear MAKEFLAGS so parent `make -n` / jobserver
# dry-run does not turn the export target into printed recipe text.
export_raw=$(MAKEFLAGS= "$MAKE" -s "$export_target")
if [ -z "$export_raw" ]; then
  echo "bootstrap_driver_seed_host_stubs: empty export from $export_target" >&2
  exit 1
fi

SEED_STUBS_CC=
SEED_STUBS_CFLAGS=
SEED_STUBS_OUT=
SEED_STUBS_HOST_DIR=
SEED_STUBS_GEN_C=
SEED_STUBS_SCAN_BASE=
SEED_STUBS_PERL=
while IFS= read -r line; do
  [ -z "${line:-}" ] && continue
  case "$line" in
    SEED_STUBS_CC=*) SEED_STUBS_CC=${line#SEED_STUBS_CC=} ;;
    SEED_STUBS_CFLAGS=*) SEED_STUBS_CFLAGS=${line#SEED_STUBS_CFLAGS=} ;;
    SEED_STUBS_OUT=*) SEED_STUBS_OUT=${line#SEED_STUBS_OUT=} ;;
    SEED_STUBS_HOST_DIR=*) SEED_STUBS_HOST_DIR=${line#SEED_STUBS_HOST_DIR=} ;;
    SEED_STUBS_GEN_C=*) SEED_STUBS_GEN_C=${line#SEED_STUBS_GEN_C=} ;;
    SEED_STUBS_SCAN_BASE=*) SEED_STUBS_SCAN_BASE=${line#SEED_STUBS_SCAN_BASE=} ;;
    SEED_STUBS_PERL=*) SEED_STUBS_PERL=${line#SEED_STUBS_PERL=} ;;
    *)
      echo "bootstrap_driver_seed_host_stubs: unknown export line: $line" >&2
      exit 1
      ;;
  esac
done <<EOF
$export_raw
EOF

if [ -z "$SEED_STUBS_CC" ] || [ -z "$SEED_STUBS_OUT" ] || [ -z "$SEED_STUBS_HOST_DIR" ] \
  || [ -z "$SEED_STUBS_GEN_C" ] || [ -z "$SEED_STUBS_SCAN_BASE" ] || [ -z "$SEED_STUBS_PERL" ]; then
  echo "bootstrap_driver_seed_host_stubs: incomplete export from $export_target" >&2
  echo "$export_raw" >&2
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
# shellcheck disable=SC2086
_scan="$SEED_STUBS_SCAN_BASE"
if [ -f "$SEED_STUBS_HOST_DIR/asm_full.o" ]; then
  _scan="$SEED_STUBS_HOST_DIR/asm_full.o $_scan"
fi
if [ -f "$SEED_STUBS_HOST_DIR/asm_backend_partial.o" ]; then
  _scan="$SEED_STUBS_HOST_DIR/asm_backend_partial.o $_scan"
fi

n_scan=$(printf '%s\n' "$_scan" | wc -w | tr -d ' ')
echo "bootstrap-driver-seed: host-stubs → $SEED_STUBS_OUT  (scan $n_scan objs via Makefile export)" >&2

# shellcheck disable=SC2086
perl "$SEED_STUBS_PERL" "$SEED_STUBS_GEN_C" $_scan
if [ ! -s "$SEED_STUBS_GEN_C" ]; then
  echo "bootstrap_driver_seed_host_stubs: generator produced empty $SEED_STUBS_GEN_C" >&2
  exit 1
fi

# shellcheck disable=SC2086
"$SEED_STUBS_CC" $SEED_STUBS_CFLAGS -c -o "$SEED_STUBS_OUT" "$SEED_STUBS_GEN_C"

echo "bootstrap_driver_seed_host_stubs: OK $SEED_STUBS_OUT" >&2

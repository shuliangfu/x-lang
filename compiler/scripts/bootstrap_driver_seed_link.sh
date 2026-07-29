#!/usr/bin/env bash
# bootstrap_driver_seed_link.sh — phase1/final link body for cold bootstrap (11.0.3)
#
# Authority (G.7):
#   - Object lists + CFLAGS + platform link flags live ONLY in compiler/Makefile
#     (DRIVER_SEED_* / BOOTSTRAP_DRIVER_SEED_* / MAIN_LINK_* expansions).
#   - This script never hardcodes an .o list. It evals export leaves:
#       make bootstrap-driver-seed-export-phase1-link
#       make bootstrap-driver-seed-export-final-link
#   - Then runs $(CC) $(CFLAGS...) -o OUT OBJS.
#
# Usage (compiler directory):
#   ./scripts/bootstrap_driver_seed_link.sh phase1
#   ./scripts/bootstrap_driver_seed_link.sh final
#
# Env:
#   MAKE   — make binary (default: make)
#   TARGET — final product name when mode=final (default: xlang); must match Makefile
#
# PLATFORM: SHARED — link command composition identical; Makefile expands platform
#            crt0 / -e / filtered.o differences into SEED_LINK_*.
# Wave: 721 Track MG · pairs with Makefile export + thin phase1/final leaves.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
MODE="${1:-}"

if [ "$MODE" != "phase1" ] && [ "$MODE" != "final" ]; then
  echo "bootstrap_driver_seed_link: usage: $0 phase1|final" >&2
  exit 2
fi

export_target="bootstrap-driver-seed-export-${MODE}-link"

# Makefile single authority. Clear MAKEFLAGS so parent `make -n` / jobserver
# dry-run does not turn the export target into printed recipe text.
# KEY=value lines (first '=' splits) — safe for CFLAGS with commas/spaces.
export_raw=$(MAKEFLAGS= "$MAKE" -s "$export_target" TARGET="${TARGET:-xlang}")
if [ -z "$export_raw" ]; then
  echo "bootstrap_driver_seed_link: empty export from $export_target" >&2
  exit 1
fi

SEED_LINK_CC=
SEED_LINK_CFLAGS=
SEED_LINK_OUT=
SEED_LINK_OBJS=
while IFS= read -r line; do
  [ -z "${line:-}" ] && continue
  case "$line" in
    SEED_LINK_CC=*) SEED_LINK_CC=${line#SEED_LINK_CC=} ;;
    SEED_LINK_CFLAGS=*) SEED_LINK_CFLAGS=${line#SEED_LINK_CFLAGS=} ;;
    SEED_LINK_OUT=*) SEED_LINK_OUT=${line#SEED_LINK_OUT=} ;;
    SEED_LINK_OBJS=*) SEED_LINK_OBJS=${line#SEED_LINK_OBJS=} ;;
    *)
      echo "bootstrap_driver_seed_link: unknown export line: $line" >&2
      exit 1
      ;;
  esac
done <<EOF
$export_raw
EOF

if [ -z "$SEED_LINK_CC" ] || [ -z "$SEED_LINK_OUT" ] || [ -z "$SEED_LINK_OBJS" ]; then
  echo "bootstrap_driver_seed_link: incomplete export (CC/OUT/OBJS) from $export_target" >&2
  echo "$export_raw" >&2
  exit 1
fi

n_objs=$(printf '%s\n' "$SEED_LINK_OBJS" | wc -w | tr -d ' ')
echo "bootstrap-driver-seed: ${MODE} link → $SEED_LINK_OUT  ($n_objs objs via Makefile export)" >&2

# Word-split CFLAGS and OBJS intentionally (space-separated make expansions).
# shellcheck disable=SC2086
"$SEED_LINK_CC" $SEED_LINK_CFLAGS -o "$SEED_LINK_OUT" $SEED_LINK_OBJS

echo "bootstrap_driver_seed_link: OK $SEED_LINK_OUT" >&2

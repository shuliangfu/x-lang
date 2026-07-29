#!/usr/bin/env bash
# bootstrap_driver_seed_rebuild_leaves.sh — §5b make-target leaf body (11.0.3)
#
# Authority (G.7):
#   - Object lists + forced flags live ONLY in compiler/Makefile
#     (DRIVER_SEED_*_OBJS + export leaves).
#   - This script never hardcodes an .o list. It evals the matching export
#     leaf, then runs make with exported targets / make-args / env.
#
# Usage (compiler directory):
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh sat
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh lsp
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh panic
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh user-asm
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh glue
#   ./scripts/bootstrap_driver_seed_rebuild_leaves.sh pipeline-x
#
# Env:
#   MAKE — make binary (default: make)
#
# PLATFORM: SHARED — rebuild orchestration identical; Makefile expands mode
#            runtime_rebuild lists (no_c vs seed) and platform USER_ASM sets.
# Wave: 722 sat/lsp · 724 bridge/panic/user-asm/glue · 725 pipeline-x FORCE.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
MODE="${1:-}"

case "$MODE" in
  sat) export_target="bootstrap-driver-seed-export-sat-rebuild" ;;
  lsp) export_target="bootstrap-driver-seed-export-lsp-x-objs" ;;
  bridge) export_target="bootstrap-driver-seed-export-bridge" ;;
  panic) export_target="bootstrap-driver-seed-export-panic" ;;
  user-asm) export_target="bootstrap-driver-seed-export-user-asm" ;;
  glue) export_target="bootstrap-driver-seed-export-glue" ;;
  pipeline-x) export_target="bootstrap-driver-seed-export-pipeline-x" ;;
  *)
    echo "bootstrap_driver_seed_rebuild_leaves: usage: $0 sat|lsp|bridge|panic|user-asm|glue|pipeline-x" >&2
    exit 2
    ;;
esac

# Makefile single authority. Clear MAKEFLAGS so parent `make -n` / jobserver
# dry-run does not turn the export target into printed recipe text.
# KEY=value lines (first '=' splits).
export_raw=$(MAKEFLAGS= "$MAKE" -s "$export_target")
if [ -z "$export_raw" ]; then
  echo "bootstrap_driver_seed_rebuild_leaves: empty export from $export_target" >&2
  exit 1
fi

SEED_REBUILD_OBJS=
SEED_REBUILD_MAKE_ARGS=
SEED_REBUILD_MAKE_VARS=
while IFS= read -r line; do
  [ -z "${line:-}" ] && continue
  case "$line" in
    SEED_REBUILD_OBJS=*) SEED_REBUILD_OBJS=${line#SEED_REBUILD_OBJS=} ;;
    SEED_REBUILD_MAKE_ARGS=*) SEED_REBUILD_MAKE_ARGS=${line#SEED_REBUILD_MAKE_ARGS=} ;;
    SEED_REBUILD_MAKE_VARS=*) SEED_REBUILD_MAKE_VARS=${line#SEED_REBUILD_MAKE_VARS=} ;;
    *)
      echo "bootstrap_driver_seed_rebuild_leaves: unknown export line: $line" >&2
      exit 1
      ;;
  esac
done <<EOF
$export_raw
EOF

if [ -z "$SEED_REBUILD_OBJS" ]; then
  echo "bootstrap_driver_seed_rebuild_leaves: empty SEED_REBUILD_OBJS from $export_target" >&2
  echo "$export_raw" >&2
  exit 1
fi

n_objs=$(printf '%s\n' "$SEED_REBUILD_OBJS" | wc -w | tr -d ' ')
echo "bootstrap-driver-seed: ${MODE} rebuild  ($n_objs targets via Makefile export)" >&2

# Word-split intentionally (space-separated make expansions).
# SEED_REBUILD_MAKE_VARS are make command-line assignments (e.g. XLANG_G05_PREFER_X_O=0),
# same priority as the pre-wave722 recipe `$(MAKE) -B ... VAR=0`.
# shellcheck disable=SC2086
"$MAKE" $SEED_REBUILD_MAKE_ARGS $SEED_REBUILD_OBJS $SEED_REBUILD_MAKE_VARS

echo "bootstrap_driver_seed_rebuild_leaves: OK ${MODE}" >&2

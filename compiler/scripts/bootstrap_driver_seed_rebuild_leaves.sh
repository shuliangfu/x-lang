#!/usr/bin/env bash
# bootstrap_driver_seed_rebuild_leaves.sh — §5b rebuild leaf orchestration (11.0.3 · wave747 R4)
#
# Authority (G.7):
#   - Object *lists* live ONLY in compiler/mk/*.mk, expanded via
#     driver_seed_obj_catalog.sh (export-obj-catalog). This script never
#     hardcodes an .o inventory.
#   - Mode policy (catalog KEY + make -B args + command-line VAR= assignments)
#     lives in this shell (wave747 R4 mode-policy swallow). Makefile
#     bootstrap-driver-seed-export-* rebuild targets remain as optional
#     inventory mirrors; cold path does not depend on them.
#   - Pattern *bodies* (host-cc / platform stamp recipes) remain Makefile
#     residual until 11.3.1 endgame — this script still invokes make for
#     the exported targets (honest R4 body residual).
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
#   XLANG_REBUILD_LEAVES_VIA_EXPORT=1 — legacy: eval Makefile export-* leaf
#     instead of catalog (escape hatch / compare; not product default)
#
# PLATFORM: SHARED — mode table + catalog expansion; Makefile expands
#            host-specific runtime rebuild lists (no_c vs seed) and platform
#            USER_ASM sets. Pattern recipe ABI stays Makefile.
# Wave: 722 sat/lsp · 724 bridge/panic/user-asm/glue · 725 pipeline-x FORCE ·
#       747 R4 mode policy + catalog list (no dual SEED_REBUILD export path).

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
MODE="${1:-}"

# Clear MAKEFLAGS so parent `make -n` / jobserver dry-run does not poison export.
export MAKEFLAGS=""

# ---------------------------------------------------------------------------
# R4 mode policy table (shell authority · wave747)
# catalog_key must match driver_seed_obj_catalog / mk lists (G.7 single list).
# make_args / make_vars match former Makefile export-* SEED_REBUILD_* lines.
# ---------------------------------------------------------------------------
catalog_key=
make_args=
make_vars=
case "$MODE" in
  sat)
    catalog_key="DRIVER_SEED_SAT_REBUILD_OBJS"
    make_args="-B"
    make_vars="XLANG_G05_PREFER_X_O=0"
    ;;
  lsp)
    catalog_key="DRIVER_SEED_LSP_X_OBJS"
    make_args=""
    make_vars=""
    ;;
  bridge)
    catalog_key="DRIVER_SEED_BRIDGE_OBJS"
    make_args=""
    make_vars=""
    ;;
  panic)
    catalog_key="DRIVER_SEED_PANIC_OBJS"
    make_args=""
    make_vars=""
    ;;
  user-asm)
    catalog_key="DRIVER_SEED_USER_ASM_SEED_OBJS"
    make_args=""
    make_vars=""
    ;;
  glue)
    catalog_key="DRIVER_SEED_ASM_GLUE_OBJS"
    make_args=""
    make_vars=""
    ;;
  pipeline-x)
    catalog_key="DRIVER_SEED_PIPELINE_X_OBJS"
    make_args=""
    make_vars="PIPELINE_X_FORCE_COMPILE=1"
    ;;
  *)
    echo "bootstrap_driver_seed_rebuild_leaves: usage: $0 sat|lsp|bridge|panic|user-asm|glue|pipeline-x" >&2
    exit 2
    ;;
esac

SEED_REBUILD_OBJS=
SEED_REBUILD_MAKE_ARGS="$make_args"
SEED_REBUILD_MAKE_VARS="$make_vars"
list_source=

if [ "${XLANG_REBUILD_LEAVES_VIA_EXPORT:-}" = "1" ]; then
  # Legacy path: Makefile export leaf (kept for compare / agent escape).
  case "$MODE" in
    sat) export_target="bootstrap-driver-seed-export-sat-rebuild" ;;
    lsp) export_target="bootstrap-driver-seed-export-lsp-x-objs" ;;
    bridge) export_target="bootstrap-driver-seed-export-bridge" ;;
    panic) export_target="bootstrap-driver-seed-export-panic" ;;
    user-asm) export_target="bootstrap-driver-seed-export-user-asm" ;;
    glue) export_target="bootstrap-driver-seed-export-glue" ;;
    pipeline-x) export_target="bootstrap-driver-seed-export-pipeline-x" ;;
  esac
  export_raw=$("$MAKE" -s "$export_target")
  if [ -z "$export_raw" ]; then
    echo "bootstrap_driver_seed_rebuild_leaves: empty export from $export_target" >&2
    exit 1
  fi
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
  list_source="Makefile export $export_target"
else
  # Default (wave747): single catalog authority for lists.
  if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
    echo "bootstrap_driver_seed_rebuild_leaves: missing scripts/driver_seed_obj_catalog.sh" >&2
    exit 1
  fi
  catalog_out="$(bash scripts/driver_seed_obj_catalog.sh)"
  SEED_REBUILD_OBJS="$(printf '%s\n' "$catalog_out" | sed -n "s/^${catalog_key}=//p" | head -1)"
  list_source="catalog ${catalog_key}"
fi

if [ -z "${SEED_REBUILD_OBJS// /}" ]; then
  echo "bootstrap_driver_seed_rebuild_leaves: empty SEED_REBUILD_OBJS from $list_source" >&2
  exit 1
fi

n_objs=$(printf '%s\n' "$SEED_REBUILD_OBJS" | wc -w | tr -d ' ')
echo "bootstrap-driver-seed: ${MODE} rebuild  ($n_objs targets via $list_source)" >&2

# Word-split intentionally (space-separated make expansions).
# SEED_REBUILD_MAKE_VARS are make command-line assignments (e.g. XLANG_G05_PREFER_X_O=0),
# same priority as the pre-wave722 recipe `$(MAKE) -B ... VAR=0`.
# R4 residual: pattern bodies still Makefile (host-cc / stamp recipes).
# shellcheck disable=SC2086
"$MAKE" $SEED_REBUILD_MAKE_ARGS $SEED_REBUILD_OBJS $SEED_REBUILD_MAKE_VARS

echo "bootstrap_driver_seed_rebuild_leaves: OK ${MODE}" >&2

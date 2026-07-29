#!/usr/bin/env bash
# bootstrap_driver_seed_rebuild_leaves.sh — §5b rebuild leaf orchestration
#   (11.0.3 · wave747 R4 mode · wave756 R4 pure-R1 · wave757 R3 cold-else ·
#    wave758 thin_glue seed-map · wave759 glue-standalone seed-map ·
#    wave760 R2 panic cold try-r2)
#
# Authority (G.7):
#   - Object *lists* live ONLY in compiler/mk/*.mk, expanded via
#     driver_seed_obj_catalog.sh (export-obj-catalog). This script never
#     hardcodes an .o inventory.
#   - Mode policy (catalog KEY + make -B args + command-line VAR= assignments)
#     lives in this shell (wave747 R4 mode-policy swallow). Makefile
#     bootstrap-driver-seed-export-* rebuild targets remain as optional
#     inventory mirrors; cold path does not depend on them.
#   - Pure R1 pattern *bodies* (host-cc seeds/*.from_x.c → .o) run via
#     ensure_host_cc_seed_o.sh try-r1 (wave756). Catalog membership only —
#     no dual .o list; same ensure_one body as R1 family modes.
#   - R3 cold-else bodies (thin+rest leaves whose cold path is pure host-cc)
#     run via ensure try-r3-cold (wave757; catalog R3_COLD_SEED_OBJS).
#   - R2 panic cold body (platform stamp + UNAME source pick) via ensure
#     try-r2 (wave760; catalog DRIVER_SEED_PANIC_OBJS). PREFER thin stays
#     Makefile when residual make still hits panic (product daily path).
#   - Remaining residual (gen *_x.o, pipeline_x, R2 typeck_f64/crt0, …)
#     still invoke make with mode ARGS/VARS.
#     wave758: parser_asm_thin_glue swallowed via R1 seed-map (try-r1).
#     wave759: pipeline_glue_standalone swallowed via R1 seed-map (try-r1).
#     wave760: runtime_panic cold swallowed via try-r2 (panic residual_make=0).
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
#   CC / CFLAGS / PIPELINE_GEN_CFLAGS — forwarded to ensure try-r1 / try-r2
#
# PLATFORM: SHARED — mode table + catalog expansion; Makefile expands
#            host-specific runtime rebuild lists (no_c vs seed) and platform
#            USER_ASM sets. Residual non-R1 recipe ABI stays Makefile.
# Wave: 722 sat/lsp · 724 bridge/panic/user-asm/glue · 725 pipeline-x FORCE ·
#       747 R4 mode policy + catalog list · 756 R4 pure-R1 body via try-r1 ·
#       757 R3 cold-else body via try-r3-cold · 758 thin_glue via seed-map ·
#       759 glue-standalone via seed-map (try-r1) · 760 R2 panic try-r2.

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
  done <<< "$export_raw"
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

# ---------------------------------------------------------------------------
# wave756: pure R1 bodies via ensure try-r1 (no make pattern for those leaves).
# wave757: R3 cold-else via try-r3-cold when try-r1 exits 3 (catalog membership).
# wave760: R2 panic cold via try-r2 when try-r3-cold exits 3 (DRIVER_SEED_PANIC).
# -B (sat) → force recompile pure R1 + R3 cold + R2 as well (match make -B).
# Remaining residual still make with SEED_REBUILD_MAKE_ARGS / VARS.
# G.7: membership via catalog KEY only; no hardcoded .o list here.
# ---------------------------------------------------------------------------
if [ ! -f scripts/ensure_host_cc_seed_o.sh ]; then
  echo "bootstrap_driver_seed_rebuild_leaves: missing scripts/ensure_host_cc_seed_o.sh (wave756/757/760)" >&2
  exit 1
fi

force_shell=0
case " ${SEED_REBUILD_MAKE_ARGS} " in
  *" -B "*|*" -B") force_shell=1 ;;
esac
# Also honor bare -B without surrounding spaces edge cases
if [ "$SEED_REBUILD_MAKE_ARGS" = "-B" ]; then
  force_shell=1
fi

residual_objs=""
pure_n=0
r3_cold_n=0
r2_n=0
residual_n=0
# Word-split intentionally (space-separated make expansions).
# shellcheck disable=SC2086
for o in $SEED_REBUILD_OBJS; do
  [ -z "$o" ] && continue
  set +e
  if [ "$force_shell" = "1" ]; then
    XLANG_HOST_CC_SEED_FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-r1 "$o"
  else
    bash scripts/ensure_host_cc_seed_o.sh try-r1 "$o"
  fi
  rc=$?
  set -e
  case "$rc" in
    0)
      pure_n=$((pure_n + 1))
      continue
      ;;
    3)
      # Not pure R1 — try R3 cold-else host-cc (wave757).
      set +e
      if [ "$force_shell" = "1" ]; then
        XLANG_HOST_CC_SEED_FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-r3-cold "$o"
      else
        bash scripts/ensure_host_cc_seed_o.sh try-r3-cold "$o"
      fi
      rc3=$?
      set -e
      case "$rc3" in
        0)
          r3_cold_n=$((r3_cold_n + 1))
          continue
          ;;
        3)
          # Not R3 cold — try R2 panic cold (wave760).
          set +e
          if [ "$force_shell" = "1" ]; then
            XLANG_HOST_CC_SEED_FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-r2 "$o"
          else
            bash scripts/ensure_host_cc_seed_o.sh try-r2 "$o"
          fi
          rc2=$?
          set -e
          case "$rc2" in
            0)
              r2_n=$((r2_n + 1))
              continue
              ;;
            3)
              residual_objs="${residual_objs} ${o}"
              residual_n=$((residual_n + 1))
              continue
              ;;
            *)
              echo "bootstrap_driver_seed_rebuild_leaves: try-r2 failed for $o (rc=$rc2)" >&2
              exit 1
              ;;
          esac
          ;;
        *)
          echo "bootstrap_driver_seed_rebuild_leaves: try-r3-cold failed for $o (rc=$rc3)" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "bootstrap_driver_seed_rebuild_leaves: try-r1 failed for $o (rc=$rc)" >&2
      exit 1
      ;;
  esac
done

if [ "$residual_n" -gt 0 ]; then
  # R4 residual: still Makefile (gen *_x, pipeline_x, …).
  # wave758: thin_glue is pure-R1 seed-map (not residual).
  # wave759: glue standalone is pure-R1 seed-map (not residual).
  # wave760: panic cold is try-r2 (not residual when rebuild path hits cold).
  # SEED_REBUILD_MAKE_VARS are make command-line assignments (e.g. XLANG_G05_PREFER_X_O=0).
  # shellcheck disable=SC2086
  echo "bootstrap-driver-seed: ${MODE} residual make ($residual_n objs; pure-R1=$pure_n r3-cold=$r3_cold_n r2=$r2_n)" >&2
  # shellcheck disable=SC2086
  "$MAKE" $SEED_REBUILD_MAKE_ARGS $residual_objs $SEED_REBUILD_MAKE_VARS
else
  echo "bootstrap-driver-seed: ${MODE} shell only (pure-R1=$pure_n r3-cold=$r3_cold_n r2=$r2_n; no make pattern)" >&2
fi

echo "bootstrap_driver_seed_rebuild_leaves: OK ${MODE} (pure_r1=$pure_n r3_cold=$r3_cold_n r2=$r2_n residual_make=$residual_n)" >&2

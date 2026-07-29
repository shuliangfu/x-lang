#!/usr/bin/env bash
# driver_seed_obj_catalog.sh — wave726–728 · read-only dump of DRIVER_SEED_* lists
#
# G.7: Object-list *definitions* live in compiler/mk/*.mk (included by Makefile).
# This script only invokes `make bootstrap-driver-seed-export-obj-catalog` and
# prints KEY=value lines. Future xbuild may parse the same leaf; never hardcode
# a second .o inventory here.
#
# Usage (compiler/ directory or with -C):
#   bash scripts/driver_seed_obj_catalog.sh
#   MAKE=gmake bash scripts/driver_seed_obj_catalog.sh
#   bash scripts/driver_seed_obj_catalog.sh --check   # require known keys
#
# PLATFORM: SHARED — thin make export consumer; no compile/link.

set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MAKE="${MAKE:-make}"
# Clear MAKEFLAGS so nested/agent make does not inject -n / jobserver noise into export.
export MAKEFLAGS=""

CHECK=0
if [ "${1:-}" = "--check" ]; then
  CHECK=1
fi

# Required keys from export-obj-catalog (must match Makefile recipe + mk lists).
# wave728: composite keys (LINK_BASE / PREREQS / X_FRONTEND) added.
REQUIRED_KEYS=(
  DRIVER_SEED_PIPELINE_X_OBJS
  DRIVER_SEED_SAT_REBUILD_OBJS
  DRIVER_SEED_LSP_X_OBJS
  DRIVER_SEED_BRIDGE_OBJS
  DRIVER_SEED_PANIC_OBJS
  DRIVER_SEED_USER_ASM_SEED_OBJS
  DRIVER_SEED_ASM_GLUE_OBJS
  DRIVER_SEED_HOST_STUBS_SCAN_BASE
  DRIVER_SEED_ASM_HOST_DISPATCH_OBJS
  DRIVER_SEED_OBJS
  DRIVER_SEED_LINK_BASE
  BOOTSTRAP_DRIVER_SEED_LINK_BASE
  DRIVER_SEED_PREREQS
  DRIVER_SEED_X_FRONTEND_OBJS
  BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS
  BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS
  USER_ASM_SEED_OBJS
  ASM_GLUE_STANDALONE_O
  RT_SEED_SLICE_OBJS
  R1_CORE_SEED_OBJS
  R1_FRONTEND_GLUE_OBJS
)

out="$("$MAKE" -s bootstrap-driver-seed-export-obj-catalog)"
printf '%s\n' "$out"

if [ "$CHECK" -eq 1 ]; then
  missing=0
  for k in "${REQUIRED_KEYS[@]}"; do
    if ! printf '%s\n' "$out" | grep -q "^${k}="; then
      echo "driver_seed_obj_catalog: missing key $k" >&2
      missing=1
    fi
  done
  # Empty lists ok (e.g. FILTERED on Linux); values must expand USER_ASM non-empty.
  user_asm=$(printf '%s\n' "$out" | sed -n 's/^USER_ASM_SEED_OBJS=//p' | head -1)
  if [ -z "${user_asm// /}" ]; then
    echo "driver_seed_obj_catalog: USER_ASM_SEED_OBJS empty (mk include broken?)" >&2
    missing=1
  fi
  if [ "$missing" -ne 0 ]; then
    exit 1
  fi
  echo "driver_seed_obj_catalog: --check OK (${#REQUIRED_KEYS[@]} keys)" >&2
fi

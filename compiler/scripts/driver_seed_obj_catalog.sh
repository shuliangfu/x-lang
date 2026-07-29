#!/usr/bin/env bash
# driver_seed_obj_catalog.sh — wave726 · read-only dump of DRIVER_SEED_* lists
#
# G.7: Makefile remains the sole authority for object-list *definitions*.
# This script only invokes `make bootstrap-driver-seed-export-obj-catalog` and
# prints KEY=value lines. Future xbuild may parse the same leaf; never hardcode
# a second .o inventory here.
#
# Usage (compiler/ directory or with -C):
#   bash scripts/driver_seed_obj_catalog.sh
#   MAKE=gmake bash scripts/driver_seed_obj_catalog.sh
#
# PLATFORM: SHARED — thin make export consumer; no compile/link.

set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MAKE="${MAKE:-make}"
# Clear MAKEFLAGS so nested/agent make does not inject -n / jobserver noise into export.
export MAKEFLAGS=""

exec "$MAKE" -s bootstrap-driver-seed-export-obj-catalog

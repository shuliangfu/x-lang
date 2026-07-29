#!/usr/bin/env bash
# driver_seed_ensure_prereqs.sh — wave744 · 11.3 residual: swallow DRIVER_SEED_PREREQS edges
#
# Authority (G.7):
#   Object-list *definition* of DRIVER_SEED_PREREQS stays in
#   compiler/mk/driver_seed_composites.mk (read via driver_seed_obj_catalog.sh /
#   make bootstrap-driver-seed-export-obj-catalog). This script owns only
#   *edge satisfaction*: expand the catalog key and invoke Make for those
#   targets (plus the historical glue companion). It does NOT hardcode a
#   second .o inventory.
#
# Usage (from compiler/):
#   bash scripts/driver_seed_ensure_prereqs.sh              # run (make prereqs)
#   bash scripts/driver_seed_ensure_prereqs.sh --dry-run
#   bash scripts/driver_seed_ensure_prereqs.sh --check
#   bash scripts/driver_seed_ensure_prereqs.sh --run
#
# Env:
#   MAKE — make binary (default: make)
#   XLANG_SKIP_DRIVER_SEED_PREREQS=1 — no-op (nested / agent escape hatch)
#
# PLATFORM: SHARED — catalog expansion is host-specific (Darwin filtered lists);
# leaf recipes carry platform ABI. Wave744 Track MG (not physical Makefile delete).

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
MODE=run
case "${1:-}" in
  --dry-run|dry-run|dryrun) MODE=dry-run ;;
  --check|check|-c) MODE=check ;;
  --run|run|ensure|"") MODE=run ;;
  help|-h|--help)
    sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "driver_seed_ensure_prereqs: unknown mode '${1:-}' (use --dry-run|--check|--run)" >&2
    exit 2
    ;;
esac

if [ "${XLANG_SKIP_DRIVER_SEED_PREREQS:-}" = "1" ]; then
  echo "driver_seed_ensure_prereqs: skip (XLANG_SKIP_DRIVER_SEED_PREREQS=1)" >&2
  exit 0
fi

# Clear MAKEFLAGS so parent `make -n` / jobserver noise does not poison export.
export MAKEFLAGS=""

if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
  echo "driver_seed_ensure_prereqs: missing scripts/driver_seed_obj_catalog.sh" >&2
  exit 1
fi

catalog_out="$(bash scripts/driver_seed_obj_catalog.sh)"
prereqs="$(printf '%s\n' "$catalog_out" | sed -n 's/^DRIVER_SEED_PREREQS=//p' | head -1)"

# Historical Makefile attached glue companion outside the composite list:
#   bootstrap-driver-seed: $(DRIVER_SEED_PREREQS) build_asm/pipeline_glue_strict_minimal.o
# Keep that edge; do not bake a full second list.
extra_glue="build_asm/pipeline_glue_strict_minimal.o"

if [ -z "${prereqs// /}" ]; then
  echo "driver_seed_ensure_prereqs: empty DRIVER_SEED_PREREQS from catalog" >&2
  exit 1
fi

# Build ordered unique word list (prereqs first, then glue if not already present).
# shellcheck disable=SC2086
set -- $prereqs
have_glue=0
for t in "$@"; do
  if [ "$t" = "$extra_glue" ]; then
    have_glue=1
    break
  fi
done
if [ "$have_glue" -eq 0 ]; then
  set -- "$@" "$extra_glue"
fi

n=$#
if [ "$n" -lt 8 ]; then
  echo "driver_seed_ensure_prereqs: DRIVER_SEED_PREREQS too short (n=$n; catalog broken?)" >&2
  exit 1
fi

# Spot-check core cold nodes are present (names only — not a second inventory).
joined=" $* "
for must in pipeline_x.o parser_x.o typeck_x.o codegen_x.o driver_x.o; do
  case "$joined" in
    *" $must "*) ;;
    *)
      echo "driver_seed_ensure_prereqs: catalog PREREQS missing expected $must" >&2
      exit 1
      ;;
  esac
done

echo "driver_seed_ensure_prereqs: mode=$MODE count=$n (catalog DRIVER_SEED_PREREQS + glue companion)" >&2

if [ "$MODE" = dry-run ] || [ "$MODE" = check ]; then
  i=0
  for t in "$@"; do
    printf 'PREREQ=%d PATH=%s\n' "$i" "$t"
    i=$((i + 1))
  done
  if [ "$MODE" = dry-run ]; then
    echo "driver_seed_ensure_prereqs: DRY-RUN OK count=$n"
  else
    echo "driver_seed_ensure_prereqs: CHECK OK count=$n"
  fi
  exit 0
fi

# run: single make invocation for all edge targets (same as former make graph).
echo "driver_seed_ensure_prereqs: make ($n targets) ..." >&2
# shellcheck disable=SC2086
"$MAKE" "$@"
echo "driver_seed_ensure_prereqs: RUN OK count=$n" >&2
exit 0

#!/usr/bin/env bash
# filter_bootstrap_seed_against_partial_o.sh — named authority for class-G
# filters that omit only seed_host/asm_backend_partial.o symbols:
#   build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o
#   build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o
#   build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o
#
# Thin wrapper over filter_o_export_against_deps.sh (G.7). Makefile recipes and
# g05_ensure Darwin product path both invoke this script — no third nm/ld copy.
#
# wave835/921 (G.7 有则补全; not physical delete):
#   Makefile residual leaves use FORCE + this script only (no SRC/partial
#   make-graph prereq). wave921: 3 per-leaf recipes → 1 multi-target
#   $(FILTER_AGAINST_PARTIAL_OBJS) in mk/driver_seed_r_lists.mk. + optional SRC ensure:
#     - ensure OUT  → catalog lookup, try-heat SRC, mtime skip, then filter
#     - positional SRC OUT STEM [PARTIAL] still works (g05 / archaeology)
#     - XLANG_FILTER_FORCE=1 always refilters
#   PLATFORM: SHARED — cheap mtime skip on every FORCE recipe run.
#
# wave863 (G.7 有则补全; not physical delete):
#   Makefile filter recipes drop multi-token CFLAGS=/PIPELINE_GEN_CFLAGS= inject.
#   try-heat (wave862) shell-loads export-try-heat-cflags when unset — do NOT
#   pass empty CFLAGS= (set-but-empty blocks shell-load).
#
# Usage (cwd = compiler/):
#   bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure OUT.o
#   bash scripts/filter_bootstrap_seed_against_partial_o.sh --check
#   bash scripts/filter_bootstrap_seed_against_partial_o.sh list
#   bash scripts/filter_bootstrap_seed_against_partial_o.sh SRC.o OUT.o STEM [PARTIAL]
#
# PLATFORM: SHARED — Darwin product link lists these filtered.o in g05_relink_env;
# Linux product link uses unfiltered USER_ASM .o (still OK to build for cold seed).

set -euo pipefail

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_self="$_script_dir/$(basename "$0")"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

TAG="filter_bootstrap_seed_against_partial"
PARTIAL_DEFAULT="build_asm/seed_host/asm_backend_partial.o"

# OUT|SRC|STEM — single catalog authority (G.7; Makefile must not re-list).
CATALOG='
build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o|src/asm/user_asm_seed_bridge.o|bootstrap_seed_user_asm_seed_bridge
build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o|src/asm/asm_backend_compat_stubs.o|bootstrap_seed_asm_backend_compat_stubs
build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o|src/asm/backend_x86_64_enc_c.o|bootstrap_seed_backend_x86_64_enc_c
'

usage() {
  echo "usage: $TAG ensure OUT.o | --check | list | SRC.o OUT.o STEM [PARTIAL]" >&2
  exit 2
}

catalog_lookup() {
  # $1 = OUT → sets SRC_O STEM
  local out="$1" line rest
  SRC_O=""
  STEM=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    if [ "${line%%|*}" = "$out" ]; then
      rest="${line#*|}"
      SRC_O="${rest%%|*}"
      STEM="${rest#*|}"
      return 0
    fi
  done <<EOF
$CATALOG
EOF
  return 1
}

catalog_count() {
  local n=0 line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    n=$((n + 1))
  done <<EOF
$CATALOG
EOF
  echo "$n"
}

need_rebuild() {
  # $1=SRC $2=OUT $3=PARTIAL
  local src="$1" out="$2" partial="$3"
  if [ -n "${XLANG_FILTER_FORCE:-}" ]; then
    return 0
  fi
  if [ ! -f "$out" ]; then
    return 0
  fi
  if [ -f "$src" ] && [ "$src" -nt "$out" ]; then
    return 0
  fi
  if [ -f "$partial" ] && [ "$partial" -nt "$out" ]; then
    return 0
  fi
  return 1
}

run_filter() {
  local src="$1" out="$2" stem="$3" partial="$4"
  if [ ! -f "$src" ]; then
    echo "$TAG: missing SRC $src (build heat leaf first)" >&2
    exit 1
  fi
  # PLATFORM: SHARED — bash required (arrays); Ubuntu dash rejects OMITS=().
  exec bash scripts/filter_o_export_against_deps.sh \
    --src "$src" \
    --out "$out" \
    --stem "$stem" \
    --omit "$partial"
}

ensure_src_via_try_heat() {
  local src="$1"
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    # PLATFORM: SHARED — try-heat builds catalog heat leaves; exit 3 = not owned.
    # wave863: pass CC only so unset CFLAGS triggers export-try-heat-cflags load.
    if ! CC="${CC:-}" \
      bash scripts/ensure_host_cc_seed_o.sh try-heat "$src" 2>/dev/null; then
      _rc=$?
      if [ "$_rc" -eq 3 ]; then
        : # not ensure-owned; require prebuilt SRC
      elif [ ! -f "$src" ]; then
        echo "$TAG: try-heat failed for $src (rc=$_rc)" >&2
        exit 1
      fi
    fi
  fi
  if [ ! -f "$src" ]; then
    echo "$TAG: missing SRC $src after try-heat" >&2
    exit 1
  fi
}

do_ensure() {
  local out="$1"
  local src stem partial
  if ! catalog_lookup "$out"; then
    echo "$TAG: ensure: not in partial-filter catalog: $out" >&2
    exit 3
  fi
  src="$SRC_O"
  stem="$STEM"
  partial="${PARTIAL_DEFAULT}"
  # Cheap path: SRC present and OUT fresh → no try-heat (FORCE recipes).
  if [ -f "$src" ] && [ -f "$partial" ] && ! need_rebuild "$src" "$out" "$partial"; then
    echo "$TAG: skip up-to-date $out"
    exit 0
  fi
  # Only heat when SRC missing (parallel make / cold). Do not re-heat on
  # XLANG_FILTER_FORCE when SRC already present (would hang L2 on large leaves).
  if [ ! -f "$src" ]; then
    ensure_src_via_try_heat "$src"
  fi
  if [ ! -f "$src" ]; then
    echo "$TAG: missing SRC $src" >&2
    exit 1
  fi
  if [ ! -f "$partial" ]; then
    echo "$TAG: missing partial $partial (make build-seed-asm-host / seed pin)" >&2
    exit 1
  fi
  if ! need_rebuild "$src" "$out" "$partial"; then
    echo "$TAG: skip up-to-date $out"
    exit 0
  fi
  bash scripts/filter_o_export_against_deps.sh \
    --src "$src" \
    --out "$out" \
    --stem "$stem" \
    --omit "$partial"
}

do_check() {
  local n bad=0 line out src stem
  n="$(catalog_count)"
  if [ "$n" != "3" ]; then
    echo "$TAG --check: catalog COUNT must be 3 (got $n)" >&2
    exit 1
  fi
  if ! grep -q 'need_rebuild\|XLANG_FILTER_FORCE' "$_self"; then
    echo "$TAG --check: must own need_rebuild / FILTER_FORCE mtime policy (wave835)" >&2
    exit 1
  fi
  if ! grep -q 'try-heat' "$_self"; then
    echo "$TAG --check: must try-heat SRC before filter (wave835 parallel-safe)" >&2
    exit 1
  fi
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    out="${line%%|*}"
    rest="${line#*|}"
    src="${rest%%|*}"
    stem="${rest#*|}"
    if [ -z "$out" ] || [ -z "$src" ] || [ -z "$stem" ]; then
      echo "$TAG --check: bad catalog line: $line" >&2
      bad=1
    fi
  done <<EOF
$CATALOG
EOF
  if [ "$bad" -ne 0 ]; then
    exit 1
  fi
  echo "$TAG --check OK (COUNT=$n wave835/921 FORCE thin multi-target; not physical delete)"
}

do_list() {
  local line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    echo "$line"
  done <<EOF
$CATALOG
EOF
}

if [ "$#" -lt 1 ]; then
  usage
fi

case "$1" in
  ensure)
    [ "$#" -eq 2 ] || usage
    do_ensure "$2"
    ;;
  --check)
    do_check
    ;;
  list)
    do_list
    ;;
  -h|--help)
    usage
    ;;
  *)
    if [ "$#" -lt 3 ]; then
      usage
    fi
    SRC_O="$1"
    OUT_O="$2"
    STEM="$3"
    PARTIAL="${4:-$PARTIAL_DEFAULT}"
    if ! need_rebuild "$SRC_O" "$OUT_O" "$PARTIAL"; then
      echo "$TAG: skip up-to-date $OUT_O"
      exit 0
    fi
    run_filter "$SRC_O" "$OUT_O" "$STEM" "$PARTIAL"
    ;;
esac

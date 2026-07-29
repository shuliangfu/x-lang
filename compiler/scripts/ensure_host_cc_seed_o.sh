#!/usr/bin/env bash
# ensure_host_cc_seed_o.sh — R1 host-cc seed/from_x → .o single body
#   wave748: first family RT_SEED_SLICE
#   wave749: second family R1_CORE_SEED (diag / link_abi / c_import / bridge / seed_link_compat)
#
# Authority (G.7):
#   Single shell *recipe body* for pure host-cc compile of seeds/*.from_x.c → .o.
#   Object *lists* stay in Makefile / mk (catalog export keys).
#   This script never hardcodes a second product .o inventory as authority.
#   Seed path convention for pure R1 families (basename match):
#     <dir>/<leaf>.o  ←  seeds/<leaf>.from_x.c
#
# Families (list authority = catalog KEY):
#   RT_SEED_SLICE_OBJS  — five Cap residual slices under src/runtime/
#   R1_CORE_SEED_OBJS   — diag + runtime_link_abi + runtime_c_import +
#                         x_seed_bridge + seed_link_compat
#
# Not in scope (honest residual):
#   - R3 thin+rest / PREFER_X_O product g05 path (g05_ensure keeps that)
#   - Other R1 leaves (lexer/ast glue basename mismatch, extra cflags, …)
#   - R2 UNAME stamps, R4 rebuild pattern multi-family, R5 CI all
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_host_cc_seed_o.sh one <out.o> <seed.from_x.c> [extra cflags...]
#   bash scripts/ensure_host_cc_seed_o.sh rt-slice          # RT_SEED_SLICE family
#   bash scripts/ensure_host_cc_seed_o.sh core-seed         # R1_CORE_SEED family
#   bash scripts/ensure_host_cc_seed_o.sh all               # both swallowed families
#   bash scripts/ensure_host_cc_seed_o.sh --check
#   bash scripts/ensure_host_cc_seed_o.sh rt-slice --force
#   ./xbuild host-cc-seed | rt-seed-slice | core-seed [--check|--force]
#
# Env:
#   CC — host compiler (default: cc; honor caller CC)
#   CFLAGS — base flags (default: -Wall -Wextra -I. -Iinclude -Isrc)
#   PIPELINE_GEN_CFLAGS — optional silence flags (Makefile exports when thin)
#   XLANG_HOST_CC_SEED_FORCE=1 — force recompile (same as --force)
#   MAKE — only for catalog list expansion (default: make)
#
# PLATFORM: SHARED — shell orchestration; seed pins host-portable C.
# Wave: 748–749 Track MG · 11.3.1 R1 families (not physical delete · not pure-ld).

set -euo pipefail
cd "$(dirname "$0")/.."

CC="${CC:-cc}"
# Match g05 / Makefile product includes; PIPELINE_GEN_CFLAGS optional (Makefile thin).
BASE_CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
PIPELINE_GEN_CFLAGS="${PIPELINE_GEN_CFLAGS:-}"
MAKE="${MAKE:-make}"
FORCE="${XLANG_HOST_CC_SEED_FORCE:-0}"

MODE="${1:-}"
if [ -z "$MODE" ]; then
  echo "ensure_host_cc_seed_o: usage: one|rt-slice|core-seed|all|--check  (see header)" >&2
  exit 2
fi
shift || true

# Parse trailing --force on any mode
for arg in "$@"; do
  case "$arg" in
    --force|-f|force) FORCE=1 ;;
  esac
done

log() { echo "ensure-host-cc-seed: $*" >&2; }

# ---------------------------------------------------------------------------
# one OUT SEED [extra cflags...]
# PLATFORM: SHARED — pure host-cc body; no make graph.
# ---------------------------------------------------------------------------
ensure_one() {
  local out="$1"
  local seed="$2"
  shift 2
  # Drop --force tokens if present as extra args
  local extras=()
  local a
  for a in "$@"; do
    case "$a" in
      --force|-f|force) continue ;;
      *) extras+=("$a") ;;
    esac
  done

  if [ -z "$out" ] || [ -z "$seed" ]; then
    echo "ensure_host_cc_seed_o one: need <out.o> <seed.from_x.c>" >&2
    exit 2
  fi
  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o: missing seed $seed" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$out")"

  if [ "$FORCE" != "1" ] && [ -f "$out" ] && [ ! "$seed" -nt "$out" ]; then
    # Sibling .x (Makefile dep): same path with .x suffix; rebuild if newer.
    local xsrc="${out%.o}.x"
    if [ -f "$xsrc" ] && [ "$xsrc" -nt "$out" ]; then
      :
    else
      log "skip $out (up-to-date vs $seed)"
      return 0
    fi
  fi

  log "cc -c $seed → $out"
  # shellcheck disable=SC2086
  $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS "${extras[@]+"${extras[@]}"}" -c -o "$out" "$seed"
}

# ---------------------------------------------------------------------------
# Catalog list expansion (G.7: KEY only; no hardcoded .o inventory in shell)
# ---------------------------------------------------------------------------
catalog_key_list() {
  # $1 = catalog KEY name (e.g. RT_SEED_SLICE_OBJS)
  local key="$1"
  if [ -z "$key" ]; then
    echo "ensure_host_cc_seed_o: catalog_key_list needs KEY" >&2
    exit 2
  fi
  if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
    echo "ensure_host_cc_seed_o: missing scripts/driver_seed_obj_catalog.sh" >&2
    exit 1
  fi
  local catalog_out key_line
  catalog_out="$(MAKE="$MAKE" bash scripts/driver_seed_obj_catalog.sh)"
  key_line="$(printf '%s\n' "$catalog_out" | sed -n "s/^${key}=//p" | head -1)"
  if [ -z "${key_line// /}" ]; then
    echo "ensure_host_cc_seed_o: empty $key from catalog (export missing?)" >&2
    exit 1
  fi
  printf '%s\n' "$key_line"
}

# seed convention: basename of .o → seeds/<basename>.from_x.c
seed_for_o() {
  local o="$1"
  local base
  base="$(basename "$o" .o)"
  printf 'seeds/%s.from_x.c\n' "$base"
}

# Ensure every .o in catalog KEY via pure host-cc body.
ensure_catalog_family() {
  # $1 = KEY  $2 = human family label (for log)
  local key="$1"
  local label="$2"
  local list n=0 o seed
  list="$(catalog_key_list "$key")"
  # Word-split intentionally (space-separated make expansion).
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    seed="$(seed_for_o "$o")"
    ensure_one "$o" "$seed"
    n=$((n + 1))
  done
  log "$label OK ($n objs via catalog $key)"
}

ensure_rt_slice() {
  ensure_catalog_family "RT_SEED_SLICE_OBJS" "rt-slice"
}

ensure_core_seed() {
  ensure_catalog_family "R1_CORE_SEED_OBJS" "core-seed"
}

ensure_all_swallowed() {
  ensure_rt_slice
  ensure_core_seed
  log "all swallowed R1 families OK (rt-slice + core-seed)"
}

# ---------------------------------------------------------------------------
# --check: wiring + catalog keys + convention (no full compile required)
# ---------------------------------------------------------------------------
check_family() {
  # $1=KEY $2=min_count $3=label $4=optional path prefix pattern (e.g. src/)
  local key="$1"
  local min_n="$2"
  local label="$3"
  local path_pfx="${4:-}"
  local list n=0 o seed
  if ! list="$(catalog_key_list "$key" 2>/dev/null)"; then
    bad "catalog cannot expand $key (add export key)"
    return
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    n=$((n + 1))
    seed="$(seed_for_o "$o")"
    if [ ! -f "$seed" ]; then
      bad "missing seed for $o → $seed ($label)"
    fi
    if [ -n "$path_pfx" ]; then
      case "$o" in
        ${path_pfx}*) ;;
        *) bad "$label .o not under $path_pfx: $o" ;;
      esac
    fi
  done
  if [ "$n" -lt "$min_n" ]; then
    bad "$key count $n < $min_n ($label)"
  else
    note "catalog $key n=$n ($label)"
  fi
}

run_check() {
  local fail=0
  note() { echo "ensure_host_cc_seed_o: $*" >&2; }
  bad() { echo "ensure_host_cc_seed_o: FAIL: $*" >&2; fail=1; }

  if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
    bad "missing driver_seed_obj_catalog.sh"
  fi
  if [ ! -f Makefile ]; then
    bad "missing Makefile (cwd must be compiler/)"
  fi
  if ! grep -q 'RT_SEED_SLICE_OBJS' Makefile \
    && ! grep -q 'RT_SEED_SLICE_OBJS' mk/*.mk 2>/dev/null; then
    bad "RT_SEED_SLICE_OBJS not defined in Makefile/mk"
  fi
  if ! grep -q 'R1_CORE_SEED_OBJS' Makefile \
    && ! grep -q 'R1_CORE_SEED_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_CORE_SEED_OBJS not defined in Makefile/mk (wave749)"
  fi

  check_family "RT_SEED_SLICE_OBJS" 5 "rt-slice" "src/runtime/"
  check_family "R1_CORE_SEED_OBJS" 5 "core-seed" "src/"

  # Makefile thin: recipes must call this script (not inline $(CC) -c for swallowed leaves)
  if ! grep -q 'ensure_host_cc_seed_o\.sh' Makefile; then
    bad "Makefile must thin-call ensure_host_cc_seed_o.sh for R1 families"
  else
    note "Makefile thin-call present"
  fi
  # Core-seed leaves must not keep inline $(CC) -c recipes (thin only).
  if grep -nE 'src/diag\.o:|src/runtime_link_abi\.o:|src/runtime_c_import\.o:|src/x_seed_bridge\.o:|src/seed_link_compat\.o:' Makefile \
    | head -1 >/dev/null; then
    # Check recipe lines under those targets still don't use bare $(CC) -c for seeds
    if grep -A1 -E '^(src/diag\.o|src/runtime_link_abi\.o|src/runtime_c_import\.o|src/x_seed_bridge\.o|src/seed_link_compat\.o):' Makefile \
      | grep -qE '\$\(CC\).*-c seeds/'; then
      bad "Makefile core-seed leaves still have inline \$(CC) -c (must thin-call ensure)"
    else
      note "Makefile core-seed leaves thin (no inline \$(CC) -c)"
    fi
  fi

  # G.7: list authority is catalog only — no hardcoded assignment of product lists.
  if grep -nE '^(export )?RT_SEED_SLICE_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode RT_SEED_SLICE_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_CORE_SEED_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_CORE_SEED_OBJS= in shell body"
  fi

  if [ "$fail" -ne 0 ]; then
    echo "ensure_host_cc_seed_o: --check FAILED" >&2
    exit 1
  fi
  echo "ensure_host_cc_seed_o: CHECK OK (R1 rt-seed-slice + core-seed · wave748–749)" >&2
}

case "$MODE" in
  one)
    if [ "$#" -lt 2 ]; then
      echo "ensure_host_cc_seed_o one: need <out.o> <seed.from_x.c> [extra...]" >&2
      exit 2
    fi
    ensure_one "$@"
    ;;
  rt-slice|rt_slice|rt-seed-slice|family=rt_seed_slice)
    ensure_rt_slice
    ;;
  core-seed|core_seed|core|r1-core|r1-core-seed|family=r1_core_seed)
    ensure_core_seed
    ;;
  all|family|families|swallowed)
    # Umbrella: all swallowed pure R1 families on this body.
    ensure_all_swallowed
    ;;
  --check|check|-c)
    run_check
    ;;
  help|-h|--help)
    sed -n '2,50p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "ensure_host_cc_seed_o: unknown mode '$MODE' (one|rt-slice|core-seed|all|--check)" >&2
    exit 2
    ;;
esac

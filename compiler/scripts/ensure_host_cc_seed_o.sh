#!/usr/bin/env bash
# ensure_host_cc_seed_o.sh — R1 host-cc seed/from_x → .o single body (wave748)
#
# Authority (G.7):
#   Single shell *recipe body* for pure host-cc compile of seeds/*.from_x.c → .o
#   for the first residual family: RT_SEED_SLICE (rt_arena_buf / rt_emit_state /
#   rt_preamble / rt_stack / rt_parse_diag).
#   Object *lists* stay in Makefile / mk (RT_SEED_SLICE_OBJS via catalog export).
#   This script never hardcodes a second product .o inventory as authority.
#   Seed path convention for this family:
#     src/runtime/<leaf>.o  ←  seeds/<leaf>.from_x.c
#
# Not in scope (honest residual):
#   - R3 thin+rest / PREFER_X_O product g05 path (g05_ensure keeps that)
#   - Other R1 leaves (diag, bridge, link_abi, …) until named follow-up families
#   - R2 UNAME stamps, R4 rebuild pattern multi-family, R5 CI all
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_host_cc_seed_o.sh one <out.o> <seed.from_x.c> [extra cflags...]
#   bash scripts/ensure_host_cc_seed_o.sh rt-slice          # family ensure
#   bash scripts/ensure_host_cc_seed_o.sh rt-slice --force  # ignore mtime
#   bash scripts/ensure_host_cc_seed_o.sh --check
#   ./xbuild host-cc-seed | rt-seed-slice [--check|--force]
#
# Env:
#   CC — host compiler (default: cc; honor caller CC)
#   CFLAGS — base flags (default: -Wall -Wextra -I. -Iinclude -Isrc)
#   PIPELINE_GEN_CFLAGS — optional silence flags (Makefile exports when thin)
#   XLANG_HOST_CC_SEED_FORCE=1 — force recompile (same as --force)
#   MAKE — only for catalog list expansion (default: make)
#
# PLATFORM: SHARED — shell orchestration; seed pins host-portable C.
# Wave: 748 Track MG · 11.3.1 R1 first family (not physical delete · not pure-ld).

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
  echo "ensure_host_cc_seed_o: usage: one|rt-slice|--check  (see header)" >&2
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
    # Optional sibling .x (Makefile dep): if newer, rebuild.
    local xsrc=""
    case "$out" in
      src/runtime/*.o)
        xsrc="src/runtime/$(basename "$out" .o).x"
        ;;
    esac
    if [ -n "$xsrc" ] && [ -f "$xsrc" ] && [ "$xsrc" -nt "$out" ]; then
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
# rt-slice family: list authority = catalog RT_SEED_SLICE_OBJS (Makefile/mk)
# seed convention: basename of .o → seeds/<basename>.from_x.c
# ---------------------------------------------------------------------------
catalog_rt_slice_list() {
  if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
    echo "ensure_host_cc_seed_o: missing scripts/driver_seed_obj_catalog.sh" >&2
    exit 1
  fi
  local catalog_out key_line
  catalog_out="$(MAKE="$MAKE" bash scripts/driver_seed_obj_catalog.sh)"
  key_line="$(printf '%s\n' "$catalog_out" | sed -n 's/^RT_SEED_SLICE_OBJS=//p' | head -1)"
  if [ -z "${key_line// /}" ]; then
    echo "ensure_host_cc_seed_o: empty RT_SEED_SLICE_OBJS from catalog (export missing?)" >&2
    exit 1
  fi
  printf '%s\n' "$key_line"
}

seed_for_rt_o() {
  # $1 = e.g. src/runtime/rt_arena_buf.o → seeds/rt_arena_buf.from_x.c
  local o="$1"
  local base
  base="$(basename "$o" .o)"
  printf 'seeds/%s.from_x.c\n' "$base"
}

ensure_rt_slice() {
  local list n=0 o seed
  list="$(catalog_rt_slice_list)"
  # Word-split intentionally (space-separated make expansion).
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    seed="$(seed_for_rt_o "$o")"
    ensure_one "$o" "$seed"
    n=$((n + 1))
  done
  log "rt-slice OK ($n objs via catalog RT_SEED_SLICE_OBJS)"
}

# ---------------------------------------------------------------------------
# --check: wiring + catalog key + convention (no full compile required)
# ---------------------------------------------------------------------------
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

  local list
  if ! list="$(catalog_rt_slice_list 2>/dev/null)"; then
    bad "catalog cannot expand RT_SEED_SLICE_OBJS (add export key)"
    list=""
  fi
  local n=0 o seed
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    n=$((n + 1))
    seed="$(seed_for_rt_o "$o")"
    if [ ! -f "$seed" ]; then
      bad "missing seed for $o → $seed"
    fi
    case "$o" in
      src/runtime/*.o) ;;
      *) bad "rt-slice .o not under src/runtime/: $o" ;;
    esac
  done
  if [ "$n" -lt 5 ]; then
    bad "RT_SEED_SLICE_OBJS count $n < 5 (expected 5 Cap residual slices)"
  else
    note "catalog RT_SEED_SLICE_OBJS n=$n"
  fi

  # Makefile thin: recipes must call this script (not inline $(CC) -c for these leaves)
  if ! grep -q 'ensure_host_cc_seed_o\.sh' Makefile; then
    bad "Makefile must thin-call ensure_host_cc_seed_o.sh for R1 rt-slice"
  else
    note "Makefile thin-call present"
  fi

  # G.7: list authority is catalog only — body uses basename convention, no
  # hardcoded five-path table. External gate also greps for assignment lines.

  if [ "$fail" -ne 0 ]; then
    echo "ensure_host_cc_seed_o: --check FAILED" >&2
    exit 1
  fi
  echo "ensure_host_cc_seed_o: CHECK OK (R1 rt-seed-slice family · wave748)" >&2
}

case "$MODE" in
  one)
    if [ "$#" -lt 2 ]; then
      echo "ensure_host_cc_seed_o one: need <out.o> <seed.from_x.c> [extra...]" >&2
      exit 2
    fi
    ensure_one "$@"
    ;;
  rt-slice|rt_slice|rt-seed-slice|family|family=rt_seed_slice)
    # Drop mode-level --force already handled via FORCE
    ensure_rt_slice
    ;;
  --check|check|-c)
    run_check
    ;;
  help|-h|--help)
    sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "ensure_host_cc_seed_o: unknown mode '$MODE' (one|rt-slice|--check)" >&2
    exit 2
    ;;
esac

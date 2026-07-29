#!/usr/bin/env bash
# ensure_gen_x_o.sh — body of residual gen *_x.o + pipeline_x.o compile (11.3.1 · wave761)
#
# Authority (G.7 有则补全):
#   Single host-cc body for product leaves that compile pinned/generated *_gen.c:
#     lsp_io_x.o   ← lsp_io_gen.c   (+ lsp_io -D renames)
#     lsp_x.o      ← lsp_gen.c
#     lsp_diag_x.o ← lsp_diag_gen.c
#     pipeline_x.o ← pipeline_gen.c (+ gen_driver cache / FORCE / PIPELINE_X_DEPS)
#   Membership for rebuild_leaves is catalog-owned:
#     DRIVER_SEED_LSP_X_OBJS · DRIVER_SEED_PIPELINE_X_OBJS
#   (pure-R1 members of LSP list still go try-r1; only these gen maps use this body).
#
#   *_gen.c production remains ensure_lsp_pipeline_gen.sh (wave739) — this script
#   may call it when gen is missing; it does not own -E regen policy.
#
#   migrate_x_objs.sh stays the authority for parser/typeck/codegen migrate leaves
#   (wave735); do not fork a second migrate path here.
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_gen_x_o.sh one <out.o>
#   bash scripts/ensure_gen_x_o.sh lsp-io|lsp|lsp-diag|pipeline
#   bash scripts/ensure_gen_x_o.sh lsp-all     # three LSP gen objs
#   bash scripts/ensure_gen_x_o.sh residual-all  # lsp trio + pipeline_x
#
# Env:
#   CC / CFLAGS / PIPELINE_GEN_CFLAGS — host compile (match Makefile)
#   XLANG_GEN_X_FORCE=1 | XLANG_HOST_CC_SEED_FORCE=1 — always recompile
#   PIPELINE_X_FORCE_COMPILE=1 | XLANG_FORCE_REGEN_GEN=1 — force pipeline STALE
#   PIPELINE_X_DEPS — space-separated dep paths for pipeline STALE (Makefile
#     thin leaf expands; rebuild_leaves may leave empty → STALE uses gen only)
#   MAKE — for ensure_lsp_pipeline_gen when gen missing
#
# PLATFORM: SHARED shell body; pipeline gen_driver cache is host-portable.
# Wave: 761 Track MG · 11.3.1 path (not physical delete · not pure-ld).

set -euo pipefail
cd "$(dirname "$0")/.."

CC="${CC:-cc}"
CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
MAKE="${MAKE:-make}"
FORCE="${XLANG_GEN_X_FORCE:-${XLANG_HOST_CC_SEED_FORCE:-0}}"
PIPELINE_X_FORCE_COMPILE="${PIPELINE_X_FORCE_COMPILE:-0}"
XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}"

# Match Makefile PIPELINE_GEN_CFLAGS when caller did not export it.
if [ -z "${PIPELINE_GEN_CFLAGS:-}" ]; then
  PIPELINE_GEN_CFLAGS_BASE="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
  PIPELINE_GEN_CFLAGS_CLANG="-Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers -Wno-parentheses-equality"
  PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS_BASE"
  if "$CC" -v 2>&1 | grep -qi clang; then
    PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS_BASE $PIPELINE_GEN_CFLAGS_CLANG"
  fi
fi

log() { echo "ensure-gen-x-o: $*" >&2; }

need_rebuild_gen_o() {
  # $1=out.o $2=gen.c — rebuild if force, missing o, or gen newer than o
  local o="$1" g="$2"
  if [ "$FORCE" = "1" ]; then
    return 0
  fi
  if [ ! -f "$o" ]; then
    return 0
  fi
  if [ -n "$g" ] && [ -f "$g" ] && [ "$g" -nt "$o" ]; then
    return 0
  fi
  return 1
}

ensure_gen_file() {
  # $1 = lsp_io|lsp_gen|lsp_diag|pipeline — ensure missing gen via wave739 shell
  local mode="$1"
  local gen=""
  case "$mode" in
    lsp_io) gen=lsp_io_gen.c ;;
    lsp_gen|lsp) gen=lsp_gen.c; mode=lsp_gen ;;
    lsp_diag) gen=lsp_diag_gen.c ;;
    pipeline) gen=pipeline_gen.c ;;
    *)
      log "ensure_gen_file: unknown mode $mode"
      return 1
      ;;
  esac
  if [ -s "$gen" ]; then
    return 0
  fi
  if [ ! -f scripts/ensure_lsp_pipeline_gen.sh ]; then
    log "missing $gen and scripts/ensure_lsp_pipeline_gen.sh"
    return 1
  fi
  log "missing $gen → ensure_lsp_pipeline_gen $mode"
  MAKE="$MAKE" XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}" \
    sh scripts/ensure_lsp_pipeline_gen.sh "$mode"
}

build_lsp_io_x() {
  ensure_gen_file lsp_io
  if ! need_rebuild_gen_o lsp_io_x.o lsp_io_gen.c; then
    log "skip lsp_io_x.o (up-to-date vs lsp_io_gen.c)"
    return 0
  fi
  log "cc -c lsp_io_gen.c → lsp_io_x.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. \
    -Dstd_io_read=io_read -Dstd_io_write=io_write \
    -Dstd_heap_alloc_usize=typeck_std_heap_alloc -Dstd_heap_free_u8_ptr=typeck_std_heap_free \
    -Dtypeck_std_heap_alloc=lsp_io_std_heap_std_heap_alloc \
    -Dtypeck_std_heap_free=lsp_io_std_heap_std_heap_free \
    -c lsp_io_gen.c -o lsp_io_x.o
}

build_lsp_x() {
  ensure_gen_file lsp_gen
  if ! need_rebuild_gen_o lsp_x.o lsp_gen.c; then
    log "skip lsp_x.o (up-to-date vs lsp_gen.c)"
    return 0
  fi
  log "cc -c lsp_gen.c → lsp_x.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -c lsp_gen.c -o lsp_x.o
}

build_lsp_diag_x() {
  ensure_gen_file lsp_diag
  if ! need_rebuild_gen_o lsp_diag_x.o lsp_diag_gen.c; then
    log "skip lsp_diag_x.o (up-to-date vs lsp_diag_gen.c)"
    return 0
  fi
  log "cc -c lsp_diag_gen.c → lsp_diag_x.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c lsp_diag_gen.c -o lsp_diag_x.o
}

build_pipeline_x() {
  # Makefile parity: token enum sync + gen_driver cache + FORCE/STALE deps.
  # PIPELINE_X_DEPS comes from Makefile thin leaf or rebuild_leaves env (list
  # authority stays mk; empty → STALE only from gen + force flags).
  ensure_gen_file pipeline
  if [ -f scripts/sync_lexer_gen_token_enum.pl ]; then
    perl scripts/sync_lexer_gen_token_enum.pl pipeline_gen.c
  fi
  local gen_drv="build_asm/gen_driver/pipeline_x.o"
  local stale=0 dep
  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ] || [ "$PIPELINE_X_FORCE_COMPILE" = "1" ] \
    || [ "$FORCE" = "1" ]; then
    stale=1
  fi
  if [ -f "$gen_drv" ]; then
    if [ pipeline_gen.c -nt "$gen_drv" ]; then
      stale=1
    fi
    # shellcheck disable=SC2086
    for dep in ${PIPELINE_X_DEPS:-}; do
      [ -z "$dep" ] && continue
      if [ -e "$dep" ] && [ "$dep" -nt "$gen_drv" ]; then
        stale=1
        break
      fi
    done
  else
    stale=1
  fi
  if [ "$stale" -eq 0 ] && [ -f "$gen_drv" ]; then
    cp "$gen_drv" pipeline_x.o
    log "pipeline_x.o: from build_asm/gen_driver"
    return 0
  fi
  log "cc -c pipeline_gen.c → pipeline_x.o (STALE=$stale)"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS \
    -DXLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS -I.. \
    -Dstd_io_driver_driver_read_ptr_len=xlang_io_read_ptr_len \
    -Dstd_io_driver_driver_read_ptr=xlang_io_read_ptr \
    -c pipeline_gen.c -o pipeline_x.o
  mkdir -p build_asm/gen_driver
  cp pipeline_x.o "$gen_drv"
}

ensure_one_out() {
  local o="$1"
  case "$o" in
    lsp_io_x.o) build_lsp_io_x ;;
    lsp_x.o) build_lsp_x ;;
    lsp_diag_x.o) build_lsp_diag_x ;;
    pipeline_x.o) build_pipeline_x ;;
    *)
      log "no gen map for $o (only lsp_io_x|lsp_x|lsp_diag_x|pipeline_x)"
      return 3
      ;;
  esac
}

MODE="${1:-}"
case "$MODE" in
  one|try-one)
    if [ "$#" -lt 2 ]; then
      echo "ensure_gen_x_o: usage: one <out.o>" >&2
      exit 2
    fi
    ensure_one_out "$2"
    ;;
  lsp-io|lsp_io|lsp_io_x.o)
    build_lsp_io_x
    ;;
  lsp|lsp_x|lsp_x.o|lsp_gen)
    build_lsp_x
    ;;
  lsp-diag|lsp_diag|lsp_diag_x.o)
    build_lsp_diag_x
    ;;
  pipeline|pipeline_x|pipeline_x.o)
    build_pipeline_x
    ;;
  lsp-all|lsp_all)
    build_lsp_io_x
    build_lsp_x
    build_lsp_diag_x
    log "lsp-all OK (lsp_io_x lsp_x lsp_diag_x)"
    ;;
  residual-all|all|gen-residual)
    build_lsp_io_x
    build_lsp_x
    build_lsp_diag_x
    build_pipeline_x
    log "residual-all OK (lsp trio + pipeline_x)"
    ;;
  help|-h|--help)
    sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "ensure_gen_x_o: unknown mode '$MODE' (one|lsp-io|lsp|lsp-diag|pipeline|lsp-all|residual-all)" >&2
    exit 2
    ;;
esac

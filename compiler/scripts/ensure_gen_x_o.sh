#!/usr/bin/env bash
# ensure_gen_x_o.sh — body of residual gen *.c → .o compile (11.3.1 · wave761 + wave782)
#
# Authority (G.7 有则补全):
#   Single host-cc body for product leaves that compile pinned/generated C:
#     wave761 (try-gen-x catalog):
#       lsp_io_x.o   ← lsp_io_gen.c   (+ lsp_io -D renames)
#       lsp_x.o      ← lsp_gen.c
#       lsp_diag_x.o ← lsp_diag_gen.c
#       pipeline_x.o ← pipeline_gen.c (+ gen_driver cache / FORCE / PIPELINE_X_DEPS)
#     wave782 (try-gen-c-to-o B4 bootstrap; NOT try-gen-x catalog):
#       lexer_x.o      ← lexer_gen.c (+ token enum sync)
#       ast_gen2.o     ← ast_gen2.c
#       driver_x.o     ← driver_gen.c (+ x_stubs + fs -D renames)
#       preprocess_x.o ← preprocess_gen.c
#       _x_stubs2.o    ← _x_stubs2.c (stage2 hybrid stubs)
#   Membership for rebuild_leaves try-gen-x is catalog-owned:
#     DRIVER_SEED_LSP_X_OBJS · DRIVER_SEED_PIPELINE_X_OBJS
#   B4 membership = try-gen-c-to-o table (ensure_host_cc_seed_o.sh); body here.
#
#   *_gen.c production remains ensure_lsp_pipeline_gen / ensure_driver_gen /
#   ensure_migrate_gen — this script may call lsp/pipeline gen when missing;
#   it does not own -E regen policy for B4 (Makefile keeps gen.c prereqs).
#
#   migrate_x_objs.sh stays the authority for parser/typeck/codegen migrate leaves
#   (wave735); do not fork a second migrate path here.
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_gen_x_o.sh one <out.o>
#   bash scripts/ensure_gen_x_o.sh lsp-io|lsp|lsp-diag|pipeline
#   bash scripts/ensure_gen_x_o.sh lexer-x|ast-gen2|driver-x|preprocess-x|x-stubs2
#   bash scripts/ensure_gen_x_o.sh lsp-all     # three LSP gen objs
#   bash scripts/ensure_gen_x_o.sh residual-all  # lsp trio + pipeline_x (not B4)
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
# Wave: 761 + 782 + 796 Track MG · 11.3.1 path (not physical delete · not pure-ld).
# wave796: Makefile gen leaves FORCE-thin; this script owns gen.c / DEPS / .x
# mtime skip (lsp_io.x included). PIPELINE_X_DEPS still exported by Makefile recipe.

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
  # wave796: historic Makefile prereq src/lsp/lsp_io.x (FORCE thin).
  if ! need_rebuild_gen_o_or_deps lsp_io_x.o lsp_io_gen.c src/lsp/lsp_io.x; then
    log "skip lsp_io_x.o (up-to-date vs lsp_io_gen.c + lsp_io.x)"
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

# ---------------------------------------------------------------------------
# wave782 B4: gen.c → .o bootstrap / stage stubs (outside try-gen-x catalog)
# Historic Makefile: pure host-cc -c on generated/pinned C (not PREFER hybrid).
# PLATFORM: SHARED shell · flags mirror Makefile leaf recipes.
# ---------------------------------------------------------------------------

need_rebuild_gen_o_or_deps() {
  # $1=out.o $2=gen.c $3...=optional extra deps (e.g. MAIN_X .x paths)
  local o="$1" g="$2"
  shift 2
  local dep
  if need_rebuild_gen_o "$o" "$g"; then
    return 0
  fi
  for dep in "$@"; do
    [ -z "$dep" ] && continue
    if [ -e "$dep" ] && [ "$dep" -nt "$o" ]; then
      return 0
    fi
  done
  return 1
}

build_lexer_x() {
  # Makefile: perl sync_lexer_gen_token_enum + PIPELINE_GEN_CFLAGS -I triad.
  if [ ! -f lexer_gen.c ]; then
    log "missing lexer_gen.c (run ensure_migrate_gen lexer / make lexer_gen.c first)"
    return 1
  fi
  if ! need_rebuild_gen_o lexer_x.o lexer_gen.c; then
    log "skip lexer_x.o (up-to-date vs lexer_gen.c)"
    return 0
  fi
  if [ -f scripts/sync_lexer_gen_token_enum.pl ]; then
    perl scripts/sync_lexer_gen_token_enum.pl lexer_gen.c
  fi
  log "cc -c lexer_gen.c → lexer_x.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c lexer_gen.c -o lexer_x.o
  log "lexer_x.o OK"
}

build_ast_gen2() {
  if [ ! -f ast_gen2.c ]; then
    log "missing ast_gen2.c"
    return 1
  fi
  if ! need_rebuild_gen_o ast_gen2.o ast_gen2.c; then
    log "skip ast_gen2.o (up-to-date vs ast_gen2.c)"
    return 0
  fi
  log "cc -c ast_gen2.c → ast_gen2.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c ast_gen2.c -o ast_gen2.o
}

build_driver_x() {
  # Makefile: -include x_stubs.h + fs_* → fs_posix_* renames (MAIN_X_DEPS stale).
  if [ ! -f driver_gen.c ]; then
    log "missing driver_gen.c (run ensure_driver_gen driver / make driver_gen.c first)"
    return 1
  fi
  if ! need_rebuild_gen_o_or_deps driver_x.o driver_gen.c \
    src/main.x src/codegen/codegen.x src/ast/ast.x src/preprocess/preprocess.x; then
    log "skip driver_x.o (up-to-date vs driver_gen.c + MAIN_X_DEPS)"
    return 0
  fi
  log "cc -c driver_gen.c → driver_x.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS \
    -include src/x_stubs.h \
    -Dstd_fs_fs_read=fs_posix_read_c \
    -Dstd_fs_fs_write=fs_posix_write_c \
    -Dstd_fs_fs_close=fs_posix_close_c \
    -Dfs_read=fs_posix_read_c \
    -Dfs_write=fs_posix_write_c \
    -Dfs_close=fs_posix_close_c \
    -c driver_gen.c -o driver_x.o
}

build_preprocess_x() {
  # Makefile: plain CFLAGS -c (no PIPELINE_GEN_CFLAGS on this leaf).
  if [ ! -f preprocess_gen.c ]; then
    log "missing preprocess_gen.c (run ensure_driver_gen preprocess first)"
    return 1
  fi
  if ! need_rebuild_gen_o_or_deps preprocess_x.o preprocess_gen.c \
    src/preprocess/preprocess.x; then
    log "skip preprocess_x.o (up-to-date vs preprocess_gen.c + PREPROCESS_X_DEPS)"
    return 0
  fi
  log "cc -c preprocess_gen.c → preprocess_x.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS -c preprocess_gen.c -o preprocess_x.o
}

build_x_stubs2() {
  # Stage2 hybrid link stubs (verify-selfhost-stage2); plain host-cc.
  if [ ! -f _x_stubs2.c ]; then
    log "missing _x_stubs2.c"
    return 1
  fi
  if ! need_rebuild_gen_o _x_stubs2.o _x_stubs2.c; then
    log "skip _x_stubs2.o (up-to-date vs _x_stubs2.c)"
    return 0
  fi
  log "cc -c _x_stubs2.c → _x_stubs2.o"
  # shellcheck disable=SC2086
  $CC $CFLAGS -c _x_stubs2.c -o _x_stubs2.o
}

ensure_one_out() {
  local o="$1"
  case "$o" in
    lsp_io_x.o) build_lsp_io_x ;;
    lsp_x.o) build_lsp_x ;;
    lsp_diag_x.o) build_lsp_diag_x ;;
    pipeline_x.o) build_pipeline_x ;;
    lexer_x.o) build_lexer_x ;;
    ast_gen2.o) build_ast_gen2 ;;
    driver_x.o) build_driver_x ;;
    preprocess_x.o) build_preprocess_x ;;
    _x_stubs2.o) build_x_stubs2 ;;
    *)
      log "no gen map for $o (lsp_io_x|lsp_x|lsp_diag_x|pipeline_x|lexer_x|ast_gen2|driver_x|preprocess_x|_x_stubs2)"
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
  lexer-x|lexer_x|lexer_x.o)
    build_lexer_x
    ;;
  ast-gen2|ast_gen2|ast_gen2.o)
    build_ast_gen2
    ;;
  driver-x|driver_x|driver_x.o)
    build_driver_x
    ;;
  preprocess-x|preprocess_x|preprocess_x.o)
    build_preprocess_x
    ;;
  x-stubs2|_x_stubs2|_x_stubs2.o|stubs2)
    build_x_stubs2
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
    sed -n '2,50p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "ensure_gen_x_o: unknown mode '$MODE' (one|lsp-io|lsp|lsp-diag|pipeline|lexer-x|ast-gen2|driver-x|preprocess-x|x-stubs2|lsp-all|residual-all)" >&2
    exit 2
    ;;
esac

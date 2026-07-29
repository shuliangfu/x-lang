#!/usr/bin/env bash
# migrate_x_objs.sh — body of make migrate-x-objs + parser/typeck/codegen _x.o (11.1.6 · wave735)
#
# Authority (G.7):
#   Single implementation of the migrate companion compile path:
#     parser_gen.c  → parser_x.o
#     typeck_gen.c  → typeck_x.o
#     codegen_gen.c → codegen_x.o
#   Makefile thin leaves call this script; refresh-gate and xbuild call it
#   directly (no `make migrate-x-objs` recipe body).
#
#   *_gen.c production still lives in Makefile (residual until 11.3). When
#   this script is invoked without a make prereq and gen is missing, it
#   restores product seed pins when present, else residual `make <leaf>_gen.c`.
#
# Usage (cwd = compiler/):
#   sh scripts/migrate_x_objs.sh              # all three (default)
#   sh scripts/migrate_x_objs.sh all
#   sh scripts/migrate_x_objs.sh parser|typeck|codegen
#   ./xbuild migrate                          # repo root
#   make migrate-x-objs | make parser_x.o …   # thin Makefile leaves
#
# Env:
#   CC / CFLAGS / PYTHON / MAKE — host compile (defaults match Makefile)
#   XLANG_MIGRATE_FORCE=1 — always recompile even if .o is newer than gen
#
# PLATFORM: SHARED shell orchestration; seed pins are host-portable C.
# Wave: 735 Track MG · pairs with Makefile thin leaves + xbuild migrate.

set -euo pipefail
cd "$(dirname "$0")/.."

CC="${CC:-cc}"
CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
MAKE="${MAKE:-make}"
PYTHON="${PYTHON:-}"
if [ -z "$PYTHON" ]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
  else
    PYTHON=python
  fi
fi
XLANG_MIGRATE_FORCE="${XLANG_MIGRATE_FORCE:-0}"
MODE="${1:-all}"

# Match Makefile PIPELINE_GEN_CFLAGS (Clang extras only when CC is clang).
PIPELINE_GEN_CFLAGS_BASE="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
PIPELINE_GEN_CFLAGS_CLANG="-Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers -Wno-parentheses-equality"
PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS_BASE"
if "$CC" -v 2>&1 | grep -qi clang; then
  PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS_BASE $PIPELINE_GEN_CFLAGS_CLANG"
fi

log() { echo "migrate-x-objs: $*" >&2; }

obj_size() {
  # PLATFORM: SHARED — Darwin stat -f%z; Linux stat -c%s
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

need_rebuild() {
  # $1=out.o $2=gen.c — rebuild if force, missing o, or gen newer than o
  local o="$1" g="$2"
  if [ "$XLANG_MIGRATE_FORCE" = "1" ]; then
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

ensure_gen() {
  # $1=gen.c $2=optional seed path $3=make target name for residual regen
  local gen="$1" seed="${2:-}" make_tgt="${3:-}"
  if [ -s "$gen" ]; then
    return 0
  fi
  if [ -n "$seed" ] && [ -f "$seed" ]; then
    cp -f "$seed" "$gen"
    log "$gen ← $seed (missing pin restore)"
    return 0
  fi
  if [ -n "$make_tgt" ]; then
    log "residual make $make_tgt (no local pin for $gen)"
    MAKEFLAGS= "$MAKE" "$make_tgt"
    return 0
  fi
  log "missing $gen and no seed/make target"
  exit 1
}

build_parser() {
  ensure_gen parser_gen.c seeds/parser_gen.linux.x86_64.c parser_gen.c
  if ! need_rebuild parser_x.o parser_gen.c; then
    log "parser_x.o up-to-date"
    return 0
  fi
  # Makefile parity: token enum sync before cc (no-op-ish if already aligned)
  if [ -f scripts/sync_lexer_gen_token_enum.pl ]; then
    perl scripts/sync_lexer_gen_token_enum.pl parser_gen.c
  fi
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    -Dstd_io_driver_driver_read_ptr_len=xlang_io_read_ptr_len \
    -Dstd_io_driver_driver_read_ptr=xlang_io_read_ptr \
    -c parser_gen.c -o parser_x.o
  log "parser_x.o OK"
}

build_typeck() {
  ensure_gen typeck_gen.c seeds/typeck_gen.linux.x86_64.c typeck_gen.c
  # Skip patch+cc when .o is current (patch may rewrite gen even when no-op-ish).
  if ! need_rebuild typeck_x.o typeck_gen.c; then
    log "typeck_x.o up-to-date"
    return 0
  fi
  # LANG-007: patch before compile (Makefile parity)
  if [ -f scripts/patch_typeck_gen_lang007.py ]; then
    "$PYTHON" scripts/patch_typeck_gen_lang007.py || true
  fi
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c typeck_gen.c -o typeck_x.o
  sz=$(obj_size typeck_x.o)
  if [ "$sz" -le 10000 ]; then
    log "typeck_x.o too small ($sz; corrupt gen? rm typeck_gen.c && make typeck_gen.c)"
    exit 1
  fi
  log "typeck_x.o OK ($sz bytes)"
}

build_codegen() {
  # Prefer tip seed pin when present (PLATFORM SHARED: guard gitignored pin drift)
  if [ -f seeds/codegen_gen.linux.x86_64.c ]; then
    if [ ! -s codegen_gen.c ] || ! cmp -s seeds/codegen_gen.linux.x86_64.c codegen_gen.c; then
      cp -f seeds/codegen_gen.linux.x86_64.c codegen_gen.c
      log "codegen_gen.c ← seeds/codegen_gen.linux.x86_64.c (tip seed pin)"
    fi
  else
    ensure_gen codegen_gen.c "" codegen_gen.c
  fi
  if ! need_rebuild codegen_x.o codegen_gen.c; then
    log "codegen_x.o up-to-date"
    return 0
  fi
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c codegen_gen.c -o codegen_x.o
  sz=$(obj_size codegen_x.o)
  if [ "$sz" -le 50000 ]; then
    log "codegen_x.o too small ($sz; corrupt gen? rm codegen_gen.c && make codegen_gen.c)"
    exit 1
  fi
  log "codegen_x.o OK ($sz bytes)"
}

case "$MODE" in
  all|"")
    build_parser
    build_typeck
    build_codegen
    echo "migrate-x-objs OK (parser_x.o typeck_x.o codegen_x.o ready)"
    ;;
  parser|parser_x.o)
    build_parser
    ;;
  typeck|typeck_x.o)
    build_typeck
    ;;
  codegen|codegen_x.o)
    build_codegen
    ;;
  -h|--help|help)
    cat <<'EOF'
Usage: migrate_x_objs.sh [all|parser|typeck|codegen]
  all (default)  — build parser_x.o typeck_x.o codegen_x.o
  parser|typeck|codegen — single leaf
Env: CC CFLAGS PYTHON MAKE XLANG_MIGRATE_FORCE=1
EOF
    ;;
  *)
    log "unknown mode: $MODE (use all|parser|typeck|codegen)"
    exit 2
    ;;
esac

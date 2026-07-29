#!/usr/bin/env bash
# ensure_driver_gen.sh — body of product driver/preprocess *_gen.c leaves
# (11.1.6 · wave738 driver_gen.c + preprocess_gen.c)
#
# Authority (G.7):
#   Single implementation of product driver-path *_gen.c production for:
#     driver_gen.c      (MAIN_X_DEPS freshness / seed pin / xlang-x|-c -E +
#                        fix_driver_gen_duplicate_main) — wave738
#     preprocess_gen.c  (pin / seed / force -E)                               — wave738
#   Makefile thin leaves and ./xbuild driver-gen call this script (0× make for
#   the gen body). Residual make only when building missing xlang-c for force
#   -E (until 11.3 swallows that graph).
#   Frontend leaves remain ensure_migrate_gen.sh (wave736/737). Product LSP +
#   pipeline_gen live in ensure_lsp_pipeline_gen.sh (wave739).
#
# Usage (cwd = compiler/):
#   sh scripts/ensure_driver_gen.sh              # driver + preprocess (default)
#   sh scripts/ensure_driver_gen.sh all
#   sh scripts/ensure_driver_gen.sh driver|preprocess
#   ./xbuild driver-gen | preprocess-gen         # repo root
#   make driver_gen.c | preprocess_gen.c         # thin leaves
#
# Env:
#   XLANG_FORCE_REGEN_GEN=1 — force -E regen (ignore local pin / deps)
#   XLANG_DRIVER_GEN_TIMEOUT — seconds for driver -E (default 120)
#   MAKE — residual make for missing xlang-c only
#   XLANG_C / XLANG_X — binary names (default xlang-c / xlang-x)
#
# PLATFORM: SHARED shell orchestration; product seed pins are host-portable C.
# Wave: 738 Track MG · pairs with Makefile thin leaves + xbuild driver-gen.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
XLANG_C="${XLANG_C:-xlang-c}"
XLANG_X="${XLANG_X:-xlang-x}"
XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}"
XLANG_DRIVER_GEN_TIMEOUT="${XLANG_DRIVER_GEN_TIMEOUT:-120}"
MODE="${1:-all}"

# Parity with Makefile MAIN_X_E_DIRS / MAIN_X_DEPS / PREPROCESS_X_DEPS
MAIN_X_E_DIRS=(-L .. -L src -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess)
MAIN_X_DEPS=(src/main.x src/codegen/codegen.x src/ast/ast.x src/preprocess/preprocess.x)
PREPROCESS_X_DEPS=(src/preprocess/preprocess.x)

log() { echo "ensure-driver-gen: $*" >&2; }

# Product pin seeds (*.linux.x86_64.c) are host-portable generated C.
# PLATFORM: SHARED — cold start on Darwin/Windows uses the same pins.
seed_ok() {
  [ -f "$1" ]
}

ensure_xlang_c() {
  if [ -x "./$XLANG_C" ] || [ -f "./$XLANG_C" ]; then
    return 0
  fi
  log "residual make $XLANG_C (missing binary for force -E)"
  MAKEFLAGS= "$MAKE" "$XLANG_C"
}

run_with_timeout() {
  # $@ = command; uses timeout(1) when present
  if command -v timeout >/dev/null 2>&1; then
    timeout "$XLANG_DRIVER_GEN_TIMEOUT" "$@" || true
  else
    "$@" || true
  fi
}

bytes_of() {
  # PLATFORM: SHARED — Darwin wc -c pads; tr -d spaces
  wc -c < "$1" | tr -d ' '
}

# Return 0 if any path in "$@" is newer than $1 (or $1 missing/empty).
any_dep_newer() {
  local target="$1"
  shift
  local dep
  if [ ! -s "$target" ]; then
    return 0
  fi
  for dep in "$@"; do
    if [ -e "$dep" ] && [ "$dep" -nt "$target" ]; then
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# driver_gen.c
# PLATFORM: SHARED — L4 true-cold wipes xlang-x / xlang-c but often leaves a
# host-local driver_gen.c older than MAIN_X_DEPS. Prefer seed restore when
# need_regen and xlang-x is missing, unless XLANG_FORCE_REGEN_GEN=1.
# ---------------------------------------------------------------------------
ensure_driver_gen() {
  local tmp seed="seeds/driver_gen.linux.x86_64.c"
  local need_regen=0
  tmp="driver_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    need_regen=1
  elif any_dep_newer driver_gen.c "${MAIN_X_DEPS[@]}"; then
    need_regen=1
  fi

  if [ "$need_regen" = "0" ]; then
    log "driver_gen.c: pinned ($(bytes_of driver_gen.c) bytes; up-to-date with MAIN_X_DEPS)"
  elif seed_ok "$seed" && [ "$XLANG_FORCE_REGEN_GEN" != "1" ] \
    && { [ ! -s driver_gen.c ] || [ ! -f "./$XLANG_X" ]; }; then
    # L4-safe: empty pin or no xlang-x → restore seed (avoid bootstrap xlang-c hang)
    cp -f "$seed" driver_gen.c
    touch driver_gen.c
    log "driver_gen.c: restored from $seed (empty or no $XLANG_X; L4-safe)"
  elif [ -f "./$XLANG_X" ]; then
    log "driver_gen.c: ./$XLANG_X -x -E ..."
    run_with_timeout "./$XLANG_X" -x -E "${MAIN_X_E_DIRS[@]}" -E-extern src/main.x >"$tmp" 2>/dev/null
    if [ -s "$tmp" ] && grep -q 'argc < 3' "$tmp" \
      && grep -q 'main_eq_minus_E(arg_buf, len) != 0' "$tmp"; then
      mv -f "$tmp" driver_gen.c
    else
      rm -f "$tmp"
      log "driver_gen.c: xlang-x failed or old bare -E block, fallback to xlang-c -E -E-extern"
      ensure_xlang_c
      run_with_timeout "./$XLANG_C" "${MAIN_X_E_DIRS[@]}" src/main.x -E -E-extern >"$tmp"
      if [ -s "$tmp" ]; then
        mv -f "$tmp" driver_gen.c
      elif seed_ok "$seed"; then
        cp -f "$seed" driver_gen.c
        touch driver_gen.c
        log "driver_gen.c: fallback seed (xlang-c -E failed/empty)"
      else
        rm -f "$tmp"
        log "driver_gen.c: FAIL (xlang-x/xlang-c -E failed and no seed)"
        exit 1
      fi
    fi
  elif seed_ok "$seed"; then
    cp -f "$seed" driver_gen.c
    touch driver_gen.c
    log "driver_gen.c: restored from $seed (no $XLANG_X; skip xlang-c -E)"
  else
    ensure_xlang_c
    if "./$XLANG_C" "${MAIN_X_E_DIRS[@]}" src/main.x -E -E-extern >"$tmp" 2>/dev/null \
      && [ -s "$tmp" ]; then
      mv -f "$tmp" driver_gen.c
    elif seed_ok "$seed"; then
      cp -f "$seed" driver_gen.c
      touch driver_gen.c
      log "driver_gen.c: fallback seed (xlang-c -E failed)"
    else
      rm -f "$tmp"
      log "driver_gen.c: FAIL (xlang-c -E failed and no seed)"
      exit 1
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  # Post-normalize (Makefile parity — runs on pin and regen)
  if [ -f scripts/fix_driver_gen_duplicate_main.pl ]; then
    perl scripts/fix_driver_gen_duplicate_main.pl driver_gen.c
  fi
  log "driver_gen.c OK ($(bytes_of driver_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# preprocess_gen.c
# ---------------------------------------------------------------------------
ensure_preprocess_gen() {
  local tmp seed="seeds/preprocess_gen.linux.x86_64.c"
  tmp="preprocess_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ -s preprocess_gen.c ] && [ "$XLANG_FORCE_REGEN_GEN" != "1" ]; then
    log "preprocess_gen.c: pinned ($(bytes_of preprocess_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
  elif seed_ok "$seed" && [ ! -s preprocess_gen.c ]; then
    cp -f "$seed" preprocess_gen.c
    log "preprocess_gen.c: restored from $seed"
  else
    ensure_xlang_c
    if "./$XLANG_C" -L src/lexer -E -E-extern src/preprocess/preprocess.x >"$tmp" 2>/dev/null \
      && [ -s "$tmp" ]; then
      mv -f "$tmp" preprocess_gen.c
    elif seed_ok "$seed"; then
      cp -f "$seed" preprocess_gen.c
      log "preprocess_gen.c: fallback seed (xlang-c -E failed)"
    else
      rm -f "$tmp"
      log "preprocess_gen.c: FAIL (xlang-c -E failed and no seed)"
      exit 1
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true
  log "preprocess_gen.c OK ($(bytes_of preprocess_gen.c) bytes)"
}

case "$MODE" in
  all|"")
    ensure_driver_gen
    ensure_preprocess_gen
    echo "ensure-driver-gen OK (driver_gen.c preprocess_gen.c ready)"
    ;;
  driver|driver_gen.c|main)
    ensure_driver_gen
    ;;
  preprocess|preprocess_gen.c)
    ensure_preprocess_gen
    ;;
  -h|--help|help)
    cat <<'EOF'
Usage: ensure_driver_gen.sh [all|driver|preprocess]
  all (default)   — ensure driver_gen.c + preprocess_gen.c
  driver          — driver_gen.c only (MAIN_X_DEPS freshness + seed/-E + fix dup main)
  preprocess      — preprocess_gen.c only
Env: XLANG_FORCE_REGEN_GEN=1 XLANG_DRIVER_GEN_TIMEOUT MAKE XLANG_C XLANG_X
EOF
    ;;
  *)
    log "unknown mode: $MODE (use all|driver|preprocess)"
    exit 2
    ;;
esac

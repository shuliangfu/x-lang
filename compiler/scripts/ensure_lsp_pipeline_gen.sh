#!/usr/bin/env bash
# ensure_lsp_pipeline_gen.sh — body of product LSP + pipeline *_gen.c leaves
# (11.1.6 · wave739 lsp_diag/io/lsp_gen.c + pipeline_gen.c)
#
# Authority (G.7):
#   Single implementation of product LSP/pipeline *_gen.c production for:
#     lsp_diag_gen.c  (pin / seed / xlang-c -E only + C-04 aliases guard)
#     lsp_io_gen.c    (pin / seed / xlang-x|-c -E; reject old io.o stub TU)
#     lsp_gen.c       (pin / seed / xlang-x|-c -E + g_lsp_state_buf sed post)
#     pipeline_gen.c  (pin / seed / force xlang-c -E + check_pipeline_gen_expr_i64_abi)
#   Makefile thin leaves and ./xbuild lsp-gen|pipeline-gen call this script
#   (0× make for the gen body). Residual make only when building missing
#   xlang-c for force -E (until 11.3 swallows that graph).
#   Frontend = ensure_migrate_gen.sh; driver path = ensure_driver_gen.sh.
#   Archaeology gens (lsp_io_std_heap_gen, driver_*_gen subcmds) stay Makefile
#   until a later MG slice (Track L retired product path).
#
# Usage (cwd = compiler/):
#   sh scripts/ensure_lsp_pipeline_gen.sh              # product all (default)
#   sh scripts/ensure_lsp_pipeline_gen.sh all
#   sh scripts/ensure_lsp_pipeline_gen.sh lsp|lsp-all  # three LSP gens
#   sh scripts/ensure_lsp_pipeline_gen.sh lsp_diag|lsp_io|lsp
#   sh scripts/ensure_lsp_pipeline_gen.sh pipeline
#   ./xbuild lsp-gen | pipeline-gen | lsp-pipeline-gen
#   make lsp_diag_gen.c | lsp_io_gen.c | lsp_gen.c | pipeline_gen.c
#
# Env:
#   XLANG_FORCE_REGEN_GEN=1 — force -E regen (ignore local pin)
#   MAKE — residual make for missing xlang-c only
#   XLANG_C / XLANG_X — binary names (default xlang-c / xlang-x)
#
# PLATFORM: SHARED shell orchestration; product seed pins are host-portable C.
# Wave: 739 Track MG · pairs with Makefile thin leaves + xbuild lsp/pipeline-gen.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
XLANG_C="${XLANG_C:-xlang-c}"
XLANG_X="${XLANG_X:-xlang-x}"
XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}"
MODE="${1:-all}"

# Parity with Makefile LSP_X_E_DIRS
LSP_X_E_DIRS=(-L .. -L src/lsp -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess)
# pipeline -E lib roots (Makefile bootstrap-pipeline recipe)
PIPELINE_X_E_DIRS=(-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess)

log() { echo "ensure-lsp-pipeline-gen: $*" >&2; }

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

bytes_of() {
  # PLATFORM: SHARED — Darwin wc -c pads; tr -d spaces
  wc -c < "$1" | tr -d ' '
}

# ---------------------------------------------------------------------------
# lsp_diag_gen.c
# Prefer xlang-c -E only (xlang-x -x -E historically produces broken TU).
# Post: require C-04 -E-extern TU aliases marker, else restore seed.
# ---------------------------------------------------------------------------
ensure_lsp_diag_gen() {
  local tmp seed="seeds/lsp_diag_gen.linux.x86_64.c"
  tmp="lsp_diag_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ -s lsp_diag_gen.c ] && [ "$XLANG_FORCE_REGEN_GEN" != "1" ]; then
    log "lsp_diag_gen.c: pinned ($(bytes_of lsp_diag_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
  elif seed_ok "$seed" && [ ! -s lsp_diag_gen.c ]; then
    cp -f "$seed" lsp_diag_gen.c
    log "lsp_diag_gen.c: restored from $seed"
  else
    log "lsp_diag_gen.c: $XLANG_C -E -E-extern (avoid xlang-x -x -E: broken TU for lsp_diag.x)"
    ensure_xlang_c
    if "./$XLANG_C" "${LSP_X_E_DIRS[@]}" -L src/pipeline src/lsp/lsp_diag.x -E -E-extern >"$tmp" 2>/dev/null \
      && [ -s "$tmp" ]; then
      mv -f "$tmp" lsp_diag_gen.c
    elif seed_ok "$seed"; then
      rm -f "$tmp"
      cp -f "$seed" lsp_diag_gen.c
      log "lsp_diag_gen.c: fallback seed (xlang-c -E failed)"
    else
      rm -f "$tmp"
      log "lsp_diag_gen.c: FAIL (xlang-c -E failed and no seed)"
      exit 1
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  if ! grep -q 'C-04 -E-extern TU aliases' lsp_diag_gen.c 2>/dev/null; then
    if seed_ok "$seed"; then
      cp -f "$seed" lsp_diag_gen.c
      log "lsp_diag_gen.c: restored seed (missing C-04 -E-extern TU aliases)"
    else
      log "lsp_diag_gen.c: FAIL missing C-04 -E-extern TU aliases (need xlang-c -E-extern codegen; no perl fallback)"
      exit 1
    fi
  fi
  log "lsp_diag_gen.c OK ($(bytes_of lsp_diag_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# lsp_io_gen.c
# Prefer xlang-x -x -E when present; reject old 'lsp_io -E-extern stubs (io.o' TU.
# ---------------------------------------------------------------------------
ensure_lsp_io_gen() {
  local tmp seed="seeds/lsp_io_gen.linux.x86_64.c"
  tmp="lsp_io_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ -s lsp_io_gen.c ] && [ "$XLANG_FORCE_REGEN_GEN" != "1" ]; then
    log "lsp_io_gen.c: pinned ($(bytes_of lsp_io_gen.c) bytes)"
  elif seed_ok "$seed" && [ ! -s lsp_io_gen.c ]; then
    cp -f "$seed" lsp_io_gen.c
    log "lsp_io_gen.c: restored from $seed"
  elif [ -f "./$XLANG_X" ]; then
    log "lsp_io_gen.c: ./$XLANG_X -x -E ..."
    "./$XLANG_X" -x -E "${LSP_X_E_DIRS[@]}" -E-extern src/lsp/lsp_io.x >"$tmp" 2>/dev/null || true
    if [ -s "$tmp" ] && ! grep -q 'lsp_io -E-extern stubs (io.o' "$tmp"; then
      mv -f "$tmp" lsp_io_gen.c
    else
      rm -f "$tmp"
      log "lsp_io_gen.c: fallback to xlang-c -E -E-extern (C-04)"
      ensure_xlang_c
      if "./$XLANG_C" "${LSP_X_E_DIRS[@]}" src/lsp/lsp_io.x -E -E-extern >"$tmp" 2>/dev/null \
        && [ -s "$tmp" ]; then
        mv -f "$tmp" lsp_io_gen.c
      elif seed_ok "$seed"; then
        rm -f "$tmp"
        cp -f "$seed" lsp_io_gen.c
        log "lsp_io_gen.c: fallback seed"
      else
        rm -f "$tmp"
        log "lsp_io_gen.c: FAIL (xlang-c -E failed and no seed)"
        exit 1
      fi
    fi
  else
    ensure_xlang_c
    if "./$XLANG_C" "${LSP_X_E_DIRS[@]}" src/lsp/lsp_io.x -E -E-extern >"$tmp" 2>/dev/null \
      && [ -s "$tmp" ]; then
      mv -f "$tmp" lsp_io_gen.c
    elif seed_ok "$seed"; then
      rm -f "$tmp"
      cp -f "$seed" lsp_io_gen.c
      log "lsp_io_gen.c: fallback seed"
    else
      rm -f "$tmp"
      log "lsp_io_gen.c: FAIL (xlang-c -E failed and no seed)"
      exit 1
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true
  log "lsp_io_gen.c OK ($(bytes_of lsp_io_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# lsp_gen.c
# Prefer xlang-x with typeck_lsp_main_impl and without old lsp_io_x stub block.
# Post: rewrite state_buf → g_lsp_state_buf (Makefile sed parity).
# ---------------------------------------------------------------------------
ensure_lsp_gen() {
  local tmp seed="seeds/lsp_gen.linux.x86_64.c"
  tmp="lsp_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ -s lsp_gen.c ] && [ "$XLANG_FORCE_REGEN_GEN" != "1" ]; then
    log "lsp_gen.c: pinned ($(bytes_of lsp_gen.c) bytes)"
  elif seed_ok "$seed" && [ ! -s lsp_gen.c ]; then
    cp -f "$seed" lsp_gen.c
    log "lsp_gen.c: restored from $seed"
  elif [ -f "./$XLANG_X" ]; then
    log "lsp_gen.c: ./$XLANG_X -x -E ..."
    "./$XLANG_X" -x -E "${LSP_X_E_DIRS[@]}" -E-extern src/lsp/lsp.x >"$tmp" 2>/dev/null || true
    if [ -s "$tmp" ] && grep -q typeck_lsp_main_impl "$tmp" \
      && ! grep -q 'lsp.x -E-extern stubs (lsp_io_x' "$tmp"; then
      mv -f "$tmp" lsp_gen.c
    else
      rm -f "$tmp"
      log "lsp_gen.c: xlang-x failed or old extern block, fallback to xlang-c -E -E-extern"
      ensure_xlang_c
      if "./$XLANG_C" "${LSP_X_E_DIRS[@]}" src/lsp/lsp.x -E -E-extern >"$tmp" 2>/dev/null \
        && [ -s "$tmp" ]; then
        mv -f "$tmp" lsp_gen.c
      elif seed_ok "$seed"; then
        rm -f "$tmp"
        cp -f "$seed" lsp_gen.c
        log "lsp_gen.c: fallback seed"
      else
        rm -f "$tmp"
        log "lsp_gen.c: FAIL (xlang-c -E failed and no seed)"
        exit 1
      fi
    fi
  else
    ensure_xlang_c
    if "./$XLANG_C" "${LSP_X_E_DIRS[@]}" src/lsp/lsp.x -E -E-extern >"$tmp" 2>/dev/null \
      && [ -s "$tmp" ]; then
      mv -f "$tmp" lsp_gen.c
    elif seed_ok "$seed"; then
      rm -f "$tmp"
      cp -f "$seed" lsp_gen.c
      log "lsp_gen.c: fallback seed"
    else
      rm -f "$tmp"
      log "lsp_gen.c: FAIL (xlang-c -E failed and no seed)"
      exit 1
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  # Post-normalize (Makefile sed parity — runs on pin and regen)
  # PLATFORM: SHARED — sed -i.bak works on GNU sed and BSD sed (Darwin).
  sed -i.bak 's/uint8_t state_buf\[16388\] = { 0 }/extern uint8_t g_lsp_state_buf[16388]/' lsp_gen.c 2>/dev/null || true
  sed -i.bak 's/(state_buf)/(g_lsp_state_buf)/g' lsp_gen.c 2>/dev/null || true
  rm -f lsp_gen.c.bak 2>/dev/null || true
  log "lsp_gen.c OK ($(bytes_of lsp_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# pipeline_gen.c
# Pin-first; empty → seed; force or missing → xlang-c -E then seed fallback.
# Always finish with check_pipeline_gen_expr_i64_abi.sh (P0-4 int64_t int_val).
# ---------------------------------------------------------------------------
ensure_pipeline_gen() {
  local seed="seeds/pipeline_gen.linux.x86_64.c"

  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    ensure_xlang_c
    if "./$XLANG_C" "${PIPELINE_X_E_DIRS[@]}" -E -E-extern src/pipeline/pipeline.x >pipeline_gen.c; then
      log "pipeline_gen.c: forced regen via $XLANG_C -E -E-extern"
    else
      log "pipeline_gen.c: FAIL forced -E"
      exit 1
    fi
  elif [ -s pipeline_gen.c ]; then
    log "pipeline_gen.c: pinned ($(bytes_of pipeline_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
  elif seed_ok "$seed"; then
    cp -f "$seed" pipeline_gen.c
    log "pipeline_gen.c: restored from $seed"
  else
    ensure_xlang_c
    if "./$XLANG_C" "${PIPELINE_X_E_DIRS[@]}" -E -E-extern src/pipeline/pipeline.x >pipeline_gen.c 2>/dev/null \
      && [ -s pipeline_gen.c ]; then
      log "pipeline_gen.c: generated via $XLANG_C -E -E-extern"
    elif seed_ok "$seed"; then
      cp -f "$seed" pipeline_gen.c
      log "pipeline_gen.c: fallback seed (xlang-c -E failed)"
    else
      log "pipeline_gen.c: FAIL (xlang-c -E failed and no seed)"
      exit 1
    fi
  fi

  # PLATFORM: SHARED — ABI guard always runs (stale int32_t int_val = P0-4 L4 red)
  if [ -f scripts/check_pipeline_gen_expr_i64_abi.sh ]; then
    chmod +x scripts/check_pipeline_gen_expr_i64_abi.sh 2>/dev/null || true
    ./scripts/check_pipeline_gen_expr_i64_abi.sh
  fi
  log "pipeline_gen.c OK ($(bytes_of pipeline_gen.c) bytes)"
}

ensure_lsp_all() {
  ensure_lsp_diag_gen
  ensure_lsp_io_gen
  ensure_lsp_gen
}

case "$MODE" in
  all|"")
    ensure_lsp_all
    ensure_pipeline_gen
    echo "ensure-lsp-pipeline-gen OK (lsp_diag/io/lsp + pipeline_gen ready)"
    ;;
  lsp|lsp-all|lsp_all)
    ensure_lsp_all
    echo "ensure-lsp-pipeline-gen OK (lsp_diag_gen.c lsp_io_gen.c lsp_gen.c ready)"
    ;;
  lsp_diag|lsp_diag_gen.c)
    ensure_lsp_diag_gen
    ;;
  lsp_io|lsp_io_gen.c)
    ensure_lsp_io_gen
    ;;
  lsp_gen|lsp_gen.c|lsp_main)
    ensure_lsp_gen
    ;;
  pipeline|pipeline_gen.c)
    ensure_pipeline_gen
    ;;
  -h|--help|help)
    cat <<'EOF'
Usage: ensure_lsp_pipeline_gen.sh [all|lsp|lsp_diag|lsp_io|lsp_gen|pipeline]
  all (default)   — ensure lsp_diag + lsp_io + lsp_gen + pipeline_gen
  lsp | lsp-all   — three product LSP gens only
  lsp_diag        — lsp_diag_gen.c only
  lsp_io          — lsp_io_gen.c only
  lsp_gen         — lsp_gen.c only
  pipeline        — pipeline_gen.c only (+ i64 ABI check)
Env: XLANG_FORCE_REGEN_GEN=1 MAKE XLANG_C XLANG_X
EOF
    ;;
  *)
    log "unknown mode: $MODE (use all|lsp|lsp_diag|lsp_io|lsp_gen|pipeline)"
    exit 2
    ;;
esac

#!/usr/bin/env bash
# ensure_migrate_gen.sh — body of product frontend *_gen.c leaves
# (11.1.6 · wave736 migrate trio · wave737 +lexer)
#
# Authority (G.7):
#   Single implementation of product frontend *_gen.c production for:
#     parser_gen.c   (seed pin / force -E / C-04 post-normalize)     — wave736
#     typeck_gen.c   (seed pin / force -E / fix_slim_arena)          — wave736
#     codegen_gen.c  (tip seed pin sync / force -E / fix_slim_arena) — wave736
#     lexer_gen.c    (seed pin / force -E / slim + token enum sync)  — wave737
#   Makefile thin leaves and migrate_x_objs.sh call this script (0× make for
#   the gen body). Residual make only when building missing xlang-c for force
#   -E (until 11.3 swallows that graph).
#   Name is historical (migrate companions); owns frontend gen leaves only —
#   driver/lsp/preprocess residual still Makefile until later MG waves.
#
# Usage (cwd = compiler/):
#   sh scripts/ensure_migrate_gen.sh              # parser+typeck+codegen (default)
#   sh scripts/ensure_migrate_gen.sh all
#   sh scripts/ensure_migrate_gen.sh all-frontend # +lexer
#   sh scripts/ensure_migrate_gen.sh parser|typeck|codegen|lexer
#   ./xbuild migrate-gen | lexer-gen              # repo root
#   make parser_gen.c | typeck_gen.c | codegen_gen.c | lexer_gen.c  # thin leaves
#
# Env:
#   XLANG_FORCE_REGEN_GEN=1 — force -E regen (ignore local pin)
#   XLANG_PARSER_GEN_TIMEOUT — seconds for parser -E (default 120)
#   MAKE — residual make for missing xlang-c only
#   XLANG_C / XLANG_X — binary names (default xlang-c / xlang-x)
#
# PLATFORM: SHARED shell orchestration; product seed pins are host-portable C.
# Wave: 736/737 Track MG · pairs with migrate_x_objs.sh + Makefile thin leaves.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
XLANG_C="${XLANG_C:-xlang-c}"
XLANG_X="${XLANG_X:-xlang-x}"
XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}"
XLANG_PARSER_GEN_TIMEOUT="${XLANG_PARSER_GEN_TIMEOUT:-120}"
MODE="${1:-all}"

log() { echo "ensure-migrate-gen: $*" >&2; }

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
    timeout "$XLANG_PARSER_GEN_TIMEOUT" "$@" || true
  else
    "$@" || true
  fi
}

bytes_of() {
  # PLATFORM: SHARED — Darwin wc -c pads; tr -d spaces
  wc -c < "$1" | tr -d ' '
}

# ---------------------------------------------------------------------------
# parser_gen.c
# ---------------------------------------------------------------------------
ensure_parser_gen() {
  local tmp seed="seeds/parser_gen.linux.x86_64.c"
  tmp="parser_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    if [ -f "./$XLANG_X" ]; then
      log "parser_gen.c: ./$XLANG_X -x -E -E-extern ... [forced regen]"
      run_with_timeout "./$XLANG_X" -x -E -L .. -L src/lexer -L src/ast \
        -E-extern src/parser/parser.x >"$tmp" 2>/dev/null
      if [ -s "$tmp" ] && grep -q 'parser_copy_module_import_path64' "$tmp"; then
        mv -f "$tmp" parser_gen.c
      else
        rm -f "$tmp"
        ensure_xlang_c
        run_with_timeout "./$XLANG_C" -L .. -L src/lexer -L src/ast \
          -E -E-extern src/parser/parser.x >"$tmp"
        if [ -s "$tmp" ]; then
          mv -f "$tmp" parser_gen.c
        else
          rm -f "$tmp"
        fi
      fi
    else
      ensure_xlang_c
      "./$XLANG_C" -L .. -L src/lexer -L src/ast \
        -E -E-extern src/parser/parser.x >"$tmp" && mv -f "$tmp" parser_gen.c
    fi
  elif [ -s parser_gen.c ]; then
    log "parser_gen.c: pinned ($(bytes_of parser_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
  elif seed_ok "$seed" && [ ! -s parser_gen.c ]; then
    cp -f "$seed" parser_gen.c
    log "parser_gen.c: restored from $seed"
  else
    # cold missing pin: try -E then seed fallback
    if [ -f "./$XLANG_X" ]; then
      log "parser_gen.c: ./$XLANG_X -x -E -E-extern ..."
      run_with_timeout "./$XLANG_X" -x -E -L .. -L src/lexer -L src/ast \
        -E-extern src/parser/parser.x >"$tmp" 2>/dev/null
      if [ -s "$tmp" ] && grep -q 'parser_copy_module_import_path64' "$tmp"; then
        mv -f "$tmp" parser_gen.c
      else
        log "parser_gen.c: xlang-x failed or thin output; fallback xlang-c"
        rm -f "$tmp" 2>/dev/null || true
        if ensure_xlang_c >/dev/null 2>&1 \
          && { run_with_timeout "./$XLANG_C" -L .. -L src/lexer -L src/ast \
            -E -E-extern src/parser/parser.x >"$tmp" 2>/dev/null; true; } \
          && [ -s "$tmp" ] && grep -q 'parser_copy_module_import_path64' "$tmp"; then
          mv -f "$tmp" parser_gen.c
        elif seed_ok "$seed"; then
          cp -f "$seed" parser_gen.c
          log "parser_gen.c: fallback $seed (xlang-c -E failed)"
        else
          rm -f "$tmp" 2>/dev/null || true
          log "parser_gen.c: FAIL (no xlang-x/xlang-c -E and no seed)"
          exit 1
        fi
      fi
    else
      if ensure_xlang_c >/dev/null 2>&1 \
        && "./$XLANG_C" -L .. -L src/lexer -L src/ast \
          -E -E-extern src/parser/parser.x >"$tmp" 2>/dev/null \
        && [ -s "$tmp" ] && grep -q 'parser_copy_module_import_path64' "$tmp"; then
        mv -f "$tmp" parser_gen.c
      elif seed_ok "$seed"; then
        cp -f "$seed" parser_gen.c
        log "parser_gen.c: fallback $seed"
      else
        rm -f "$tmp" 2>/dev/null || true
        log "parser_gen.c: FAIL (xlang-c -E failed and no seed)"
        exit 1
      fi
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  # Post-normalize (Makefile parity — runs on pin and regen)
  perl -i -ne 'print unless /^struct xlang_slice_uint8_t/ && $seen++' parser_gen.c 2>/dev/null || true

  if ! grep -q 'C-04 -E-extern TU aliases' parser_gen.c 2>/dev/null; then
    log "parser_gen.c: FAIL missing C-04 -E-extern TU aliases (need xlang-c -E-extern codegen; no perl fallback)"
    exit 1
  fi
  if ! grep -q 'C-04 parser: ast_expr_init_match_enum after struct ast_Expr' parser_gen.c 2>/dev/null; then
    log "parser_gen.c: FAIL missing C-04 parser pool marker (need xlang-c -E-extern codegen; no perl fallback)"
    exit 1
  fi
  if ! grep -q 'parser_copy_module_import_path64' parser_gen.c; then
    log "parser_gen.c: inject extern parser_copy_module_import_path64 (parser_asm_parse_expr_link/thin_c)"
    printf '%s\n' \
      '/* pipeline extern parser_copy_module_import_path64 (thin parser_gen TU) */' \
      'extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);' \
      >>parser_gen.c
  fi
  log "parser_gen.c: normalize ast_pipeline onefunc const extern aliases"
  perl -0pi -e 's@^extern int32_t ast_pipeline_onefunc_append_const\(.*\);\n@@mg; s@^extern int32_t ast_pipeline_onefunc_const_init_ref\(.*\);\n@@mg; s@^extern int32_t ast_pipeline_onefunc_const_type_ref\(.*\);\n@@mg; s@/\* C-04 -E-extern TU aliases \*/\n@extern int32_t ast_pipeline_onefunc_append_const(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);\nextern int32_t ast_pipeline_onefunc_const_init_ref(uint8_t * restrict out, int32_t i);\nextern int32_t ast_pipeline_onefunc_const_type_ref(uint8_t * restrict out, int32_t i);\n/* C-04 -E-extern TU aliases */\n@s' parser_gen.c
  log "parser_gen.c: from parser.x (-E-extern, full TU via xlang-x -x) OK"
}

# ---------------------------------------------------------------------------
# typeck_gen.c
# ---------------------------------------------------------------------------
ensure_typeck_gen() {
  local tmp seed="seeds/typeck_gen.linux.x86_64.c"
  tmp="typeck_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    ensure_xlang_c
    "./$XLANG_C" -L .. -L src -L src/lexer -L src/ast -L src/parser \
      src/typeck/typeck.x -E-extern >"$tmp" && mv "$tmp" typeck_gen.c
  elif [ -s typeck_gen.c ]; then
    log "typeck_gen.c: pinned ($(bytes_of typeck_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
  elif seed_ok "$seed" && [ ! -s typeck_gen.c ]; then
    cp -f "$seed" typeck_gen.c
    log "typeck_gen.c: restored from $seed"
  else
    ensure_xlang_c
    if "./$XLANG_C" -L .. -L src -L src/lexer -L src/ast -L src/parser \
      src/typeck/typeck.x -E-extern >"$tmp" && mv "$tmp" typeck_gen.c; then
      :
    else
      rm -f "$tmp"
      if seed_ok "$seed"; then
        cp -f "$seed" typeck_gen.c
        log "typeck_gen.c: fallback seed (xlang-c -E failed)"
      else
        exit 1
      fi
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  if [ -f scripts/fix_slim_arena_gen_c.pl ]; then
    perl scripts/fix_slim_arena_gen_c.pl typeck_gen.c
  fi
  log "typeck_gen.c OK ($(bytes_of typeck_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# codegen_gen.c
# ---------------------------------------------------------------------------
ensure_codegen_gen() {
  local tmp seed="seeds/codegen_gen.linux.x86_64.c"
  tmp="codegen_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    ensure_xlang_c
    "./$XLANG_C" -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck \
      src/codegen/codegen.x -E-extern >"$tmp" && mv "$tmp" codegen_gen.c
  elif [ -f "$seed" ]; then
    # PLATFORM SHARED: tip seed pin guards gitignored pin drift
    if [ ! -s codegen_gen.c ] || ! cmp -s "$seed" codegen_gen.c; then
      cp -f "$seed" codegen_gen.c
      log "codegen_gen.c: synced from tip seed pin (PLATFORM SHARED: guard gitignored pin drift)"
    else
      log "codegen_gen.c: pinned matches tip seed ($(bytes_of codegen_gen.c) bytes)"
    fi
  else
    ensure_xlang_c
    if "./$XLANG_C" -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck \
      src/codegen/codegen.x -E-extern >"$tmp" && mv "$tmp" codegen_gen.c; then
      :
    else
      rm -f "$tmp"
      exit 1
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  if [ -f scripts/fix_slim_arena_gen_c.pl ]; then
    perl scripts/fix_slim_arena_gen_c.pl codegen_gen.c
  fi
  log "codegen_gen.c OK ($(bytes_of codegen_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# lexer_gen.c (wave737)
# Must use full TU (xlang-x -x -E preferred): thin xlang-c gen lacks
# lexer_advance_one / next_body. Post: fix_slim_arena + token enum sync.
# ---------------------------------------------------------------------------
ensure_lexer_gen() {
  local tmp seed="seeds/lexer_gen.linux.x86_64.c"
  tmp="lexer_gen.c.tmp.$$"
  rm -f "$tmp"

  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    if [ -f "./$XLANG_X" ]; then
      log "lexer_gen.c: ./$XLANG_X -x -E -E-extern ... [forced regen]"
      if "./$XLANG_X" -x -E -L src/lexer -E-extern src/lexer/lexer.x >"$tmp" 2>/dev/null \
        && grep -q 'lexer_advance_one' "$tmp"; then
        mv -f "$tmp" lexer_gen.c
      else
        rm -f "$tmp"
        ensure_xlang_c
        "./$XLANG_C" -L src/lexer -E -E-extern src/lexer/lexer.x >"$tmp" \
          && mv -f "$tmp" lexer_gen.c
      fi
    else
      ensure_xlang_c
      "./$XLANG_C" -L src/lexer -E -E-extern src/lexer/lexer.x >"$tmp" \
        && mv -f "$tmp" lexer_gen.c
    fi
  elif [ -s lexer_gen.c ]; then
    log "lexer_gen.c: pinned ($(bytes_of lexer_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
  elif seed_ok "$seed" && [ ! -s lexer_gen.c ]; then
    cp -f "$seed" lexer_gen.c
    log "lexer_gen.c: restored from $seed"
  else
    # cold missing pin: try -E then seed fallback
    if [ -f "./$XLANG_X" ]; then
      log "lexer_gen.c: ./$XLANG_X -x -E -E-extern ..."
      if "./$XLANG_X" -x -E -L src/lexer -E-extern src/lexer/lexer.x >"$tmp" 2>/dev/null \
        && grep -q 'lexer_advance_one' "$tmp"; then
        mv -f "$tmp" lexer_gen.c
      else
        log "lexer_gen.c: xlang-x failed or thin output; fallback xlang-c"
        rm -f "$tmp" 2>/dev/null || true
        if ensure_xlang_c >/dev/null 2>&1 \
          && "./$XLANG_C" -L src/lexer -E -E-extern src/lexer/lexer.x >"$tmp" 2>/dev/null \
          && [ -s "$tmp" ] && grep -q 'lexer_advance_one' "$tmp"; then
          mv -f "$tmp" lexer_gen.c
        elif seed_ok "$seed"; then
          cp -f "$seed" lexer_gen.c
          log "lexer_gen.c: fallback $seed (xlang-c -E failed)"
        else
          rm -f "$tmp" 2>/dev/null || true
          log "lexer_gen.c: FAIL (no xlang-x/xlang-c -E and no seed)"
          exit 1
        fi
      fi
    else
      if ensure_xlang_c >/dev/null 2>&1 \
        && "./$XLANG_C" -L src/lexer -E -E-extern src/lexer/lexer.x >"$tmp" 2>/dev/null \
        && [ -s "$tmp" ] && grep -q 'lexer_advance_one' "$tmp"; then
        mv -f "$tmp" lexer_gen.c
      elif seed_ok "$seed"; then
        cp -f "$seed" lexer_gen.c
        log "lexer_gen.c: fallback $seed"
      else
        rm -f "$tmp" 2>/dev/null || true
        log "lexer_gen.c: FAIL (xlang-c -E failed and no seed)"
        exit 1
      fi
    fi
  fi
  rm -f "$tmp" 2>/dev/null || true

  # Post-normalize (Makefile parity — runs on pin and regen)
  if [ -f scripts/fix_slim_arena_gen_c.pl ]; then
    perl scripts/fix_slim_arena_gen_c.pl lexer_gen.c
  fi
  if [ -f scripts/sync_lexer_gen_token_enum.pl ]; then
    perl scripts/sync_lexer_gen_token_enum.pl lexer_gen.c
  fi
  if ! grep -q 'lexer_advance_one' lexer_gen.c; then
    log "lexer_gen.c: missing lexer_advance_one (need xlang-x -x -E full TU)"
    exit 1
  fi
  log "lexer_gen.c: from lexer.x (-E-extern, full TU via xlang-x -x) OK ($(bytes_of lexer_gen.c) bytes)"
}

case "$MODE" in
  all|"")
    # Default: migrate companions only (wave736 ABI for migrate_x_objs / migrate-gen)
    ensure_parser_gen
    ensure_typeck_gen
    ensure_codegen_gen
    echo "ensure-migrate-gen OK (parser_gen.c typeck_gen.c codegen_gen.c ready)"
    ;;
  all-frontend|frontend)
    ensure_parser_gen
    ensure_typeck_gen
    ensure_codegen_gen
    ensure_lexer_gen
    echo "ensure-migrate-gen OK (parser typeck codegen lexer _gen.c ready)"
    ;;
  parser|parser_gen.c)
    ensure_parser_gen
    ;;
  typeck|typeck_gen.c)
    ensure_typeck_gen
    ;;
  codegen|codegen_gen.c)
    ensure_codegen_gen
    ;;
  lexer|lexer_gen.c)
    ensure_lexer_gen
    ;;
  -h|--help|help)
    cat <<'EOF'
Usage: ensure_migrate_gen.sh [all|all-frontend|parser|typeck|codegen|lexer]
  all (default)   — ensure parser_gen.c typeck_gen.c codegen_gen.c
  all-frontend    — above + lexer_gen.c
  parser|typeck|codegen|lexer — single leaf
Env: XLANG_FORCE_REGEN_GEN=1 XLANG_PARSER_GEN_TIMEOUT MAKE XLANG_C XLANG_X
EOF
    ;;
  *)
    log "unknown mode: $MODE (use all|all-frontend|parser|typeck|codegen|lexer)"
    exit 2
    ;;
esac

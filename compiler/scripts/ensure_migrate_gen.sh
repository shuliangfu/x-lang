#!/usr/bin/env bash
# ensure_migrate_gen.sh — body of product frontend *_gen.c leaves
# (11.1.6 · wave736 migrate trio · wave737 +lexer)
#
# Authority (G.7):
#   Single implementation of product frontend *_gen.c production for:
#     parser_gen.c   (wave324 M4 7.2.2: prefer parser.x assemble; pin archaeology)
#     typeck_gen.c   (wave322 M4 7.4.1: prefer typeck.x assemble; pin archaeology)
#     codegen_gen.c  (wave323 M4 7.4.2: prefer codegen.x assemble; pin archaeology)
#     lexer_gen.c    (seed pin + contract refresh / force -E / slim) — wave737
#   migrate_x_objs.sh and ./xbuild migrate-gen call this script (0× make for
#   the gen body). Missing xlang-c for force -E → scripts/ensure_xlang_c.sh
#   (wave949; not $MAKE — Makefile physically deleted wave941).
#   Name is historical (migrate companions); owns frontend gen leaves only —
#   driver/preprocess → ensure_driver_gen.sh (wave738)
#   LSP + pipeline_gen → ensure_lsp_pipeline_gen.sh (wave739)
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_migrate_gen.sh              # parser+typeck+codegen (default)
#   bash scripts/ensure_migrate_gen.sh all
#   bash scripts/ensure_migrate_gen.sh all-frontend # +lexer
#   bash scripts/ensure_migrate_gen.sh parser|typeck|codegen|lexer
#   ./xbuild migrate-gen | lexer-gen              # repo root
#
# Env:
#   XLANG_FORCE_REGEN_GEN=1 — force -E regen (ignore local pin)
#   XLANG_TYPECK_FROM_X=1   — force typeck.x assemble path (default prefer when -E works)
#   XLANG_TYPECK_ALLOW_PIN=1 — allow seed pin restore / refresh (default 1 for true-cold egg)
#   XLANG_CODEGEN_FROM_X=1  — force codegen.x assemble path (default prefer when -E works)
#   XLANG_CODEGEN_ALLOW_PIN=1 — allow seed pin restore (default 1 for true-cold egg)
#   XLANG_PARSER_FROM_X=1   — tip -E assemble path (default 0: pin still product authority
#                             until tip matrix green — residual P011 trait bare self)
#   XLANG_PARSER_ALLOW_PIN=1 — allow seed pin restore (default 1 for true-cold egg)
#   XLANG_PARSER_GEN_TIMEOUT — seconds for parser -E (default 180)
#   XLANG_C / XLANG_X — binary names (default xlang-c / xlang-x)
#   XLANG_TYPECK_E / XLANG_CODEGEN_E / XLANG_PARSER_E — preferred binary for tip -E (optional)
#
# PLATFORM: SHARED shell orchestration; product seed pins are host-portable C.
# Stale gitignored pins (dual-boot Windows) fail product symbol contract →
# refresh from seeds/*_gen.linux.x86_64.c when assemble cannot run.
# wave829 (G.7 有则补全): FORCE dep-thin — Makefile prereqs FORCE+script only;
#   shell owns pin/seed/FORCE_REGEN policy. NOT physical delete.
# wave322 (G.7 M4 7.4.1): typeck cold path prefer assemble_typeck_gen_from_x
#   (tip -E + companions); pin seed is archaeology / no-binary egg only.
# wave323 (G.7 M4 7.4.2): codegen cold path prefer assemble_codegen_gen_from_x
#   (tip -E + Cap residual); pin seed archaeology only.
# wave324 (G.7 M4 7.2.2): parser cold path prefer assemble_parser_gen_from_x
#   (tip -E + product renames + init_globals scrub); pin seed archaeology only.
# Wave: 736/737 Track MG · pairs with migrate_x_objs.sh + Makefile thin leaves.

set -euo pipefail
cd "$(dirname "$0")/.."

XLANG_C="${XLANG_C:-xlang-c}"
XLANG_X="${XLANG_X:-xlang-x}"
XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}"
# Prefer typeck.x assemble whenever a product -E binary works (wave322 / 7.4.1).
XLANG_TYPECK_FROM_X="${XLANG_TYPECK_FROM_X:-1}"
# Archaeology seed restore allowed when no -E binary (true cold egg).
XLANG_TYPECK_ALLOW_PIN="${XLANG_TYPECK_ALLOW_PIN:-1}"
# Prefer codegen.x assemble whenever a product -E binary works (wave323 / 7.4.2).
XLANG_CODEGEN_FROM_X="${XLANG_CODEGEN_FROM_X:-1}"
XLANG_CODEGEN_ALLOW_PIN="${XLANG_CODEGEN_ALLOW_PIN:-1}"
# wave325: tip -E assemble matrix green (scripts/assemble_parser_gen_from_x.py).
# Close parser cold pin: prefer .x assemble by default; pin only archaeology egg.
XLANG_PARSER_FROM_X="${XLANG_PARSER_FROM_X:-1}"
XLANG_PARSER_ALLOW_PIN="${XLANG_PARSER_ALLOW_PIN:-1}"
XLANG_PARSER_GEN_TIMEOUT="${XLANG_PARSER_GEN_TIMEOUT:-180}"
MODE="${1:-all}"

log() { echo "ensure-migrate-gen: $*" >&2; }

# Product pin seeds (*.linux.x86_64.c) are host-portable generated C.
# PLATFORM: SHARED — cold start on Darwin/Windows uses the same pins.
seed_ok() {
  [ -f "$1" ]
}

# Gitignored local *_gen.c pins can drift on dual-boot hosts (Windows keeps
# weeks-old pins while tip seed has new product symbols). codegen already tip-
# seed syncs; typeck/lexer must not treat any non-empty pin as final.
# Contract = symbols phase1/final link actually needs from that TU.
# PLATFORM: SHARED — same seed pins on macOS/Ubuntu/Windows.
gen_has_sym() {
  # $1=file $2=symbol substring (grep -F)
  [ -s "$1" ] && grep -Fq "$2" "$1"
}

typeck_gen_contract_ok() {
  # phase1 UNDEF surface from pipeline_x → typeck_x
  gen_has_sym "$1" 'typeck_check_call_arity' \
    && gen_has_sym "$1" 'typeck_check_call_arg_types' \
    && gen_has_sym "$1" 'typeck_expr_is_null_keyword' \
    && gen_has_sym "$1" 'typeck_type_is_valid_subscript_index'
}

codegen_gen_contract_ok() {
  # product pure-ld needs emit_expr + x_ast + Cap residual faces
  (gen_has_sym "$1" 'codegen_emit_expr' || gen_has_sym "$1" 'codegen_emit_expr_ASTArena') \
    && gen_has_sym "$1" 'codegen_x_ast' \
    && gen_has_sym "$1" 'codegen_set_host_call_arg_param_ty' \
    && gen_has_sym "$1" 'pipeline_loop_should_continue_ndep_c'
}

parser_gen_contract_ok() {
  # product pure-ld / pipeline_x surface from parser_x
  gen_has_sym "$1" 'parser_copy_module_import_path64' \
    && gen_has_sym "$1" 'parser_parse_expr_into' \
    && gen_has_sym "$1" 'parser_collect_imports' \
    && gen_has_sym "$1" 'parser_parse_one_function_impl'
}

lexer_gen_contract_ok() {
  # phase1 UNDEF surface from parser_x / thin_glue → lexer_x
  gen_has_sym "$1" 'lexer_advance_one' \
    && gen_has_sym "$1" 'lexer_invalid_type_suffix_reset' \
    && gen_has_sym "$1" 'lexer_note_string_lit_overflow'
}

refresh_gen_from_seed_if_stale() {
  # $1=local gen  $2=seed  $3=contract_fn_name  $4=label
  # Refresh gitignored local pin from tip seed when:
  #   (A) local fails product contract and tip seed passes, or
  #   (B) tip seed is newer (mtime) and byte-differs (post-pull pin advance).
  # PLATFORM: SHARED — without (B), Ubuntu keeps pre-pull typeck_gen.c that still
  # passes contract but lacks new export bodies → pure-ld UNDEF (8.3.3 L2 lesson).
  # FORCE_REGEN path leaves gen newer than seed until seed is re-pinned; we do
  # not clobber that mid-wave local -E (only seed -nt gen triggers (B)).
  local gen="$1" seed="$2" contract="$3" label="$4"
  if [ ! -s "$gen" ]; then
    return 1
  fi
  if ! seed_ok "$seed"; then
    if ! "$contract" "$gen"; then
      log "${label}: pin fails product contract and no tip seed ($seed)"
    fi
    return 1
  fi
  # (B) tip seed newer + content drift → take seed (post-pull dual-end L2).
  if [ "$seed" -nt "$gen" ] && ! cmp -s "$seed" "$gen" 2>/dev/null; then
    if ! "$contract" "$seed"; then
      log "${label}: tip seed newer but fails contract ($seed) — need FORCE regen"
      return 1
    fi
    cp -f "$seed" "$gen"
    log "${label}: refreshed from tip seed (seed newer than gitignored pin; PLATFORM SHARED)"
    return 0
  fi
  # (A) local contract fail, seed ok.
  if "$contract" "$gen"; then
    return 1
  fi
  if ! "$contract" "$seed"; then
    log "${label}: pin and tip seed both fail contract ($seed) — need FORCE regen"
    return 1
  fi
  cp -f "$seed" "$gen"
  log "${label}: refreshed from tip seed (stale gitignored pin failed contract; PLATFORM SHARED)"
  return 0
}

# G.7 single authority for default xlang-c alias: ensure_xlang_c.sh (wave876/949).
# PLATFORM: SHARED — 0-make; SRC=bootstrap_xlangc must already exist (select seed).
ensure_xlang_c() {
  if [ -x "./$XLANG_C" ] || [ -f "./$XLANG_C" ]; then
    return 0
  fi
  log "ensure $XLANG_C via scripts/ensure_xlang_c.sh (missing binary for force -E)"
  bash scripts/ensure_xlang_c.sh ensure "$XLANG_C"
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
# parser_gen.c — wave324 M4 7.2.2: prefer parser.x assemble over pin
# ---------------------------------------------------------------------------
# Run tip -E for parser.x into $1. Product pure NO_C rejects -E-extern; plain -E works.
# PLATFORM: SHARED — same -E face on Darwin/Linux; binary may be xlang / xlang_asm / xlang-c.
parser_run_tip_e() {
  local out="$1"
  local b err
  err="${out}.err"
  rm -f "$out" "$err"
  for b in ${XLANG_PARSER_E:-} xlang_asm xlang xlang-c xlang-x; do
    [ -z "$b" ] && continue
    [ -x "./$b" ] || continue
    # Product freestanding: plain -E (not -E-extern) emits library C for parser.x.
    if run_with_timeout "./$b" -L .. -L src -L src/lexer -L src/ast -L src/parser \
      -E src/parser/parser.x >"$out" 2>"$err"; then
      if [ -s "$out" ] && [ "$(bytes_of "$out")" -gt 10000 ]; then
        log "parser tip -E via ./$b ($(bytes_of "$out") bytes)"
        rm -f "$err"
        return 0
      fi
    fi
    rm -f "$out"
  done
  return 1
}

# Assemble parser_gen.c from tip -E (G.7 body = assemble_parser_gen_from_x.py).
parser_assemble_from_x() {
  local tip tmp py
  tip="parser_gen.tip_e.tmp.$$"
  tmp="parser_gen.c.tmp.$$"
  py="${PYTHON:-python3}"
  if [ ! -f scripts/assemble_parser_gen_from_x.py ]; then
    log "missing scripts/assemble_parser_gen_from_x.py (wave324)"
    return 1
  fi
  if ! parser_run_tip_e "$tip"; then
    rm -f "$tip"
    log "parser tip -E failed (no working product -E binary?)"
    return 1
  fi
  if ! "$py" scripts/assemble_parser_gen_from_x.py --tip "$tip" --out "$tmp"; then
    rm -f "$tip" "$tmp"
    return 1
  fi
  mv -f "$tmp" parser_gen.c
  rm -f "$tip"
  log "parser_gen.c: assembled from parser.x (wave324 / 7.2.2)"
  return 0
}

# True when parser.x (or assemble script) is newer than local parser_gen.c → must re-assemble.
parser_x_sources_newer_than_gen() {
  local gen="parser_gen.c"
  [ -s "$gen" ] || return 0
  local f
  for f in \
    src/parser/parser.x \
    scripts/assemble_parser_gen_from_x.py; do
    if [ -f "$f" ] && [ "$f" -nt "$gen" ]; then
      return 0
    fi
  done
  return 1
}

ensure_parser_gen() {
  local seed="seeds/parser_gen.linux.x86_64.c"
  local need_assemble=0

  # Prefer .x assemble when:
  #   FORCE, missing gen, sources newer, contract fail, or FROM_X default
  #   product authority = parser.x assemble
  #   pin seed = archaeology / true-cold egg only
  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    need_assemble=1
  elif [ ! -s parser_gen.c ]; then
    need_assemble=1
  elif [ "$XLANG_PARSER_FROM_X" = "1" ] && parser_x_sources_newer_than_gen; then
    need_assemble=1
  elif [ "$XLANG_PARSER_FROM_X" = "1" ] && ! parser_gen_contract_ok parser_gen.c; then
    need_assemble=1
  fi

  if [ "$need_assemble" = "1" ] && [ "$XLANG_PARSER_FROM_X" = "1" ]; then
    if parser_assemble_from_x; then
      :
    else
      if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
        if [ "$XLANG_PARSER_ALLOW_PIN" = "1" ] && seed_ok "$seed"; then
          cp -f "$seed" parser_gen.c
          log "parser_gen.c: FORCE fallback archaeology seed (tip -E failed)"
        else
          log "parser_gen.c: FAIL FORCE regen (no -E and no pin escape)"
          exit 1
        fi
      else
        log "parser_gen.c: tip assemble unavailable; try local/pin (archaeology)"
      fi
    fi
  fi

  if [ ! -s parser_gen.c ]; then
    if [ "$XLANG_PARSER_ALLOW_PIN" = "1" ] && seed_ok "$seed"; then
      cp -f "$seed" parser_gen.c
      log "parser_gen.c: restored archaeology seed $seed (no -E binary; true-cold egg)"
    else
      log "parser_gen.c: FAIL no assemble and no archaeology seed"
      exit 1
    fi
  fi

  # Stale local gen: refresh from seed only when assemble path not authority.
  if [ "$XLANG_PARSER_FROM_X" != "1" ] || ! grep -q 'wave324 parser M4 cold assemble' parser_gen.c 2>/dev/null; then
    if ! parser_gen_contract_ok parser_gen.c; then
      if seed_ok "$seed" && parser_gen_contract_ok "$seed"; then
        cp -f "$seed" parser_gen.c
        log "parser_gen.c: local failed contract → archaeology seed"
      fi
    fi
  fi

  # Dedup slice layouts if any (legacy pin + assemble both may emit them).
  perl -i -ne 'print unless /^struct xlang_slice_uint8_t/ && $seen++' parser_gen.c 2>/dev/null || true

  if ! parser_gen_contract_ok parser_gen.c; then
    log "parser_gen.c: FAIL product contract (missing parse_expr / collect_imports / copy_module / one_function_impl)"
    exit 1
  fi
  log "parser_gen.c OK ($(bytes_of parser_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# typeck_gen.c — wave322 M4 7.4.1: prefer typeck.x assemble over pin
# ---------------------------------------------------------------------------
# Run tip -E for typeck.x into $1. Product pure NO_C rejects -E-extern; plain -E works.
# PLATFORM: SHARED — same -E face on Darwin/Linux; binary may be xlang / xlang_asm / xlang-c.
typeck_run_tip_e() {
  local out="$1"
  local b err
  err="${out}.err"
  rm -f "$out" "$err"
  for b in ${XLANG_TYPECK_E:-} xlang xlang_asm xlang-c bootstrap_xlangc; do
    [ -n "$b" ] || continue
    if [ ! -x "./$b" ] && [ ! -f "./$b" ]; then
      continue
    fi
    # Product freestanding: plain -E (not -E-extern) emits library C for typeck.x.
    if "./$b" -L .. -L src -L src/lexer -L src/ast -L src/parser \
      -E src/typeck/typeck.x >"$out" 2>"$err"; then
      if [ -s "$out" ]; then
        log "typeck tip -E via ./$b ($(bytes_of "$out") bytes)"
        return 0
      fi
    fi
  done
  return 1
}

# Assemble typeck_gen.c from tip -E + companions (G.7 body = assemble_typeck_gen_from_x.py).
typeck_assemble_from_x() {
  local tip tmp py
  tip="typeck_gen.tip_e.tmp.$$"
  tmp="typeck_gen.c.tmp.$$"
  py="${PYTHON:-python3}"
  if [ ! -f scripts/assemble_typeck_gen_from_x.py ]; then
    log "missing scripts/assemble_typeck_gen_from_x.py (wave322)"
    return 1
  fi
  if ! typeck_run_tip_e "$tip"; then
    rm -f "$tip" "$tip.err" 2>/dev/null || true
    log "typeck tip -E failed (no working product -E binary?)"
    return 1
  fi
  if ! "$py" scripts/assemble_typeck_gen_from_x.py --tip "$tip" --out "$tmp"; then
    rm -f "$tip" "$tip.err" "$tmp" 2>/dev/null || true
    return 1
  fi
  mv -f "$tmp" typeck_gen.c
  rm -f "$tip" "$tip.err" 2>/dev/null || true
  log "typeck_gen.c: assembled from typeck.x + companions (wave322 / 7.4.1)"
  return 0
}

# True when typeck.x (or companions) is newer than local typeck_gen.c → must re-assemble.
typeck_x_sources_newer_than_gen() {
  local gen="typeck_gen.c"
  local src
  [ -s "$gen" ] || return 0
  for src in \
    src/typeck/typeck.x \
    seeds/typeck_short_face_alias.from_x.c \
    seeds/typeck_cap_residual.from_x.c \
    seeds/typeck_mangle_link_alias.from_x.c \
    scripts/assemble_typeck_gen_from_x.py
  do
    if [ -f "$src" ] && [ "$src" -nt "$gen" ]; then
      return 0
    fi
  done
  return 1
}

ensure_typeck_gen() {
  local seed="seeds/typeck_gen.linux.x86_64.c"
  local need_assemble=0
  local did_assemble=0

  # wave322 / 7.4.1 policy (G.7):
  #   product authority = typeck.x + companions assemble
  #   pin seed = archaeology / true-cold egg only (no -E binary)
  # Prefer assemble when: FORCE, missing gen, .x/companions newer, or
  # XLANG_TYPECK_FROM_X=1 with no contract-ok local (stale bare -E).
  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    need_assemble=1
  elif [ ! -s typeck_gen.c ]; then
    need_assemble=1
  elif [ "$XLANG_TYPECK_FROM_X" = "1" ] && typeck_x_sources_newer_than_gen; then
    need_assemble=1
  elif [ "$XLANG_TYPECK_FROM_X" = "1" ] && ! typeck_gen_contract_ok typeck_gen.c; then
    need_assemble=1
  fi

  if [ "$need_assemble" = "1" ]; then
    if typeck_assemble_from_x; then
      did_assemble=1
    else
      if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
        if [ "$XLANG_TYPECK_ALLOW_PIN" = "1" ] && seed_ok "$seed"; then
          cp -f "$seed" typeck_gen.c
          log "typeck_gen.c: FORCE fallback archaeology seed (tip -E failed)"
        else
          log "typeck_gen.c: FAIL FORCE regen (no -E and no pin escape)"
          exit 1
        fi
      else
        log "typeck_gen.c: tip assemble unavailable; try local/pin (archaeology)"
      fi
    fi
  fi

  # Local still missing: archaeology seed (true cold, no product -E binary).
  if [ ! -s typeck_gen.c ]; then
    if [ "$XLANG_TYPECK_ALLOW_PIN" = "1" ] && seed_ok "$seed"; then
      cp -f "$seed" typeck_gen.c
      log "typeck_gen.c: restored archaeology seed $seed (no -E binary; true-cold egg)"
    else
      log "typeck_gen.c: FAIL no assemble and no archaeology seed"
      exit 1
    fi
  fi

  # Optional: if local is pre-wave322 bare pin without assemble banner, and
  # FROM_X=1, refresh from archaeology seed only when seed is newer AND we
  # did not just assemble (post-pull dual-end). Does NOT re-assert pin authority
  # over typeck.x — seed is a snapshot of last good assemble.
  if [ "$did_assemble" != "1" ] && [ "$XLANG_TYPECK_ALLOW_PIN" = "1" ]; then
    if ! typeck_gen_contract_ok typeck_gen.c; then
      if seed_ok "$seed" && typeck_gen_contract_ok "$seed"; then
        cp -f "$seed" typeck_gen.c
        log "typeck_gen.c: local failed contract → archaeology seed"
      fi
    fi
  fi

  if [ -f scripts/fix_slim_arena_gen_c.pl ]; then
    perl scripts/fix_slim_arena_gen_c.pl typeck_gen.c
  fi
  if ! typeck_gen_contract_ok typeck_gen.c; then
    log "typeck_gen.c: FAIL product contract (missing typeck_check_call_* / null_keyword / subscript)"
    exit 1
  fi
  log "typeck_gen.c OK ($(bytes_of typeck_gen.c) bytes)"
}

# ---------------------------------------------------------------------------
# codegen_gen.c — wave323 M4 7.4.2: prefer codegen.x assemble over pin
# ---------------------------------------------------------------------------
# Run tip -E for codegen.x into $1. Product pure NO_C rejects -E-extern; plain -E works.
# PLATFORM: SHARED — same -E face on Darwin/Linux; binary may be xlang / xlang_asm / xlang-c.
codegen_run_tip_e() {
  local out="$1"
  local b err
  err="${out}.err"
  rm -f "$out" "$err"
  for b in ${XLANG_CODEGEN_E:-} xlang xlang_asm xlang-c bootstrap_xlangc; do
    [ -n "$b" ] || continue
    if [ ! -x "./$b" ] && [ ! -f "./$b" ]; then
      continue
    fi
    # Product freestanding: plain -E (not -E-extern) emits library C for codegen.x.
    if "./$b" -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen \
      -E src/codegen/codegen.x >"$out" 2>"$err"; then
      if [ -s "$out" ]; then
        log "codegen tip -E via ./$b ($(bytes_of "$out") bytes)"
        return 0
      fi
    fi
  done
  return 1
}

# Assemble codegen_gen.c from tip -E + Cap residual (G.7 body = assemble_codegen_gen_from_x.py).
codegen_assemble_from_x() {
  local tip tmp py
  tip="codegen_gen.tip_e.tmp.$$"
  tmp="codegen_gen.c.tmp.$$"
  py="${PYTHON:-python3}"
  if [ ! -f scripts/assemble_codegen_gen_from_x.py ]; then
    log "missing scripts/assemble_codegen_gen_from_x.py (wave323)"
    return 1
  fi
  if ! codegen_run_tip_e "$tip"; then
    rm -f "$tip" "$tip.err" 2>/dev/null || true
    log "codegen tip -E failed (no working product -E binary?)"
    return 1
  fi
  if ! "$py" scripts/assemble_codegen_gen_from_x.py --tip "$tip" --out "$tmp"; then
    rm -f "$tip" "$tip.err" "$tmp" 2>/dev/null || true
    return 1
  fi
  mv -f "$tmp" codegen_gen.c
  rm -f "$tip" "$tip.err" 2>/dev/null || true
  log "codegen_gen.c: assembled from codegen.x + Cap residual (wave323 / 7.4.2)"
  return 0
}

# True when codegen.x (or companions) is newer than local codegen_gen.c → must re-assemble.
codegen_x_sources_newer_than_gen() {
  local gen="codegen_gen.c"
  local src
  [ -s "$gen" ] || return 0
  for src in \
    src/codegen/codegen.x \
    seeds/codegen_cap_residual.from_x.c \
    scripts/assemble_codegen_gen_from_x.py
  do
    if [ -f "$src" ] && [ "$src" -nt "$gen" ]; then
      return 0
    fi
  done
  return 1
}

ensure_codegen_gen() {
  local seed="seeds/codegen_gen.linux.x86_64.c"
  local need_assemble=0
  local did_assemble=0

  # wave323 / 7.4.2 policy (G.7):
  #   product authority = codegen.x + Cap residual assemble
  #   pin seed = archaeology / true-cold egg only (no -E binary)
  if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
    need_assemble=1
  elif [ ! -s codegen_gen.c ]; then
    need_assemble=1
  elif [ "$XLANG_CODEGEN_FROM_X" = "1" ] && codegen_x_sources_newer_than_gen; then
    need_assemble=1
  elif [ "$XLANG_CODEGEN_FROM_X" = "1" ] && ! codegen_gen_contract_ok codegen_gen.c; then
    need_assemble=1
  fi

  if [ "$need_assemble" = "1" ]; then
    if codegen_assemble_from_x; then
      did_assemble=1
    else
      if [ "$XLANG_FORCE_REGEN_GEN" = "1" ]; then
        if [ "$XLANG_CODEGEN_ALLOW_PIN" = "1" ] && seed_ok "$seed"; then
          cp -f "$seed" codegen_gen.c
          log "codegen_gen.c: FORCE fallback archaeology seed (tip -E failed)"
        else
          log "codegen_gen.c: FAIL FORCE regen (no -E and no pin escape)"
          exit 1
        fi
      else
        log "codegen_gen.c: tip assemble unavailable; try local/pin (archaeology)"
      fi
    fi
  fi

  if [ ! -s codegen_gen.c ]; then
    if [ "$XLANG_CODEGEN_ALLOW_PIN" = "1" ] && seed_ok "$seed"; then
      cp -f "$seed" codegen_gen.c
      log "codegen_gen.c: restored archaeology seed $seed (no -E binary; true-cold egg)"
    else
      log "codegen_gen.c: FAIL no assemble and no archaeology seed"
      exit 1
    fi
  fi

  # Stale local without assemble this run: allow archaeology pin restore if contract fails.
  if [ "$did_assemble" != "1" ] && [ "$XLANG_CODEGEN_ALLOW_PIN" = "1" ]; then
    if ! codegen_gen_contract_ok codegen_gen.c; then
      if seed_ok "$seed" && codegen_gen_contract_ok "$seed"; then
        cp -f "$seed" codegen_gen.c
        log "codegen_gen.c: local failed contract → archaeology seed"
      fi
    fi
  fi

  if [ -f scripts/fix_slim_arena_gen_c.pl ]; then
    perl scripts/fix_slim_arena_gen_c.pl codegen_gen.c
  fi
  if ! codegen_gen_contract_ok codegen_gen.c; then
    log "codegen_gen.c: FAIL product contract (missing emit_expr / x_ast / host_call / loop residual)"
    exit 1
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
    if refresh_gen_from_seed_if_stale lexer_gen.c "$seed" lexer_gen_contract_ok lexer_gen.c; then
      :
    else
      log "lexer_gen.c: pinned ($(bytes_of lexer_gen.c) bytes; XLANG_FORCE_REGEN_GEN=1 to regen)"
    fi
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
  if ! lexer_gen_contract_ok lexer_gen.c; then
    log "lexer_gen.c: FAIL product contract (missing advance_one / invalid_type_suffix_reset / note_string_lit_overflow)"
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
Env: XLANG_FORCE_REGEN_GEN=1 XLANG_PARSER_GEN_TIMEOUT XLANG_C XLANG_X
EOF
    ;;
  *)
    log "unknown mode: $MODE (use all|all-frontend|parser|typeck|codegen|lexer)"
    exit 2
    ;;
esac

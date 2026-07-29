#!/usr/bin/env bash
# ensure_host_cc_seed_o.sh — R1 host-cc seed/from_x → .o single body
#   wave748: first family RT_SEED_SLICE
#   wave749: second family R1_CORE_SEED (diag / link_abi / c_import / bridge / seed_link_compat)
#   wave750: third family R1_FRONTEND_GLUE (lexer/ast/lsp basename-mismatch map)
#   wave751: fourth family R1_MAIN_RUNTIME (main/runtime multi-flag variants)
#   wave752: fifth family R1_ALIAS_STUBS (link alias / bare / compat stubs)
#   wave753: sixth family R1_EXTRA_CFLAGS (pipeline_abi / -fPIE / sqlite multi-flag /
#            parser link-alias extras)
#   wave754: seventh family R1_MISC_BASENAME (misc pure basename host-cc:
#            channel/kv/scheduler glue, backend enc, lsp ctx, pipeline_glue
#            strict_minimal, runtime_asm_build, link_abi_user_env)
#   wave755: eighth family R1_SEED_MAP (basename-mismatch + orch -D:
#            target_cpu_pure → target_cpu.o, runtime_ast_glue → ast_seed.o,
#            pipeline_bootstrap_orchestration + -Ibuild_asm -D)
#   wave756: R4 pure-R1 body helper — `try-r1 OUT` resolves OUT against the
#            eight catalog KEY memberships (G.7 lists stay mk) and runs the
#            same ensure_one body. Used by rebuild_leaves so pure R1 leaves
#            leave the make pattern graph; non-members exit 3 (caller make).
#
# Authority (G.7):
#   Single shell *recipe body* for pure host-cc compile of seeds/*.from_x.c → .o.
#   Object *lists* stay in Makefile / mk (catalog export keys).
#   This script never hardcodes a second product .o inventory as authority.
#   Seed / flag path conventions (not .o lists):
#     basename match:  <dir>/<leaf>.o  ←  seeds/<leaf>.from_x.c
#     frontend-glue:   fixed o→seed map (leaf stem ≠ seed stem)
#     main-runtime:    o→seed map (main_* ← main; runtime_* ← runtime) +
#                      o→extra -D flags (thin Makefile passes expanded make vars)
#     alias-stubs:     basename match (same as core-seed / rt-slice)
#     extra-cflags:    o→seed map (sqlite_stub shares sqlite seed) +
#                      o→extra flags (-D / -fPIE; thin passes make vars)
#     misc-basename:   basename match (same as alias-stubs / core-seed)
#     seed-map:        o→seed map (stem ≠ seed stem) + optional orch extras
#
# Families (list authority = catalog KEY):
#   RT_SEED_SLICE_OBJS     — five Cap residual slices under src/runtime/
#   R1_CORE_SEED_OBJS      — diag + runtime_link_abi + runtime_c_import +
#                            x_seed_bridge + seed_link_compat
#   R1_FRONTEND_GLUE_OBJS  — lexer.o / ast.o / lsp_diag.o (runtime_*_glue seeds)
#   R1_MAIN_RUNTIME_OBJS   — main / main_x / main_driver / runtime / runtime_x /
#                            runtime_driver / runtime_driver_no_c
#   R1_ALIAS_STUBS_OBJS    — x_frontend_link_alias + bare aliases + typeck stubs +
#                            user_asm_seed_bridge + asm_backend_compat_stubs +
#                            runtime_driver_strict_glue_stubs
#   R1_EXTRA_CFLAGS_OBJS   — runtime_pipeline_abi + runtime_asm_io_stubs (-fPIE) +
#                            runtime_sqlite_glue[+_stub] + parser_asm_parse_expr_link
#   R1_MISC_BASENAME_OBJS  — pure basename host-cc without special -D/-f extras
#                            (glue/enc/ctx/pipeline_glue_strict_minimal/asm_build/…)
#   R1_SEED_MAP_OBJS       — basename-mismatch + bootstrap orch extras
#                            (target_cpu / ast_seed / pipeline_bootstrap_orchestration)
#
# Not in scope (honest residual):
#   - R3 thin+rest / PREFER_X_O product g05 path (g05_ensure keeps that)
#   - R2 UNAME stamps, R4 non-R1 rebuild residual (panic/gen/thin+rest), R5 CI all
#   - pure-ld (11.1.4) · physical Makefile delete (11.3.1)
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_host_cc_seed_o.sh one <out.o> <seed.from_x.c> [extra cflags...]
#   bash scripts/ensure_host_cc_seed_o.sh try-r1 <out.o>   # wave756 R4 pure-R1 helper
#   bash scripts/ensure_host_cc_seed_o.sh rt-slice          # RT_SEED_SLICE family
#   bash scripts/ensure_host_cc_seed_o.sh core-seed         # R1_CORE_SEED family
#   bash scripts/ensure_host_cc_seed_o.sh frontend-glue     # R1_FRONTEND_GLUE family
#   bash scripts/ensure_host_cc_seed_o.sh main-runtime      # R1_MAIN_RUNTIME family
#   bash scripts/ensure_host_cc_seed_o.sh alias-stubs       # R1_ALIAS_STUBS family
#   bash scripts/ensure_host_cc_seed_o.sh extra-cflags      # R1_EXTRA_CFLAGS family
#   bash scripts/ensure_host_cc_seed_o.sh misc-basename     # R1_MISC_BASENAME family
#   bash scripts/ensure_host_cc_seed_o.sh seed-map          # R1_SEED_MAP family
#   bash scripts/ensure_host_cc_seed_o.sh all               # all swallowed families
#   bash scripts/ensure_host_cc_seed_o.sh --check
#   bash scripts/ensure_host_cc_seed_o.sh seed-map --force
#   ./xbuild host-cc-seed | … | misc-basename | seed-map
#
# Env:
#   CC — host compiler (default: cc; honor caller CC)
#   CFLAGS — base flags (default: -Wall -Wextra -I. -Iinclude -Isrc)
#   PIPELINE_GEN_CFLAGS — optional silence flags (Makefile exports when thin)
#   RUNTIME_DRIVER_CFLAGS / RUNTIME_DRIVER_NO_C_CFLAGS — multi-flag variants
#   RUNTIME_PIPELINE_ABI_CFLAGS / PARSER_ASM_LINK_ALIAS_CFLAGS — extra-cflags family
#     (Makefile thin expands make vars; family mode uses env or defaults below)
#   XLANG_HOST_CC_SEED_FORCE=1 — force recompile (same as --force)
#   MAKE — only for catalog list expansion (default: make)
#
# PLATFORM: SHARED — shell orchestration; seed pins host-portable C.
# Wave: 748–756 Track MG · 11.3.1 R1 families + R4 pure-R1 body (not physical delete · not pure-ld).

set -euo pipefail
cd "$(dirname "$0")/.."

CC="${CC:-cc}"
# Match g05 / Makefile product includes; PIPELINE_GEN_CFLAGS optional (Makefile thin).
BASE_CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
PIPELINE_GEN_CFLAGS="${PIPELINE_GEN_CFLAGS:-}"
MAKE="${MAKE:-make}"
FORCE="${XLANG_HOST_CC_SEED_FORCE:-0}"

# Default multi-flag mirrors for family mode when env empty.
# PLATFORM: SHARED — must stay aligned with Makefile RUNTIME_DRIVER_*_CFLAGS
# (without optional XLANG_LEGACY_PREPROCESS_C). Thin leaves pass make-expanded vars.
_DEFAULT_RT_SLICE_CFLAGS="-DXLANG_RT_ARENA_BUF_FROM_X -DXLANG_RT_EMIT_STATE_FROM_X -DXLANG_RT_PREAMBLE_FROM_X -DXLANG_RT_STACK_FROM_X -DXLANG_RT_PARSE_DIAG_FROM_X"
_DEFAULT_RUNTIME_DRIVER_CFLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C ${_DEFAULT_RT_SLICE_CFLAGS}"
_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C ${_DEFAULT_RT_SLICE_CFLAGS}"
# PLATFORM: SHARED — defaults aligned with Makefile (without optional LEGACY).
_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS="-DXLANG_USE_X_PIPELINE"
_DEFAULT_PARSER_ASM_LINK_ALIAS_CFLAGS="-DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS"

MODE="${1:-}"
if [ -z "$MODE" ]; then
  echo "ensure_host_cc_seed_o: usage: one|try-r1|rt-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map|all|--check  (see header)" >&2
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
    # Sibling .x deps: out path stem, seed-stem under src/asm or src/,
    # and main_c_entry.x for main family (Makefile dep name).
    local need=0
    local xsrc stem cand
    xsrc="${out%.o}.x"
    if [ -f "$xsrc" ] && [ "$xsrc" -nt "$out" ]; then
      need=1
    fi
    stem="$(basename "$seed" .from_x.c)"
    for cand in "src/asm/${stem}.x" "src/${stem}.x" "src/main_c_entry.x"; do
      if [ -f "$cand" ] && [ "$cand" -nt "$out" ]; then
        need=1
        break
      fi
    done
    if [ "$need" -eq 0 ]; then
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

# seed convention (basename match): basename of .o → seeds/<basename>.from_x.c
seed_for_o() {
  local o="$1"
  local base
  base="$(basename "$o" .o)"
  printf 'seeds/%s.from_x.c\n' "$base"
}

# seed convention (frontend-glue basename mismatch): o path → seed path.
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
# Not a second .o inventory: unknown catalog members fail closed.
seed_for_frontend_glue() {
  local o="$1"
  case "$o" in
    src/lexer/lexer.o)   printf 'seeds/runtime_lexer_glue.from_x.c\n' ;;
    src/ast/ast.o)       printf 'seeds/runtime_ast_glue.from_x.c\n' ;;
    src/lsp/lsp_diag.o)  printf 'seeds/runtime_lsp_glue.from_x.c\n' ;;
    *)
      echo "ensure_host_cc_seed_o: no frontend-glue seed map for $o" >&2
      exit 1
      ;;
  esac
}

# seed convention (main-runtime multi-out from shared seeds).
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
seed_for_main_runtime() {
  local o="$1"
  case "$o" in
    src/main.o|src/main_x.o|src/main_driver.o)
      printf 'seeds/main.from_x.c\n'
      ;;
    src/runtime.o|src/runtime_x.o|src/runtime_driver.o|src/runtime_driver_no_c.o)
      printf 'seeds/runtime.from_x.c\n'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no main-runtime seed map for $o" >&2
      exit 1
      ;;
  esac
}

# Extra -D flags for main-runtime family (stdout, space-separated; may be empty).
# Thin Makefile leaves pass make-expanded vars as extras to `one` (authority).
# Family mode: use env when set, else defaults aligned with Makefile base flags.
extras_for_main_runtime() {
  local o="$1"
  case "$o" in
    src/main.o|src/runtime.o)
      ;;
    src/main_x.o|src/runtime_x.o)
      printf '%s' '-DXLANG_USE_X_PIPELINE'
      ;;
    src/main_driver.o)
      printf '%s' '-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE'
      ;;
    src/runtime_driver.o)
      if [ -n "${RUNTIME_DRIVER_CFLAGS:-}" ]; then
        printf '%s' "$RUNTIME_DRIVER_CFLAGS"
      else
        printf '%s' "$_DEFAULT_RUNTIME_DRIVER_CFLAGS"
      fi
      ;;
    src/runtime_driver_no_c.o)
      if [ -n "${RUNTIME_DRIVER_NO_C_CFLAGS:-}" ]; then
        printf '%s' "$RUNTIME_DRIVER_NO_C_CFLAGS"
      else
        printf '%s' "$_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS"
      fi
      ;;
    *)
      echo "ensure_host_cc_seed_o: no main-runtime extras map for $o" >&2
      exit 1
      ;;
  esac
}

# seed convention (extra-cflags: basename + multi-out sqlite stub).
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
seed_for_extra_cflags() {
  local o="$1"
  case "$o" in
    runtime_sqlite_glue_stub.o)
      printf 'seeds/runtime_sqlite_glue.from_x.c\n'
      ;;
    src/runtime_pipeline_abi.o|runtime_asm_io_stubs.o|runtime_sqlite_glue.o|src/asm/parser_asm_parse_expr_link.o)
      seed_for_o "$o"
      ;;
    *)
      echo "ensure_host_cc_seed_o: no extra-cflags seed map for $o" >&2
      exit 1
      ;;
  esac
}

# Extra flags for extra-cflags family (stdout, space-separated; may be empty).
# Thin Makefile leaves pass make-expanded vars as extras to `one` (authority).
# Family mode: use env when set, else defaults aligned with Makefile base flags.
extras_for_extra_cflags() {
  local o="$1"
  case "$o" in
    src/runtime_pipeline_abi.o)
      if [ -n "${RUNTIME_PIPELINE_ABI_CFLAGS:-}" ]; then
        printf '%s' "$RUNTIME_PIPELINE_ABI_CFLAGS"
      else
        printf '%s' "$_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS"
      fi
      ;;
    runtime_asm_io_stubs.o)
      printf '%s' '-fPIE'
      ;;
    runtime_sqlite_glue.o)
      printf '%s' '-DXLANG_DB_USE_SQLITE3'
      ;;
    runtime_sqlite_glue_stub.o)
      ;;
    src/asm/parser_asm_parse_expr_link.o)
      if [ -n "${PARSER_ASM_LINK_ALIAS_CFLAGS:-}" ]; then
        printf '%s' "$PARSER_ASM_LINK_ALIAS_CFLAGS"
      else
        printf '%s' "$_DEFAULT_PARSER_ASM_LINK_ALIAS_CFLAGS"
      fi
      ;;
    *)
      echo "ensure_host_cc_seed_o: no extra-cflags extras map for $o" >&2
      exit 1
      ;;
  esac
}


# seed convention (seed-map: basename mismatch + orch basename).
# PLATFORM: SHARED — map is path convention only; list authority = catalog KEY.
# Not a second .o inventory: unknown catalog members fail closed.
seed_for_seed_map() {
  local o="$1"
  case "$o" in
    src/driver/target_cpu.o)
      printf 'seeds/target_cpu_pure.from_x.c\n'
      ;;
    src/ast/ast_seed.o)
      printf 'seeds/runtime_ast_glue.from_x.c\n'
      ;;
    pipeline_bootstrap_orchestration.o)
      printf 'seeds/pipeline_bootstrap_orchestration.from_x.c\n'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no seed-map seed map for $o" >&2
      exit 1
      ;;
  esac
}

# Extra flags for seed-map family (stdout, space-separated; may be empty).
# Thin Makefile leaves pass make-expanded extras to `one` (authority).
# Family mode: orch needs -Ibuild_asm + -D; target_cpu/ast_seed pure base.
extras_for_seed_map() {
  local o="$1"
  case "$o" in
    src/driver/target_cpu.o|src/ast/ast_seed.o)
      ;;
    pipeline_bootstrap_orchestration.o)
      printf '%s' '-Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no seed-map extras map for $o" >&2
      exit 1
      ;;
  esac
}

# Ensure every .o in catalog KEY via pure host-cc body.
# $1=KEY $2=label $3=seed_mode (basename|frontend-glue|main-runtime|extra-cflags|seed-map)
ensure_catalog_family() {
  local key="$1"
  local label="$2"
  local seed_mode="${3:-basename}"
  local list n=0 o seed extras_str
  list="$(catalog_key_list "$key")"
  # Word-split intentionally (space-separated make expansion).
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    case "$seed_mode" in
      basename) seed="$(seed_for_o "$o")" ;;
      frontend-glue) seed="$(seed_for_frontend_glue "$o")" ;;
      main-runtime) seed="$(seed_for_main_runtime "$o")" ;;
      extra-cflags) seed="$(seed_for_extra_cflags "$o")" ;;
      seed-map) seed="$(seed_for_seed_map "$o")" ;;
      *)
        echo "ensure_host_cc_seed_o: unknown seed_mode $seed_mode" >&2
        exit 2
        ;;
    esac
    extras_str=""
    case "$seed_mode" in
      main-runtime) extras_str="$(extras_for_main_runtime "$o")" ;;
      extra-cflags) extras_str="$(extras_for_extra_cflags "$o")" ;;
      seed-map) extras_str="$(extras_for_seed_map "$o")" ;;
    esac
    if [ -n "$extras_str" ]; then
      # shellcheck disable=SC2086
      ensure_one "$o" "$seed" $extras_str
    else
      ensure_one "$o" "$seed"
    fi
    n=$((n + 1))
  done
  log "$label OK ($n objs via catalog $key)"
}

ensure_rt_slice() {
  ensure_catalog_family "RT_SEED_SLICE_OBJS" "rt-slice" "basename"
}

ensure_core_seed() {
  ensure_catalog_family "R1_CORE_SEED_OBJS" "core-seed" "basename"
}

ensure_frontend_glue() {
  ensure_catalog_family "R1_FRONTEND_GLUE_OBJS" "frontend-glue" "frontend-glue"
}

ensure_main_runtime() {
  ensure_catalog_family "R1_MAIN_RUNTIME_OBJS" "main-runtime" "main-runtime"
}

ensure_alias_stubs() {
  # Basename convention — same seed_mode as core-seed / rt-slice.
  ensure_catalog_family "R1_ALIAS_STUBS_OBJS" "alias-stubs" "basename"
}

ensure_extra_cflags() {
  # Multi-flag / multi-out pure host-cc (pipeline_abi, -fPIE, sqlite, parser link).
  ensure_catalog_family "R1_EXTRA_CFLAGS_OBJS" "extra-cflags" "extra-cflags"
}

ensure_misc_basename() {
  # Pure basename host-cc without special extras (glue / enc / ctx / pipeline_glue / …).
  ensure_catalog_family "R1_MISC_BASENAME_OBJS" "misc-basename" "basename"
}

ensure_seed_map() {
  # Basename-mismatch + orch -D pure host-cc (target_cpu / ast_seed / orch).
  ensure_catalog_family "R1_SEED_MAP_OBJS" "seed-map" "seed-map"
}

ensure_all_swallowed() {
  ensure_rt_slice
  ensure_core_seed
  ensure_frontend_glue
  ensure_main_runtime
  ensure_alias_stubs
  ensure_extra_cflags
  ensure_misc_basename
  ensure_seed_map
  log "all swallowed R1 families OK (rt-slice + core-seed + frontend-glue + main-runtime + alias-stubs + extra-cflags + misc-basename + seed-map)"
}

# ---------------------------------------------------------------------------
# wave756: try-r1 OUT — pure R1 body for R4 rebuild without hardcoding .o lists.
#
# Resolve OUT by *membership* in catalog KEY families (lists = mk only).
# Exit codes:
#   0 — OUT is pure R1; ensure_one ran (or skipped up-to-date)
#   3 — OUT not in any R1 catalog family (caller should use make residual)
#   1 — membership found but ensure failed / catalog error
# PLATFORM: SHARED — same host-cc body as family modes; no dual recipe.
# ---------------------------------------------------------------------------
_catalog_blob_cache=""
catalog_blob() {
  if [ -z "$_catalog_blob_cache" ]; then
    if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
      echo "ensure_host_cc_seed_o: missing scripts/driver_seed_obj_catalog.sh" >&2
      exit 1
    fi
    _catalog_blob_cache="$(MAKE="$MAKE" bash scripts/driver_seed_obj_catalog.sh)"
  fi
  printf '%s\n' "$_catalog_blob_cache"
}

catalog_key_words() {
  # $1 = KEY — print space-separated words from cached catalog blob
  local key="$1"
  local line
  line="$(catalog_blob | sed -n "s/^${key}=//p" | head -1)"
  printf '%s\n' "$line"
}

list_has_word() {
  # $1=needle $2=space-separated list
  local needle="$1"
  local list="$2"
  local w
  # shellcheck disable=SC2086
  for w in $list; do
    [ "$w" = "$needle" ] && return 0
  done
  return 1
}

# Print seed_mode for OUT if member of any pure R1 family; else return 1.
# Order: specific maps first (seed-map / frontend-glue / main-runtime / extra-cflags),
# then basename families. KEY membership only — no second .o inventory.
r1_seed_mode_for_o() {
  local o="$1"
  local list
  list="$(catalog_key_words "R1_SEED_MAP_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "seed-map"
    return 0
  fi
  list="$(catalog_key_words "R1_FRONTEND_GLUE_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "frontend-glue"
    return 0
  fi
  list="$(catalog_key_words "R1_MAIN_RUNTIME_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "main-runtime"
    return 0
  fi
  list="$(catalog_key_words "R1_EXTRA_CFLAGS_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "extra-cflags"
    return 0
  fi
  list="$(catalog_key_words "RT_SEED_SLICE_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  list="$(catalog_key_words "R1_CORE_SEED_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  list="$(catalog_key_words "R1_ALIAS_STUBS_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  list="$(catalog_key_words "R1_MISC_BASENAME_OBJS")"
  if list_has_word "$o" "$list"; then
    printf '%s\n' "basename"
    return 0
  fi
  return 1
}

try_ensure_r1_one() {
  local o="$1"
  local seed_mode seed extras_str
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r1: need <out.o>" >&2
    exit 2
  fi
  if ! seed_mode="$(r1_seed_mode_for_o "$o")"; then
    # Not pure R1 — honest residual for R2/R3/gen/etc.
    return 3
  fi
  case "$seed_mode" in
    basename) seed="$(seed_for_o "$o")" ;;
    frontend-glue) seed="$(seed_for_frontend_glue "$o")" ;;
    main-runtime) seed="$(seed_for_main_runtime "$o")" ;;
    extra-cflags) seed="$(seed_for_extra_cflags "$o")" ;;
    seed-map) seed="$(seed_for_seed_map "$o")" ;;
    *)
      echo "ensure_host_cc_seed_o try-r1: unknown seed_mode $seed_mode for $o" >&2
      exit 1
      ;;
  esac
  extras_str=""
  case "$seed_mode" in
    main-runtime) extras_str="$(extras_for_main_runtime "$o")" ;;
    extra-cflags) extras_str="$(extras_for_extra_cflags "$o")" ;;
    seed-map) extras_str="$(extras_for_seed_map "$o")" ;;
  esac
  if [ -n "$extras_str" ]; then
    # shellcheck disable=SC2086
    ensure_one "$o" "$seed" $extras_str
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

# ---------------------------------------------------------------------------
# --check: wiring + catalog keys + convention (no full compile required)
# ---------------------------------------------------------------------------
check_family() {
  # $1=KEY $2=min_count $3=label $4=seed_mode $5=optional path prefix pattern
  local key="$1"
  local min_n="$2"
  local label="$3"
  local seed_mode="${4:-basename}"
  local path_pfx="${5:-}"
  local list n=0 o seed
  if ! list="$(catalog_key_list "$key" 2>/dev/null)"; then
    bad "catalog cannot expand $key (add export key)"
    return
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    n=$((n + 1))
    case "$seed_mode" in
      basename) seed="$(seed_for_o "$o")" ;;
      frontend-glue)
        if ! seed="$(seed_for_frontend_glue "$o" 2>/dev/null)"; then
          bad "frontend-glue map missing for catalog member $o"
          continue
        fi
        ;;
      main-runtime)
        if ! seed="$(seed_for_main_runtime "$o" 2>/dev/null)"; then
          bad "main-runtime map missing for catalog member $o"
          continue
        fi
        # extras map must also resolve (fail closed)
        if ! extras_for_main_runtime "$o" >/dev/null 2>&1; then
          bad "main-runtime extras map missing for catalog member $o"
        fi
        ;;
      extra-cflags)
        if ! seed="$(seed_for_extra_cflags "$o" 2>/dev/null)"; then
          bad "extra-cflags map missing for catalog member $o"
          continue
        fi
        if ! extras_for_extra_cflags "$o" >/dev/null 2>&1; then
          bad "extra-cflags extras map missing for catalog member $o"
        fi
        ;;
      seed-map)
        if ! seed="$(seed_for_seed_map "$o" 2>/dev/null)"; then
          bad "seed-map map missing for catalog member $o"
          continue
        fi
        if ! extras_for_seed_map "$o" >/dev/null 2>&1; then
          bad "seed-map extras map missing for catalog member $o"
        fi
        ;;
      *) bad "unknown seed_mode $seed_mode for $label"; continue ;;
    esac
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
  if ! grep -q 'R1_FRONTEND_GLUE_OBJS' Makefile \
    && ! grep -q 'R1_FRONTEND_GLUE_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_FRONTEND_GLUE_OBJS not defined in Makefile/mk (wave750)"
  fi
  if ! grep -q 'R1_MAIN_RUNTIME_OBJS' Makefile \
    && ! grep -q 'R1_MAIN_RUNTIME_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_MAIN_RUNTIME_OBJS not defined in Makefile/mk (wave751)"
  fi
  if ! grep -q 'R1_ALIAS_STUBS_OBJS' Makefile \
    && ! grep -q 'R1_ALIAS_STUBS_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_ALIAS_STUBS_OBJS not defined in Makefile/mk (wave752)"
  fi
  if ! grep -q 'R1_EXTRA_CFLAGS_OBJS' Makefile \
    && ! grep -q 'R1_EXTRA_CFLAGS_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_EXTRA_CFLAGS_OBJS not defined in Makefile/mk (wave753)"
  fi
  if ! grep -q 'R1_MISC_BASENAME_OBJS' Makefile \
    && ! grep -q 'R1_MISC_BASENAME_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_MISC_BASENAME_OBJS not defined in Makefile/mk (wave754)"
  fi
  if ! grep -q 'R1_SEED_MAP_OBJS' Makefile \
    && ! grep -q 'R1_SEED_MAP_OBJS' mk/*.mk 2>/dev/null; then
    bad "R1_SEED_MAP_OBJS not defined in Makefile/mk (wave755)"
  fi

  check_family "RT_SEED_SLICE_OBJS" 5 "rt-slice" "basename" "src/runtime/"
  check_family "R1_CORE_SEED_OBJS" 5 "core-seed" "basename" "src/"
  check_family "R1_FRONTEND_GLUE_OBJS" 3 "frontend-glue" "frontend-glue" "src/"
  check_family "R1_MAIN_RUNTIME_OBJS" 7 "main-runtime" "main-runtime" "src/"
  # alias-stubs: mixed cwd-root and src/ paths; no single path prefix.
  check_family "R1_ALIAS_STUBS_OBJS" 8 "alias-stubs" "basename" ""
  # extra-cflags: mixed paths; multi-flag map.
  check_family "R1_EXTRA_CFLAGS_OBJS" 5 "extra-cflags" "extra-cflags" ""
  # misc-basename: mixed cwd-root / src/ / build_asm/ paths; pure basename.
  check_family "R1_MISC_BASENAME_OBJS" 9 "misc-basename" "basename" ""
  # seed-map: mismatch stems + orch extras.
  check_family "R1_SEED_MAP_OBJS" 3 "seed-map" "seed-map" ""

  # Makefile thin: recipes must call this script (not inline $(CC) -c for swallowed leaves)
  if ! grep -q 'ensure_host_cc_seed_o\.sh' Makefile; then
    bad "Makefile must thin-call ensure_host_cc_seed_o.sh for R1 families"
  else
    note "Makefile thin-call present"
  fi
  # Core-seed leaves must not keep inline $(CC) -c recipes (thin only).
  if grep -A1 -E '^(src/diag\.o|src/runtime_link_abi\.o|src/runtime_c_import\.o|src/x_seed_bridge\.o|src/seed_link_compat\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile core-seed leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile core-seed leaves thin (no inline \$(CC) -c)"
  fi
  # Frontend-glue leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(src/lexer/lexer\.o|src/ast/ast\.o|src/lsp/lsp_diag\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile frontend-glue leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile frontend-glue leaves thin (no inline \$(CC) -c)"
  fi
  # Main-runtime leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(src/main\.o|src/main_x\.o|src/main_driver\.o|src/runtime\.o|src/runtime_x\.o|src/runtime_driver\.o|src/runtime_driver_no_c\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile main-runtime leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile main-runtime leaves thin (no inline \$(CC) -c)"
  fi
  # Alias-stubs leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(x_frontend_link_alias\.o|ast_asm_bare_link_alias\.o|backend_asm_bare_link_alias\.o|backend_asm_strict_fallback_alias\.o|typeck_c_module_stubs\.o|src/asm/user_asm_seed_bridge\.o|src/asm/asm_backend_compat_stubs\.o|src/runtime_driver_strict_glue_stubs\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile alias-stubs leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile alias-stubs leaves thin (no inline \$(CC) -c)"
  fi
  # Extra-cflags leaves must not keep inline $(CC) -c recipes.
  if grep -A1 -E '^(src/runtime_pipeline_abi\.o|runtime_asm_io_stubs\.o|runtime_sqlite_glue\.o|runtime_sqlite_glue_stub\.o|src/asm/parser_asm_parse_expr_link\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile extra-cflags leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile extra-cflags leaves thin (no inline \$(CC) -c)"
  fi
  # Misc-basename leaves must not keep inline $(CC) -c recipes.
  if grep -A2 -E '^(runtime_link_abi_user_env\.o|runtime_channel_glue\.o|runtime_scheduler_glue\.o|runtime_kv_mmap_glue\.o|src/asm/backend_x86_64_enc_c\.o|src/asm/backend_arm64_enc_c\.o|src/lsp/lsp_diag_pipeline_ctx\.o|build_asm/pipeline_glue_strict_minimal\.o|src/asm/runtime_asm_build\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile misc-basename leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile misc-basename leaves thin (no inline \$(CC) -c)"
  fi
  # Seed-map leaves must not keep inline $(CC) -c recipes.
  if grep -A2 -E '^(src/driver/target_cpu\.o|src/ast/ast_seed\.o|pipeline_bootstrap_orchestration\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile seed-map leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile seed-map leaves thin (no inline \$(CC) -c)"
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
  if grep -nE '^(export )?R1_FRONTEND_GLUE_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_FRONTEND_GLUE_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_MAIN_RUNTIME_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_MAIN_RUNTIME_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_ALIAS_STUBS_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_ALIAS_STUBS_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_EXTRA_CFLAGS_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_EXTRA_CFLAGS_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_MISC_BASENAME_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_MISC_BASENAME_OBJS= in shell body"
  fi
  if grep -nE '^(export )?R1_SEED_MAP_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R1_SEED_MAP_OBJS= in shell body"
  fi

  if [ "$fail" -ne 0 ]; then
    echo "ensure_host_cc_seed_o: --check FAILED" >&2
    exit 1
  fi
  # wave756: try-r1 entry must exist (R4 pure-R1 body helper)
  if ! grep -q 'try_ensure_r1_one\|try-r1' "$0"; then
    bad "try-r1 / try_ensure_r1_one missing (wave756 R4 pure-R1)"
  else
    note "try-r1 pure-R1 helper present (wave756)"
  fi

  echo "ensure_host_cc_seed_o: CHECK OK (R1 rt-seed-slice + core-seed + frontend-glue + main-runtime + alias-stubs + extra-cflags + misc-basename + seed-map · try-r1 · wave748–756)" >&2
}

case "$MODE" in
  one)
    if [ "$#" -lt 2 ]; then
      echo "ensure_host_cc_seed_o one: need <out.o> <seed.from_x.c> [extra...]" >&2
      exit 2
    fi
    ensure_one "$@"
    ;;
  try-r1|try_r1|one-r1|r1-one)
    # wave756: R4 pure-R1 helper — exit 3 if not pure R1 catalog member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r1: need <out.o>" >&2
      exit 2
    fi
    # Drop trailing --force tokens already handled via FORCE global.
    _try_out="$1"
    set +e
    try_ensure_r1_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  rt-slice|rt_slice|rt-seed-slice|family=rt_seed_slice)
    ensure_rt_slice
    ;;
  core-seed|core_seed|core|r1-core|r1-core-seed|family=r1_core_seed)
    ensure_core_seed
    ;;
  frontend-glue|frontend_glue|glue|r1-frontend-glue|r1-glue|family=r1_frontend_glue)
    ensure_frontend_glue
    ;;
  main-runtime|main_runtime|r1-main-runtime|r1-main|family=r1_main_runtime)
    ensure_main_runtime
    ;;
  alias-stubs|alias_stubs|r1-alias-stubs|r1-alias|family=r1_alias_stubs)
    ensure_alias_stubs
    ;;
  extra-cflags|extra_cflags|r1-extra-cflags|r1-extra|pipeline-abi|family=r1_extra_cflags)
    ensure_extra_cflags
    ;;
  misc-basename|misc_basename|misc|r1-misc-basename|r1-misc|family=r1_misc_basename)
    ensure_misc_basename
    ;;
  seed-map|seed_map|r1-seed-map|r1-mismatch|mismatch|family=r1_seed_map)
    ensure_seed_map
    ;;
  all|family|families|swallowed)
    # Umbrella: all swallowed pure R1 families on this body.
    ensure_all_swallowed
    ;;
  --check|check|-c)
    run_check
    ;;
  help|-h|--help)
    sed -n '2,75p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "ensure_host_cc_seed_o: unknown mode '$MODE' (one|try-r1|rt-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map|all|--check)" >&2
    exit 2
    ;;
esac

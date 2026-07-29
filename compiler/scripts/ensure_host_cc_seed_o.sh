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
#   wave757: R3 cold-else body helper — `try-r3-cold OUT` resolves OUT against
#            catalog R3_COLD_SEED_OBJS (thin+rest leaves whose cold path is
#            pure basename host-cc). Same ensure_one body; exit 3 if not member.
#            rebuild_leaves residual uses this before make.
#   wave763: R3 PREFER thin+rest product path — `try-r3-prefer OUT` (same catalog
#            R3_COLD_SEED_OBJS; G.7 有则补全, no new list). When
#            XLANG_G05_PREFER_X_O=1 and xlang-c works: thin.x|-E → thin.o +
#            seed rest (-D FROM_X) → ld -r. Else / fail → ensure_one cold seed
#            (same body as try-r3-cold). Makefile nine leaves thin-call this
#            helper (no inline thin+rest recipe). simd_enc/loop keep nm symbol
#            gates.
#   wave764: G.7 g05 dual-hybrid swallow — same try-r3-prefer body owns product
#            daily path for R3_COLD nine (g05_ensure thin-calls r3-prefer-family).
#            Leaf map gains optional full.x first ladder (simd/backend R2 full
#            surface H=0; fail → thin; fail → cold).
#   wave765: G.7 g05 labi multi-slice swallow — `try-labi-prefer OUT` for
#            src/runtime_link_abi.o (L0..L9+L8b+L8c + rest FROM_X → cc -r).
#            g05_ensure + Makefile thin-call (no dual hybrid body). Residual:
#            rt multi-slice · pipeline_abi · ldpc · target_cpu · pure-ld · physical delete.
#   wave758: R4 residual pure host-cc thin_glue → R1 seed-map (G.7 有则补全):
#            parser_asm_thin_glue.o ← seeds/parser_asm_thin_c.from_x.c +
#            -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/lexer -Isrc/asm -Iseeds/parser_asm;
#            ensure_one also refreshes on seeds/parser_asm/*.inc (Makefile prereq twin).
#   wave759: R4 residual glue standalone → R1 seed-map (G.7 有则补全):
#            build_asm/pipeline_glue_standalone.o ← seeds/pipeline_glue_standalone.from_x.c
#            + -Wno-error=return-type -Ibuild_asm; ensure_one refreshes on
#            pipeline_glue.c / ast_pool.c / build_asm/pipeline_glue_types.inc
#            (Makefile prereq twin). Body = ensure_one direct cc (seed accepts
#            cc -c; former Makefile/g05 used cc_inc_tu wrap — same seed TU).
#   wave760: R2 panic cold body — `try-r2 OUT` resolves OUT against catalog
#            DRIVER_SEED_PANIC_OBJS (lists = mk). Cold path selects source by
#            host uname (Linux x86_64 → runtime_panic_x86_64.s when present;
#            arm64/aarch64 → runtime_panic_arm64.from_x.c; else
#            runtime_panic.from_x.c), touches platform stamp
#            build_asm/runtime_panic.$(uname -s).$(uname -m).stamp, then
#            ensure_one (seed) or plain cc -c (.s). PREFER thin+rest stays
#            Makefile. rebuild_leaves residual uses try-r2 before make.
#   wave762: R2 typeck_f64 + crt0 — extend try-r2 membership to catalog
#            DRIVER_SEED_TYPECK_F64_OBJS + DRIVER_SEED_CRT0_OBJS (lists = mk).
#            typeck_f64_bits.o: host picks platform .s (Linux/Darwin/Windows).
#            crt0*.o / freestanding_io_x86_64.o: fixed o→.s map; crt0_mingw.o
#            uses seeds/crt0_mingw.from_x.c via cc_inc_tu (+ WIN32_O_CFLAGS).
#            G.7 有则补全 on try-r2 (no second helper name).
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
#   R1_SEED_MAP_OBJS       — basename-mismatch + bootstrap orch extras + thin_glue
#                            + glue standalone (target_cpu / ast_seed / orch /
#                            parser_asm_thin_glue · pipeline_glue_standalone · wave758/759)
#   R3_COLD_SEED_OBJS      — thin+rest cold-else pure host-cc (wave757)
#   wave761: R4 residual gen *_x + pipeline_x — `try-gen-x OUT`
#            membership = catalog LSP_X / PIPELINE_X keys;
#            body = scripts/ensure_gen_x_o.sh (G.7 有则补全).
#            rebuild_leaves try-r2 then try-gen-x then residual make.

# Not in scope (honest residual):
#   - ~~R3 Makefile PREFER thin for R3_COLD nine~~ wave763 try-r3-prefer
#   - ~~g05 R3_COLD nine dual hybrid~~ wave764 → r3-prefer-family
#   - ~~g05 labi multi-slice~~ wave765 try-labi-prefer
#   - g05 other PREFER hybrid (rt multi-slice · pipeline_abi · ldpc · target_cpu ·
#     other L2) · panic PREFER thin · R5 CI all
#   - pure-ld (11.1.4) · physical Makefile delete (11.3.1)
#   - bootstrap_nostdlib_stubs.o (cc_inc_tu residual) · crt0_user.o cp wrappers
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_host_cc_seed_o.sh one <out.o> <seed.from_x.c> [extra cflags...]
#   bash scripts/ensure_host_cc_seed_o.sh try-r1 <out.o>   # wave756 R4 pure-R1 helper
#   bash scripts/ensure_host_cc_seed_o.sh try-r3-cold <out.o>
#   bash scripts/ensure_host_cc_seed_o.sh try-r3-prefer <out.o> # wave763 PREFER thin+rest
#   bash scripts/ensure_host_cc_seed_o.sh try-labi-prefer <out.o> # wave765 labi multi-slice
#   bash scripts/ensure_host_cc_seed_o.sh try-r2 <out.o>   # wave760/762 R2 UNAME leaves
#   bash scripts/ensure_host_cc_seed_o.sh try-gen-x <out.o> # wave761 gen *_x / pipeline_x
#   bash scripts/ensure_host_cc_seed_o.sh r2-panic         # DRIVER_SEED_PANIC family
#   bash scripts/ensure_host_cc_seed_o.sh r2-typeck-f64    # DRIVER_SEED_TYPECK_F64 family
#   bash scripts/ensure_host_cc_seed_o.sh r2-crt0          # DRIVER_SEED_CRT0 family
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
#   ./xbuild host-cc-seed | … | misc-basename | seed-map | r2-panic
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
#   R2 panic body: PLATFORM LINUX|x86_64 (.s) / MACOS|arm64 + LINUX|aarch64
#   (arm64 seed) / else (from_x seed). PREFER thin stays Makefile.
#   R2 typeck_f64 / crt0: PLATFORM per host .s / mingw seed (wave762).
# Wave: 748–763 Track MG · 11.3.1 R1 families + R4 pure-R1 + R3 cold-else +
#       R3 PREFER thin (try-r3-prefer) + thin_glue/glue-standalone seed-map +
#       R2 panic/typeck_f64/crt0 (not physical delete · not pure-ld).

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
# PLATFORM: SHARED — aligned with Makefile PARSER_ASM_THIN_GLUE_CFLAGS + -I paths.
_DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/lexer -Isrc/asm -Iseeds/parser_asm"

MODE="${1:-}"
if [ -z "$MODE" ]; then
  echo "ensure_host_cc_seed_o: usage: one|try-r1|try-r3-cold|try-r3-prefer|try-labi-prefer|try-r2|try-gen-x|rt-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map|r3-cold-seed|r2-panic|r2-typeck-f64|r2-crt0|gen-x|all|--check  (see header)" >&2
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
    local xsrc stem cand inc
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
    # wave758: parser_asm_thin_glue monothin includes many seeds/parser_asm/*.inc;
    # Makefile lists them as prereqs — mirror freshness here (G.7 single body).
    if [ "$need" -eq 0 ] && [ "$stem" = "parser_asm_thin_c" ]; then
      for inc in seeds/parser_asm/*.inc; do
        if [ -f "$inc" ] && [ "$inc" -nt "$out" ]; then
          need=1
          break
        fi
      done
    fi
    # wave759: pipeline_glue_standalone embeds pipeline_glue.c + ast_pool + types.inc;
    # Makefile lists them as prereqs — mirror freshness here (G.7 single body).
    if [ "$need" -eq 0 ] && [ "$stem" = "pipeline_glue_standalone" ]; then
      for cand in pipeline_glue.c ast_pool.c build_asm/pipeline_glue_types.inc; do
        if [ -f "$cand" ] && [ "$cand" -nt "$out" ]; then
          need=1
          break
        fi
      done
    fi
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
    # wave758: R4 residual pure host-cc monothin (basename mismatch).
    parser_asm_thin_glue.o)
      printf 'seeds/parser_asm_thin_c.from_x.c\n'
      ;;
    # wave759: R4 residual glue standalone (build_asm/ path; basename seed).
    build_asm/pipeline_glue_standalone.o)
      printf 'seeds/pipeline_glue_standalone.from_x.c\n'
      ;;
    *)
      echo "ensure_host_cc_seed_o: no seed-map seed map for $o" >&2
      exit 1
      ;;
  esac
}

# Extra flags for seed-map family (stdout, space-separated; may be empty).
# Thin Makefile leaves pass make-expanded extras to `one` (authority).
# Family mode: orch needs -Ibuild_asm + -D; thin_glue needs NO_SEED_PARSE + -I;
# glue standalone needs -Wno-error=return-type -Ibuild_asm; target_cpu/ast_seed pure.
extras_for_seed_map() {
  local o="$1"
  case "$o" in
    src/driver/target_cpu.o|src/ast/ast_seed.o)
      ;;
    pipeline_bootstrap_orchestration.o)
      printf '%s' '-Ibuild_asm -DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER'
      ;;
    parser_asm_thin_glue.o)
      if [ -n "${PARSER_ASM_THIN_GLUE_CFLAGS:-}" ]; then
        # Makefile thin may export only -D; always append monothin -I paths.
        printf '%s %s' "$PARSER_ASM_THIN_GLUE_CFLAGS" "-Isrc/lexer -Isrc/asm -Iseeds/parser_asm"
      else
        printf '%s' "$_DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS"
      fi
      ;;
    # wave759: match Makefile/g05 cc_inc_tu extras (types.inc under build_asm/).
    build_asm/pipeline_glue_standalone.o)
      printf '%s' '-Wno-error=return-type -Ibuild_asm'
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
# wave757: try-r3-cold OUT — R3 cold-else pure host-cc without dual .o lists.
#
# Membership = catalog R3_COLD_SEED_OBJS only (lists = mk).
# Seed = basename convention (seeds/<leaf>.from_x.c); same ensure_one as R1.
# Exit codes:
#   0 — OUT is R3 cold-seed member; ensure_one ran (or skipped up-to-date)
#   3 — OUT not in R3_COLD_SEED_OBJS (caller residual make)
#   1 — membership found but ensure failed / catalog error
# PLATFORM: SHARED — cold path body only; PREFER thin+rest remains Makefile.
# ---------------------------------------------------------------------------
try_ensure_r3_cold_one() {
  local o="$1"
  local list seed
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r3-cold: need <out.o>" >&2
    exit 2
  fi
  list="$(catalog_key_words "R3_COLD_SEED_OBJS")"
  if ! list_has_word "$o" "$list"; then
    return 3
  fi
  seed="$(seed_for_o "$o")"
  ensure_one "$o" "$seed"
  return 0
}

ensure_r3_cold_seed() {
  ensure_catalog_family "R3_COLD_SEED_OBJS" "r3-cold-seed" "basename"
}

# ---------------------------------------------------------------------------
# wave763/764: try-r3-prefer OUT — R3 PREFER thin+rest product path (single body).
#
# Membership = catalog R3_COLD_SEED_OBJS only (lists = mk; same KEY as cold).
# When XLANG_G05_PREFER_X_O=1 and ./xlang-c is executable:
#   wave764 ladder (per leaf map):
#     1) optional full.x + full rest -D (R2 full surface; simd/backend)
#     2) thin.x (or primary .x) + thin rest -D
#     3) ld -r prefer.o rest.o → OUT (Darwin arch + multidef; ELF/PE allow-multidef)
#     4) optional nm symbol gate (simd_enc / simd_loop) — fail → next ladder step
# Prefer fail / PREFER≠1 / no xlang-c → ensure_one cold seed (try-r3-cold twin).
# Callers: Makefile nine leaves (wave763) · g05 r3-prefer-family (wave764).
# Exit codes:
#   0 — OUT is R3_COLD member; prefer or cold body produced OUT
#   3 — OUT not in R3_COLD_SEED_OBJS
#   1 — membership found but both prefer and cold failed
# PLATFORM: SHARED shell body · Darwin ld -r arch/multidef · cold chain PREFER=0.
# G.7: no second .o list; per-leaf x/rest-defs/nm/full are seed-path conventions.
# ---------------------------------------------------------------------------

# R3 prefer leaf map — NOT an .o inventory (membership = catalog only).
# stdout fields (pipe-separated):
#   thin_x | thin_rest_defs | nm_sym | full_x_or_- | full_rest_defs_or_-
# rest_defs = comma-joined -D tokens without -D prefix.
# PLATFORM: SHARED — Makefile phase4 thin + former g05 full ladder (wave764).
r3_prefer_leaf_spec() {
  local o="$1"
  case "$o" in
    src/runtime_io_abi.o)
      # Primary surface is full .x (not *_thin.x); dual rest -D historical.
      printf '%s\n' "src/runtime_io_abi.x|XLANG_L2_RIO_THIN_FROM_X,XLANG_RUNTIME_IO_ABI_FROM_X|-|-|-"
      ;;
    src/runtime_driver_abi.o)
      printf '%s\n' "src/runtime_driver_abi_thin.x|XLANG_L2_RDABI_THIN_FROM_X|-|-|-"
      ;;
    src/runtime_driver_diagnostic.o)
      printf '%s\n' "src/runtime_driver_diagnostic_thin.x|XLANG_L2_RDD_THIN_FROM_X|-|-|-"
      ;;
    src/asm/simd_enc.o)
      # wave764: full.x first (R2 H=0), then thin L2; nm gate on both.
      printf '%s\n' "src/asm/simd_enc_thin.x|XLANG_L2_SIMD_ENC_THIN_FROM_X|simd_rbp_disp32|src/asm/simd_enc.x|XLANG_SIMD_ENC_FROM_X"
      ;;
    src/asm/simd_loop.o)
      printf '%s\n' "src/asm/simd_loop_thin.x|XLANG_L2_SIMD_LOOP_THIN_FROM_X|glue_simd_loop_pick_lanes_c|src/asm/simd_loop.x|XLANG_SIMD_LOOP_FROM_X"
      ;;
    src/asm/backend_enc_dispatch.o)
      printf '%s\n' "src/asm/backend_enc_dispatch_thin.x|XLANG_L2_ENC_DISPATCH_THIN_FROM_X|-|src/asm/backend_enc_dispatch.x|XLANG_BACKEND_ENC_DISPATCH_FROM_X"
      ;;
    src/asm/backend_arch_emit_dispatch.o)
      printf '%s\n' "src/asm/backend_arch_emit_dispatch_thin.x|XLANG_L2_ARCH_EMIT_THIN_FROM_X|-|src/asm/backend_arch_emit_dispatch.x|XLANG_BACKEND_ARCH_EMIT_DISPATCH_FROM_X"
      ;;
    src/asm/backend_try_inline_dispatch.o)
      printf '%s\n' "src/asm/backend_try_inline_dispatch_thin.x|XLANG_L2_TRY_INLINE_THIN_FROM_X|-|src/asm/backend_try_inline_dispatch.x|XLANG_BACKEND_TRY_INLINE_DISPATCH_FROM_X"
      ;;
    src/asm/backend_call_dispatch.o)
      printf '%s\n' "src/asm/backend_call_dispatch_thin.x|XLANG_L2_CALL_DISPATCH_THIN_FROM_X|-|src/asm/backend_call_dispatch.x|XLANG_BACKEND_CALL_DISPATCH_FROM_X"
      ;;
    *)
      return 1
      ;;
  esac
}

r3_prefer_ld_r_flags() {
  # stdout: ld args for partial link (no -o / inputs). PLATFORM: SHARED.
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  if [ "$uname_s" = "Darwin" ]; then
    case "$uname_m" in
      arm64|aarch64) printf '%s\n' "-arch arm64 -r -multiply_defined suppress" ;;
      x86_64|amd64)  printf '%s\n' "-arch x86_64 -r -multiply_defined suppress" ;;
      *)             printf '%s\n' "-r -multiply_defined suppress" ;;
    esac
  else
    # PLATFORM: LINUX|WINDOWS (ELF/PE) — GNU ld multidef for thin+rest merge.
    printf '%s\n' "-r --allow-multiple-definition"
  fi
}

r3_prefer_nm_has_sym() {
  # $1=out.o $2=symbol (unadorned). Accepts Darwin leading underscore.
  local o="$1" sym="$2"
  [ -z "$sym" ] || [ "$sym" = "-" ] && return 0
  nm -gU "$o" 2>/dev/null | awk -v s="$sym" '
    $0 ~ (" " s "$") || $0 ~ (" _" s "$") { found=1 }
    END { exit !found }
  '
}

# Try one prefer step: xlang -E x_src → cc thin → cc seed rest -D → ld -r OUT.
# $1=out.o $2=x_src $3=rest_csv $4=nm_sym $5=seed $6=xlang_bin
# Returns 0 on success (OUT written + nm ok).
r3_prefer_try_step() {
  local o="$1" x_src="$2" rest_csv="$3" nm_sym="$4" seed="$5" xlang_bin="$6"
  local tmp_c thin_o rest_o ld_flags d_args=() d
  local label="${x_src##*/}"

  [ -n "$x_src" ] && [ "$x_src" != "-" ] && [ -f "$x_src" ] || return 1
  [ -f "$seed" ] || return 1
  [ -x "$xlang_bin" ] || return 1

  tmp_c="$(mktemp "${TMPDIR:-/tmp}/r3pref.XXXXXX")"
  thin_o="${o%.o}_prefer_step.o"
  rest_o="${o%.o}_prefer_rest.o"
  mkdir -p "$(dirname "$o")"
  # shellcheck disable=SC2086
  if ! "$xlang_bin" \
    -L .. -L src -L src/asm -L src/ast -L src/parser -L src/typeck \
    -L src/preprocess -L src/codegen -L src/pipeline \
    -E "$x_src" >"$tmp_c" 2>/dev/null \
    || [ ! -s "$tmp_c" ] \
    || ! $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -x c -c "$tmp_c" -o "$thin_o" 2>/dev/null; then
    rm -f "$tmp_c" "$thin_o" "$rest_o"
    return 1
  fi
  d_args=()
  if [ -n "$rest_csv" ] && [ "$rest_csv" != "-" ]; then
    IFS=',' read -r -a _defs <<< "$rest_csv"
    for d in "${_defs[@]}"; do
      [ -n "$d" ] && d_args+=("-D$d")
    done
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    "${d_args[@]}" -c "$seed" -o "$rest_o" 2>/dev/null; then
    rm -f "$tmp_c" "$thin_o" "$rest_o"
    return 1
  fi
  ld_flags="$(r3_prefer_ld_r_flags)"
  # shellcheck disable=SC2086
  if ld $ld_flags -o "$o" "$thin_o" "$rest_o" 2>/dev/null \
    && r3_prefer_nm_has_sym "$o" "$nm_sym"; then
    log "prefer thin+rest $o <- $x_src + $seed ($label; try-r3-prefer)"
    rm -f "$tmp_c" "$thin_o" "$rest_o"
    return 0
  fi
  rm -f "$tmp_c" "$thin_o" "$rest_o"
  return 1
}

ensure_r3_prefer_one() {
  # Prefer ladder (full→thin) or cold seed for one R3_COLD member (no membership check).
  local o="$1"
  local spec x_src rest_csv nm_sym full_x full_rest seed
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local xlang_bin="./xlang-c"
  local ok=0
  local stale=0

  seed="$(seed_for_o "$o")"
  if ! spec="$(r3_prefer_leaf_spec "$o")"; then
    echo "ensure_host_cc_seed_o try-r3-prefer: no leaf spec for $o" >&2
    return 1
  fi
  x_src="$(printf '%s' "$spec" | cut -d'|' -f1)"
  rest_csv="$(printf '%s' "$spec" | cut -d'|' -f2)"
  nm_sym="$(printf '%s' "$spec" | cut -d'|' -f3)"
  full_x="$(printf '%s' "$spec" | cut -d'|' -f4)"
  full_rest="$(printf '%s' "$spec" | cut -d'|' -f5)"
  [ -z "$full_x" ] && full_x="-"
  [ -z "$full_rest" ] && full_rest="-"

  # Up-to-date skip (make / g05 already gated; shell direct calls benefit).
  # wave764: also consider full.x mtime when present.
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ -f "$seed" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    if [ -f "$x_src" ] && [ "$x_src" -nt "$o" ]; then
      stale=1
    fi
    if [ -n "$full_x" ] && [ "$full_x" != "-" ] && [ -f "$full_x" ] && [ "$full_x" -nt "$o" ]; then
      stale=1
    fi
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (r3-prefer)"
      return 0
    fi
  fi

  # PLATFORM: SHARED cold-chain — only PREFER=1 may thin (Darwin history: thin
  # with PREFER=0 left UNDEFs in phase1). wave763 unified PREFER=1 for all nine;
  # wave764 full→thin ladder for g05 R2 full surface (simd/backend).
  if [ "$prefer" = "1" ] && [ -x "$xlang_bin" ] && [ -f "$seed" ]; then
    # 1) optional full.x first
    if [ -n "$full_x" ] && [ "$full_x" != "-" ] && [ -f "$full_x" ]; then
      if r3_prefer_try_step "$o" "$full_x" "$full_rest" "$nm_sym" "$seed" "$xlang_bin"; then
        ok=1
      fi
    fi
    # 2) thin / primary .x
    if [ "$ok" != "1" ] && [ -f "$x_src" ]; then
      if r3_prefer_try_step "$o" "$x_src" "$rest_csv" "$nm_sym" "$seed" "$xlang_bin"; then
        ok=1
      fi
    fi
  fi

  if [ "$ok" = "1" ]; then
    return 0
  fi

  # Cold fallback — same ensure_one as try-r3-cold.
  # Force when prefer path may have left a partial/bad OUT (e.g. nm gate fail).
  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-r3-prefer: missing seed $seed for $o" >&2
    return 1
  fi
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    # Prefer attempted: never keep a thin that failed nm / ld semantics.
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_r3_prefer_one() {
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r3-prefer: need <out.o>" >&2
    exit 2
  fi
  list="$(catalog_key_words "R3_COLD_SEED_OBJS")"
  if ! list_has_word "$o" "$list"; then
    return 3
  fi
  ensure_r3_prefer_one "$o"
  return 0
}

ensure_r3_prefer() {
  # Family mode: all R3_COLD members via prefer-or-cold body.
  local list o
  list="$(catalog_key_words "R3_COLD_SEED_OBJS")"
  if [ -z "$list" ]; then
    echo "ensure_host_cc_seed_o r3-prefer: empty R3_COLD_SEED_OBJS" >&2
    exit 1
  fi
  for o in $list; do
    ensure_r3_prefer_one "$o" || return 1
  done
}


# ---------------------------------------------------------------------------
# wave765: try-labi-prefer OUT — g05 labi multi-slice product PREFER (single body).
#
# Single leaf: src/runtime_link_abi.o (in R1_CORE_SEED_OBJS; cold twin = ensure_one).
# When XLANG_G05_PREFER_X_O=1 and an xlang binary works:
#   L0..L9 + L8b(+L8c capacity split) prefer .x → .o (else cold layer seed)
#   rest = seeds/runtime_link_abi.from_x.c with XLANG_LABI_*_FROM_X for ok layers
#   merge: $CC -r -nostdlib slices + rest → OUT
# Prefer fail / PREFER≠1 / no xlang → ensure_one cold full seed (same as core-seed).
# Callers: g05_ensure (wave765) · Makefile src/runtime_link_abi.o (unified).
# Exit codes:
#   0 — OUT is runtime_link_abi.o; prefer or cold body produced OUT
#   3 — OUT is not src/runtime_link_abi.o
#   1 — membership found but cold seed missing / compile failed
# PLATFORM: SHARED shell body · g05 historic PREFER=1 · cold chain PREFER=0.
# G.7: no second .o list; layer table is seed-path convention (not product inventory).
# Residual after: rt multi-slice · pipeline_abi · ldpc · target_cpu · pure-ld · physical delete.
# ---------------------------------------------------------------------------

labi_prefer_pick_xlang() {
  # stdout: first executable product binary.
  local b
  for b in ./xlang ./xlang-c ./bootstrap_xlangc; do
    if [ -x "$b" ]; then
      printf '%s\n' "$b"
      return 0
    fi
  done
  return 1
}

# Prefer one layer .x → .o (simple -E harness; fail → caller seed).
# $1=x_src $2=out.o  Returns 0 on success.
# PLATFORM: SHARED — retry -E then -backend c -E (Ubuntu SIGSEGV history).
labi_prefer_try_x_to_o() {
  local x_src="$1" x_out="$2" xlang_bin tmp e_ok e_try
  [ -f "$x_src" ] || return 1
  xlang_bin="$(labi_prefer_pick_xlang)" || return 1
  mkdir -p "$(dirname "$x_out")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/labipref.XXXXXX")"
  e_ok=0
  for e_try in 1 2 3 4 5; do
    if "$xlang_bin" -E "$x_src" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      e_ok=1
      break
    fi
    : >"$tmp"
    if "$xlang_bin" -backend c -E "$x_src" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      e_ok=1
      break
    fi
    : >"$tmp"
  done
  if [ "$e_ok" != "1" ]; then
    rm -f "$tmp"
    return 1
  fi
  # shellcheck disable=SC2086
  if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -x c -c -o "$x_out" "$tmp" 2>/dev/null; then
    rm -f "$tmp"
    return 1
  fi
  rm -f "$tmp"
  return 0
}

# Compile one layer: prefer .x else seed → tmp .o. Sets ok via nameref-ish stdout.
# $1=label $2=x $3=seed $4=out_tmp  → 0 if layer .o ready.
labi_prefer_layer() {
  local label="$1" x_src="$2" seed="$3" out_tmp="$4"
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  if [ "$prefer" = "1" ] && [ -f "$x_src" ]; then
    if labi_prefer_try_x_to_o "$x_src" "$out_tmp"; then
      log "labi $label ← $x_src (prefer .x)"
      return 0
    fi
  fi
  if [ -f "$seed" ]; then
    # shellcheck disable=SC2086
    if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$out_tmp" "$seed" 2>/dev/null; then
      log "labi $label ← $seed (cold seed slice)"
      return 0
    fi
  fi
  return 1
}

ensure_labi_prefer_one() {
  # Prefer multi-slice or cold full seed for src/runtime_link_abi.o (no membership check).
  local o="$1"
  local seed="seeds/runtime_link_abi.from_x.c"
  local prefer="${XLANG_G05_PREFER_X_O:-0}"
  local stale=0 done=0
  local l0_o l1_o l2_o l3_o l4_o l5_o l6_o l7_o l8_o l8b_o l8c_o l9_o rest_o
  local l0_ok=0 l1_ok=0 l2_ok=0 l3_ok=0 l4_ok=0 l5_ok=0 l6_ok=0 l7_ok=0
  local l8_ok=0 l8b_ok=0 l8c_ok=0 l9_ok=0
  local l8b_x_ok=0 l8c_x_ok=0
  local rest_defs link_objs
  # Layer paths (seed-path convention; not a product .o list).
  local l0_x=src/runtime/labi_path_pure.x l0_seed=seeds/labi_path_pure.from_x.c
  local l1_x=src/runtime/labi_diag_pure.x l1_seed=seeds/labi_diag_pure.from_x.c
  local l2_x=src/runtime/labi_host_lit.x l2_seed=seeds/labi_host_lit.from_x.c
  local l3_x=src/runtime/labi_path_io.x l3_seed=seeds/labi_path_io.from_x.c
  local l4_x=src/runtime/labi_ensure_list.x l4_seed=seeds/labi_ensure_list.from_x.c
  local l5_x=src/runtime/labi_invoke_cc_list.x l5_seed=seeds/labi_invoke_cc_list.from_x.c
  local l6_x=src/runtime/labi_invoke_ld_list.x l6_seed=seeds/labi_invoke_ld_list.from_x.c
  local l7_x=src/runtime/labi_freestanding_list.x l7_seed=seeds/labi_freestanding_list.from_x.c
  local l8_x=src/runtime/labi_std_list.x l8_seed=seeds/labi_std_list.from_x.c
  local l8b_x=src/runtime/labi_ondemand_list.x l8b_seed=seeds/labi_ondemand_list.from_x.c
  local l8c_x=src/runtime/labi_ondemand_heavy.x
  local l9_x=src/runtime/labi_gates.x l9_seed=seeds/labi_gates.from_x.c

  if [ ! -f "$seed" ]; then
    echo "ensure_host_cc_seed_o try-labi-prefer: missing seed $seed" >&2
    return 1
  fi

  # Up-to-date skip: seed + any layer .x / layer seed newer → rebuild.
  if [ "$FORCE" != "1" ] && [ -f "$o" ]; then
    stale=0
    [ "$seed" -nt "$o" ] && stale=1
    for f in \
      "$l0_x" "$l0_seed" "$l1_x" "$l1_seed" "$l2_x" "$l2_seed" \
      "$l3_x" "$l3_seed" "$l4_x" "$l4_seed" "$l5_x" "$l5_seed" \
      "$l6_x" "$l6_seed" "$l7_x" "$l7_seed" "$l8_x" "$l8_seed" \
      "$l8b_x" "$l8b_seed" "$l8c_x" "$l9_x" "$l9_seed"
    do
      if [ -f "$f" ] && [ "$f" -nt "$o" ]; then
        stale=1
        break
      fi
    done
    if [ "$stale" = "0" ]; then
      log "skip up-to-date $o (labi-prefer)"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$o")"

  # Multi-slice prefer only when PREFER=1 (Darwin cold-chain safety twin of R3).
  if [ "$prefer" = "1" ] && labi_prefer_pick_xlang >/dev/null 2>&1; then
    l0_o="$(mktemp "${TMPDIR:-/tmp}/labi_l0.XXXXXX")"
    l1_o="$(mktemp "${TMPDIR:-/tmp}/labi_l1.XXXXXX")"
    l2_o="$(mktemp "${TMPDIR:-/tmp}/labi_l2.XXXXXX")"
    l3_o="$(mktemp "${TMPDIR:-/tmp}/labi_l3.XXXXXX")"
    l4_o="$(mktemp "${TMPDIR:-/tmp}/labi_l4.XXXXXX")"
    l5_o="$(mktemp "${TMPDIR:-/tmp}/labi_l5.XXXXXX")"
    l6_o="$(mktemp "${TMPDIR:-/tmp}/labi_l6.XXXXXX")"
    l7_o="$(mktemp "${TMPDIR:-/tmp}/labi_l7.XXXXXX")"
    l8_o="$(mktemp "${TMPDIR:-/tmp}/labi_l8.XXXXXX")"
    l8b_o="$(mktemp "${TMPDIR:-/tmp}/labi_l8b.XXXXXX")"
    l8c_o="$(mktemp "${TMPDIR:-/tmp}/labi_l8c.XXXXXX")"
    l9_o="$(mktemp "${TMPDIR:-/tmp}/labi_l9.XXXXXX")"
    rest_o="$(mktemp "${TMPDIR:-/tmp}/labi_rest.XXXXXX")"

    labi_prefer_layer L0 "$l0_x" "$l0_seed" "$l0_o" && l0_ok=1
    labi_prefer_layer L1 "$l1_x" "$l1_seed" "$l1_o" && l1_ok=1
    labi_prefer_layer L2 "$l2_x" "$l2_seed" "$l2_o" && l2_ok=1
    labi_prefer_layer L3 "$l3_x" "$l3_seed" "$l3_o" && l3_ok=1
    labi_prefer_layer L4 "$l4_x" "$l4_seed" "$l4_o" && l4_ok=1
    labi_prefer_layer L5 "$l5_x" "$l5_seed" "$l5_o" && l5_ok=1
    labi_prefer_layer L6 "$l6_x" "$l6_seed" "$l6_o" && l6_ok=1
    labi_prefer_layer L7 "$l7_x" "$l7_seed" "$l7_o" && l7_ok=1
    labi_prefer_layer L8 "$l8_x" "$l8_seed" "$l8_o" && l8_ok=1
    labi_prefer_layer L9 "$l9_x" "$l9_seed" "$l9_o" && l9_ok=1

    # wave263: L8b early + L8c heavy must BOTH prefer .x, else full L8b seed covers both.
    if [ "$prefer" = "1" ] && [ -f "$l8b_x" ] && labi_prefer_try_x_to_o "$l8b_x" "$l8b_o"; then
      l8b_x_ok=1
    fi
    if [ "$prefer" = "1" ] && [ -f "$l8c_x" ] && labi_prefer_try_x_to_o "$l8c_x" "$l8c_o"; then
      l8c_x_ok=1
    fi
    if [ "$l8b_x_ok" = "1" ] && [ "$l8c_x_ok" = "1" ]; then
      l8b_ok=1
      l8c_ok=1
      log "labi L8b+L8c ← $l8b_x + $l8c_x (capacity split)"
    elif [ -f "$l8b_seed" ]; then
      # shellcheck disable=SC2086
      if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$l8b_o" "$l8b_seed" 2>/dev/null; then
        l8b_ok=1
        l8c_ok=0
        log "labi L8b ← $l8b_seed (full seed; L8c unused)"
      fi
    fi

    # Rest FROM_X flags (L0 always required for hybrid path).
    rest_defs="-DXLANG_LABI_PATH_PURE_FROM_X"
    [ "$l1_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_DIAG_PURE_FROM_X"
    [ "$l2_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_HOST_LIT_FROM_X"
    [ "$l3_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_PATH_IO_FROM_X"
    [ "$l4_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_ENSURE_LIST_FROM_X"
    [ "$l5_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_INVOKE_CC_LIST_FROM_X"
    [ "$l6_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_INVOKE_LD_LIST_FROM_X"
    [ "$l7_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_FREESTANDING_LIST_FROM_X"
    [ "$l8_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_STD_LIST_FROM_X"
    [ "$l8b_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_ONDEMAND_LIST_FROM_X"
    [ "$l9_ok" = "1" ] && rest_defs="$rest_defs -DXLANG_LABI_GATES_FROM_X"

    if [ "$l0_ok" = "1" ]; then
      # shellcheck disable=SC2086
      if $CC $BASE_CFLAGS -I. -Iinclude -Isrc $rest_defs -c -o "$rest_o" "$seed" 2>/dev/null; then
        link_objs="$l0_o"
        [ "$l1_ok" = "1" ] && link_objs="$link_objs $l1_o"
        [ "$l2_ok" = "1" ] && link_objs="$link_objs $l2_o"
        [ "$l3_ok" = "1" ] && link_objs="$link_objs $l3_o"
        [ "$l4_ok" = "1" ] && link_objs="$link_objs $l4_o"
        [ "$l5_ok" = "1" ] && link_objs="$link_objs $l5_o"
        [ "$l6_ok" = "1" ] && link_objs="$link_objs $l6_o"
        [ "$l7_ok" = "1" ] && link_objs="$link_objs $l7_o"
        [ "$l8_ok" = "1" ] && link_objs="$link_objs $l8_o"
        [ "$l8b_ok" = "1" ] && link_objs="$link_objs $l8b_o"
        [ "$l8c_ok" = "1" ] && link_objs="$link_objs $l8c_o"
        [ "$l9_ok" = "1" ] && link_objs="$link_objs $l9_o"
        # shellcheck disable=SC2086
        # PLATFORM: SHARED — historic g05 used $CC -r -nostdlib (not ld Darwin flags).
        if $CC -r -nostdlib -o "$o" $link_objs "$rest_o" 2>/dev/null; then
          log "prefer multi-slice $o <- L0..L9+L8b+L8c + link_abi rest (try-labi-prefer)"
          done=1
        fi
      fi
    fi
    rm -f "$l0_o" "$l1_o" "$l2_o" "$l3_o" "$l4_o" "$l5_o" "$l6_o" \
      "$l7_o" "$l8_o" "$l8b_o" "$l8c_o" "$l9_o" "$rest_o"
    if [ "$done" = "0" ]; then
      log "labi multi-slice hybrid failed; fallback full seed"
    fi
  fi

  if [ "$done" = "1" ]; then
    return 0
  fi

  # Cold full seed (ensure_one twin / PREFER=0).
  if [ -f "$o" ] && [ "$prefer" = "1" ]; then
    FORCE=1
    ensure_one "$o" "$seed"
    FORCE=0
  else
    ensure_one "$o" "$seed"
  fi
  return 0
}

try_ensure_labi_prefer_one() {
  local o="$1"
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-labi-prefer: need <out.o>" >&2
    exit 2
  fi
  if [ "$o" != "src/runtime_link_abi.o" ]; then
    return 3
  fi
  ensure_labi_prefer_one "$o"
  return 0
}

# ---------------------------------------------------------------------------
# wave760: try-r2 OUT — R2 platform-stamp panic cold body (UNAME leaf).
#
# Membership = catalog DRIVER_SEED_PANIC_OBJS only (lists = mk; currently
# runtime_panic.o). Cold source selection mirrors Makefile / build_xlang_asm:
#   PLATFORM: LINUX|x86_64 — cc -c src/asm/runtime_panic_x86_64.s when present
#   PLATFORM: MACOS|arm64 / LINUX|aarch64 — seeds/runtime_panic_arm64.from_x.c
#   else — seeds/runtime_panic.from_x.c
# Platform stamp: build_asm/runtime_panic.$(uname -s).$(uname -m).stamp
# (create if missing; force rebuild when stamp was missing so platform switch
# cannot leave a stale .o without a matching stamp).
# Exit codes:
#   0 — OUT is panic catalog member; cold body ran (or skipped up-to-date)
#   3 — OUT not in DRIVER_SEED_PANIC_OBJS (caller residual make)
#   1 — membership found but compile failed / missing source
# PLATFORM: SHARED shell body · per-host source pick tagged above.
# PREFER_X_O=1 thin+rest remains Makefile (not this helper).
# ---------------------------------------------------------------------------
r2_panic_host_pick_src() {
  # stdout: "asm|seed <path>" — host cold source for runtime_panic.o
  # PLATFORM: LINUX|x86_64 prefer pure-syscall .s; arm64/aarch64 arm64 seed;
  #           else portable from_x seed (incl. Darwin x86_64 / Windows).
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  if [ "$uname_s" = "Linux" ] && [ "$uname_m" = "x86_64" ] \
    && [ -f src/asm/runtime_panic_x86_64.s ]; then
    printf '%s\n' "asm src/asm/runtime_panic_x86_64.s"
    return 0
  fi
  case "$uname_m" in
    arm64|aarch64)
      if [ -f seeds/runtime_panic_arm64.from_x.c ]; then
        printf '%s\n' "seed seeds/runtime_panic_arm64.from_x.c"
        return 0
      fi
      ;;
  esac
  if [ -f seeds/runtime_panic.from_x.c ]; then
    printf '%s\n' "seed seeds/runtime_panic.from_x.c"
    return 0
  fi
  echo "ensure_host_cc_seed_o r2-panic: no runtime_panic cold source for $uname_s/$uname_m" >&2
  return 1
}

ensure_r2_panic_one() {
  # Cold body for a DRIVER_SEED_PANIC_OBJS member (no membership check).
  local o="$1"
  local pick kind src stamp uname_s uname_m need=0 cand
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  stamp="build_asm/runtime_panic.${uname_s}.${uname_m}.stamp"
  mkdir -p build_asm
  if [ ! -f "$stamp" ]; then
    touch "$stamp"
    need=1
  fi
  pick="$(r2_panic_host_pick_src)" || return 1
  kind="${pick%% *}"
  src="${pick#* }"
  if [ ! -f "$src" ]; then
    echo "ensure_host_cc_seed_o r2-panic: missing source $src" >&2
    return 1
  fi
  case "$kind" in
    seed)
      # Sibling .x freshness is inside ensure_one; stamp-missing forces compile.
      # FORCE is script-global (read at ensure_one); temporarily raise when stamp was new.
      if [ "$need" = "1" ] && [ "$FORCE" != "1" ]; then
        FORCE=1
        ensure_one "$o" "$src"
        FORCE=0
      else
        ensure_one "$o" "$src"
      fi
      ;;
    asm)
      # PLATFORM: LINUX|x86_64 — plain cc -c .s (no PIPELINE_GEN_CFLAGS).
      if [ "$FORCE" != "1" ] && [ "$need" = "0" ] && [ -f "$o" ] \
        && [ ! "$src" -nt "$o" ]; then
        log "skip $o (up-to-date vs $src)"
        return 0
      fi
      log "cc -c $src → $o"
      # shellcheck disable=SC2086
      $CC -c -o "$o" "$src"
      ;;
    *)
      echo "ensure_host_cc_seed_o r2-panic: unknown kind $kind" >&2
      return 1
      ;;
  esac
  # Keep stamp mtime after successful compile so make prereq stays satisfied.
  touch "$stamp"
  return 0
}

try_ensure_r2_one() {
  # wave760 panic + wave762 typeck_f64/crt0 — single try-r2 entry (G.7 有则补全).
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-r2: need <out.o>" >&2
    exit 2
  fi
  # 1) panic catalog
  list="$(catalog_key_words "DRIVER_SEED_PANIC_OBJS")"
  if list_has_word "$o" "$list"; then
    case "$o" in
      runtime_panic.o) ensure_r2_panic_one "$o"; return 0 ;;
      *)
        echo "ensure_host_cc_seed_o try-r2: no cold map for panic member $o" >&2
        return 1
        ;;
    esac
  fi
  # 2) typeck_f64 catalog
  list="$(catalog_key_words "DRIVER_SEED_TYPECK_F64_OBJS")"
  if list_has_word "$o" "$list"; then
    case "$o" in
      src/typeck/typeck_f64_bits.o) ensure_r2_typeck_f64_one "$o"; return 0 ;;
      *)
        echo "ensure_host_cc_seed_o try-r2: no cold map for typeck_f64 member $o" >&2
        return 1
        ;;
    esac
  fi
  # 3) crt0 catalog
  list="$(catalog_key_words "DRIVER_SEED_CRT0_OBJS")"
  if list_has_word "$o" "$list"; then
    ensure_r2_crt0_one "$o" || return 1
    return 0
  fi
  return 3
}

ensure_r2_panic() {
  local list n=0 o
  list="$(catalog_key_words "DRIVER_SEED_PANIC_OBJS")"
  if [ -z "${list// /}" ]; then
    echo "ensure_host_cc_seed_o: empty DRIVER_SEED_PANIC_OBJS" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    ensure_r2_panic_one "$o" || exit 1
    n=$((n + 1))
  done
  log "r2-panic OK ($n objs; catalog DRIVER_SEED_PANIC_OBJS)"
}

# ---------------------------------------------------------------------------
# wave762: R2 typeck_f64_bits — host picks platform pure-.s source.
# Membership = catalog DRIVER_SEED_TYPECK_F64_OBJS (lists = mk).
# PLATFORM: LINUX|x86_64 / LINUX|aarch64 / DARWIN|arm64 / DARWIN|x86_64 /
#           WINDOWS|x86_64 mingw .s. Mirrors g05_ensure + Makefile (G.7 one body).
# ---------------------------------------------------------------------------
r2_typeck_f64_host_pick_src() {
  # stdout: path to .s for typeck_f64_bits.o on this host
  local uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  # PLATFORM: WINDOWS — MSYS/MinGW uname often MINGW64_NT-* / MSYS_NT-*.
  case "$uname_s" in
    MINGW*|MSYS*|CYGWIN*)
      if [ -f src/typeck/typeck_f64_bits_x86_64_mingw.s ]; then
        printf '%s\n' "src/typeck/typeck_f64_bits_x86_64_mingw.s"
        return 0
      fi
      ;;
  esac
  if [ "${XLANG_IS_WIN_HOST:-0}" = "1" ]; then
    if [ -f src/typeck/typeck_f64_bits_x86_64_mingw.s ]; then
      printf '%s\n' "src/typeck/typeck_f64_bits_x86_64_mingw.s"
      return 0
    fi
  fi
  case "${uname_s}/${uname_m}" in
    Linux/x86_64)
      printf '%s\n' "src/typeck/typeck_f64_bits_x86_64.s" ;;
    Linux/aarch64)
      printf '%s\n' "src/typeck/typeck_f64_bits_aarch64_elf.s" ;;
    Darwin/arm64|Darwin/aarch64)
      printf '%s\n' "src/typeck/typeck_f64_bits_arm64.s" ;;
    Darwin/x86_64|Darwin/amd64)
      printf '%s\n' "src/typeck/typeck_f64_bits_x86_64.s" ;;
    *)
      echo "ensure_host_cc_seed_o r2-typeck-f64: unsupported host $uname_s/$uname_m" >&2
      return 1
      ;;
  esac
  return 0
}

ensure_r2_typeck_f64_one() {
  local o="$1"
  local src
  src="$(r2_typeck_f64_host_pick_src)" || return 1
  if [ ! -f "$src" ]; then
    echo "ensure_host_cc_seed_o r2-typeck-f64: missing $src" >&2
    return 1
  fi
  mkdir -p "$(dirname "$o")"
  if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$src" -nt "$o" ]; then
    log "skip $o (up-to-date vs $src)"
    return 0
  fi
  log "cc -c $src → $o"
  # shellcheck disable=SC2086
  $CC -c -o "$o" "$src"
}

ensure_r2_typeck_f64() {
  local list n=0 o
  list="$(catalog_key_words "DRIVER_SEED_TYPECK_F64_OBJS")"
  if [ -z "${list// /}" ]; then
    echo "ensure_host_cc_seed_o: empty DRIVER_SEED_TYPECK_F64_OBJS" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    ensure_r2_typeck_f64_one "$o" || exit 1
    n=$((n + 1))
  done
  log "r2-typeck-f64 OK ($n objs; catalog DRIVER_SEED_TYPECK_F64_OBJS)"
}

# ---------------------------------------------------------------------------
# wave762: R2 crt0 / freestanding platform leaves — fixed o→src map.
# Membership = catalog DRIVER_SEED_CRT0_OBJS. Most are plain .s; mingw is seed
# via cc_inc_tu (+ WIN32_O_CFLAGS from env/make).
# PLATFORM: LINUX crt0_x86_64 + freestanding · MACOS arm64/darwin_x86_64 ·
#           WINDOWS crt0_mingw seed.
# ---------------------------------------------------------------------------
r2_crt0_src_for_out() {
  # stdout: "asm|seed|cc_inc_tu <path>" for OUT; fail closed if unknown.
  local o="$1"
  case "$o" in
    src/asm/crt0_x86_64.o)
      printf '%s\n' "asm src/asm/crt0_x86_64.s" ;;
    src/asm/crt0_arm64.o)
      printf '%s\n' "asm src/asm/crt0_arm64.s" ;;
    src/asm/crt0_darwin_x86_64.o)
      printf '%s\n' "asm src/asm/crt0_darwin_x86_64.s" ;;
    src/asm/crt0_user_x86_64.o)
      printf '%s\n' "asm src/asm/crt0_user_x86_64.s" ;;
    src/asm/freestanding_io_x86_64.o)
      printf '%s\n' "asm src/asm/freestanding_io_x86_64.s" ;;
    src/asm/crt0_mingw.o)
      # PLATFORM: WINDOWS — seed via cc_inc_tu (Makefile twin).
      printf '%s\n' "cc_inc_tu seeds/crt0_mingw.from_x.c" ;;
    *)
      echo "ensure_host_cc_seed_o r2-crt0: no source map for $o" >&2
      return 1
      ;;
  esac
  return 0
}

ensure_r2_crt0_one() {
  local o="$1"
  local pick kind src
  pick="$(r2_crt0_src_for_out "$o")" || return 1
  kind="${pick%% *}"
  src="${pick#* }"
  if [ ! -f "$src" ]; then
    echo "ensure_host_cc_seed_o r2-crt0: missing $src" >&2
    return 1
  fi
  mkdir -p "$(dirname "$o")"
  case "$kind" in
    asm)
      if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$src" -nt "$o" ]; then
        log "skip $o (up-to-date vs $src)"
        return 0
      fi
      log "cc -c $src → $o"
      # shellcheck disable=SC2086
      $CC -c -o "$o" "$src"
      ;;
    cc_inc_tu)
      # PLATFORM: WINDOWS — same wrap as Makefile (WIN32_O_CFLAGS from env).
      if [ "$FORCE" != "1" ] && [ -f "$o" ] && [ ! "$src" -nt "$o" ]; then
        log "skip $o (up-to-date vs $src)"
        return 0
      fi
      if [ ! -f scripts/cc_inc_tu.sh ]; then
        echo "ensure_host_cc_seed_o r2-crt0: missing scripts/cc_inc_tu.sh" >&2
        return 1
      fi
      log "cc_inc_tu $src → $o"
      # shellcheck disable=SC2086
      sh scripts/cc_inc_tu.sh "$src" "$o" ${WIN32_O_CFLAGS:-}
      ;;
    *)
      echo "ensure_host_cc_seed_o r2-crt0: unknown kind $kind" >&2
      return 1
      ;;
  esac
  return 0
}

r2_crt0_host_relevant() {
  # Family-mode filter: catalog lists all platforms, but .s for other OS/ISA
  # live in-tree and must not be assembled by the host toolchain.
  # try-r2 OUT still runs ensure_r2_crt0_one for any member (Makefile only
  # requests the host MAIN_LINK / freestanding leaf).
  # PLATFORM: per-leaf gate below.
  local o="$1" uname_s uname_m
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  case "$o" in
    src/asm/crt0_x86_64.o|src/asm/crt0_user_x86_64.o|src/asm/freestanding_io_x86_64.o)
      [ "$uname_s" = "Linux" ] && [ "$uname_m" = "x86_64" ]
      ;;
    src/asm/crt0_arm64.o)
      [ "$uname_s" = "Darwin" ] && { [ "$uname_m" = "arm64" ] || [ "$uname_m" = "aarch64" ]; }
      ;;
    src/asm/crt0_darwin_x86_64.o)
      [ "$uname_s" = "Darwin" ] && { [ "$uname_m" = "x86_64" ] || [ "$uname_m" = "amd64" ]; }
      ;;
    src/asm/crt0_mingw.o)
      case "$uname_s" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
      esac
      [ "${XLANG_IS_WIN_HOST:-0}" = "1" ]
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_r2_crt0() {
  # Family runner: only host-relevant leaves (source present + host gate).
  local list n=0 o pick src
  list="$(catalog_key_words "DRIVER_SEED_CRT0_OBJS")"
  if [ -z "${list// /}" ]; then
    echo "ensure_host_cc_seed_o: empty DRIVER_SEED_CRT0_OBJS" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  for o in $list; do
    [ -z "$o" ] && continue
    if ! r2_crt0_host_relevant "$o"; then
      log "r2-crt0 skip $o (not host MAIN_LINK/freestanding leaf)"
      continue
    fi
    pick="$(r2_crt0_src_for_out "$o")" || continue
    src="${pick#* }"
    if [ ! -f "$src" ]; then
      log "r2-crt0 skip $o (source $src missing)"
      continue
    fi
    ensure_r2_crt0_one "$o" || exit 1
    n=$((n + 1))
  done
  log "r2-crt0 OK ($n host-relevant objs; catalog DRIVER_SEED_CRT0_OBJS)"
}


# ---------------------------------------------------------------------------
# wave761: try-gen-x OUT — residual gen *_x.o + pipeline_x.o (R4 pattern body).
#
# Membership (catalog only; G.7 no dual .o list):
#   lsp_io_x.o | lsp_x.o | lsp_diag_x.o ∈ DRIVER_SEED_LSP_X_OBJS
#   pipeline_x.o ∈ DRIVER_SEED_PIPELINE_X_OBJS
# Body: scripts/ensure_gen_x_o.sh one OUT (compile map + gen_driver STALE).
# Exit codes:
#   0 — OUT is gen residual member; body ran (or skipped up-to-date)
#   3 — OUT not in gen residual map / catalog
#   1 — membership found but compile failed
# PLATFORM: SHARED shell · PIPELINE_X_DEPS / FORCE from env (Makefile expands).
# ---------------------------------------------------------------------------
try_ensure_gen_x_one() {
  local o="$1"
  local list
  if [ -z "$o" ]; then
    echo "ensure_host_cc_seed_o try-gen-x: need <out.o>" >&2
    exit 2
  fi
  case "$o" in
    lsp_io_x.o|lsp_x.o|lsp_diag_x.o)
      list="$(catalog_key_words "DRIVER_SEED_LSP_X_OBJS")"
      if ! list_has_word "$o" "$list"; then
        return 3
      fi
      ;;
    pipeline_x.o)
      list="$(catalog_key_words "DRIVER_SEED_PIPELINE_X_OBJS")"
      if ! list_has_word "$o" "$list"; then
        return 3
      fi
      ;;
    *)
      return 3
      ;;
  esac
  if [ ! -f scripts/ensure_gen_x_o.sh ]; then
    echo "ensure_host_cc_seed_o try-gen-x: missing scripts/ensure_gen_x_o.sh (wave761)" >&2
    return 1
  fi
  # Propagate FORCE into gen body (same global FORCE used by ensure_one).
  if [ "$FORCE" = "1" ]; then
    XLANG_GEN_X_FORCE=1 XLANG_HOST_CC_SEED_FORCE=1 \
      bash scripts/ensure_gen_x_o.sh one "$o" || return 1
  else
    bash scripts/ensure_gen_x_o.sh one "$o" || return 1
  fi
  return 0
}

ensure_gen_x_residual() {
  # Family runner: all gen residual maps (lsp trio + pipeline).
  bash scripts/ensure_gen_x_o.sh residual-all
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
  if ! grep -q 'R3_COLD_SEED_OBJS' Makefile \
    && ! grep -q 'R3_COLD_SEED_OBJS' mk/*.mk 2>/dev/null; then
    bad "R3_COLD_SEED_OBJS not defined in Makefile/mk (wave757)"
  fi
  if ! grep -q 'DRIVER_SEED_PANIC_OBJS' Makefile \
    && ! grep -q 'DRIVER_SEED_PANIC_OBJS' mk/*.mk 2>/dev/null; then
    bad "DRIVER_SEED_PANIC_OBJS not defined in Makefile/mk (wave760 R2 panic list)"
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
  # seed-map: mismatch stems + orch extras + thin_glue (wave758) + glue standalone (wave759).
  check_family "R1_SEED_MAP_OBJS" 5 "seed-map" "seed-map" ""
  # R3 cold-else: thin+rest leaves cold path = pure basename host-cc.
  check_family "R3_COLD_SEED_OBJS" 9 "r3-cold-seed" "basename" ""
  # R2 panic: catalog list must resolve; seed/asm pick must work on this host.
  {
    local panic_list panic_n=0 po pick
    if ! panic_list="$(catalog_key_list "DRIVER_SEED_PANIC_OBJS" 2>/dev/null)"; then
      bad "catalog cannot expand DRIVER_SEED_PANIC_OBJS (wave760)"
    else
      # shellcheck disable=SC2086
      for po in $panic_list; do
        [ -z "$po" ] && continue
        panic_n=$((panic_n + 1))
      done
      if [ "$panic_n" -lt 1 ]; then
        bad "DRIVER_SEED_PANIC_OBJS empty (wave760)"
      else
        note "catalog DRIVER_SEED_PANIC_OBJS n=$panic_n (r2-panic)"
      fi
      if ! pick="$(r2_panic_host_pick_src 2>/dev/null)"; then
        bad "r2_panic_host_pick_src failed on this host (wave760)"
      else
        note "r2-panic host pick: $pick"
      fi
    fi
  }
  # wave762: typeck_f64 + crt0 catalogs + host pick / map
  {
    local f64_list f64_n=0 fo f64_src crt0_list crt0_n=0 co
    if ! f64_list="$(catalog_key_list "DRIVER_SEED_TYPECK_F64_OBJS" 2>/dev/null)"; then
      bad "catalog cannot expand DRIVER_SEED_TYPECK_F64_OBJS (wave762)"
    else
      # shellcheck disable=SC2086
      for fo in $f64_list; do
        [ -z "$fo" ] && continue
        f64_n=$((f64_n + 1))
      done
      if [ "$f64_n" -lt 1 ]; then
        bad "DRIVER_SEED_TYPECK_F64_OBJS empty (wave762)"
      else
        note "catalog DRIVER_SEED_TYPECK_F64_OBJS n=$f64_n (r2-typeck-f64)"
      fi
      if ! f64_src="$(r2_typeck_f64_host_pick_src 2>/dev/null)"; then
        bad "r2_typeck_f64_host_pick_src failed on this host (wave762)"
      else
        note "r2-typeck-f64 host pick: $f64_src"
      fi
    fi
    if ! crt0_list="$(catalog_key_list "DRIVER_SEED_CRT0_OBJS" 2>/dev/null)"; then
      bad "catalog cannot expand DRIVER_SEED_CRT0_OBJS (wave762)"
    else
      # shellcheck disable=SC2086
      for co in $crt0_list; do
        [ -z "$co" ] && continue
        crt0_n=$((crt0_n + 1))
      done
      if [ "$crt0_n" -lt 1 ]; then
        bad "DRIVER_SEED_CRT0_OBJS empty (wave762)"
      else
        note "catalog DRIVER_SEED_CRT0_OBJS n=$crt0_n (r2-crt0)"
      fi
    fi
  }

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
  # Seed-map leaves must not keep inline $(CC) -c recipes (incl. thin_glue wave758).
  if grep -A2 -E '^(src/driver/target_cpu\.o|src/ast/ast_seed\.o|pipeline_bootstrap_orchestration\.o|parser_asm_thin_glue\.o):' Makefile \
    | grep -qE '\$\(CC\).*-c seeds/'; then
    bad "Makefile seed-map leaves still have inline \$(CC) -c (must thin-call ensure)"
  else
    note "Makefile seed-map leaves thin (no inline \$(CC) -c; wave758 thin_glue)"
  fi
  # wave759: glue standalone target is $(ASM_GLUE_STANDALONE_O) — recipe must call ensure,
  # not residual cc_inc_tu (G.7 single body via ensure_one).
  if awk '
    /^\$\(ASM_GLUE_STANDALONE_O\):|^build_asm\/pipeline_glue_standalone\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body !~ /cc_inc_tu\.sh/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile glue standalone thin (ensure; no cc_inc_tu; wave759)"
  else
    bad "Makefile ASM_GLUE_STANDALONE / pipeline_glue_standalone must thin-call ensure (wave759; no cc_inc_tu)"
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
  if grep -nE '^(export )?R3_COLD_SEED_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode R3_COLD_SEED_OBJS= in shell body"
  fi
  if grep -nE '^(export )?DRIVER_SEED_PANIC_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode DRIVER_SEED_PANIC_OBJS= in shell body (wave760)"
  fi
  if grep -nE '^(export )?DRIVER_SEED_TYPECK_F64_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode DRIVER_SEED_TYPECK_F64_OBJS= in shell body (wave762)"
  fi
  if grep -nE '^(export )?DRIVER_SEED_CRT0_OBJS=' "$0" 2>/dev/null \
    | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
    bad "must not hardcode DRIVER_SEED_CRT0_OBJS= in shell body (wave762)"
  fi

  # wave760: Makefile cold panic body must thin-call try-r2 (PREFER thin may stay).
  if awk '
    /^runtime_panic\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      # At least one recipe body must call ensure try-r2 / r2-panic.
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-r2|r2-panic|try_r2/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile runtime_panic cold thin-calls ensure try-r2 (wave760)"
  else
    bad "Makefile runtime_panic.o cold path must thin-call ensure try-r2 (wave760)"
  fi

  # wave762: typeck_f64 + host crt0 leaves must thin-call try-r2 (no inline $(CC) -c).
  if awk '
    /^src\/typeck\/typeck_f64_bits\.o:/ { in_t=1; next }
    in_t && /^[^[:space:]#]/ { in_t=0 }
    in_t { body = body $0 "\n" }
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-r2/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile typeck_f64_bits thin-calls ensure try-r2 (wave762)"
  else
    bad "Makefile typeck_f64_bits.o must thin-call ensure try-r2 (wave762)"
  fi
  # Host MAIN_LINK crt0 (Darwin arm64 / Linux x86_64 / …) — at least one recipe body.
  if awk '
    /^src\/asm\/crt0_[a-z0-9_]+\.o:/ { in_t=1; body=""; next }
    in_t && /^[^[:space:]#]/ {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-r2/) found=1
      in_t=0
    }
    in_t { body = body $0 "\n" }
    END { if (found) exit 0; exit 1 }
  ' Makefile; then
    note "Makefile crt0 leaves thin-call ensure try-r2 (wave762)"
  else
    bad "Makefile crt0_*.o recipes must thin-call ensure try-r2 (wave762)"
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
  # wave757: try-r3-cold entry must exist (R3 cold-else body helper)
  if ! grep -q 'try_ensure_r3_cold_one\|try-r3-cold' "$0"; then
    bad "try-r3-cold / try_ensure_r3_cold_one missing (wave757 R3 cold-else)"
  else
    note "try-r3-cold R3 cold-else helper present (wave757)"
  fi
  # wave763: try-r3-prefer PREFER thin+rest product path
  if ! grep -q 'try_ensure_r3_prefer_one\|try-r3-prefer' "$0"; then
    bad "try-r3-prefer / try_ensure_r3_prefer_one missing (wave763 R3 PREFER thin)"
  else
    note "try-r3-prefer R3 PREFER thin helper present (wave763)"
  fi
  if ! grep -q 'r3_prefer_leaf_spec\|ensure_r3_prefer_one' "$0"; then
    bad "r3 prefer body missing (wave763)"
  else
    note "r3-prefer leaf map + body present (wave763)"
  fi
  # Makefile R3_COLD nine must thin-call try-r3-prefer (no inline thin+rest).
  for leaf in \
    src/runtime_io_abi.o \
    src/runtime_driver_abi.o \
    src/runtime_driver_diagnostic.o \
    src/asm/simd_enc.o \
    src/asm/simd_loop.o \
    src/asm/backend_enc_dispatch.o \
    src/asm/backend_arch_emit_dispatch.o \
    src/asm/backend_try_inline_dispatch.o \
    src/asm/backend_call_dispatch.o
  do
    if awk -v t="$leaf" '
      $0 ~ "^" t ":" {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-r3-prefer/) exit 0
        exit 1
      }
    ' Makefile; then
      note "Makefile $leaf thin-calls ensure try-r3-prefer (wave763)"
    else
      bad "Makefile $leaf must thin-call ensure try-r3-prefer (wave763)"
    fi
    # No residual inline ld -r thin+rest in the leaf recipe body.
    if awk -v t="$leaf" '
      $0 ~ "^" t ":" {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END {
        if (body ~ /ld -r/ && body ~ /_rest\.o/) exit 1
        exit 0
      }
    ' Makefile; then
      :
    else
      bad "Makefile $leaf still has inline ld -r thin+rest (wave763)"
    fi
  done
  # wave764: g05 product daily path must thin-call r3-prefer-family (no dual hybrid
  # for R3_COLD nine: rio / rdabi / rdd / simd_* / backend_*).
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'r3-prefer-family\|r3_prefer_family' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure r3-prefer-family (wave764)"
    else
      bad "g05_ensure must thin-call ensure r3-prefer-family for R3_COLD (wave764)"
    fi
    # Dual body residual: g05 must not re-open inline hybrid for R3_COLD leaves.
    if grep -qE 'g05_rio_thin|g05_rdabi_thin|g05_rdd_thin|g05_simd_enc_thin|g05_bed_thin|G-02f-334：runtime_io_abi' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has R3_COLD dual hybrid body (wave764)"
    else
      note "g05_ensure R3_COLD dual hybrid body removed (wave764)"
    fi
    # wave764 full ladder in leaf map (simd/backend full.x field present).
    if grep -q 'XLANG_SIMD_ENC_FROM_X' "$0" \
      && grep -q 'r3_prefer_try_step' "$0"; then
      note "try-r3-prefer full→thin ladder present (wave764)"
    else
      bad "try-r3-prefer must gain full→thin ladder (wave764)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave764 g05 gate)"
  fi
  # wave765: try-labi-prefer labi multi-slice (g05 + Makefile thin-call; no dual hybrid)
  if ! grep -q 'try_ensure_labi_prefer_one\|try-labi-prefer' "$0"; then
    bad "try-labi-prefer / try_ensure_labi_prefer_one missing (wave765 labi multi-slice)"
  else
    note "try-labi-prefer labi multi-slice helper present (wave765)"
  fi
  if ! grep -q 'ensure_labi_prefer_one\|labi_prefer_try_x_to_o' "$0"; then
    bad "labi prefer body missing (wave765)"
  else
    note "labi-prefer multi-slice body present (wave765)"
  fi
  if awk '
    $0 ~ /^src\/runtime_link_abi\.o:/ {grab=1; next}
    grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
    grab {body = body $0 "\n"}
    END {
      if (body ~ /ensure_host_cc_seed_o\.sh/ && body ~ /try-labi-prefer/) exit 0
      exit 1
    }
  ' Makefile; then
    note "Makefile src/runtime_link_abi.o thin-calls ensure try-labi-prefer (wave765)"
  else
    bad "Makefile src/runtime_link_abi.o must thin-call ensure try-labi-prefer (wave765)"
  fi
  if [ -f scripts/g05_ensure_relink_prereqs.sh ]; then
    if grep -q 'try-labi-prefer\|labi-prefer' scripts/g05_ensure_relink_prereqs.sh \
      && grep -q 'ensure_host_cc_seed_o.sh' scripts/g05_ensure_relink_prereqs.sh; then
      note "g05_ensure thin-calls ensure try-labi-prefer (wave765)"
    else
      bad "g05_ensure must thin-call ensure try-labi-prefer for labi (wave765)"
    fi
    if grep -qE 'g05_labi_l0\.|_labi_l0_seed=seeds/labi_path_pure|_labi_rest_defs=.*LABI_PATH_PURE' \
      scripts/g05_ensure_relink_prereqs.sh; then
      bad "g05_ensure still has labi multi-slice dual hybrid body (wave765)"
    else
      note "g05_ensure labi multi-slice dual hybrid body removed (wave765)"
    fi
  else
    bad "scripts/g05_ensure_relink_prereqs.sh missing (wave765 g05 gate)"
  fi
  # wave760/762: try-r2 R2 UNAME leaves (panic + typeck_f64 + crt0)
  if ! grep -q 'try_ensure_r2_one\|try-r2' "$0"; then
    bad "try-r2 / try_ensure_r2_one missing (wave760/762 R2 UNAME)"
  else
    note "try-r2 R2 UNAME helper present (wave760 panic + wave762 typeck_f64/crt0)"
  fi
  if ! grep -q 'ensure_r2_typeck_f64_one\|r2_typeck_f64_host_pick' "$0"; then
    bad "r2 typeck_f64 body missing (wave762)"
  else
    note "r2-typeck-f64 body present (wave762)"
  fi
  if ! grep -q 'ensure_r2_crt0_one\|r2_crt0_src_for_out' "$0"; then
    bad "r2 crt0 body missing (wave762)"
  else
    note "r2-crt0 body present (wave762)"
  fi
  # wave761: try-gen-x gen residual helper
  if ! grep -q 'try_ensure_gen_x_one\|try-gen-x' "$0"; then
    bad "try-gen-x / try_ensure_gen_x_one missing (wave761 gen residual)"
  else
    note "try-gen-x gen residual helper present (wave761)"
  fi
  if [ ! -f scripts/ensure_gen_x_o.sh ]; then
    bad "scripts/ensure_gen_x_o.sh missing (wave761)"
  else
    note "ensure_gen_x_o.sh present (wave761)"
  fi
  # Makefile gen residual thin-call ensure_gen_x_o
  for leaf in lsp_io_x.o lsp_x.o lsp_diag_x.o pipeline_x.o; do
    if awk -v t="$leaf" '
      $0 ~ "^" t ":" {grab=1; next}
      grab && /^[^\t#]/ && $0 !~ /^$/ {exit}
      grab {body = body $0 "\n"}
      END { if (body ~ /ensure_gen_x_o\.sh/) exit 0; exit 1 }
    ' Makefile; then
      note "Makefile $leaf thin-calls ensure_gen_x_o (wave761)"
    else
      bad "Makefile $leaf must thin-call ensure_gen_x_o.sh (wave761)"
    fi
  done

  if [ "$fail" -ne 0 ]; then
    echo "ensure_host_cc_seed_o: --check FAILED" >&2
    exit 1
  fi
  echo "ensure_host_cc_seed_o: CHECK OK (R1 families + try-r1 + R3 cold-else + R3 PREFER thin + R2 panic/typeck_f64/crt0 + gen-x residual · wave748–763)" >&2
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
  try-r3-cold|try_r3_cold|r3-cold|r3-cold-one)
    # wave757: R3 cold-else helper — exit 3 if not R3_COLD_SEED_OBJS member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r3-cold: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r3_cold_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-r3-prefer|try_r3_prefer|r3-prefer|r3-prefer-one|prefer-thin|try-prefer-thin)
    # wave763: R3 PREFER thin+rest helper — exit 3 if not R3_COLD_SEED_OBJS member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r3-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r3_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  r3-prefer-family|r3_prefer_family|prefer-thin-family|family=r3_prefer)
    ensure_r3_prefer
    ;;
  try-labi-prefer|try_labi_prefer|labi-prefer|labi-prefer-one|try-labi)
    # wave765: labi multi-slice PREFER helper — exit 3 if not src/runtime_link_abi.o.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-labi-prefer: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_labi_prefer_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-r2|try_r2|try-r2-panic|r2-one|r2-panic-one)
    # wave760/762: R2 UNAME helper — panic | typeck_f64 | crt0; exit 3 if not member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-r2: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_r2_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  try-gen-x|try_gen_x|try-gen|gen-x-one|r4-gen-one)
    # wave761: gen residual helper — exit 3 if not gen map + catalog member.
    if [ "$#" -lt 1 ]; then
      echo "ensure_host_cc_seed_o try-gen-x: need <out.o>" >&2
      exit 2
    fi
    _try_out="$1"
    set +e
    try_ensure_gen_x_one "$_try_out"
    _try_rc=$?
    set -e
    exit "$_try_rc"
    ;;
  r3-cold-seed|r3_cold_seed|cold-seed|family=r3_cold_seed)
    ensure_r3_cold_seed
    ;;
  r2-panic|r2_panic|panic-cold|family=r2_panic|family=driver_seed_panic)
    ensure_r2_panic
    ;;
  r2-typeck-f64|r2_typeck_f64|typeck-f64|typeck_f64|family=r2_typeck_f64|family=driver_seed_typeck_f64)
    ensure_r2_typeck_f64
    ;;
  r2-crt0|r2_crt0|crt0|family=r2_crt0|family=driver_seed_crt0)
    ensure_r2_crt0
    ;;
  gen-x|gen_x|residual-gen|family=gen_x|family=r4_gen_x)
    ensure_gen_x_residual
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
    echo "ensure_host_cc_seed_o: unknown mode '$MODE' (one|try-r1|try-r3-cold|try-r3-prefer|try-labi-prefer|try-r2|try-gen-x|rt-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map|r3-cold-seed|r2-panic|r2-typeck-f64|r2-crt0|gen-x|all|--check)" >&2
    exit 2
    ;;
esac

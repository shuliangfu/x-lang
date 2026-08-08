#!/usr/bin/env bash
# bc_host_cc_product_inventory.sh — wave963 · open BC track (stage 8.3 map)
#
# Authority (G.7):
#   Single machine-checkable inventory of *product residual C* that still
#   require host-cc on the cold / product path (BC layer). Does NOT compile
#   and does NOT own .o lists (those stay compiler/mk/*.mk + catalog).
#
#   Human map: analysis/C迁移追踪.md §8.3
#   Progress:  analysis/自举进度.md (wave rows)
#   Related:   leaf_pattern_residual.sh (MG leaf residual · already closed)
#
# What this is:
#   BC = bootstrap compile layer: compiler TUs should not need host cc/gcc.
#   Today glue/ast_pool / pin gen / stubs still do. This script freezes the
#   known residual surface so new orphan product C cannot land silently, and
#   so 8.3.9-class debug scratch cannot reappear under analysis/.
#
# What this is NOT:
#   - Not a second compile driver
#   - Not physical delete of product glue (that is later 8.3.1+ waves)
#   - Not pin lift
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/bc_host_cc_product_inventory.sh
#   bash compiler/scripts/bc_host_cc_product_inventory.sh dump
#   bash compiler/scripts/bc_host_cc_product_inventory.sh --check
#   ./xbuild bc-inventory | bc-host-cc [--check]
#
# PLATFORM: SHARED — inventory of sources; ABI lives in the residual bodies.
# Wave: 963 open BC + 8.3.9 orphan gone (analysis/_debug_io_ctx_gen.c was
# gitignored local scratch; --check asserts ABSENT).
# 8.3.1 domain thin cuts: typeck (ctfe/assign/coerce/method/check_block/region) +
#   asm emit leaves (unary…expr_rec + async_cps/lea/var_decl/with_arena/x86_enc)
#   (#include into pipeline_glue TU).
# 8.3.2 domain thin cuts (wave978–1280): ast_pool shell is #include orchestration
#   only (~0.18k); domain leaves cover lifecycle/typedefs/sidecar/GrowVec + pool
#   cold accessors + pipeline orchestration (resolve/import/parse/codegen/lsp) +
#   ELF write/ctx + codegen type-to-c/skip/struct/residual + asm locals…WPO +
#   EMIT_HEAVY env/safe_helper/parser + skip_dispatch/diag + backend wrapper +
#   scratch. All same-TU #include into pipeline_x (still host-cc).
# wave1281: honesty pass — shell min_loc floors match post-thin reality; register
#   ~40 extracted domain leaves that were already on PIPELINE_X_DEPS but missing
#   from this inventory (bc-inventory --check was red on glue/ast_pool floors).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"

MODE="${1:-dump}"
case "$MODE" in
  --check|check|-c) MODE=check ;;
  dump|list|""|--dump) MODE=dump ;;
  help|-h|--help)
    sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "bc_host_cc_product_inventory: unknown mode '$MODE' (use dump|check)" >&2
    exit 2
    ;;
esac

# relpath_from_repo|stage_id|role|min_loc|expect
# expect: present | absent
# min_loc: for present rows, soft floor (0 = any non-empty / placeholder OK)
PRODUCT_RESIDUAL_ROWS=(
  # --- 8.3.1 / 8.3.2 host shells (post-thin floors · wave1281 honesty) ---
  # glue ~3.4k residual body + #include face; not the historical ~18k mega.
  "compiler/pipeline_glue.c|8.3.1|product glue host shell retired wave309 (0 body mega; product pure-ld no pipeline_x)|0|absent"
  # ast_pool ~0.18k pure #include orchestration; domain bodies live in leaves.
  "compiler/ast_pool.c|8.3.2|AST pool host shell retired wave309 (structure floor leave)|0|absent"
  # --- 8.3.2 ast_pool domain leaves (same-TU into pipeline_x) ---
  "compiler/ast_pool_module_import.c|8.3.2|module ImportEntry Cap residual pure-owned leave (wave263)|0|absent"
  "compiler/ast_pool_struct_layout.c|8.3.2|module StructLayout Cap residual pure-owned leave (wave266)|0|absent"
  "compiler/ast_pool_top_level.c|8.3.2|module TopLevelLetEntry Cap residual pure-owned leave (wave265)|0|absent"
  "compiler/ast_pool_type_alias.c|8.3.2|module TypeAliasEntry Cap residual pure-owned leave (wave262)|0|absent"
  "compiler/ast_pool_expr_sidecar.c|8.3.2|expr (+ type-pos) var-len sidecar domain slice|0|absent"
  "compiler/ast_pool_module_enum.c|8.3.2|module ModuleEnumEntry Cap residual pure-owned leave (wave264)|0|absent"
  "compiler/ast_pool_onefunc.c|8.3.2|OneFunc sidecar + fill_from_onefunc Cap residual (wave281 leave)|0|absent"
  "compiler/ast_pool_dep_ctx.c|8.3.2|PipelineDepCtx Cap residual pure-owned leave (wave272)|0|absent"
  "compiler/ast_pool_module_func.c|8.3.2|module Func cold accessors Cap residual (wave280 leave)|0|absent"
  "compiler/ast_pool_arena.c|8.3.2|ASTArena main-pool Cap residual pure-owned leave (wave276)|0|absent"
  "compiler/ast_pool_block.c|8.3.2|block domain Cap residual pure-owned leave via seed ALWAYS (wave277)|0|absent"
  "compiler/ast_pool_lifecycle.c|8.3.2|ast_pool lifecycle/reset/release domain (wave279 leave)|0|absent"
  "compiler/ast_pool_ptr_at.c|8.3.2|ast_pool core ptr_at dead leave (wave298; zero residual callers)|0|absent"
  "compiler/ast_pool_sidecar_pool.c|8.3.2|ast_pool sidecar pool Cap residual pure-owned leave (wave275)|0|absent"
  "compiler/ast_pool_typedefs.c|8.3.2|ast_pool typedef domain retired wave309 (structure floor leave)|0|absent"
  "compiler/ast_pool_type.c|8.3.2|ast_pool type pool Cap residual pure-owned leave (wave270)|0|absent"
  "compiler/pipeline_grow_vec.c|8.3.2|GrowVec pure-owned leave (wave271)|0|absent"
  "compiler/pipeline_lint_meta.c|8.3.2|pipeline lint+meta pure-owned leave wave121|0|absent"
  "compiler/pipeline_backend_asm_wrapper.c|8.3.2|backend asm thin wrappers (wave113 pure-owned leave)|65|absent"
  "compiler/pipeline_scratch_bufs.c|8.3.2|scratch bufs retired (codegen_x.o BSS; host-cc leave)|0|absent"
  # --- 8.3.1 domain thin slices (#include into pipeline_glue TU; not separate .o) ---
  "compiler/pipeline_typeck_ctfe.c|8.3.1|typeck CTFE thin retired (typeck.x authority; host-cc leave wave255)|0|absent"
  "compiler/pipeline_typeck_assign.c|8.3.1|typeck assign Cap residual retired (typeck.x authority; host-cc leave wave256)|0|absent"
  "compiler/pipeline_typeck_coerce_init.c|8.3.1|typeck coerce-init Cap residual retired (typeck.x authority; host-cc leave wave258)|0|absent"
  "compiler/pipeline_typeck_method_call.c|8.3.1|typeck method_call Cap residual pure-owned leave (wave260)|400|absent"
  "compiler/pipeline_typeck_check_block.c|8.3.1|typeck check_block Cap residual retired (typeck.x authority; host-cc leave wave259)|0|absent"
  "compiler/pipeline_typeck_region_assign.c|8.3.1|typeck region/escape Cap residual retired (typeck.x authority; host-cc leave wave257)|0|absent"
  "compiler/pipeline_asm_emit_unary.c|8.3.1|asm ELF unary emit (wave133 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_as.c|8.3.1|asm ELF as/await/try/float-lit emit (wave138 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_modlet.c|8.3.1|asm ELF modlet COMMON cell emit (wave139 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_return.c|8.3.1|asm ELF return emit (wave144 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_logand.c|8.3.1|asm ELF LOGAND/LOGOR short-circuit emit (wave128 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_block_body.c|8.3.1|asm ELF block body sync emit (wave153 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_block_if_stmt.c|8.3.1|asm ELF block-level if-stmt emit (wave129 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_wpo_mono.c|8.3.1|asm ELF WPO-S2 mono thunk bag+emit (wave130 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_block_inits.c|8.3.1|asm ELF block const/let init emit slice (wave145 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_assign.c|8.3.1|asm ELF EXPR_ASSIGN emit (wave142 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_array_lit.c|8.3.1|asm ELF EXPR_ARRAY_LIT emit (wave143 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_index.c|8.3.1|asm ELF EXPR_INDEX/ADDR_OF/DEREF emit (wave140 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_context.c|8.3.1|asm ELF emit context set/get + frame/param/local slots (wave141 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_match.c|8.3.1|asm ELF EXPR_MATCH/EXPR_IF emit (arm cmp+jeq + if jz) slice|140|absent"
  "compiler/pipeline_asm_emit_panic.c|8.3.1|asm ELF EXPR_PANIC + int div-zero face (wave127 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_field_access.c|8.3.1|asm ELF EXPR_FIELD_ACCESS emit (wave151 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_binop.c|8.3.1|asm ELF EXPR_BINOP emit (wave149 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_cmp.c|8.3.1|asm ELF relational CMP emit (wave137 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_call_args.c|8.3.1|asm ELF CALL-arg emit (wave218 pure-owned leave; call_args+spill+index shells)|0|absent"
  "compiler/pipeline_asm_emit_struct_lit.c|8.3.1|asm ELF STRUCT_LIT emit (wave154 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_fold_count_up_while.c|8.3.1|asm ELF count_up_while fold + while/for emit (wave155 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_vector_let.c|8.3.1|asm ELF vector_let / fixed-array field store (wave146 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_vector_simd.c|8.3.1|asm ELF SIMD vector lane / shuffle / select / fma (wave148 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_struct_let.c|8.3.1|asm ELF struct let-init domain (wave132 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_index_helpers.c|8.3.1|asm ELF INDEX residual helpers (wave218 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_spill.c|8.3.1|asm ELF 7.3 live/Chaitin Cap residual (wave218 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_index_eff_addr.c|8.3.1|asm ELF INDEX eff-addr (wave147 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_expr_rec.c|8.3.1|asm ELF expr recursion + fast (lit_i32 + rec + emit_expr_elf_c + fast) slice|0|absent"
  "compiler/pipeline_asm_emit_async_cps.c|8.3.1|asm ELF async/CPS emit domain (wave131 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_lea_common.c|8.3.1|asm ELF lea common helpers (wave123 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_var_decl.c|8.3.1|asm ELF var decl emit (wave124 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_with_arena.c|8.3.1|asm ELF with_arena emit (wave122 pure-owned leave)|0|absent"
  "compiler/pipeline_asm_emit_x86_enc_helpers.c|8.3.1|asm x86 enc helpers|0|absent"
  "compiler/pipeline_asm_emit_fold_primitives.c|8.3.1|asm fold pattern detectors (wave136 pure-owned leave)|0|absent"
  # --- 8.3.2 pipeline/asm/codegen domain leaves (wave1246–1280; still host-cc) ---
  "compiler/pipeline_elf_write_o.c|8.3.2|ELF/Mach-O .o writers pure-owned leave (wave273)|0|absent"
  "compiler/pipeline_elf_ctx.c|8.3.2|ELF/Mach-O ctx accessors pure-owned leave (wave273)|0|absent"
  "compiler/pipeline_codegen_type_to_c.c|8.3.2|codegen type-to-c (wave109 pure-owned leave)|240|absent"
  "compiler/pipeline_codegen_skip_force.c|8.3.2|codegen skip/force predicates (wave1249 pure-owned leave)|270|absent"
  "compiler/pipeline_codegen_struct_emit.c|8.3.2|codegen struct emit (wave110 pure-owned leave)|170|absent"
  "compiler/pipeline_codegen_residual.c|8.3.2|codegen residual name/predicate (wave1251 pure-owned leave)|130|absent"
  "compiler/pipeline_asm_ctx_layout.c|8.3.1|AsmFuncCtx layout cast pure leave (wave125); typedef in glue shell|0|absent"
  "compiler/pipeline_glue_early_fwd.c|8.3|glue early fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_mid_fwd.c|8.3|glue mid fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_backend_fwd.c|8.3|glue backend fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_typeck_fwd.c|8.3|glue typeck fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_typeck_mid_fwd.c|8.3|glue typeck mid fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_emit_fwd.c|8.3|glue emit fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_emit_block_fwd.c|8.3|glue emit block fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_emit_lea_fwd.c|8.3|glue emit lea fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_emit_mid_fwd.c|8.3|glue emit mid fwd shell retired wave309|0|absent"
  "compiler/pipeline_glue_statics.c|8.3|glue emit/typeck Cap residual pure-owned leave (wave261; BSS era closed wave224)|0|absent"
  "compiler/pipeline_asm_locals.c|8.3.2|asm locals + block slot sidecar (wave1252; pure leave wave267)|200|absent"
  "compiler/pipeline_asm_slot_bytes.c|8.3.2|asm slot bytes + ensure_block_locals (wave1253; pure leave wave268)|320|absent"
  "compiler/pipeline_asm_block_tree.c|8.3.2|asm block tree traversal + frame sizing (wave1254; pure leave wave269)|210|absent"
  "compiler/pipeline_asm_ctx_loop.c|8.3.2|asm ctx loop + block emit cont (wave114 pure-owned leave)|130|absent"
  "compiler/pipeline_asm_wpo.c|8.3.2|asm WPO v0 DCE + PGO-Lite pure-owned leave (wave274)|0|absent"
  "compiler/pipeline_asm_selfhost.c|8.3.2|asm module self-host classification (wave115 pure-owned leave)|190|absent"
  "compiler/pipeline_asm_thin_delegate.c|8.3.2|asm M8-tail thin delegate tables (wave116 pure-owned leave)|220|absent"
  "compiler/pipeline_asm_emit_heavy_safe_helper.c|8.3.2|EMIT_HEAVY safe-helper classifiers (wave117 pure-owned leave)|470|absent"
  "compiler/pipeline_asm_parser_emit_heavy.c|8.3.2|asm parser EMIT_HEAVY pure-owned leave wave120|0|absent"
  "compiler/pipeline_asm_diag.c|8.3.2|asm diagnostics retired (runtime_pipeline_abi pure; host-cc leave)|0|absent"
  "compiler/pipeline_asm_skip_dispatch.c|8.3.2|asm skip/stub dispatch pure-owned leave wave118|0|absent"
  "compiler/pipeline_asm_emit_heavy_env.c|8.3.2|EMIT_HEAVY env/thresholds/path/whitelist (wave1280)|0|absent"
  "compiler/pipeline_resolve_path.c|8.3.2|import path resolve retired (runtime_pipeline_abi pure; host-cc leave)|0|absent"
  "compiler/pipeline_import_bind.c|8.3.2|fs read + import bind/sync (wave1270; pure leave 2026-08-05)|100|absent"
  "compiler/pipeline_parse_typeck_dispatch.c|8.3.2|parse/typeck dispatch retired (runtime_pipeline_abi pure wave112 leave)|0|absent"
  "compiler/pipeline_run_x_pipeline.c|8.3.2|run_x_pipeline core orchestration (wave1272)|90|absent"
  "compiler/pipeline_loop_glue.c|8.3.2|loop glue retired (codegen_x.o; host-cc leave)|0|absent"
  "compiler/pipeline_codegen_dep.c|8.3.2|codegen dep orchestration (wave111 pure-owned leave)|360|absent"
  "compiler/pipeline_lsp_diag.c|8.3.2|LSP diag retired (runtime_pipeline_abi pure; host-cc leave)|0|absent"
  "compiler/pipeline_emit_sidecar.c|8.3.2|emit sidecar retired (runtime_pipeline_abi pure; host-cc leave)|0|absent"
  "compiler/pipeline_preprocess_if.c|8.3.2|preprocess #if stack retired (runtime_pipeline_abi pure; host-cc leave)|0|absent"
  "compiler/pipeline_typeck_slots.c|8.3.1|typeck slots retired (typeck_x.o BSS; host-cc leave)|0|absent"
  # --- 8.3.3 typeck slices often pulled by glue ---
  "compiler/pipeline_typeck_field_access.c|8.3.3|field_access thin retired (typeck.x authority; host-cc leave)|0|absent"
  "compiler/pipeline_typeck_soa.c|8.3.3|soa thin retired (typeck.x authority; host-cc leave)|0|absent"
  # --- 8.3.4 bootstrap glue / orchestration ---
  "compiler/ast_pool_bootstrap_glue.c|8.3.4|bootstrap glue retired (seed ALWAYS leave wave282)|0|absent"
  "compiler/pipeline_ast_forwarders.c|8.3.2|ast_pipeline_* forwarders retired (seed ALWAYS leave wave283)|0|absent"
  "compiler/pipeline_parse_orch.c|8.3.2|parse/load/typeck orch Cap residual (wave284 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_typeck_orch.c|8.3.2|typeck orch Cap residual thin (wave285 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_typeck_check_expr.c|8.3.2|typeck check_expr Cap residual thin (wave286 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_parser_result.c|8.3.2|parser result copy/lex/slice Cap residual (wave287 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_asm_label_format.c|8.3.2|asm label format Cap residual (wave288 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_codegen_outbuf.c|8.3.2|codegen outbuf Cap residual (wave289 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_asm_codegen_mega_body.c|8.3.2|asm codegen mega_body Cap residual (wave290 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_elf_codegen_forwarders.c|8.3.2|elf/codegen prefix forwarders Cap residual (wave291 seed ALWAYS leave)|0|absent"
  "compiler/pipeline_bootstrap_orchestration.c|8.3.4|orchestration host wrapper retired (wave292 seed-only .o)|0|absent"
  # --- 8.3 product weak twin / standalone seed ---
  "compiler/seeds/pipeline_glue_standalone.from_x.c|8.3.1|standalone glue seed retired wave309 (product pure-ld no mega)|0|absent"
  "compiler/seeds/pipeline_glue_strict_minimal.from_x.c|8.3.6|strict_minimal seed shell retired wave304 (0 T after wave303; product g05 unlinked)|0|absent"
  # --- 8.3.5 link alias / stubs (wave293: 5 seed host wrappers leave; wave294: _stubs+xlang_x_stubs leave) ---
  "compiler/ast_asm_bare_link_alias.c|8.3.5|bare link alias host wrapper retired (wave293 seed-only .o)|0|absent"
  "compiler/backend_asm_bare_link_alias.c|8.3.5|bare link alias host wrapper retired (wave293 seed-only .o)|0|absent"
  "compiler/backend_asm_strict_fallback_alias.c|8.3.5|strict fallback alias host wrapper retired (wave293 seed-only .o)|0|absent"
  "compiler/typeck_asm_bare_link_alias.c|8.3.5|typeck bare link alias host retired (wave296 seed-only .o)|0|absent"
  "compiler/x_frontend_link_alias.c|8.3.5|x frontend link alias host wrapper retired (wave293 seed-only .o)|0|absent"
  "compiler/_stubs.c|8.3.5|cold weak stubs host retired (wave294 seed x_stubs.from_x authority)|0|absent"
  "compiler/_x_stubs2.c|8.3.5|x frontend stubs2 host retired (wave295 dead dual; not g05/stage2 link)|0|absent"
  "compiler/xlang_x_stubs.c|8.3.5|xlang-x stubs host retired (wave294 seed x_stubs.from_x authority)|0|absent"
  "compiler/typeck_c_module_stubs.c|8.3.5|typeck c-module stubs host wrapper retired (wave293 seed-only .o)|0|absent"
  # --- 8.3.7 scripts asm stubs ---
  "compiler/scripts/asm_text_stub.c|8.3.7|asm text stub host retired (wave297 seed authority)|0|absent"
  "compiler/scripts/asm_xlang_lsp_diag_stub.c|8.3.7|lsp diag asm stub host retired (wave297 seed authority)|0|absent"
  # --- 8.3.9 orphan debug gen (wave963: must stay gone) ---
  "analysis/_debug_io_ctx_gen.c|8.3.9|orphan debug gen (gitignored scratch)|0|absent"
)

# 8.3.8 gen_driver placeholders live outside compiler/; empty files are OK.
GEN_DRIVER_DIR="build_asm/gen_driver"
GEN_DRIVER_EXPECTED=(
  driver_check.c
  driver_fmt.c
  driver_gen.c
  driver_test.c
  lsp_gen.c
  lsp_io_gen.c
  lsp_io_std_heap_gen.c
  pipeline_gen.c
  preprocess_gen.c
)

loc_of() {
  local f="$1"
  if [ ! -f "$f" ]; then
    echo 0
    return
  fi
  wc -l < "$f" | tr -d ' '
}

dump_rows() {
  local row path stage role min_loc expect abs loc status
  echo "BC_HOST_CC_PRODUCT_INVENTORY wave963"
  echo "ROOT=$ROOT"
  echo "MODE=dump"
  echo "--- product residual C (stage 8.3 map) ---"
  printf '%-8s %-10s %7s %s\n' "EXPECT" "STAGE" "LOC" "PATH"
  for row in "${PRODUCT_RESIDUAL_ROWS[@]}"; do
    IFS='|' read -r path stage role min_loc expect <<<"$row"
    abs="$ROOT/$path"
    if [ -f "$abs" ]; then
      loc="$(loc_of "$abs")"
      status="present"
    else
      loc=0
      status="absent"
    fi
    printf '%-8s %-10s %7s %s\n' "$status" "$stage" "$loc" "$path"
  done
  echo "--- 8.3.8 build_asm/gen_driver placeholders ---"
  local g
  for g in "${GEN_DRIVER_EXPECTED[@]}"; do
    abs="$ROOT/$GEN_DRIVER_DIR/$g"
    if [ -f "$abs" ]; then
      loc="$(loc_of "$abs")"
      printf 'present  8.3.8     %7s %s/%s\n' "$loc" "$GEN_DRIVER_DIR" "$g"
    else
      printf 'absent   8.3.8     %7s %s/%s\n' "0" "$GEN_DRIVER_DIR" "$g"
    fi
  done
  echo "--- summary ---"
  local present=0 absent=0
  for row in "${PRODUCT_RESIDUAL_ROWS[@]}"; do
    IFS='|' read -r path stage role min_loc expect <<<"$row"
    if [ -f "$ROOT/$path" ]; then present=$((present + 1)); else absent=$((absent + 1)); fi
  done
  echo "ROWS=${#PRODUCT_RESIDUAL_ROWS[@]} present_on_disk=$present absent_on_disk=$absent"
  echo "BC_TRACK=open wave963"
  echo "NEXT=BC 8.3 floor closed + wave320 product no_c refuse monofile (present 0); monofile seed still in tree for R1 other leaves; M4 7.1.1／7.4.1 关 pin ⬜; BC 终局 still ⬜"
}

run_check() {
  local fail=0
  note() { echo "bc_host_cc_product_inventory: $*" >&2; }
  bad() { echo "bc_host_cc_product_inventory: FAIL: $*" >&2; fail=1; }

  note "wave963 BC track open — product residual C inventory check"
  note "PLATFORM: SHARED — inventory only; no compile"

  local row path stage role min_loc expect abs loc
  local present_debt=0
  for row in "${PRODUCT_RESIDUAL_ROWS[@]}"; do
    IFS='|' read -r path stage role min_loc expect <<<"$row"
    abs="$ROOT/$path"
    case "$expect" in
      present)
        if [ ! -f "$abs" ]; then
          bad "missing expected residual $path ($stage · $role)"
          continue
        fi
        loc="$(loc_of "$abs")"
        if [ "$loc" -lt "$min_loc" ]; then
          bad "$path loc=$loc < min_loc=$min_loc ($stage)"
        else
          note "ok present $path loc=$loc ($stage)"
        fi
        present_debt=$((present_debt + 1))
        ;;
      absent)
        if [ -e "$abs" ]; then
          bad "must stay absent (wave963 8.3.9): $path still exists"
        else
          note "ok absent $path ($stage)"
        fi
        ;;
      *)
        bad "unknown expect='$expect' for $path"
        ;;
    esac
  done

  # 8.3.8: directory + named placeholders (empty files allowed; missing dir soft-notes).
  if [ ! -d "$ROOT/$GEN_DRIVER_DIR" ]; then
    note "gen_driver dir absent (ok if unused on this host): $GEN_DRIVER_DIR"
  else
    local g
    for g in "${GEN_DRIVER_EXPECTED[@]}"; do
      if [ ! -f "$ROOT/$GEN_DRIVER_DIR/$g" ]; then
        bad "missing gen_driver placeholder $GEN_DRIVER_DIR/$g (8.3.8)"
      fi
    done
    note "ok gen_driver placeholders n=${#GEN_DRIVER_EXPECTED[@]}"
  fi

  # Guard: no second debug orphan under analysis/ matching *_debug_*_gen.c
  # (gitignored area — only catch local reintroduction).
  if [ -d "$ROOT/analysis" ]; then
    local hit
    hit="$(find "$ROOT/analysis" -maxdepth 1 -type f \( -name '_debug_*_gen.c' -o -name '*_debug_io_ctx_gen.c' \) 2>/dev/null | head -5 || true)"
    if [ -n "$hit" ]; then
      bad "analysis/ debug gen scratch reappeared (8.3.9 class): $hit"
    else
      note "ok no analysis/ _debug_*_gen.c scratch"
    fi
  fi

  # Self-document wave tag + xbuild surface (leaf honesty twin).
  if ! grep -q 'wave963' "$0"; then
    bad "inventory script must document wave963"
  fi
  if [ ! -f "$ROOT/xlang-build.sh" ]; then
    bad "missing root xlang-build.sh"
  elif ! grep -qE 'bc-inventory|bc_host_cc_product_inventory' "$ROOT/xlang-build.sh"; then
    bad "xlang-build.sh must wire bc-inventory → this script (wave963)"
  else
    note "ok xbuild bc-inventory wiring"
  fi

  # wave309: 8.3 structure floor can close to present=0 (glue shell／typedefs／9×fwd／standalone).
  # Under-count guard only when debt still expected open (>=1 and < floor).
  if [ "$present_debt" -eq 0 ]; then
    note "present residual product C rows=0 (wave309 8.3 structure floor closed)"
  elif [ "$present_debt" -lt 1 ]; then
    bad "present residual debt rows invalid"
  else
    note "present residual product C rows=$present_debt (BC residual still open)"
  fi

  if [ "$fail" -ne 0 ]; then
    echo "bc_host_cc_product_inventory: --check FAILED" >&2
    exit 1
  fi
  echo "bc_host_cc_product_inventory: CHECK OK (wave309 8.3 structure floor closed · present 0 · glue/typedefs/9×fwd/standalone absent · gen/runtime host-cc seeds may remain outside this map)" >&2
}

case "$MODE" in
  dump) dump_rows ;;
  check) run_check ;;
esac

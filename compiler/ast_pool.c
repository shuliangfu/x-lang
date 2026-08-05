/**
 * ast_pool.c — AST 块/模块/OneFunc 附属数据的 C 侧可增长池。
 *
 * Block 不再内嵌 const/let/if/expr_stmt/stmt_order 固定数组，仅保留 base+count；
 * Module.funcs 亦迁至可增长池。由 pipeline_glue.c #include 进同一 TU。
 */
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#if defined(__APPLE__) || defined(__linux__)
#include <sys/mman.h>
#endif
#include <xlang_weak.h>
#include "diag.h"

/* wave246 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product ast_pool residual raw getenv call sites migrate to this face
 * (DEBUG_PIPE / ASM_DEBUG / TRACE / WPO / emit-heavy / bootstrap-emit gates; same G.7
 * pattern as wave240 pipeline_glue). Textually #include'd into pipeline_glue /
 * pipeline_glue_standalone; redeclaration is compatible with glue's wave240 extern.
 */
extern char *link_abi_getenv(const char *name);

/* Pool grow policy macros must precede pipeline_grow_vec.c (uses AST_POOL_GROW /
 * AST_POOL_INIT_CAP). ifndef-guarded copies also live in ast_pool_typedefs.c for
 * readers of that domain file alone. PLATFORM: SHARED. */
#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

/* BC 8.3.2 wave1278: GrowVec leaf → pipeline_grow_vec.c (wave1275);
 * early typedef domain → ast_pool_typedefs.c; sidecar pool → ast_pool_sidecar_pool.c
 * (wave1276); core ptr_at accessors → ast_pool_ptr_at.c.
 * Order is load-bearing: macros → GrowVec type → entry/sidecar typedefs → pool
 * globals → ptr_at. PLATFORM: SHARED — same-TU #include into pipeline_glue / pipeline_x.
 */
#include "pipeline_grow_vec.c"
#include "ast_pool_typedefs.c"
#include "ast_pool_sidecar_pool.c"
#include "ast_pool_ptr_at.c"

/** Forward: pipeline_arena_block_alloc calls this before its definition in lifecycle. */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref);

/** BC 8.3.2: ASTArena main-pool cold accessors domain (same-TU thin). */
#include "ast_pool_arena.c"

/* wave1166 G.7: type pool cold accessors (read/write/find-or-alloc) —
 * migrated from pipeline_glue.c L1041-1153/L2216. Same TU via ast_pool.c
 * #include. Depends on pipeline_arena_type_ptr / pipeline_arena_type_alloc
 * (ast_pool_arena.c above). Forward decls retained in glue.c L761-762
 * (kind_ord_at / array_size_at) for callsites before this #include at
 * glue.c L5160.
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these. */
#include "ast_pool_type.c"


#include "ast_pool_lifecycle.c"


/** BC 8.3.2: Module Func cold accessors domain (same-TU thin). */
#include "ast_pool_module_func.c"


#include "pipeline_lint_meta.c"


/** BC 8.3.2 wave988–990 + wave992: block domain thin (append/region/defer +
 * loop/labeled/getters + parent/resolve + stmt_order rebuild/fixup) — same-TU. */
#include "ast_pool_block.c"

/* BC 8.3.2 wave991: onefunc fill residual lives in ast_pool_onefunc.c (include later).
 * BC 8.3.2 wave993+994: name_is_const + hoist + asm hoist_target / sum stack live in
 * ast_pool_top_level.c (include below; after block so static prepend_lets is visible).
 * BC 8.3.2 wave1280: emit-heavy env/thresholds + path helpers / whitelist →
 * pipeline_asm_emit_heavy_env.c (before selfhost).
 * wave1281 shell scan: no function bodies remain here — host shell is #include
 * orchestration + pool macros + link_abi_getenv extern + one forward decl only.
 * PLATFORM: SHARED same-TU into pipeline_glue / pipeline_x (still host-cc). */

/** ---------- Module import / struct_layout / top_level / enum 动态池 ---------- */

/** BC 8.3.2: module ImportEntry cold-twin accessors (same-TU thin). */
#include "ast_pool_module_import.c"

/** BC 8.3.2: module StructLayout cold accessors (same-TU thin). */
#include "ast_pool_struct_layout.c"

/** BC 8.3.2 wave980+993+994: TopLevelLetEntry + name_is_const/hoist + hoist_target/sum. */
#include "ast_pool_top_level.c"

/** BC 8.3.2: module TypeAliasEntry cold accessors (same-TU thin). */
#include "ast_pool_type_alias.c"

/* 2026-08-05: pipeline_backend_asm_wrapper.c pure-owned leave (wave113).
 * Live face: runtime_pipeline_abi.x (pipeline_backend_asm_codegen_ast_c /
 * pipeline_backend_asm_codegen_ast_to_elf_c). Cap residual: hoist / seed mega /
 * emit_set_* / mega_body / wpo thunks / typeck merge. PLATFORM: SHARED. */

#include "ast_pool_module_enum.c"



/** BC 8.3.2: OneFunc sidecar + fill_from_onefunc domain (wave984+991 same-TU thin). */
#include "ast_pool_onefunc.c"
/** BC 8.3.2: expr (+ type-pos) var-len sidecar domain (same-TU thin). */
#include "ast_pool_expr_sidecar.c"

/** BC 8.3.2: PipelineDepCtx cold accessors domain (same-TU thin). */
#include "ast_pool_dep_ctx.c"


/* 2026-08-05: pipeline_resolve_path.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (path_append_*_c / resolve probe / flat_import /
 * off-sidecar / codegen_out_buf_len|set_len / resolve_path_x_impl_c|_c).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_import_bind.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (read_file_x / preprocess_loaded /
 * bind_import / try_bind / sync_one_dep / preprocess_len_get /
 * read_file_x_impl_c / read_file_x_c / read_fd_into_loaded_buf).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_parse_typeck_dispatch.c pure-owned leave retired (wave112).
 * Live face: runtime_pipeline_abi.x (parse scalars BSS/getters + fail_diag +
 * buf/slice scalars + apply_main + typeck_parsed/entry + should_skip_c +
 * load_import_resolve_read + load_one_import_slot). Cap residual:
 * pipeline_parse_into_with_init_buf_impl_rc + result_c in pipeline_parse_orch.c.
 * Already pure same-TU: realign / load_and_sync / parse_set_main_from_buf_c.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_run_x_pipeline.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (last_rc get/store + typeck_fail/null_return
 * + load_deps_after_parse_c + typecheck_after_load_c + parse_entry_do_parse_c
 * + typecheck_entry_emit_c + pipeline_run_x_pipeline const-buf face).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_dep.c pure-owned leave retired (wave111).
 * Live face: runtime_pipeline_abi.x (one_dep_emit / entry_emit / parse_entry_if_needed_c /
 * fill/prepare/finish path glue / one_dep_c / deps_c / entry_c + entry_arena_for_mono).
 * Omits DEBUG_PIPE dump; product skip/rebind/emit control-flow preserved.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 8.3.2 host-cc leave: pipeline_loop_glue.c retired — bounded-loop predicates
 * + one_dep prepare glue live in codegen_x.o (codegen_gen seed append).
 * Callers already extern the `*_c` faces (pipeline.x / pipeline_gen).
 */

/* 2026-08-05: pipeline_emit_sidecar.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (driver_emit_lib_root_* +
 * driver_emit_append_lib_root + asm_qual_sym_layer_* fixed-cap BSS).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 8.3.2 host-cc leave: pipeline_preprocess_if.c retired — pure-owned WEAK cold
 * delete-only leave (highest-efficiency BC leave class). Live #if nest stack
 * is G.7 single authority in runtime_pipeline_abi.x / runtime_pipeline_abi.o
 * (fixed i32[32] BSS; no GrowVec). Callers already extern preprocess_if_stack_*.
 * Strict re-link companion: preprocess_if_stack_only.o now partial-exports from
 * runtime_pipeline_abi.o (was pipeline_glue_standalone). Do not re-include.
 */

/* 8.3.1 host-cc leave: pipeline_typeck_slots.c retired — BSS accessors live in
 * typeck_x.o (typeck_gen seed). Do not re-include into pipeline_x. */

#include "pipeline_elf_ctx.c"

/* 8.3.2 host-cc leave: pipeline_scratch_bufs.c retired — path/prefix
 * scratch BSS accessors live in codegen_x.o (codegen_gen seed append).
 * ast_/codegen_ mangled thin faces stay in pipeline_*_forwarders (host-cc).
 */

/* 2026-08-05: pipeline_codegen_type_to_c.c pure-owned leave retired (wave109).
 * Live face: runtime_pipeline_abi.x (type_kind_copy / type_kind_append /
 * vector_type_copy / type_to_c_repr).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_struct_emit.c pure-owned leave retired (wave110).
 * Live face: runtime_pipeline_abi.x (c_file_prologue_done_* / struct_tag_try_claim /
 * emit_struct_field_type / emit_struct_field_decl). Depends on wave109 type_to_c
 * public faces + wave105 codegen_out_buf_len|set_len.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_skip_force.c pure-owned leave retired (wave108).
 * Live face: runtime_pipeline_abi.x (call_num_args_override / path_is_std_io_* /
 * dep_skip_* / should_skip_emit_* / entry_is_lsp_* / force_param_*).
 * Reuses private pure cg_residual_name_prefix_eq (wave107) — single prefix helper.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

/* 2026-08-05: pipeline_codegen_residual.c pure-owned leave retired.
 * Live face: runtime_pipeline_abi.x (use_buf_wrapper / skip_emit_extern_io_batch_buf
 * / should_skip_emit_func_by_name / emit_seed_mega_enabled / is_submit_batch_buf_call
 * / should_skip_emit_func_core_read_ptr / asm_io_core_extern_callee_sym
 * / io_driver_buf_call_sym / std_io_fixed_fd_emit_impl).
 * Private pure prefix_eq is shared with skip_force pure leave (wave108).
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */

#include "pipeline_asm_locals.c"

#include "pipeline_asm_slot_bytes.c"

#include "pipeline_asm_block_tree.c"

/* 2026-08-05: pipeline_asm_ctx_loop.c pure-owned leave (wave114).
 * Live face: runtime_pipeline_abi.x (asm_ctx_loop_* + asm_be_cont_*).
 * Fixed-cap BSS sidecars (64 ctx × depth8; be_cont 24). Seed cold twin under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */


/* BC 8.3.2 wave1280: EMIT_HEAVY env/thresholds + path helpers + whitelist +
 * func-name prefix → pipeline_asm_emit_heavy_env.c (before selfhost faces so
 * extern asm_module_is_parser_selfhost resolves). PLATFORM: SHARED same-TU. */
#include "pipeline_asm_emit_heavy_env.c"

/* 2026-08-05: pipeline_asm_selfhost.c pure-owned leave (wave115).
 * Live face: runtime_pipeline_abi.x (num_defined/ordinal + 9 is_* predicates).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Residual same-TU callers (skip/wpo/heavy/thin) link pure via extern below.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t asm_module_num_defined_funcs(struct ast_Module *m);
extern int32_t asm_module_defined_func_ordinal(struct ast_Module *m, int32_t func_index);
extern int32_t asm_module_is_backend_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_typeck_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_pipeline_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_main_driver_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_driver_compile_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_parser_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m);
extern int32_t asm_module_is_ast_selfhost(struct ast_Module *m);
extern int32_t asm_module_is_compiler_selfhost(struct ast_Module *m);

/* 2026-08-05: pipeline_asm_emit_heavy_safe_helper.c pure-owned leave (wave117).
 * Live face: runtime_pipeline_abi.x (9 EMIT_HEAVY 2nd-pass name classifiers).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * pipeline_module_func_name_has_prefix_at un-static'd in emit_heavy_env.c for
 * pure extern. Residual same-TU caller (skip_dispatch) links pure via extern.
 * PLATFORM: SHARED — no host-cc twin in pipeline_x mega-TU. */
extern int32_t asm_typeck_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_pipeline_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_driver_compile_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_helper_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_helper_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_tail_thin_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_helper_keep(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_mega_entry(struct ast_Module *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_mega_entry(struct ast_Module *m, int32_t func_index);


/* 2026-08-05: pipeline_asm_thin_delegate.c pure-owned leave (wave116).
 * Live face: runtime_pipeline_abi.x (backend/pipeline/driver/typeck m8-tail
 * thin delegate C-name lookup). Seed cold twin under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * k_asm_parser_thin_delegate table + its 2 consumers relocated into
 * pipeline_asm_parser_emit_heavy.c (same TU). PLATFORM: SHARED — no host-cc
 * twin in pipeline_x mega-TU. */
extern int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                         int32_t out_cap, int32_t *out_len);
extern int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                          int32_t out_cap, int32_t *out_len);
extern int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);
extern int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);


#include "pipeline_asm_parser_emit_heavy.c"

/* 2026-08-05: pipeline_asm_skip_dispatch.c pure-owned leave (wave118).
 * Live face: runtime_pipeline_abi.x (asm_empty_text_stub_label +
 * asm_skip_heavy_module_func_body + set_pipeline_ctx BSS).
 * Seed cold twin under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Residual same-TU callers (codegen_mega_body / call_args) + early_fwd
 * link pure via extern. PLATFORM: SHARED — no host-cc twin in pipeline_x. */
extern void asm_empty_text_stub_label(struct ast_Module *m, uint8_t *out, int32_t out_cap, int32_t *out_len);
extern int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index);

/* 2026-08-05: pipeline_asm_diag.c pure-owned leave retired.
 * Live = runtime_pipeline_abi pure asm_diag_start_func_skip + BODY/FUNC_TRACE.
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * Callers: backend.x / pipeline_asm_codegen_mega_body (start_func_skip);
 * early_fwd still declares extern. PLATFORM: SHARED. */

#include "pipeline_asm_wpo.c"

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"

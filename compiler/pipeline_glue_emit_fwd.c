/**
 * pipeline_glue_emit_fwd.c — Early emit inter-include forward-decl / static shell
 * (BC 8.3 shell thin; after async_cps; logand host leaf left at wave128).
 *
 * wave1287 BC 8.3 G.7 same-TU domain fold from pipeline_glue.c:
 * pure forward declarations, static prototypes, and shared static state that
 * must be visible before pipeline_asm_emit_struct_lit.c (STRUCT_LIT /
 * vector_let / field_access / match / expr_rec chain).
 *
 * wave128 pure-owned leave: LOGAND/LOGOR short-circuit live in
 * runtime_pipeline_abi pure — extern decls below for residual expr_rec
 * (ko==20/21); do not re-define host-cc bodies (G.7).
 *
 * Sub-clusters (order preserved):
 *  - pipeline_asm_emit_logand/logor_elf_impl public pure faces (wave128 leave)
 *  - pipeline_asm_typekind_variant_tag static fwd (def at cmp.c EOF)
 *  - glue_if_expr_arm_emit_depth static (if/ternary arm depth; read in block_body)
 *  - pipeline_asm_emit_expr_if_arm_elf_c public fwd (def at block_body EOF)
 *  - dual-GP / named layout / type_size_simple / vector_let_init / struct field
 *    store / frame mag / field offset / store_retval / emit_module / struct
 *    let-init static prototypes
 *  - pipeline_asm_emit_set_call_sret_reg_shift_c public face
 *  - GLUE_TYPE_NAMED kind ordinal macro
 *
 * Include site: pipeline_glue.c after async_cps (was after logand host leaf)
 * and before STRUCT_LIT domain #include.
 * Not a separate .o — host-cc via pipeline_x.o.
 *
 * G.7: declarations + shared static only; no second implementation of any face.
 * PLATFORM: SHARED — host-cc residual shell.
 */

/* wave128 pure-owned leave: LOGAND/LOGOR short-circuit ELF faces (was same-TU
 * static in pipeline_asm_emit_logand.c). Residual expr_rec dispatches ko 20/21
 * via these public pure symbols. PLATFORM: SHARED freestanding emit. */
extern int32_t pipeline_asm_emit_logand_elf_impl(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_logor_elf_impl(struct ast_ASTArena *arena,
                                               struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                               struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave133 pure-owned leave: unary ELF faces (was same-TU pipeline_asm_emit_unary.c).
 * Residual expr_rec (ko 22/23/24) + match/fold (jz_after_bool) call pure symbols.
 * PLATFORM: SHARED freestanding emit. */
extern int32_t pipeline_asm_emit_neg_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_lognot_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_bitnot_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t glue_enc_jz_after_bool_in_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label,
                                             int32_t label_len, int32_t ta);
extern int32_t glue_enc_sxt_i32_result_to_rax_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);

/* wave138 pure-owned leave: as/await/try/float-lit ELF faces (was same-TU
 * pipeline_asm_emit_as.c). Residual expr_rec / binop / block_body / struct_lit
 * / array_lit call these pure symbols. PLATFORM: SHARED freestanding emit. */
extern int32_t glue_expr_is_await_at_c(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t glue_expr_is_x_as_cast_at_c(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_await_sync_elf_impl(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                     struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_try_propagate_elf_impl(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t glue_emit_float_lit_to_rax_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 int32_t ta, int32_t force_ty_ref, int32_t call_abi_widen_f64);
extern int32_t pipeline_asm_emit_as_elf_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_as_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave140 pure-owned leave: INDEX/ADDR_OF/DEREF + esz (was same-TU
 * pipeline_asm_emit_index.c). Residual expr_rec/assign/binop/helpers Cap-call
 * pure symbols. PLATFORM: SHARED freestanding emit. */
extern int32_t pipeline_asm_index_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_asm_index_elem_byte_sz(struct ast_ASTArena *arena, int32_t index_expr_ref);
extern int32_t pipeline_asm_emit_index_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_addr_of_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_deref_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave134 pure-owned leave: MATCH/EXPR_IF + subject context (was same-TU
 * pipeline_asm_emit_match.c). Residual expr_rec (MATCH/IF ko) + host-C
 * codegen_gen seed call pure symbols. PLATFORM: SHARED freestanding emit. */
extern int32_t pipeline_asm_emit_match_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_if_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern void pipeline_codegen_match_set_subject_c(struct ast_Module *module, int32_t matched_ref, int32_t subject_ty);
extern void pipeline_codegen_match_clear_subject_c(void);
extern int32_t pipeline_codegen_match_matched_ref_c(void);
extern int32_t pipeline_codegen_match_subject_ty_c(void);
extern struct ast_Module *pipeline_codegen_match_mod_c(void);
extern int32_t pipeline_codegen_match_name_is_subject_field_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                              uint8_t *name, int32_t name_len);

/* wave131 pure-owned leave: async CPS ELF faces (was same-TU in
 * pipeline_asm_emit_async_cps.c). Residual block_body (after_await) + mega_body
 * (entry/end) call these pure symbols. phase_reset is declared earlier in
 * pipeline_glue_emit_lea_fwd.c for return/as #include order.
 * PLATFORM: SHARED freestanding emit. */
extern int32_t glue_async_cps_emit_after_await(struct ast_ASTArena *arena,
                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_async_cps_entry_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       struct backend_AsmFuncCtx *ctx, struct ast_Module *mod,
                                                       int32_t func_index, int32_t ta);
extern void pipeline_asm_emit_async_cps_end_func_elf_c(void);

/* wave1033 G.7: pipeline_token_kind_variant_tag folded into
 * pipeline_asm_emit_field_access.c (same TU #include at L2489; no new DEPS).
 * Chinese docblock converted to English per G.9. field_access.c is the sole
 * in-TU leaf consumer (2 callsites); residual glue.c caller
 * pipeline_expr_enum_namespace_field_tag is after the #include site — no
 * forward decl needed. */
/* wave1146 G.7: TypeKind 枚举变体 tag (definition migrated to
 * pipeline_asm_emit_cmp.c EOF). Static fwd decl here provides
 * visibility to field_access.c (#include at L2281) and cmp.c
 * (#include at L3547) — both before the definition at cmp.c EOF. */
/* wave137 pure-owned leave: typekind table lives in runtime_pipeline_abi pure. */
extern int32_t pipeline_asm_typekind_variant_tag(const uint8_t *field_buf, int32_t flen);
/** if/三元分支块 emit 深度（定义见 glue_block_emit_stmt_i 旁；此处前置供 if_arm 使用）。 */
static int32_t glue_if_expr_arm_emit_depth;

/* wave1217 G.7: pipeline_asm_emit_expr_if_arm_elf_c (34 lines) migrated to
 * pipeline_asm_emit_block_body.c EOF (colocated with if-expr arm depth
 * consumer at block_body.c L900 — sole other reader of
 * glue_if_expr_arm_emit_depth; #include at L2095).
 * if/ternary branch emit: EXPR_BLOCK -> C block body sync emit; non-block
 * -> rec.
 * Deps:
 *  - pipeline_asm_ctx_layout (static fn, glue.c L86 — same TU, visible at
 *    block_body.c EOF since L86 < L2095)
 *  - glue_if_expr_arm_emit_depth (static var, glue.c L1347 — same TU,
 *    visible at block_body.c EOF since L1347 < L2095; both write site in
 *    this function + read site at block_body.c L900 stay in same TU)
 *  - pipeline_expr_kind_ord_at / pipeline_expr_block_ref_at /
 *    backend_ensure_block_local_slots / pipeline_asm_emit_block_body_sync_elf
 *    / pipeline_asm_emit_expr_elf_rec / link_abi_getenv (all extern,
 *    visible at block_body.c EOF via same-TU fwd decls / extern decls)
 * Fwd decl below retained — covers pure match leave Cap residual + expr_rec
 * if_arm callsite (def at block_body EOF). wave134: match_elf/expr_if_elf live
 * in runtime_pipeline_abi pure (extern above); if_arm stays host-cc residual.
 * No dual authority — seeds only declare extern, no definition.
 * PLATFORM: SHARED — emits both x86_64 + arm64 ELF (ta param selects arch
 * inside delegated callees; no direct arch branch in this function). */
int32_t pipeline_asm_emit_expr_if_arm_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t arm_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave134: EXPR_IF / MATCH ELF faces pure-owned (emit_fwd extern above).
 * Residual expr_rec dispatches via pure symbols; do not re-define host bodies. */
/* Forward: dual-GP / named layout used by STRUCT_LIT field store (defs later). */
static int32_t glue_sysv_dual_gp_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);
/* wave132 pure leave Cap residual: named_layout static→extern (def call_args.c). */
int32_t glue_type_named_layout_size_any_module_elf_c(struct ast_ASTArena *arena, int32_t ty_ref);
/* wave1032 G.7: glue_type_is_empty_struct_c folded into
 * pipeline_asm_emit_struct_lit.c (same TU #include at L2160; no new DEPS).
 * Chinese docblock converted to English per G.9. struct_lit.c is the sole
 * in-TU leaf consumer; residual glue.c callers (layout metrics / call
 * return size) are after the #include site — no forward decl needed. */
/* wave132 pure leave Cap residual: type_size_simple static→extern (def struct_lit.c). */
int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/* wave349/350: STRUCT_LIT fixed TYPE_ARRAY field inline store (def after vector_let_init). */
static int32_t pipeline_asm_emit_vector_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off);
static int32_t glue_struct_lit_store_fixed_array_field_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t sret_direct, int32_t base_off, int32_t foff, int32_t fty);
/* wave652: arch-aware struct field frame mag (nest_slot + fixed array field). */
static int32_t glue_struct_field_frame_mag_c(int32_t base_off, int32_t foff, int32_t ta);
/* Used by wave350 FIELD init; full def near pipeline_expr_field_access_layout_offset. */
static int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t fa_ref);
/* wave351 CALL field init: reuse let-init CALL store authority (defs later). */
/* wave1048 G.7: glue_call_return_byte_size_c fwd decl removed — definition
 * migrated to pipeline_asm_emit_call_args.c (fwd decl at call_args.c:356,
 * visible after #include at L2392; struct_let.c:93 retains its own fwd decl
 * for struct_let.c:141 callsite before #include at L2266). */
/* wave132 pure leave Cap residual: store_retval / module_from_ctx static→extern
 * (defs in call_args.c / index_helpers.c). PLATFORM: SHARED. */
int32_t glue_store_retval_pair_to_rbp_elf_c(struct ast_Module *m, struct ast_ASTArena *arena,
                                            struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ty_ref,
                                            int32_t slot_off, int32_t ta, int32_t init_ref,
                                            struct backend_AsmFuncCtx *ctx);
struct ast_Module *glue_emit_module_from_ctx(struct backend_AsmFuncCtx *ctx);
/* wave132 pure-owned leave: struct let-init + sret shift live in
 * runtime_pipeline_abi pure (was same-TU pipeline_asm_emit_struct_let.c).
 * Residual vector_let / array_lit / block_inits / assign / field_access /
 * call_args call these pure symbols. PLATFORM: SHARED freestanding emit. */
extern int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t let_ty_ref, int32_t stack_slot_off);
extern int32_t pipeline_asm_emit_struct_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off);
extern void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift);
extern int32_t pipeline_asm_emit_call_sret_reg_shift_c(void);

/* wave141 pure-owned leave: pipeline_asm_emit_context.c deleted.
 * Live = runtime_pipeline_abi pure; residual mega_body / block_inits / call_args /
 * vector_simd / slot_bytes Cap residual these faces. PLATFORM: SHARED. */
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern struct ast_Module *pipeline_asm_emit_module_ref_c(void);
extern struct ast_Module *pipeline_asm_glue_emit_module_ref(void);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);
extern void pipeline_asm_emit_set_call_param_type_ref(int32_t type_ref);
extern void pipeline_asm_emit_call_arg_begin_c(void);
extern void pipeline_asm_emit_call_arg_end_c(void);
extern int32_t pipeline_asm_emit_call_arg_active_c(void);
extern void pipeline_asm_emit_set_func_index(int32_t func_index);
extern void pipeline_asm_emit_set_elf_ctx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_asm_emit_func_param_is_ptr_by_name_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                             uint8_t *vname, int32_t vlen);
extern int32_t pipeline_asm_var_is_emit_func_param_ptr_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         uint8_t *asm_ctx, int32_t var_expr_ref);
extern int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, struct ast_ASTArena *arena, int32_t block_ref,
                                                 struct ast_Module *mod, int32_t func_index);
extern void pipeline_asm_fill_param_slots(struct backend_AsmFuncCtx *ctx, struct ast_Module *mod, int32_t func_index);
extern int32_t pipeline_asm_emit_param_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                  struct backend_AsmFuncCtx *ctx, struct ast_Module *mod,
                                                  int32_t func_index, int32_t ta);
extern void pipeline_asm_fill_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                          int32_t block_ref);

/* wave132: include-order fwd decls formerly only in pipeline_asm_emit_struct_let.c.
 * Keep visibility for call_args / field_access / index_eff_addr / binop without
 * re-opening a second struct_let face (G.7). PLATFORM: SHARED. */
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(struct ast_ASTArena *arena,
                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                             int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t call_ref, struct backend_AsmFuncCtx *ctx,
                                                                   int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_var_field_sum_binop_elf(struct ast_ASTArena *arena,
                                                  struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t left_ref,
                                                  int32_t right_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
/* glue_* names alias public pipeline_asm_* faces (defs call_args.c). */
#define glue_deref_struct16_rax_ptr_elf_c pipeline_asm_deref_struct16_rax_ptr_elf_c
#define glue_call_struct16_ret_needs_rax_deref_c pipeline_asm_call_struct16_ret_needs_rax_deref_c
int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
int32_t pipeline_asm_call_return_type_kind_ord_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
/* static resolve stays call_args.c; fwd here so call_return_byte_size / early call_args see it. */
static int32_t glue_asm_resolve_call_target_module_c(struct ast_ASTArena *arena, int32_t call_expr_ref,
                                                     struct ast_Module **mod_out, int32_t *func_ix_out,
                                                     int32_t *dep_ix_out);

/* GLUE_TYPE_NAMED (TYPE_NAMED kind ord) — used by struct_lit leaf + call_args leaf + later glue residual. */
#define GLUE_TYPE_NAMED 8


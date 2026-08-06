/**
 * pipeline_asm_emit_index_helpers.c — asm ELF INDEX residual helpers domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding INDEX support helpers
 * that pipeline_asm_emit_index.c (esz + emit_index + addr_of + deref face)
 * depends on:
 * - glue_emit_module_from_ctx / local_var_slot_needs_ptr_load /
 *   func_param_is_indirect_{array,struct}_slot — wave189 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twins
 * - glue_field_access_field_type_ref_c — wave187 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - fixed_array_total_bytes / glue_index_elem_byte_sz_from_type_ref_c
 *   — wave180 pure (INDEX stride inference)
 * - try_index_* forest (base→rax/rbx, assign-addr→rbx, eff_addr→rax;
 *   lit/var/add/sub/mul nested shapes + index scratch cache)
 *   · wave178–184: peel / local-slot / type / assign / base / nested / rax pure
 * - glue_emit_soa_index_field_addr_elf_c — wave186 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 * - pipeline_asm_emit_lvalue_eff_addr_{elf,text}_c — wave185 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twins
 * - glue_var_expr_stack_off_elf_c — wave188 pure leave
 *   (runtime_pipeline_abi); Cap residual extern only + seed cold twin
 *
 * G.7: single product-mega INDEX residual-helper face — do not open a second
 * try_index forest or lvalue_eff_addr path. Face emitters stay in
 * pipeline_asm_emit_index.c; index assign finish_store / bulk_mem_copy_spills /
 * Chaitin spill live in pipeline_asm_emit_spill.c (same TU, next include);
 * glue_emit_index_eff_addr_scaled_elf_c + local_slot_text live in
 * runtime_pipeline_abi pure (wave147 pure-owned leave).
 *
 * Callers: pipeline_asm_emit_index.c; assign INDEX lhs; call-arg base;
 * field_access INDEX-rooted chains; expr_elf_rec INDEX/ADDR_OF/DEREF;
 * text path M8-tail / backend wrappers for lvalue text.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_struct_let.c (before pipeline_asm_emit_spill.c).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — lea/load slot + scaled index
 *   · MACOS|ARM64 AAPCS64 — index scratch / ldur co-path
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_index_elem_byte_sz_c (pipeline_asm_emit_index.c, later include)
 * - glue_field_access_effective_offset_c (def later near layout_offset)
 * - glue_type_size_simple / glue_type_ref_is_named_struct_layout_elf_c
 *   (named_struct body in call_args leaf wave1017; same-TU forward here)
 * - glue_var_expr_stack_off_elf_c — wave188 pure (runtime_pipeline_abi);
 *   Cap residual callers use pure; G.7 single authority — no host body
 * - glue_emit_index_eff_addr_scaled_elf_c (runtime_pipeline_abi pure wave147)
 * - glue_binop_stack_spill_* / glue_asm73_var_prefers_stack_spill (defs later)
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / asm_ctx_local_*
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_func_index
 *
 * Note: binop_stack_spill table BSS pure leave wave208 (runtime_pipeline_abi);
 * Cap residual try_reload still host (enc + VAR cache). CAP cache structs
 * (minus_pair / subadd3) + thin valid/slot/ctx/keys/record/clear + hit_var
 * pure leave closed (wave209). rax_frame spill + scratch depth pure leave
 * closed (wave207). module_from_ctx / needs_ptr / array_slot /
 * named_struct_layout_elf pure leave closed earlier.
 */

/** INDEX 元素字节宽（前向声明，定义见本文件后部）。 */
/* wave140 pure-owned leave: esz authority in runtime_pipeline_abi pure (#[no_mangle]).
 * Residual assign/binop/spill/lvalue_eff_addr Cap-call this face. PLATFORM: SHARED. */
extern int32_t pipeline_asm_index_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);
/* wave151 Cap residual: pure field_access leave (was static in field_access leaf). */
extern int32_t glue_field_access_call_base_rvalue_elf_c(struct ast_ASTArena *arena,
    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
    int32_t ta, int32_t leave_addr);
/** VAR 基址 FIELD_ACCESS 有效偏移（定义见 pipeline_expr_field_access_layout_offset 附近）。 */
int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t fa_ref);

/** AsmFuncCtx.module_ref 在 X/C 布局中的字节偏移（与 backend.x fill_param_slots 一致）。 */
#define GLUE_ASM_CTX_MODULE_REF_OFF 16

/* wave189 pure-owned: glue_emit_module_from_ctx (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding emit-module resolve. */
struct ast_Module *glue_emit_module_from_ctx(struct backend_AsmFuncCtx *ctx);

/* wave189 pure-owned: glue_emit_func_param_is_indirect_array_slot_c (pure).
 * Was static; call_args co-uses public pure face. G.7 single authority.
 * PLATFORM: SHARED freestanding T[N] formal pointer home. */
int32_t glue_emit_func_param_is_indirect_array_slot_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                       int32_t var_expr_ref);

/* wave190 pure-owned: glue_type_ref_is_named_struct_layout_elf_c (pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding layout predicate. */
int32_t glue_type_ref_is_named_struct_layout_elf_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t ty_ref);
int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);

/* wave189 pure-owned: pipeline_asm_emit_func_param_is_indirect_struct_slot_c
 * (always 0 SysV product). Cap residual / backend_try_inline use pure.
 * PLATFORM: SHARED freestanding. */
int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                                int32_t var_expr_ref);

/* wave189 pure-owned: glue_local_var_slot_needs_ptr_load_elf_c (pure).
 * Cap residual try_index / lvalue / enc_local_slot call pure; G.7 single
 * authority — no host body. stack_off_is_emit_param_ptr folded into pure private.
 * PLATFORM: SHARED freestanding load-vs-lea for *T / T[N] / T[] formals. */
int32_t glue_local_var_slot_needs_ptr_load_elf_c(struct ast_ASTArena *arena, int32_t var_expr_ref,
                                                         int32_t stack_off, struct backend_AsmFuncCtx *ctx);

/**
 * wave179 pure-owned: local VAR slot → rax/rbx (load *T/slice* / lea by-value).
 * Cap residual try_index / lvalue call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX local slot.
 */
int32_t glue_enc_local_slot_ptr_or_addr_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t var_expr_ref,
                                                     int32_t stack_off, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t glue_enc_local_slot_ptr_or_addr_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t var_expr_ref, int32_t stack_off,
                                                         struct backend_AsmFuncCtx *ctx, int32_t ta);

/** TYPE_PTR 在 TypeKind 序数表中的值（与 pipeline_asm_index_elem_byte_sz_c 一致）。 */
#define GLUE_TYPE_KIND_PTR 9

/* wave187 pure-owned: glue_field_access_field_type_ref_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * (layout-name match helper folded into pure private.)
 * PLATFORM: SHARED freestanding FIELD type recovery. */
int32_t glue_field_access_field_type_ref_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                           int32_t fa_ref);

/**
 * wave180 pure-owned: fixed TYPE_ARRAY total payload bytes (recursive multi-dim).
 * Cap residual try_index / esz / array_lit call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding layout · LINUX gold.
 */
int32_t glue_fixed_array_total_bytes_c(struct ast_ASTArena *arena, int32_t ty_ref, int32_t depth);

/**
 * wave180 pure-owned: INDEX element / pointer-base stride from type ref.
 * Cap residual try_index / emit_index / array_lit call pure; G.7 single authority.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
int32_t glue_index_elem_byte_sz_from_type_ref_c(struct ast_ASTArena *arena, int32_t tr);

/**
 * wave179 pure-owned: FIELD slot auto-deref *T / TYPE_SLICE into rax or rbx.
 * Cap residual try_index base paths call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX field base.
 */
int32_t glue_index_deref_ptr_field_slot_rax_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t fa_ref, int32_t ta);
int32_t glue_index_deref_ptr_field_slot_rbx_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t fa_ref, int32_t ta);

/**
 * wave180 pure-owned: VAR type for emit (resolved + param/scope/body decl fallback).
 * Cap residual INDEX/slice faces call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding · skip_typeck import asm recovery.
 */
int32_t glue_var_expr_type_ref_with_decl_fallback_c(struct ast_ASTArena *arena, int32_t var_ref);

/**
 * wave182 pure-owned: INDEX base materialize → rax / rbx (2 faces).
 * Cap residual nested add3/subadd3/eff_addr call pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX base.
 */
int32_t glue_try_index_var_or_field_base_to_rax_elf_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t base_ref, struct backend_AsmFuncCtx *ctx,
                                                              int32_t ta);
int32_t glue_try_index_var_or_field_base_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                              int32_t base_ref, struct backend_AsmFuncCtx *ctx,
                                                              int32_t ta);

/**
 * wave181 pure-owned: simple try_index assign-addr→rbx forest (8 faces).
 * Cap residual nested add3/subadd3/eff_addr call pure; base pure since wave182.
 * G.7 single authority — no host body. PLATFORM: SHARED freestanding INDEX assign.
 */
int32_t glue_try_index_var_lit_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t base_ref, int32_t idx_ref,
                                                         struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t esz);
int32_t glue_try_index_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                           int32_t base_ref, int32_t idx_ref,
                                                           struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t esz);
int32_t glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                  int32_t esz);
int32_t glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                  int32_t esz);
int32_t glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t base_ref, int32_t idx_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                   int32_t esz);
int32_t glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                   int32_t base_ref, int32_t idx_ref,
                                                                   struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                   int32_t esz);
int32_t glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                  struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                  int32_t esz);
int32_t glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                 struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                 int32_t base_ref, int32_t idx_ref,
                                                                 struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                 int32_t esz);

/**
 * wave183 pure-owned: nested try_index assign-addr→rbx forest (10 faces).
 * Cap residual CAP BSS + eff_addr remain host; nested addr bodies → pure.
 * G.7 single authority — no host body. PLATFORM: SHARED freestanding INDEX assign.
 */


/* wave178 pure-owned INDEX expr shape peel forest (runtime_pipeline_abi pure).
 * Cap residual try_index faces call these; G.7 single authority — no static twin.
 * PLATFORM: SHARED freestanding INDEX peel. */
int32_t glue_index_expr_var_plus_var_pair_elf_c(struct ast_ASTArena *arena, int32_t add_ref,
                                               int32_t *out_left_var, int32_t *out_right_var);
int32_t glue_index_expr_var_add3_elf_c(struct ast_ASTArena *arena, int32_t add_ref, int32_t *out_i,
                                      int32_t *out_j, int32_t *out_k);
int32_t glue_index_expr_var_minus_var_pair_elf_c(struct ast_ASTArena *arena, int32_t sub_ref,
                                                int32_t *out_left_var, int32_t *out_right_var);
int32_t glue_index_expr_var_minus_add3_elf_c(struct ast_ASTArena *arena, int32_t sub_ref, int32_t *out_i,
                                            int32_t *out_j, int32_t *out_k);
int32_t glue_index_expr_var_subadd3_elf_c(struct ast_ASTArena *arena, int32_t add_ref, int32_t *out_i,
                                         int32_t *out_j, int32_t *out_k);
int32_t glue_index_expr_var_subsub3_elf_c(struct ast_ASTArena *arena, int32_t sub_ref, int32_t *out_i,
                                         int32_t *out_j, int32_t *out_k);

/* wave183 pure-owned: glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                            int32_t base_ref, int32_t idx_ref,
                                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                            int32_t esz);


/* wave183 pure-owned: glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                            int32_t base_ref, int32_t idx_ref,
                                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                            int32_t esz);


/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR)-VAR) 混合 SUB → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-j)-k）。
 */

/** 7.3：Chaitin 溢出或物理 spill 槽用尽时的栈帧 spill（which=5；与 index scratch 共用 push 深度）。 */
#define GLUE_BINOP_STACK_SPILL_CAP 12
/** 7.3：栈帧 spill 着色号（物理槽 0–5 对应 x10–x15）。 */
#define GLUE_ASM73_SPILL_WHICH_STACK 6

/* wave207 pure-owned: rax_frame spill nest + index_scratch depth BSS in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path. */
int32_t glue_binop_rax_frame_spill_push(int32_t home);
int32_t glue_binop_rax_frame_spill_pop(void);
int32_t glue_binop_rax_frame_spill_depth(void);
void glue_binop_rax_frame_spill_n_set(int32_t v);
void glue_index_scratch_stack_depth_set(int32_t v);
int32_t glue_index_scratch_stack_depth_get(void);

/* wave208 pure-owned: binop stack-spill table BSS + thin accessors in
 * runtime_pipeline_abi.x (#[no_mangle] export). Cap residual: prototype only.
 * try_reload_elf remains Cap residual (enc + VAR cache). Seed cold twins under
 * #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path. */
int32_t glue_binop_stack_spill_append_at_depth(int32_t off, int32_t depth);
int32_t glue_binop_stack_spill_cap_get(void);
void glue_binop_stack_spill_clear(void);
void glue_binop_stack_spill_drop_off(int32_t off);
int32_t glue_binop_stack_spill_find_depth(int32_t off);
int32_t glue_binop_stack_spill_n_get(void);
int32_t glue_binop_stack_spill_off_at(int32_t i);

/* wave209 pure-owned: CAP cache BSS (minus_pair / subadd3) + thin accessors +
 * caches_hit_var in runtime_pipeline_abi.x (#[no_mangle] export). Cap residual:
 * prototype only. Seed cold twins under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path. */
void glue_index_minus_pair_cache_clear(void);
void glue_index_subadd3_sum_cache_clear(void);
int32_t glue_index_minus_pair_cache_valid_get(void);
int32_t glue_index_minus_pair_cache_slot_depth_get(void);
int32_t glue_index_minus_pair_cache_ctx_matches(struct backend_AsmFuncCtx *ctx);
int32_t glue_index_minus_pair_cache_keys_eq(struct ast_ASTArena *arena, int32_t i_ref, int32_t j_ref);
void glue_index_minus_pair_cache_record(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                       int32_t i_ref, int32_t j_ref);
int32_t glue_index_subadd3_sum_cache_valid_get(void);
int32_t glue_index_subadd3_sum_cache_slot_depth_get(void);
int32_t glue_index_subadd3_sum_cache_ctx_matches(struct backend_AsmFuncCtx *ctx);
int32_t glue_index_subadd3_sum_cache_keys_eq(struct ast_ASTArena *arena, int32_t i_ref, int32_t j_ref,
                                            int32_t k_ref);
void glue_index_subadd3_sum_cache_record(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t i_ref, int32_t j_ref, int32_t k_ref);
int32_t glue_index_scratch_caches_hit_var(struct ast_ASTArena *arena, int32_t var_ref);
/* wave169 pure-owned: glue_binop_stack_spill_push_elf_c (runtime_pipeline_abi pure). */
int32_t glue_binop_stack_spill_push_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta, int32_t off,
                                                  int32_t from_rbx);
/* wave211 pure-owned: glue_binop_stack_spill_try_reload_elf_c
 * (runtime_pipeline_abi pure; seed cold twin under #ifndef FROM_X). */
int32_t glue_binop_stack_spill_try_reload_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                int32_t off, int32_t to_rbx);
/* wave149 Cap residual non-static (def spill.c). */
int32_t glue_asm73_var_prefers_stack_spill(int32_t off);

/* wave172 pure-owned: minus_pair/subadd3 cache spill helpers (runtime_pipeline_abi pure). */
int32_t glue_index_minus_pair_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                       int32_t i_ref, int32_t j_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                         int32_t j_ref, int32_t ta);
/* wave171 pure-owned: index-scratch enc reload faces (runtime_pipeline_abi pure). */
int32_t glue_index_reload_scratch_slot_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                            int32_t slot_depth);
/* wave169 pure-owned: glue_index_scratch_spills_cleanup_all_elf_c (runtime_pipeline_abi pure). */
int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave172 pure-owned: subadd3 sum cache hit (runtime_pipeline_abi pure). */
int32_t glue_index_subadd3_sum_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t i_ref, int32_t j_ref, int32_t k_ref, int32_t ta);
/* wave171 pure-owned: reload slot → rbx (runtime_pipeline_abi pure). */
int32_t glue_index_reload_scratch_slot_to_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                   int32_t slot_depth);

/* wave183 pure-owned: glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                             int32_t base_ref, int32_t idx_ref,
                                                                             struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                             int32_t esz);


/* wave183 pure-owned: glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                    struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                    int32_t base_ref, int32_t idx_ref,
                                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                    int32_t esz);


/* wave183 pure-owned: glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                              struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                              int32_t base_ref, int32_t idx_ref,
                                                                              struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                              int32_t esz);


/* wave183 pure-owned: glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                           int32_t base_ref, int32_t idx_ref,
                                                                           struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                           int32_t esz);


/* wave183 pure-owned: glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                         int32_t base_ref, int32_t idx_ref,
                                                                         struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                         int32_t esz);


/**
 * INDEX assign：VAR/FIELD 基址 + ((VAR-VAR+VAR)*lit) MUL 嵌套 → scratch 缩放寻址入 rbx。
 * 0=OK，-1=错，-2=不适用（如 (i-j+k)*2）。
 */
/* wave172 pure-owned: minus_pair/subadd3 cache spill helpers (runtime_pipeline_abi pure). */
int32_t glue_index_subadd3_sum_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t i_ref, int32_t j_ref, int32_t k_ref, int32_t ta);
int32_t glue_index_subadd3_sum_cache_spill_store_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                      struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                      int32_t j_ref, int32_t k_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                         int32_t j_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                       int32_t i_ref, int32_t j_ref, int32_t ta);
/* wave169 pure-owned (runtime_pipeline_abi pure). */
int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave172 pure-owned: pop top stale (i-j+k) spill (runtime_pipeline_abi pure). */
int32_t glue_index_subadd3_spill_pop_top_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave171 pure-owned: reload faces (runtime_pipeline_abi pure). */
int32_t glue_index_reload_scratch_slot_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                            int32_t slot_depth);

/* wave183 pure-owned: glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                         int32_t base_ref, int32_t idx_ref,
                                                                         struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                         int32_t esz);


/* wave183 pure-owned: glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                        int32_t base_ref, int32_t idx_ref,
                                                                        struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                        int32_t esz);


/* wave183 pure-owned: glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX assign nested path. */
int32_t glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(struct ast_ASTArena *arena,
                                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                          int32_t base_ref, int32_t idx_ref,
                                                                          struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                                          int32_t esz);


/* wave184 pure-owned: try_index eff_addr→rax forest (16 faces) live in runtime_pipeline_abi pure.
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX rvalue/lea path. */
/* wave184 pure-owned: glue_try_index_var_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_mul_var_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_mul_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_plus_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_plus_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_plus_var_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_plus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_var_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_add3_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_add3_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave184 pure-owned: glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding INDEX eff_addr→rax path. */
int32_t glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t base_ref, int32_t idx_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t esz);

/* wave186 pure-owned: glue_emit_soa_index_field_addr_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding SoA arr[i].field path. */
int32_t glue_emit_soa_index_field_addr_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t index_expr_ref, int32_t fa_ref,
                                                     struct backend_AsmFuncCtx *ctx, int32_t ta);

/**
 * Forward decls for lvalue text twin (wave147 pure-owned leave):
 * - pipeline_asm_emit_index_eff_addr_text_c — pure public face
 * - glue_arch_emit_local_slot_ptr_or_addr_text_c — pure helper (was static in leaf)
 * residual calls via extern. PLATFORM: SHARED.
 */
extern int32_t pipeline_asm_emit_index_eff_addr_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                int32_t ix_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                int32_t elem_sz);
extern int32_t glue_arch_emit_local_slot_ptr_or_addr_text_c(struct ast_ASTArena *arena,
                                                            struct codegen_CodegenOutBuf *out, int32_t var_expr_ref,
                                                            int32_t stack_off, struct backend_AsmFuncCtx *ctx,
                                                            int32_t ta);

/* wave185 pure-owned: pipeline_asm_emit_lvalue_eff_addr_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding assign/field/INDEX/DEREF lvalue path. */
int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lval_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave185 pure-owned: pipeline_asm_emit_lvalue_eff_addr_text_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * PLATFORM: SHARED freestanding text lvalue path. */
int32_t pipeline_asm_emit_lvalue_eff_addr_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                 int32_t lval_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave1212 G.7: glue_var_expr_stack_off_elf_c migrated from pipeline_glue.c
 * L1578-1595. Resolves VAR expression stack offset via scoped local table,
 * falls back to name lookup. Colocated with index_helpers.c (30+ callsites;
 * #include at glue.c L1530).
 * Deps: glue_asm_local_var_stack_off_scoped (runtime_pipeline_abi pure wave148;
 *       #include L1513 < L1530 — visible),
 *       pipeline_expr_kind_ord_at (extern),
 *       pipeline_expr_var_name_len/into (extern),
 *       asm_ctx_local_find_offset (extern fwd decl, glue.c L956),
 *       GLUE_EXPR_KIND_VAR (macro, glue.c early).
 * Consumers (all #include after L1530 — visible via existing static fwd decl
 * at glue.c L1109): return.c L356 (#include L1302 — covered by glue.c fwd decl),
 * index_helpers.c L617+ (this file), assign.c L313 (#include L1550),
 * index_eff_addr.c L86+ (#include L1637), call_args.c L178+ (#include L1660),
 * binop.c L106+ (#include L1678). PLATFORM: SHARED. */
/* wave188 pure-owned: glue_var_expr_stack_off_elf_c (runtime_pipeline_abi pure).
 * Cap residual callers use pure; G.7 single authority — no host body.
 * (scoped + unscoped name fallback folded into pure via wave148 scoped).
 * PLATFORM: SHARED freestanding VAR stack_off. */
int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t var_expr_ref);

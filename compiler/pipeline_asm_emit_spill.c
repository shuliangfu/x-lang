/**
 * pipeline_asm_emit_spill.c — asm ELF 7.3 live / Chaitin spill Cap residual shell
 * (BC 8.3.1).
 *
 * wave156–213 pure-owned slices live in runtime_pipeline_abi pure (#[no_mangle];
 * seed cold twins under #ifndef FROM_X). See history comments in git.
 *
 * wave214 pure-owned live set arrays + opaque u8 overlay thins:
 *   · block_live_fwd / live_at_stmt[32] / snap_before_if / sub_exit_snap
 *   · cfg_peak_live + peak_stmt_i + peak_clear/snapshot/getters
 *   · loop break/continue stacks + push/pop/note/union_into_u8
 *   · live_fwd n_get/off_at/clear/add/copy/remove/contains + global thins
 *   · fill_live_end_for_merge / set_from_expr_uses
 *
 * Cap residual authority remaining in this host leaf (same TU #include):
 *   · glue_asm_cache_invalidate_at_cfg_merge (whole-table fallback)
 *
 * G.7: do not re-define pure-owned faces above in this file.
 * Not a separate .o — #included from pipeline_glue.c after index_helpers.
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — spill/reload
 *   · MACOS|ARM64 AAPCS64 — x10–x15 linear scan + index scratch stack
 */


/* wave156 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * G.7: definitions must not reappear in this Cap residual leaf. PLATFORM: SHARED. */
void glue_index_assign_addr_cache_clear(void);
int32_t glue_index_assign_addr_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                         int32_t base_ref, int32_t idx_ref, int32_t esz);
int32_t glue_emit_bulk_mem_copy_spills_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t src_spill,
                                            int32_t dst_spill, int32_t esz, int32_t ta);
int32_t glue_index_assign_finish_store_elf_c(struct ast_ASTArena *arena,
                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            struct backend_AsmFuncCtx *ctx, int32_t base_ref,
                                            int32_t idx_ref, int32_t esz, int32_t ta);
int32_t glue_index_load_from_cached_assign_addr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t esz, int32_t ta);
int32_t glue_try_block_let_index_init_from_assign_cache_elf_c(struct ast_ASTArena *arena,
                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             struct backend_AsmFuncCtx *ctx,
                                                             int32_t init_ref, int32_t ta);
int32_t glue_enc_swap_rax_rbx_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t glue_expr_kind_is_assign_like_ord(int32_t ko);
void glue_binop_kill_assign_lhs_slots_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t assign_expr_ref);

/* wave158 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual live_fwd_add calls pure collect/add. PLATFORM: SHARED. */
int32_t glue_cfg_def_offs_contains(const int32_t *buf, int32_t n, int32_t off);
void glue_cfg_def_offs_add(int32_t *buf, int32_t cap, int32_t *n, int32_t off);
void glue_cfg_collect_block_def_offs_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                           int32_t block_ref, int32_t *buf, int32_t cap, int32_t *n);
void glue_asm_cache_invalidate_at_cfg_merge_selective(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                      int32_t branch_a_ref, int32_t branch_b_ref);
void glue_asm_if_phi_invalidate_both_branch_defs(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t then_ref, int32_t else_ref);

/* wave159 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual linear live paths call has_cfg; while/for pure call loop_phi. PLATFORM: SHARED. */
int32_t glue_block_stmt_order_has_cfg(struct ast_ASTArena *arena, int32_t block_ref);
void glue_asm_loop_phi_invalidate_carried_defs(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t body_ref);

/* wave160 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual fill_live_end / snap / break-continue stacks + new thin accessors. PLATFORM: SHARED. */
void glue_asm_if_merge_live_union_from_ends(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                           void *then_live, void *else_live);
void glue_asm_loop_merge_live_union(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                    int32_t body_ref);

/* wave161 pure-owned face (extern; live in runtime_pipeline_abi pure).
 * Residual: collect_expr_uses + forward_after_def + union_from_u8. PLATFORM: SHARED. */
void glue_live_fwd_apply_expr_effect(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                     int32_t expr_ref);

/* wave162 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: break/continue note_current + live stacks + push/pop. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_break_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_continue_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave163 pure-owned face (extern; live in runtime_pipeline_abi pure).
 * Residual: cache BSS + live_fwd contains + stack_spill drop thin faces. PLATFORM: SHARED. */
void glue_binop_cache_intersect_live_fwd(void);

/* wave164 pure-owned face (extern; live in runtime_pipeline_abi pure).
 * Residual: interf BSS + pin/color maps + next-use + thin accessors. PLATFORM: SHARED. */
void glue_asm73_compute_spill_color_chaitin(int32_t peak_i, const void *peak_live);

/* wave165 pure-owned face (extern; live in runtime_pipeline_abi pure).
 * Residual: interf BSS + live_at_stmt + thin clear/add/n/as_u8. PLATFORM: SHARED. */
void glue_asm73_compute_spill_color_pins(void);

/* wave166 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: cache/live BSS + thin thresh/find_depth/evict_entry/live_fwd_as_u8.
 * PLATFORM: SHARED freestanding 7.3. */
void glue_asm73_linear_scan_evict_cache_if_pressure_live(const void *live, int32_t stmt_i, int32_t ta,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx);
void glue_asm73_linear_scan_evict_cache_if_pressure(int32_t stmt_i, int32_t ta,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx);
void glue_asm73_evict_cache_if_live_pressure_elf_c(int32_t ta, struct platform_elf_ElfCodegenCtx *elf_ctx);

/* wave167 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: interf/peak BSS + thin prepare/bind/snapshot.
 * PLATFORM: SHARED freestanding 7.3. */
void glue_asm73_note_cfg_live_peak(const void *live, int32_t stmt_i, int32_t nso, int32_t add_interf_edges);
void glue_block_compute_cfg_peak_live_and_color(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t block_ref, int32_t slot_base, int32_t nconst,
                                               int32_t nlet);

/* wave168 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: live_fwd/interf BSS + gen_kill helpers + thin u8 faces.
 * PLATFORM: SHARED freestanding 7.3. */
void glue_block_simulate_cfg_live(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx, int32_t block_ref,
                                 const void *live_in, void *live_out, int32_t depth);
void glue_block_simulate_cfg_live_from_empty(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t block_ref);

/* wave169 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: CAP BSS + thin depth/pop/hit/append. PLATFORM: SHARED freestanding 7.3. */
int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
void glue_index_scratch_spill_invalidate_var(struct ast_ASTArena *arena,
                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             struct backend_AsmFuncCtx *ctx, int32_t var_ref, int32_t ta);
int32_t glue_binop_stack_spill_push_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta, int32_t off,
                                          int32_t from_rbx);

/* wave170 pure-owned face (extern; live in runtime_pipeline_abi pure).
 * PLATFORM: SHARED freestanding 7.3. */
int32_t glue_binop_try_reload_spill_off_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             struct backend_AsmFuncCtx *ctx, int32_t off, int32_t ta,
                                             int32_t to_rbx);
/* wave211 pure-owned: stack-spill try_reload enc (extern; live pure).
 * G.7 dual-export ban — body must not reappear in this Cap residual leaf.
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64 AAPCS64. */
int32_t glue_binop_stack_spill_try_reload_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                int32_t off, int32_t to_rbx);

/* wave171 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: CAP depth BSS + wave172 pure spill helpers call these.
 * PLATFORM: SHARED freestanding 7.3 / MACOS|ARM64 AAPCS64. */
int32_t glue_enc_push_index_scratch_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t glue_enc_reload_index_scratch_from_stack_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t ta);
int32_t glue_enc_pop_index_scratch_stack_arm64_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t glue_index_reload_scratch_slot_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                            int32_t slot_depth);
int32_t glue_index_reload_scratch_slot_to_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                   int32_t slot_depth);

/* wave172 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: CAP cache BSS + thin record/valid/slot/ctx/keys for pure leave.
 * PLATFORM: SHARED freestanding 7.3. */
int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                         int32_t j_ref, int32_t ta);
int32_t glue_index_minus_pair_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                       int32_t i_ref, int32_t j_ref, int32_t ta);
int32_t glue_index_subadd3_sum_cache_spill_store_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                      struct backend_AsmFuncCtx *ctx, int32_t i_ref,
                                                      int32_t j_ref, int32_t k_ref, int32_t ta);
int32_t glue_index_subadd3_sum_cache_hit(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t i_ref, int32_t j_ref, int32_t k_ref, int32_t ta);
int32_t glue_index_subadd3_spill_pop_top_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);

/* wave173 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: VAR cache / live_fwd BSS + thin active/cfg_parent/emit_stmt_i +
 * contains_off / live_at_stmt_as_u8 / copy_from_u8 / gen_kill_u8 /
 * live_fwd_as_u8 / apply_stmt_gen_kill_u8.
 * PLATFORM: SHARED freestanding 7.3. */
void glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(struct ast_ASTArena *arena,
                                                           struct backend_AsmFuncCtx *ctx, int32_t right_ref,
                                                           int32_t ta, struct platform_elf_ElfCodegenCtx *elf_ctx);
void glue_block_live_fwd_before_stmt(int32_t stmt_i, int32_t ta, struct platform_elf_ElfCodegenCtx *elf_ctx);
void glue_block_live_fwd_apply_top_stmt(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t block_ref, int32_t slot_base, int32_t nconst, int32_t nlet,
                                        int32_t stmt_i);

/* wave174 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * PLATFORM: SHARED freestanding 7.3. */
int32_t glue_binop_spill_reg_to_spill_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta, int32_t off,
                                           int32_t from_rbx, int32_t stmt_i);
void glue_asm73_evict_rax_cache_entry(int32_t stmt_i, int32_t ta, struct platform_elf_ElfCodegenCtx *elf_ctx);
void glue_asm73_evict_rbx_cache_entry(int32_t stmt_i, int32_t ta, struct platform_elf_ElfCodegenCtx *elf_ctx);

/* wave175 pure-owned Chaitin/color physical-slot thin (extern; live pure).
 * Residual thin: set_spill_slot / off_is_spill_pin / stack_spill_enabled /
 * max_live_n_get + color which / next_use.
 * PLATFORM: SHARED freestanding 7.3. */
int32_t glue_binop_spill_mov_reg_to_spill_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                               int32_t off, int32_t from_rbx, int32_t spill_which);
int32_t glue_asm73_try_spill_to_colored_slot(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta, int32_t off,
                                            int32_t from_rbx);
int32_t glue_asm73_spill_slot_farthest(int32_t stmt_i);
int32_t glue_asm73_spill_pick_evict_which(int32_t stmt_i, int32_t new_off, int32_t dist_new);

/* wave176 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * Residual: live_fwd / live_at_stmt / linear ctx BSS + thin remove/contains/
 * live_at_stmt_copy / linear getters / sub_exit snap stamp. PLATFORM: SHARED.
 * Use void* for live overlays — GlueBlockLiveFwd typedef is later in this file. */
void glue_live_fwd_collect_expr_uses(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t expr_ref, void *gen);
void glue_block_stmt_gen_kill_u8(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx, int32_t block_ref,
                                 int32_t slot_base, int32_t nconst, int32_t nlet, int32_t stmt_i, void *gen,
                                 void *kill);
void glue_live_fwd_apply_stmt_gen_kill_u8(void *live, const void *gen, const void *kill);
void glue_block_compute_linear_live_in(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                               int32_t block_ref, int32_t slot_base, int32_t nconst, int32_t nlet);
void glue_block_compute_live_end_linear(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t block_ref, void *out);
void glue_block_compute_live_end_linear_to_sub_exit_snap(struct ast_ASTArena *arena,
                                                        struct backend_AsmFuncCtx *ctx,
                                                        int32_t block_ref);
void glue_live_fwd_forward_after_def(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t def_off, int32_t gen_expr);
int32_t glue_asm73_linear_next_use_dist(int32_t from_stmt, int32_t off);

/* wave177 pure-owned INDEX structural key hash (extern; live in runtime_pipeline_abi pure).
 * G.7: was static residual twin of w156 pure helpers — dual authority closed.
 * wave209 pure CAP cache thin (keys_eq/record/hit_var) call these.
 * PLATFORM: SHARED freestanding 7.3. */
uint64_t glue_index_addr_key_mix64(uint64_t h, uint64_t v);
uint64_t glue_index_expr_struct_key_elf_c(struct ast_ASTArena *arena, int32_t ref);
uint64_t glue_index_base_struct_key_elf_c(struct ast_ASTArena *arena, int32_t base_ref);

/* Forward decls / callees defined elsewhere in the same TU:
 * - glue_var_expr_stack_off_elf_c (def after assign/index includes)
 * - glue_emit_index_eff_addr_scaled_elf_c (runtime_pipeline_abi pure wave147)
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / asm_ctx_local_*
 * - CAP depth pure wave207; stack_spill table pure wave208; CAP cache pure
 *   wave209; VAR slot cache pure wave210; try_reload enc pure wave211
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_func_index
 *
 * Note: try_reload enc pure leave closed wave211; color/pin BSS pure wave212;
 * wave213 pure owns live control scalars + interf BSS + linear_ctx + pressure
 * thresh; wave214 pure owns live set arrays + opaque u8 overlay thins.
 * Residual shell: cache_invalidate_at_cfg_merge only.
 */

/* wave212 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * G.7: definitions must not reappear in this Cap residual leaf.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path. */
void glue_asm73_pin_spill_off_clear_all(void);
void glue_asm73_pin_spill_off_set(int32_t which, int32_t off);
int32_t glue_asm73_off_is_spill_pin(int32_t off);
void glue_asm73_clear_spill_color_map(void);
void glue_asm73_set_spill_color(int32_t off, int32_t which);
int32_t glue_asm73_off_spill_color_which(int32_t off);
int32_t glue_asm73_cfg_coloring_active_get(void);
void glue_asm73_cfg_coloring_active_set(int32_t v);
void glue_asm73_cfg_final_expr_use_n_set(int32_t n);
int32_t glue_asm73_stack_spill_enabled(void);
int32_t glue_asm73_var_prefers_stack_spill(int32_t off);

/* wave213 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * G.7: definitions must not reappear in this Cap residual leaf.
 * PLATFORM: SHARED freestanding 7.3. */
int32_t glue_block_live_cfg_parent_get(void);
void glue_block_live_cfg_parent_set(int32_t v);
int32_t glue_block_live_fwd_active_get(void);
void glue_block_live_fwd_active_set(int32_t v);
void glue_block_emit_stmt_i_set(int32_t v);
int32_t glue_block_emit_stmt_i_get(void);
int32_t glue_asm73_linear_max_live_n_get(void);
void glue_asm73_linear_max_live_n_set(int32_t n);
void glue_asm73_linear_max_live_n_maybe_raise(int32_t n);
int32_t glue_asm73_pressure_live_thresh_get(void);
void glue_asm73_interf_clear(void);
int32_t glue_asm73_interf_n_get(void);
int32_t glue_asm73_interf_off_at(int32_t i);
int32_t glue_asm73_interf_has_edge(int32_t i, int32_t j);
void glue_asm73_interf_add_live_set_u8(const void *live);
void glue_asm73_interf_add_live_at_stmt(int32_t stmt_i);
void glue_asm73_interf_push(void);
void glue_asm73_interf_pop_merge(void);
void glue_asm73_cfg_interf_prepare(void);
void glue_asm73_linear_ctx_bind(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx, int32_t block_ref,
                               int32_t slot_base, int32_t nconst, int32_t nlet, int32_t nso);
void *glue_asm73_linear_arena_get(void);
void *glue_asm73_linear_ctx_get(void);
int32_t glue_asm73_linear_block_ref_get(void);
int32_t glue_asm73_linear_slot_base_get(void);
int32_t glue_asm73_linear_nconst_get(void);
int32_t glue_asm73_linear_nlet_get(void);
int32_t glue_asm73_linear_nso_get(void);

/* wave210 pure-owned: binop VAR slot cache BSS + thin faces (extern).
 * G.7: definitions must not reappear in this Cap residual leaf.
 * PLATFORM: SHARED freestanding 7.3 · MACOS|ARM64 AAPCS64 co-path for x10–x15. */
void glue_binop_var_slot_cache_clear(void);
void glue_binop_var_slot_cache_invalidate_rax(void);
void glue_binop_var_slot_cache_invalidate_rbx(void);
void glue_binop_var_slot_cache_invalidate_slot(int32_t off);
void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off);
int32_t glue_binop_var_slot_cache_ctx_matches(void *ctx);
int32_t glue_binop_var_slot_cache_hit_rax(void *ctx, int32_t off);
int32_t glue_binop_var_slot_cache_hit_rbx(void *ctx, int32_t off);
int32_t glue_binop_var_slot_cache_valid_rax_get(void);
int32_t glue_binop_var_slot_cache_valid_rbx_get(void);
int32_t glue_binop_var_slot_cache_rax_off_get(void);
int32_t glue_binop_var_slot_cache_rbx_off_get(void);
void glue_binop_var_slot_cache_set_ctx_key(void *ctx);
void glue_binop_var_slot_cache_set_rax(void *ctx, int32_t off);
void glue_binop_var_slot_cache_set_rbx(void *ctx, int32_t off);
void glue_binop_var_slot_cache_set_valid_rax(int32_t v);
void glue_binop_var_slot_cache_set_valid_rbx(int32_t v);
void glue_binop_var_slot_cache_set_rax_off(int32_t off);
void glue_binop_var_slot_cache_set_rbx_off(int32_t off);
void glue_binop_var_slot_cache_set_spill_slot(int32_t which, int32_t off);
int32_t glue_binop_var_slot_cache_valid_x10_get(void);
int32_t glue_binop_var_slot_cache_valid_x11_get(void);
int32_t glue_binop_var_slot_cache_valid_x12_get(void);
int32_t glue_binop_var_slot_cache_valid_x13_get(void);
int32_t glue_binop_var_slot_cache_valid_x14_get(void);
int32_t glue_binop_var_slot_cache_valid_x15_get(void);
int32_t glue_binop_var_slot_cache_x10_off_get(void);
int32_t glue_binop_var_slot_cache_x11_off_get(void);
int32_t glue_binop_var_slot_cache_x12_off_get(void);
int32_t glue_binop_var_slot_cache_x13_off_get(void);
int32_t glue_binop_var_slot_cache_x14_off_get(void);
int32_t glue_binop_var_slot_cache_x15_off_get(void);
void glue_binop_var_slot_cache_set_valid_x10(int32_t v);
void glue_binop_var_slot_cache_set_valid_x11(int32_t v);
void glue_binop_var_slot_cache_set_valid_x12(int32_t v);
void glue_binop_var_slot_cache_set_valid_x13(int32_t v);
void glue_binop_var_slot_cache_set_valid_x14(int32_t v);
void glue_binop_var_slot_cache_set_valid_x15(int32_t v);

/** Forward decl: rec emit 是否会 clobber rbx（定义见 binop 活跃性 helpers）。 */
int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref);

/** Drop cached INDEX effective address (rbx no longer trusted for reuse). */

/** CFG 写槽扫描所需 AST 块 API（定义见本文件后部；须先于 glue_cfg_collect_block_def_offs）。 */
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t block_ref);

/** CFG 汇合点收集的写槽 off 上限（块内 let/assign 并集；pure collect 同 cap=32）。 */
#define GLUE_CFG_DEF_OFFS_CAP 32

/* wave158: pure owns glue_cfg_def_offs_* / collect / selective / if_phi (extern above).
 * Residual live_fwd_add + loop_phi call pure collect/add. PLATFORM: SHARED. */


/* wave214 pure-owned faces (extern; live in runtime_pipeline_abi pure).
 * G.7: definitions must not reappear in this Cap residual leaf.
 * PLATFORM: SHARED freestanding 7.3. */
int32_t glue_live_fwd_n_get(const void *live);
int32_t glue_live_fwd_off_at(const void *live, int32_t i);
void glue_live_fwd_clear_u8(void *live);
void glue_live_fwd_add_u8(void *live, int32_t off);
void glue_live_fwd_copy_u8(void *dst, const void *src);
void glue_live_fwd_remove_u8(void *live, int32_t off);
int32_t glue_live_fwd_contains_u8(const void *live, int32_t off);
void *glue_block_live_fwd_as_u8(void);
void glue_block_live_fwd_clear_global(void);
int32_t glue_block_live_fwd_contains_off(int32_t off);
void glue_block_live_fwd_add_off(int32_t off);
void glue_block_live_fwd_remove_off(int32_t off);
void glue_block_live_fwd_copy_from_u8(void *src);
void glue_block_live_fwd_union_from_u8(void *src);
void glue_live_snap_before_if_copy_from_block_live_fwd(void);
void glue_live_fwd_copy_from_snap_before_if(void *dst);
void glue_block_live_sub_exit_snap_clear(void);
void glue_block_live_sub_exit_snap_copy_from_block_live_fwd(void);
void glue_block_live_sub_exit_snap_copy_from_u8(const void *src);
int32_t glue_asm73_live_at_stmt_n_get(int32_t stmt_i);
void *glue_asm73_live_at_stmt_as_u8(int32_t stmt_i);
void glue_block_live_at_stmt_copy_from_u8(int32_t stmt_i, const void *live);
int32_t glue_asm73_cfg_peak_live_n_get(void);
void *glue_asm73_cfg_peak_live_as_u8(void);
int32_t glue_asm73_cfg_peak_stmt_i_get(void);
void glue_asm73_cfg_peak_snapshot_from_u8(const void *live, int32_t stmt_i);
void glue_asm73_cfg_peak_clear(void);
void glue_block_live_fwd_set_from_expr_uses(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                           int32_t expr_ref);
void glue_block_fill_live_end_for_merge(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                        int32_t block_ref, void *out_live);
int32_t glue_loop_break_exit_depth_get(void);
void glue_loop_break_exit_push(void);
void glue_loop_break_exit_pop(void);
void glue_loop_break_exit_note_current(void);
void glue_loop_continue_head_note_current(void);
void glue_loop_break_exit_live_union_into_u8(void *dst, int32_t d);
void glue_loop_continue_head_live_union_into_u8(void *dst, int32_t d);


/* wave158: pure owns glue_cfg_def_offs_* / collect / selective / if_phi (extern above).
 * PLATFORM: SHARED. */

/* wave214 pure-owned: all live set arrays + opaque u8 overlay thins + fill /
 * set_from_expr_uses + loop break/continue stacks (runtime_pipeline_abi pure).
 * Cap residual: no host live BSS or overlay bodies (G.7 dual-export ban).
 * Whole-table cache_invalidate_at_cfg_merge removed (unused; pure selective only).
 * PLATFORM: SHARED freestanding 7.3. */

/* wave157 residual shell: externs for same-TU consumers (wpo / index) that
 * frame-sum historically provided. Not live-set related. PLATFORM: SHARED. */
extern int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
extern int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);

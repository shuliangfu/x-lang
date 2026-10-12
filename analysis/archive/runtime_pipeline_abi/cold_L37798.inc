/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen remaining wave156 FROM_X after leftover-PE assign_like unique */

void glue_binop_kill_assign_lhs_slots_elf_c(void *arena, void *ctx, int32_t assign_expr_ref) {
  (void)arena; (void)ctx; (void)assign_expr_ref;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */ /* remaining wave156 after leftover-PE assign_like unique */


/*
 * wave157 cold twins: frame-sum pure-owned faces
 * (glue_asm_sum_block_call_spill_bytes + glue_sum_block_slice_reent_dc_bytes_c).
 * Freestanding-safe stubs (return 0). Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_sum_block_slice_reent_dc_bytes_c(void *arena, int32_t block_ref) {
  (void)arena; (void)block_ref;
  return 0;
}

int32_t glue_asm_sum_block_call_spill_bytes(void *arena, int32_t block_ref) {
  (void)arena; (void)block_ref;
  return 0;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/*
 * wave158 cold twins: CFG merge/phi + def-offs collect pure-owned faces.
 * Freestanding-safe stubs (no-op / return 0). Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_cfg_def_offs_contains(const int32_t *buf, int32_t n, int32_t off) {
  (void)buf; (void)n; (void)off;
  return 0;
}

void glue_cfg_def_offs_add(int32_t *buf, int32_t cap, int32_t *n, int32_t off) {
  (void)buf; (void)cap; (void)n; (void)off;
}

void glue_cfg_collect_block_def_offs_elf_c(void *arena, void *ctx, int32_t block_ref, int32_t *buf, int32_t cap,
                                           int32_t *n) {
  (void)arena; (void)ctx; (void)block_ref; (void)buf; (void)cap; (void)n;
}

void glue_asm_cache_invalidate_at_cfg_merge_selective(void *arena, void *ctx, int32_t branch_a_ref,
                                                      int32_t branch_b_ref) {
  (void)arena; (void)ctx; (void)branch_a_ref; (void)branch_b_ref;
}

void glue_asm_if_phi_invalidate_both_branch_defs(void *arena, void *ctx, int32_t then_ref, int32_t else_ref) {
  (void)arena; (void)ctx; (void)then_ref; (void)else_ref;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/*
 * wave159 cold twins: loop φ carried-def invalidate + stmt_order has_cfg.
 * Freestanding-safe stubs (no-op / return 0). Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_block_stmt_order_has_cfg(void *arena, int32_t block_ref) {
  (void)arena; (void)block_ref;
  return 0;
}

void glue_asm_loop_phi_invalidate_carried_defs(void *arena, void *ctx, int32_t body_ref) {
  (void)arena; (void)ctx; (void)body_ref;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave160 cold twins: if/loop live-merge union.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_asm_if_merge_live_union_from_ends(void *arena, void *ctx, void *then_live, void *else_live) {
  (void)arena; (void)ctx; (void)then_live; (void)else_live;
}

void glue_asm_loop_merge_live_union(void *arena, void *ctx, int32_t body_ref) {
  (void)arena; (void)ctx; (void)body_ref;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave161 cold twin: glue_live_fwd_apply_expr_effect.
 * Freestanding-safe no-op stub. Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_live_fwd_apply_expr_effect(void *arena, void *ctx, int32_t expr_ref) {
  (void)arena; (void)ctx; (void)expr_ref;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave162 cold twins: pipeline_asm_emit_break_elf_c / continue_elf_c.
 * Freestanding-safe fail stubs (-1). Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t pipeline_asm_emit_break_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)ctx; (void)ta;
  return -1;
}

int32_t pipeline_asm_emit_continue_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)ctx; (void)ta;
  return -1;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave163 cold twin: glue_binop_cache_intersect_live_fwd.
 * Freestanding-safe no-op stub. Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_binop_cache_intersect_live_fwd(void) {
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave164 cold twin: glue_asm73_compute_spill_color_chaitin.
 * Freestanding-safe no-op stub. Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_asm73_compute_spill_color_chaitin(int32_t peak_i, const void *peak_live) {
  (void)peak_i;
  (void)peak_live;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave165 cold twin: glue_asm73_compute_spill_color_pins.
 * Freestanding-safe no-op stub. Hybrid product links pure.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_asm73_compute_spill_color_pins(void) {
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave166 cold twins: linear-scan pressure eviction faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_asm73_linear_scan_evict_cache_if_pressure_live(const void *live, int32_t stmt_i, int32_t ta,
                                                        void *elf_ctx) {
  (void)live;
  (void)stmt_i;
  (void)ta;
  (void)elf_ctx;
}

void glue_asm73_linear_scan_evict_cache_if_pressure(int32_t stmt_i, int32_t ta, void *elf_ctx) {
  (void)stmt_i;
  (void)ta;
  (void)elf_ctx;
}

void glue_asm73_evict_cache_if_live_pressure_elf_c(int32_t ta, void *elf_ctx) {
  (void)ta;
  (void)elf_ctx;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave167 cold twins: cfg interf peak + color entry faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_asm73_note_cfg_live_peak(const void *live, int32_t stmt_i, int32_t nso, int32_t add_interf_edges) {
  (void)live;
  (void)stmt_i;
  (void)nso;
  (void)add_interf_edges;
}

void glue_block_compute_cfg_peak_live_and_color(void *arena, void *ctx, int32_t block_ref, int32_t slot_base,
                                               int32_t nconst, int32_t nlet) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
  (void)slot_base;
  (void)nconst;
  (void)nlet;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave168 cold twins: cfg simulate walk faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_block_simulate_cfg_live(void *arena, void *ctx, int32_t block_ref, const void *live_in, void *live_out,
                                 int32_t depth) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
  (void)live_in;
  (void)live_out;
  (void)depth;
}

void glue_block_simulate_cfg_live_from_empty(void *arena, void *ctx, int32_t block_ref) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave169 cold twins: index-scratch public faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * glue_index_scratch_spills_cleanup_all_elf_c moved to leftover-PE
 * try_propagate unique OR after await/as (WIN leftover T; !FROM_X still
 * compiled there). Keep invalidate_var / binop_stack_spill_push here.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_index_scratch_spill_invalidate_var(void *arena, void *elf_ctx, void *ctx, int32_t var_ref,
                                             int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)var_ref;
  (void)ta;
}

int32_t glue_binop_stack_spill_push_elf_c(void *elf_ctx, int32_t ta, int32_t off, int32_t from_rbx) {
  (void)elf_ctx;
  (void)ta;
  (void)off;
  (void)from_rbx;
  return 0;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave170 cold twin: binop spill try-reload public face.
 * Freestanding-safe no-op stub. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_binop_try_reload_spill_off_elf_c(void *elf_ctx, void *ctx, int32_t off, int32_t ta, int32_t to_rbx) {
  (void)elf_ctx;
  (void)ctx;
  (void)off;
  (void)ta;
  (void)to_rbx;
  return 0;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave171 cold twins: index-scratch enc push/reload/pop + slot reload faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_enc_push_index_scratch_arm64_elf_c(void *elf_ctx, int32_t ta) {
  (void)elf_ctx;
  (void)ta;
  return 0;
}

int32_t glue_enc_reload_index_scratch_from_stack_arm64_elf_c(void *elf_ctx, int32_t ta) {
  (void)elf_ctx;
  (void)ta;
  return 0;
}

int32_t glue_enc_pop_index_scratch_stack_arm64_elf_c(void *elf_ctx, int32_t ta) {
  (void)elf_ctx;
  (void)ta;
  return 0;
}

int32_t glue_index_reload_scratch_slot_elf_c(void *elf_ctx, int32_t ta, int32_t slot_depth) {
  (void)elf_ctx;
  (void)ta;
  (void)slot_depth;
  return 0;
}

int32_t glue_index_reload_scratch_slot_to_rbx_elf_c(void *elf_ctx, int32_t ta, int32_t slot_depth) {
  (void)elf_ctx;
  (void)ta;
  (void)slot_depth;
  return 0;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave172 cold twins: minus_pair / subadd3 cache spill helper faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_index_minus_pair_cache_spill_after_sub_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t i_ref,
                                                         int32_t j_ref, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)i_ref;
  (void)j_ref;
  (void)ta;
  return 0;
}

int32_t glue_index_minus_pair_cache_hit(void *arena, void *ctx, int32_t i_ref, int32_t j_ref, int32_t ta) {
  (void)arena;
  (void)ctx;
  (void)i_ref;
  (void)j_ref;
  (void)ta;
  return 0;
}

int32_t glue_index_subadd3_sum_cache_spill_store_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t i_ref,
                                                      int32_t j_ref, int32_t k_ref, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)i_ref;
  (void)j_ref;
  (void)k_ref;
  (void)ta;
  return 0;
}

int32_t glue_index_subadd3_sum_cache_hit(void *arena, void *ctx, int32_t i_ref, int32_t j_ref, int32_t k_ref,
                                        int32_t ta) {
  (void)arena;
  (void)ctx;
  (void)i_ref;
  (void)j_ref;
  (void)k_ref;
  (void)ta;
  return 0;
}

int32_t glue_index_subadd3_spill_pop_top_elf_c(void *elf_ctx, int32_t ta) {
  (void)elf_ctx;
  (void)ta;
  return 0;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave173 cold twins: left_assoc spill + live_fwd before/apply faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_asm73_left_assoc_spill_rbx_before_var_load_elf_c(void *arena, void *ctx, int32_t right_ref, int32_t ta,
                                                           void *elf_ctx) {
  (void)arena;
  (void)ctx;
  (void)right_ref;
  (void)ta;
  (void)elf_ctx;
}

void glue_block_live_fwd_before_stmt(int32_t stmt_i, int32_t ta, void *elf_ctx) {
  (void)stmt_i;
  (void)ta;
  (void)elf_ctx;
}

void glue_block_live_fwd_apply_top_stmt(void *arena, void *ctx, int32_t block_ref, int32_t slot_base, int32_t nconst,
                                        int32_t nlet, int32_t stmt_i) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
  (void)slot_base;
  (void)nconst;
  (void)nlet;
  (void)stmt_i;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave174 cold twins: spill_reg_to_spill + rax/rbx cache evict faces.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_binop_spill_reg_to_spill_elf_c(void *elf_ctx, int32_t ta, int32_t off, int32_t from_rbx,
                                           int32_t stmt_i) {
  (void)elf_ctx;
  (void)ta;
  (void)off;
  (void)from_rbx;
  (void)stmt_i;
  return 0;
}

void glue_asm73_evict_rax_cache_entry(int32_t stmt_i, int32_t ta, void *elf_ctx) {
  (void)stmt_i;
  (void)ta;
  (void)elf_ctx;
}

void glue_asm73_evict_rbx_cache_entry(int32_t stmt_i, int32_t ta, void *elf_ctx) {
  (void)stmt_i;
  (void)ta;
  (void)elf_ctx;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave175 cold twins: Chaitin/color physical-slot thin (mov/try/farthest/pick).
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_binop_spill_mov_reg_to_spill_elf_c(void *elf_ctx, int32_t ta, int32_t off, int32_t from_rbx,
                                               int32_t spill_which) {
  (void)elf_ctx;
  (void)ta;
  (void)off;
  (void)from_rbx;
  (void)spill_which;
  return 0;
}

int32_t glue_asm73_try_spill_to_colored_slot(void *elf_ctx, int32_t ta, int32_t off, int32_t from_rbx) {
  (void)elf_ctx;
  (void)ta;
  (void)off;
  (void)from_rbx;
  return -1;
}

int32_t glue_asm73_spill_slot_farthest(int32_t stmt_i) {
  (void)stmt_i;
  return -1;
}

int32_t glue_asm73_spill_pick_evict_which(int32_t stmt_i, int32_t new_off, int32_t dist_new) {
  (void)stmt_i;
  (void)new_off;
  (void)dist_new;
  return -1;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave176 cold twins: linear live reverse DF + gen/kill + next-use.
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_live_fwd_collect_expr_uses(void *arena, void *ctx, int32_t expr_ref, void *gen) {
  (void)arena;
  (void)ctx;
  (void)expr_ref;
  (void)gen;
}

void glue_block_stmt_gen_kill_u8(void *arena, void *ctx, int32_t block_ref, int32_t slot_base, int32_t nconst,
                                 int32_t nlet, int32_t stmt_i, void *gen, void *kill) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
  (void)slot_base;
  (void)nconst;
  (void)nlet;
  (void)stmt_i;
  (void)gen;
  (void)kill;
}

void glue_live_fwd_apply_stmt_gen_kill_u8(void *live, const void *gen, const void *kill) {
  (void)live;
  (void)gen;
  (void)kill;
}

void glue_block_compute_linear_live_in(void *arena, void *ctx, int32_t block_ref, int32_t slot_base, int32_t nconst,
                                       int32_t nlet) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
  (void)slot_base;
  (void)nconst;
  (void)nlet;
}

void glue_block_compute_live_end_linear(void *arena, void *ctx, int32_t block_ref, void *out) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
  (void)out;
}

void glue_block_compute_live_end_linear_to_sub_exit_snap(void *arena, void *ctx, int32_t block_ref) {
  (void)arena;
  (void)ctx;
  (void)block_ref;
}

void glue_live_fwd_forward_after_def(void *arena, void *ctx, int32_t def_off, int32_t gen_expr) {
  (void)arena;
  (void)ctx;
  (void)def_off;
  (void)gen_expr;
}

int32_t glue_asm73_linear_next_use_dist(int32_t from_stmt, int32_t off) {
  (void)from_stmt;
  (void)off;
  return 9999;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave177 cold twins: INDEX structural key hash (G.7 pure leave).
 * Freestanding-safe no-op stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding 7.3.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

uint64_t glue_index_addr_key_mix64(uint64_t h, uint64_t v) {
  (void)h;
  (void)v;
  return 0;
}

uint64_t glue_index_expr_struct_key_elf_c(void *arena, int32_t ref) {
  (void)arena;
  (void)ref;
  return 0;
}

uint64_t glue_index_base_struct_key_elf_c(void *arena, int32_t base_ref) {
  (void)arena;
  (void)base_ref;
  return 0;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/*
 * wave178 cold twins: INDEX expr shape peel forest (G.7 pure leave).
 * Freestanding-safe no-op stubs (return 0 = no match). Hybrid product links pure.
 * PLATFORM: SHARED freestanding INDEX peel.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t glue_index_expr_var_plus_var_pair_elf_c(void *arena, int32_t add_ref, int32_t *out_left_var,
                                               int32_t *out_right_var) {
  (void)arena;
  (void)add_ref;
  (void)out_left_var;
  (void)out_right_var;
  return 0;
}

int32_t glue_index_expr_var_add3_elf_c(void *arena, int32_t add_ref, int32_t *out_i, int32_t *out_j,
                                      int32_t *out_k) {
  (void)arena;
  (void)add_ref;
  (void)out_i;
  (void)out_j;
  (void)out_k;
  return 0;
}

int32_t glue_index_expr_var_minus_var_pair_elf_c(void *arena, int32_t sub_ref, int32_t *out_left_var,
                                                int32_t *out_right_var) {
  (void)arena;
  (void)sub_ref;
  (void)out_left_var;
  (void)out_right_var;
  return 0;
}

int32_t glue_index_expr_var_minus_add3_elf_c(void *arena, int32_t sub_ref, int32_t *out_i, int32_t *out_j,
                                            int32_t *out_k) {
  (void)arena;
  (void)sub_ref;
  (void)out_i;
  (void)out_j;
  (void)out_k;
  return 0;
}

int32_t glue_index_expr_var_subadd3_elf_c(void *arena, int32_t add_ref, int32_t *out_i, int32_t *out_j,
                                         int32_t *out_k) {
  (void)arena;
  (void)add_ref;
  (void)out_i;
  (void)out_j;
  (void)out_k;
  return 0;
}

int32_t glue_index_expr_var_subsub3_elf_c(void *arena, int32_t sub_ref, int32_t *out_i, int32_t *out_j,
                                         int32_t *out_k) {
  (void)arena;
  (void)sub_ref;
  (void)out_i;
  (void)out_j;
  (void)out_k;
  return 0;
}

/*
 * wave179 cold twins: INDEX local-slot ptr/addr + field-slot deref thin (G.7 pure leave).
 * Freestanding-safe stubs: enc faces return -1 (force residual/fallback paths);
 * field-slot deref returns 0 (no-op). Hybrid product links pure.
 * PLATFORM: SHARED freestanding INDEX local slot.
 */
int32_t glue_enc_local_slot_ptr_or_addr_elf_c(void *arena, void *elf_ctx, int32_t var_ref, int32_t var_off,
                                             void *ctx, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)var_ref;
  (void)var_off;
  (void)ctx;
  (void)ta;
  return -1;
}

int32_t glue_enc_local_slot_ptr_or_addr_rbx_elf_c(void *arena, void *elf_ctx, int32_t var_ref, int32_t var_off,
                                                 void *ctx, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)var_ref;
  (void)var_off;
  (void)ctx;
  (void)ta;
  return -1;
}

int32_t glue_index_deref_ptr_field_slot_rax_elf_c(void *arena, void *elf_ctx, int32_t fa_ref, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)fa_ref;
  (void)ta;
  return 0;
}

int32_t glue_index_deref_ptr_field_slot_rbx_elf_c(void *arena, void *elf_ctx, int32_t fa_ref, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)fa_ref;
  (void)ta;
  return 0;
}

/*
 * wave180 cold twins: INDEX type / stride helpers (G.7 pure leave).
 * Freestanding-safe stubs: fixed_array→0, esz→4, var_type→0.
 * Hybrid product links pure. PLATFORM: SHARED freestanding INDEX type helpers.
 */
int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth) {
  (void)arena;
  (void)ty_ref;
  (void)depth;
  return 0;
}

int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr) {
  (void)arena;
  (void)tr;
  return 4;
}

int32_t glue_var_expr_type_ref_with_decl_fallback_c(void *arena, int32_t var_ref) {
  (void)arena;
  (void)var_ref;
  return 0;
}

/*
 * wave181 cold twins: simple try_index assign-addr→rbx forest (G.7 pure leave).
 * Freestanding-safe stubs: return -2 (not applicable; force residual/fallback).
 * Hybrid product links pure. PLATFORM: SHARED freestanding INDEX assign.
 */
int32_t glue_try_index_var_lit_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                         void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                         void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                          void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                          void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                        void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

int32_t glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref,
                                                        void *ctx, int32_t ta, int32_t esz) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)ctx;
  (void)ta;
  (void)esz;
  return -2;
}

/*
 * wave182 cold twins: INDEX base materialize → rax / rbx (G.7 pure leave).
 * Freestanding-safe stubs: return -2 (not applicable; force residual/fallback).
 * Hybrid product links pure. PLATFORM: SHARED freestanding INDEX base.
 * 2026-09-13: guard under #ifndef FROM_X — as STRONG symbols these stubs beat
 * the WEAK pure .x bodies in ld -r, so hybrid silently ran the stub (base
 * helper always -2) and the .x TYPE_VECTOR(13) ptr-home deref fix (local SIMD
 * vector INDEX) never linked. Cold full seed (no FROM_X) keeps the stubs.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t glue_try_index_var_or_field_base_to_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, void *ctx,
                                                     int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)ctx;
  (void)ta;
  return -2;
}

int32_t glue_try_index_var_or_field_base_to_rbx_elf_c(void *arena, void *elf_ctx, int32_t base_ref, void *ctx,
                                                     int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)base_ref;
  (void)ctx;
  (void)ta;
  return -2;
}
#endif /* !XLANG_RUNTIME_PIPELINE_ABI_FROM_X wave182 base twins */

/*
 * wave183 cold twins: nested try_index assign-addr→rbx forest (G.7 pure leave).
 * Freestanding-safe stubs: return -2 (not applicable; force residual/fallback).
 * Hybrid product links pure. PLATFORM: SHARED freestanding INDEX assign.
 */
#define XLANG_W183_TRY_INDEX_ADDR_TWIN(name) \
  int32_t name(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, \
               void *ctx, int32_t ta, int32_t esz) { \
    (void)arena; (void)elf_ctx; (void)base_ref; (void)idx_ref; \
    (void)ctx; (void)ta; (void)esz; \
    return -2; \
  }

XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c)
XLANG_W183_TRY_INDEX_ADDR_TWIN(glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c)

#undef XLANG_W183_TRY_INDEX_ADDR_TWIN

/*
 * wave184 cold twins: try_index eff_addr→rax forest (16 faces, G.7 pure leave).
 * Freestanding-safe stubs: return -2 (not applicable; force residual/fallback).
 * Hybrid product links pure. PLATFORM: SHARED freestanding INDEX rvalue/lea.
 */
#define XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(name) \
  int32_t name(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, \
               void *ctx, int32_t ta, int32_t esz) { \
    (void)arena; (void)elf_ctx; (void)base_ref; (void)idx_ref; \
    (void)ctx; (void)ta; (void)esz; \
    return -2; \
  }

XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_mul_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_mul_var_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_plus_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_plus_var_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_var_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_add3_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c)
XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN(glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c)

#undef XLANG_W184_TRY_INDEX_EFF_ADDR_TWIN

/*
 * wave185 cold twins: lvalue_eff_addr ELF + text (G.7 pure leave).
 * Freestanding-safe stubs: return -1 (unhandled). Hybrid product links pure.
 * PLATFORM: SHARED freestanding assign/field/INDEX lvalue path.
 */
int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t lval_ref, void *ctx,
                                               int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)lval_ref;
  (void)ctx;
  (void)ta;
  return -1;
}

int32_t pipeline_asm_emit_lvalue_eff_addr_text_c(void *arena, void *out, int32_t lval_ref, void *ctx, int32_t ta) {
  (void)arena;
  (void)out;
  (void)lval_ref;
  (void)ctx;
  (void)ta;
  return -1;
}

/*
 * wave186 cold twin: SoA index.field addr (G.7 pure leave).
 * Freestanding-safe stub: return -1 (unhandled). Hybrid product links pure.
 * PLATFORM: SHARED freestanding SoA arr[i].field path.
 */
int32_t glue_emit_soa_index_field_addr_elf_c(void *arena, void *elf_ctx, int32_t index_expr_ref,
                                             int32_t fa_ref, void *ctx, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)index_expr_ref;
  (void)fa_ref;
  (void)ctx;
  (void)ta;
  return -1;
}

/*
 * wave187 cold twin: FIELD_ACCESS field type_ref (G.7 pure leave).
 * Freestanding-safe stub: return 0 (unknown type). Hybrid product links pure.
 * PLATFORM: SHARED freestanding FIELD type recovery.
 */
int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t fa_ref) {
  (void)arena;
  (void)mod;
  (void)fa_ref;
  return 0;
}

/*
 * wave188 cold twin: VAR expr stack_off (G.7 pure leave).
 * Body moved to leftover-PE emit_as callee unique OR (file-scope
 * !FROM_X || WIN). Leaving it here would dual-def on !FROM_X.
 * PLATFORM: SHARED freestanding VAR frame offset path.
 */

/*
 * wave189 cold twins: module_from_ctx + needs_ptr cluster (G.7 pure leave).
 * glue_emit_module_from_ctx moved to leftover-PE emit_as callee unique OR.
 * Remaining needs_ptr stubs stay here (not unique).
 * PLATFORM: SHARED freestanding emit-module / load-vs-lea path.
 */

int32_t glue_emit_func_param_is_indirect_array_slot_c(void *arena, void *mod, int32_t var_expr_ref) {
  (void)arena;
  (void)mod;
  (void)var_expr_ref;
  return 0;
}

int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(void *arena, void *mod, int32_t var_expr_ref) {
  (void)arena;
  (void)mod;
  (void)var_expr_ref;
  return 0;
}

int32_t glue_local_var_slot_needs_ptr_load_elf_c(void *arena, int32_t var_expr_ref, int32_t stack_off, void *ctx) {
  (void)arena;
  (void)var_expr_ref;
  (void)stack_off;
  (void)ctx;
  return 0;
}


/*
 * wave190 cold twins: CALL-arg lea-vs-load gate (G.7 pure leave).
 * Freestanding-safe stubs. Hybrid product links pure.
 * PLATFORM: SHARED freestanding CALL-arg packing.
 */
int32_t glue_type_ref_is_named_struct_layout_elf_c(void *arena, void *mod, int32_t ty_ref) {
  (void)arena;
  (void)mod;
  (void)ty_ref;
  return 0;
}

int32_t glue_call_arg_var_use_lea_not_load_elf_c(void *arena, int32_t expr_ref, void *ctx) {
  (void)arena;
  (void)expr_ref;
  (void)ctx;
  return 0;
}

#endif /* close wave178 FROM_X for leftover-PE named_layout unique */

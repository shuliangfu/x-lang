/* PLATFORM: WINDOWS leftover-PE — real glue_emit_assign_var_elf_c.
 * windows_link_stubs.c still has return -1 stubs; windows_e assign_emit
 * dispatches VAR lhs here. Without this, `c = 7` / `c = res.value` CG002.
 * Merge first with -Wl,--allow-multiple-definition over the stub.
 * Authority twin: runtime_pipeline_abi_assign_var_*.x finish+store path.
 */
#include <stdint.h>

extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t glue_emit_assign_rhs_to_rax_elf_c(void *arena, void *elf_ctx, int32_t assign_expr_ref,
                                                int32_t left_ref, int32_t right_ref, void *ctx,
                                                int32_t ta);
extern int32_t glue_float_promote_src_ty_ref_c(void *arena, int32_t right_ref);
extern int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(void *arena, void *elf_ctx, int32_t ltr,
                                                      int32_t rty, int32_t ta);
extern int32_t glue_maybe_demote_f64_to_f32_eax_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ltr,
                                                     int32_t right_ref, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                                    int32_t slot_off, int32_t ta, int32_t init_ref,
                                                    void *ctx);
extern void *glue_emit_module_from_ctx(void *ctx);
extern void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off);
extern void glue_binop_var_slot_cache_invalidate_slot(int32_t off);
extern void glue_index_scratch_spill_invalidate_var(void *arena, void *elf_ctx, void *ctx,
                                                    int32_t left_ref, int32_t ta);

/* Weak fallback when assign_rhs helper is absent from leftover link. */
__attribute__((weak)) int32_t glue_emit_assign_rhs_to_rax_elf_c(void *arena, void *elf_ctx,
                                                               int32_t assign_expr_ref, int32_t left_ref,
                                                               int32_t right_ref, void *ctx, int32_t ta) {
  int32_t ako;
  (void)left_ref;
  if (!arena || !elf_ctx || !ctx || right_ref <= 0)
    return -1;
  ako = pipeline_expr_kind_ord_at(arena, assign_expr_ref);
  if (ako != 28 && !(ako >= 29 && ako <= 38))
    return -1;
  /* Plain ASSIGN: emit RHS into rax (compound-assign needs fuller twin). */
  if (ako == 28)
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
  return -1;
}

__attribute__((weak)) int32_t glue_float_promote_src_ty_ref_c(void *arena, int32_t right_ref) {
  (void)arena;
  (void)right_ref;
  return 0;
}

__attribute__((weak)) int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(void *arena, void *elf_ctx, int32_t ltr,
                                                                    int32_t rty, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)ltr;
  (void)rty;
  (void)ta;
  return 0;
}

__attribute__((weak)) int32_t glue_maybe_demote_f64_to_f32_eax_elf_c(void *arena, void *elf_ctx, void *ctx,
                                                                   int32_t ltr, int32_t right_ref, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)ctx;
  (void)ltr;
  (void)right_ref;
  (void)ta;
  return 0;
}

__attribute__((weak)) void glue_binop_var_slot_cache_kill_def_at_slot(int32_t off) { (void)off; }
__attribute__((weak)) void glue_binop_var_slot_cache_invalidate_slot(int32_t off) { (void)off; }
__attribute__((weak)) void glue_index_scratch_spill_invalidate_var(void *a, void *e, void *c, int32_t l,
                                                                  int32_t t) {
  (void)a;
  (void)e;
  (void)c;
  (void)l;
  (void)t;
}

int32_t glue_emit_assign_var_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                  int32_t right_ref, void *ctx, int32_t ta) {
  int32_t off;
  int32_t ltr;
  int32_t ltk;
  int32_t rty;

  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  if (off < 0)
    return -1;
  glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, left_ref, ta);
  glue_binop_var_slot_cache_invalidate_slot(off);

  if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0)
    return -1;

  ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  rty = glue_float_promote_src_ty_ref_c(arena, right_ref);
  if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, ltr, rty, ta) != 0)
    return -1;
  if (glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, ltr, right_ref, ta) != 0)
    return -1;

  ltk = (ltr > 0) ? pipeline_type_kind_ord_at(arena, ltr) : 0;
  if (ltk == 11) {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
      return -1;
  } else if (ltr > 0 && ltk == 14) {
    if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
  } else if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, ltr, off, ta,
                                                right_ref, ctx) != 0) {
    return -1;
  }
  glue_binop_var_slot_cache_kill_def_at_slot(off);
  return 0;
}

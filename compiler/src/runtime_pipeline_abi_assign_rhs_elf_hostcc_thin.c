/* Source-faithful glue_emit_assign_rhs_* twins
 * (runtime_pipeline_abi_assign_thin.x / assign_rhsrax_arms_*_thin.x).
 *
 * s213 DIG: dig PE first-wins absolute ret0 stubs (3B xor+ret) at
 *   glue_emit_assign_rhs_elf_c / glue_emit_assign_load_lr_elf_c /
 *   glue_emit_assign_rhs_mod_elf_c (cluster ~0x14050554f). Callers of
 *   plain assign (ako==28) invoke glue_emit_assign_rhs_elf_c → stub
 *   returns 0 without emitting RHS → `i = i + 1` stores leftover rax
 *   (0) with no ADD. Real body lives as pipeline_glue_emit_assign_rhs_elf_c
 *   under a different name, so it never wins. Same class as s211/s212
 *   tipU first-wins (stub / pointer-as-value).
 *
 * Aside dig s213_assign_rhs: stub → jmp pipeline_glue → assign/while/
 * break probes emit ADD + loop jmps. Host-cc twins restore the named
 * symbols for tip LINK_WINNERS.
 *
 * docs-only .x overlays that tip-return-0 must not first-wins; do not idx8.
 * PLATFORM: SHARED host-cc first-wins.
 */
#include <stdint.h>

/* Plain assign RHS → value in rax (assign_thin.x authority). */
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx,
                                           int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t glue_assign_lhs_f32_type_ref_elf_c(void *arena, void *ctx,
                                                 int32_t left_ref);
extern int32_t glue_emit_float_lit_to_rax_elf_c(void *arena, void *elf_ctx,
                                               int32_t expr_ref, int32_t ta,
                                               int32_t force_ty_ref,
                                               int32_t call_abi_widen_f64);

/* Compound load L/R (assign_rhsrax_arms_load_lr_thin.x). */
extern int32_t glue_try_binop_left_rax_right_rbx_elf_c(void *arena, void *elf_ctx,
                                                       int32_t left_ref,
                                                       int32_t right_ref,
                                                       void *ctx, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf_ctx, int32_t ta);

/* Compound %= arm (assign_rhsrax_arms_mod_thin.x). */
extern int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(void *elf_ctx,
                                                             void *ctx,
                                                             int32_t ta);
extern int32_t backend_enc_rem_mod_arch(void *elf_ctx, int32_t ta);

/**
 * Emit assign RHS into rax. Float-lit + lhs-f32 uses imm32 path;
 * otherwise general expr emit (covers `i + 1` binop).
 * @return 0 ok; -1 failure
 */
int32_t glue_emit_assign_rhs_elf_c(void *arena, void *elf_ctx, int32_t left_ref,
                                   int32_t right_ref, void *ctx, int32_t ta) {
  int32_t rko;
  int32_t lhs_f32;
  int32_t rc;
  (void)left_ref;
  if (arena == 0 || right_ref <= 0) {
    return -1;
  }
  rko = pipeline_expr_kind_ord_at(arena, right_ref);
  /* FLOAT_LIT kind_ord == 1 — match assign_thin.x fast path. */
  if (rko == 1) {
    lhs_f32 = glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref);
    if (lhs_f32 > 0) {
      rc = glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta,
                                           lhs_f32, 0);
      return rc;
    }
  }
  return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
}

/**
 * Load LHS→rax and RHS→rbx for compound assign.
 * @return 0 ok; -1 fail
 */
int32_t glue_emit_assign_load_lr_elf_c(void *arena, void *elf_ctx,
                                      int32_t left_ref, int32_t right_ref,
                                      void *ctx, int32_t ta) {
  int32_t vr;
  if (arena == 0 || elf_ctx == 0 || ctx == 0) {
    return -1;
  }
  vr = glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref,
                                               right_ref, ctx, ta);
  if (vr == -1) {
    return -1;
  }
  if (vr != -2) {
    return 0;
  }
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
    return -1;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
    return -1;
  }
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
    return -1;
  }
  if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
    return -1;
  }
  return 0;
}

/**
 * Compound %= arm — zero-check then rem/mod.
 * @return 0 ok; -1 fail
 */
int32_t glue_emit_assign_rhs_mod_elf_c(void *arena, void *elf_ctx,
                                      int32_t assign_expr_ref, int32_t left_ref,
                                      int32_t right_ref, void *ctx,
                                      int32_t ta) {
  (void)arena;
  (void)assign_expr_ref;
  (void)left_ref;
  (void)right_ref;
  if (elf_ctx == 0 || ctx == 0) {
    return -1;
  }
  if (pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta) != 0) {
    return -1;
  }
  return backend_enc_rem_mod_arch(elf_ctx, ta);
}

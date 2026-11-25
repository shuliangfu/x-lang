#include <stdint.h>
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
    int32_t slot_off, int32_t ta, int32_t init_ref, void *ctx);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                      void *ctx, int32_t ta, int32_t stack_slot_off);

static int32_t emit_then_store(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                               int32_t ta, int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t rc;
  void *modp;
  if (stack_slot_off < 0)
    return -2;
  rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
  if (rc != 0)
    return -1;
  if (let_ty_ref > 0) {
    modp = glue_emit_module_from_ctx(ctx);
    if (glue_store_retval_pair_to_rbp_elf_c(modp, arena, elf_ctx, let_ty_ref, stack_slot_off, ta, init_ref, ctx) == 0)
      return 0;
  }
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  return 0;
}

/* PLATFORM: WINDOWS tip PE — import-call-to-let + scalar let-init cover.
 * Host leftover CALL/METHOD let-init returned -1 (CG002 code_len≈19).
 * STRUCT_LIT → existing emitter. Scalar/VAR/CALL/METHOD → emit+store.
 * Else -2 for specialized faces (vector/array) to decline.
 */
int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx,
                                            int32_t ta, int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t ko;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 45 && (stack_slot_off >= 0 || stack_slot_off == -3))
    return pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  /* 0 INT_LIT 1 FLOAT_LIT 2 BOOL 3 VAR 48 CALL 49 METHOD — tip.x fallthrough twins */
  if (ko == 0 || ko == 1 || ko == 2 || ko == 3 || ko == 48 || ko == 49)
    return emit_then_store(arena, elf_ctx, init_ref, ctx, ta, let_ty_ref, stack_slot_off);
  return -2;
}

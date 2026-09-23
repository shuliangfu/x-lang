/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_enc_test_eax_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jnz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);

int32_t pipeline_asm_emit_logand_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t false_lbl[256];
  uint8_t end_lbl[256];
  int32_t false_len;
  int32_t end_len;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  false_len = pipeline_asm_emit_next_label_c(ctx, false_lbl, 64);
  end_len = pipeline_asm_emit_next_label_c(ctx, end_lbl, 64);
  if (false_len <= 0 || end_len <= 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jz_arch(elf_ctx, false_lbl, false_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jz_arch(elf_ctx, false_lbl, false_len, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, end_lbl, end_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, false_lbl, false_len, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, end_lbl, end_len, 0, ta) != 0)
    return -1;
  return 0;
}

int32_t pipeline_asm_emit_logor_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t true_lbl[256];
  uint8_t end_lbl[256];
  int32_t true_len;
  int32_t end_len;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  true_len = pipeline_asm_emit_next_label_c(ctx, true_lbl, 64);
  end_len = pipeline_asm_emit_next_label_c(ctx, end_lbl, 64);
  if (true_len <= 0 || end_len <= 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jnz_arch(elf_ctx, true_lbl, true_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jnz_arch(elf_ctx, true_lbl, true_len, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, end_lbl, end_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, true_lbl, true_len, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, end_lbl, end_len, 0, ta) != 0)
    return -1;
  return 0;
}

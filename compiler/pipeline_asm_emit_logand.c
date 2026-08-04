/**
 * pipeline_asm_emit_logand.c — asm ELF EXPR_LOGAND / EXPR_LOGOR emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding short-circuit boolean
 * binary emit:
 * - pipeline_asm_emit_logand_elf_impl (&& : left false → 0 else right → 0/1)
 * - pipeline_asm_emit_logor_elf_impl  (|| : left true  → 1 else right → 0/1)
 *
 * G.7: single product-mega LOGAND/LOGOR ELF emit path — do not open a second
 * short-circuit emitter in seed partial or a parallel glue copy. rec / thin
 * wrappers stay in pipeline_glue.c and call these static impls (same TU).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after async
 * CPS emit helpers and before if-arm / token-kind / block-body emit.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

static int32_t pipeline_asm_emit_logand_elf_impl(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t false_lbl[128];
  uint8_t end_lbl[128];
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
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jz_arch(elf_ctx, false_lbl, false_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
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

/** EXPR_LOGOR 短路：左真则 1，否则右真则 1，否则 0。 */
static int32_t pipeline_asm_emit_logor_elf_impl(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t true_lbl[128];
  uint8_t end_lbl[128];
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
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jnz_arch(elf_ctx, true_lbl, true_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, right_ref, ctx, ta) != 0)
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

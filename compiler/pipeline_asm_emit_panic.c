/**
 * pipeline_asm_emit_panic.c — asm ELF EXPR_PANIC + integer div-zero panic face
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding panic-related ELF emit:
 * - pipeline_asm_emit_xlang_panic_call_elf_c (call xlang_panic_(code, msg);
 *   arg1 then arg0 load order — arm64 w0 safety; msg_ref==0 → imm 0)
 * - pipeline_asm_emit_panic_elf_c (EXPR_PANIC → has_msg 0/1/2: bare / int /
 *   cstr STRING_LIT|TYPE_PTR — Cap residual pure; wave386 host-C align)
 * - pipeline_asm_emit_panic_int_div_zero_elf_c (UB narrow: xlang_panic_(1,0)
 *   matching host-C integer div-zero check)
 * - pipeline_asm_emit_divisor_zero_check_rbx_elf_c (test rbx/w1; zero → panic;
 *   else fall through — idiv/rem preflight)
 *
 * G.7: single product-mega PANIC / div-zero ELF face — do not open a second
 * panic call sequence. Nested binop div/mod bodies remain in pipeline_glue.c
 * (same TU; call into these helpers).
 *
 * Callers: expr_elf_rec EXPR_PANIC arm; binop div/mod / rem zero checks.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the former
 * panic body site (after match include + glue_var helpers; before binop
 * unsigned/64bit classifiers).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_emit_expr_elf_rec (static; declared earlier)
 * - pipeline_asm_emit_next_label_c
 * - backend_enc_*_arch
 * - pipeline_expr_unary_operand_ref_at / pipeline_expr_kind_ord_at /
 *   pipeline_expr_resolved_type_ref / pipeline_type_kind_ord_at
 */

/**
 * Emit call xlang_panic_(code, msg); msg_ref==0 loads second arg as 0.
 * Load arg1 then arg0 on both x86 and arm64 so arm64 does not clobber w0.
 */
static int32_t pipeline_asm_emit_xlang_panic_call_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t code,
                                                            int32_t msg_ref) {
  static const uint8_t panic_nm[] = "xlang_panic_";

  if (msg_ref > 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, msg_ref, ctx, ta) != 0)
      return -1;
  } else if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) {
    return -1;
  }
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, code, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)panic_nm, 14, ta);
}

/**
 * EXPR_PANIC → xlang_panic_(has_msg, msg).
 * has_msg: 0 bare / 1 integer / 2 cstr pointer (STRING_LIT or TYPE_PTR).
 * PLATFORM: SHARED freestanding+asm — wave386 aligns with host-C has_msg=2 cstr print.
 * Second arg is pointer-width in arg1; runtime prints cstr when has_msg==2.
 */
int32_t pipeline_asm_emit_panic_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t op_ref;
  int32_t code;
  int32_t is_cstr;
  int32_t op_ty;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op_ref <= 0) {
    code = 0;
  } else {
    is_cstr = 0;
    if (pipeline_expr_kind_ord_at(arena, op_ref) == 59) /* EXPR_STRING_LIT */ {
      is_cstr = 1;
    } else {
      op_ty = pipeline_expr_resolved_type_ref(arena, op_ref);
      if (op_ty > 0 && pipeline_type_kind_ord_at(arena, op_ty) == (int32_t)ast_TypeKind_TYPE_PTR)
        is_cstr = 1;
    }
    code = is_cstr ? 2 : 1;
  }
  return pipeline_asm_emit_xlang_panic_call_elf_c(arena, elf_ctx, ctx, ta, code, op_ref);
}

/**
 * UB narrow: emit xlang_panic_(1, 0) (matches host-C integer div-zero check).
 */
static int32_t pipeline_asm_emit_panic_int_div_zero_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  return pipeline_asm_emit_xlang_panic_call_elf_c(0, elf_ctx, 0, ta, 1, 0);
}

/**
 * Divisor already in rbx/w1: zero-check; if zero panic else continue idiv/rem.
 * Must use enc_test_rbx (not mov rbx→rax); VAR fast path dividend stays in w0/rax.
 */
static int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                struct backend_AsmFuncCtx *ctx, int32_t ta) {
  uint8_t ok_lbl[128];
  int32_t ok_len;

  ok_len = pipeline_asm_emit_next_label_c(ctx, ok_lbl, 64);
  if (ok_len <= 0)
    return -1;
  if (backend_enc_test_rbx_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jne_arch(elf_ctx, ok_lbl, ok_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_lbl, ok_len, 0, ta) != 0)
    return -1;
  return 0;
}

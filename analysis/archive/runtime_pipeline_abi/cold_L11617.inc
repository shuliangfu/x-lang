/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t backend_enc_test_rbx_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jne_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);

int32_t pipeline_asm_emit_xlang_panic_call_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ta, int32_t code,
                                                 int32_t msg_ref) {
  static const uint8_t panic_nm[] = "xlang_panic_";
  if (msg_ref > 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, msg_ref, ctx, ta) != 0)
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

int32_t pipeline_asm_emit_panic_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
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
      if (op_ty > 0 && pipeline_type_kind_ord_at(arena, op_ty) == 9 /* TYPE_PTR */)
        is_cstr = 1;
    }
    code = is_cstr ? 2 : 1;
  }
  return pipeline_asm_emit_xlang_panic_call_elf_c(arena, elf_ctx, ctx, ta, code, op_ref);
}

int32_t pipeline_asm_emit_panic_int_div_zero_elf_c(void *elf_ctx, int32_t ta) {
  return pipeline_asm_emit_xlang_panic_call_elf_c(0, elf_ctx, 0, ta, 1, 0);
}

/* User product -o: test rbx/w1, jne ok, CALL xlang_panic_(1,0), label.
 * XLANG_PREFER_ASM_O=1: host-E no-op so prefer-asm compiler leaves with / %
 * stay free of U xlang_panic_ (Stage 12.0.5). Darwin ARM64 sdiv #0 is 0.
 * PLATFORM: SHARED cold twin of runtime_pipeline_abi.x authority (G.7 same commit). */
int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(void *elf_ctx, void *ctx, int32_t ta) {
  uint8_t ok_lbl[256];
  int32_t ok_len;
  const char *pe;
  if (elf_ctx == 0 || ctx == 0)
    return 0;
  pe = link_abi_getenv("XLANG_PREFER_ASM_O");
  if (pe && pe[0] == '1')
    return 0;
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

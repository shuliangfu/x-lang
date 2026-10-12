/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t pipeline_asm_emit_expr_if_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t cond;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[256];
  uint8_t done_lbl[256];
  int32_t else_len;
  int32_t done_len;
  cond = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  then_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
  else_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
  if (cond == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cond, ctx, ta) != 0)
    return -1;
  else_len = pipeline_asm_emit_next_label_c(ctx, else_lbl, 64);
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (else_len <= 0 || done_len <= 0)
    return -1;
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, else_lbl, else_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, then_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
    return -1;
  if (else_ref != 0) {
    if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, else_ref, ctx, ta) != 0)
      return -1;
  } else {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
      return -1;
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  return 0;
}

/*
 * wave135: pipeline_asm_emit_x86_enc_helpers pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: 27 glue_enc_x86_* + glue_emit_lcg_xor_body_x86_c.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave132+ leave twins.
 */
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);

/** x86: cmpl $imm32, %eax. */
int32_t glue_enc_x86_cmpl_eax_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[5];
  if (!elf_ctx)
    return -1;
  b[0] = 0x3d;
  b[1] = (uint8_t)imm32;
  b[2] = (uint8_t)(imm32 >> 8);
  b[3] = (uint8_t)(imm32 >> 16);
  b[4] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 5);
}

/** x86: imull $imm32, %eax. */
int32_t glue_enc_x86_imull_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x69;
  b[1] = 0xc0;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: addl $imm32, %eax (skip if imm==0). */
int32_t glue_enc_x86_addl_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  if (imm32 == 0)
    return 0;
  if (imm32 >= -128 && imm32 <= 127) {
    b[0] = 0x83;
    b[1] = 0xc0;
    b[2] = (uint8_t)imm32;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x05;
  b[1] = (uint8_t)imm32;
  b[2] = (uint8_t)(imm32 >> 8);
  b[3] = (uint8_t)(imm32 >> 16);
  b[4] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 5);
}

/** x86: addl $imm8/imm32, -off(%rbp) (i++ fast path; disp32 for large disp). */
int32_t glue_enc_x86_addl_imm_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off,
                                             int32_t imm32) {
  int32_t disp;
  uint8_t b[10];
  if (!elf_ctx)
    return -1;
  if (imm32 == 0)
    return 0;
  disp = -off;
  if (imm32 >= -128 && imm32 <= 127 && disp >= -128 && disp <= -1) {
    b[0] = 0x83;
    b[1] = 0x45;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)imm32;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 4);
  }
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x81;
    b[1] = 0x45;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)imm32;
    b[4] = (uint8_t)(imm32 >> 8);
    b[5] = (uint8_t)(imm32 >> 16);
    b[6] = (uint8_t)(imm32 >> 24);
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 7);
  }
  if (imm32 >= -128 && imm32 <= 127) {
    b[0] = 0x83;
    b[1] = 0x85;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)(disp >> 8);
    b[4] = (uint8_t)(disp >> 16);
    b[5] = (uint8_t)(disp >> 24);
    b[6] = (uint8_t)imm32;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 7);
  }
  b[0] = 0x81;
  b[1] = 0x85;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  b[6] = (uint8_t)imm32;
  b[7] = (uint8_t)(imm32 >> 8);
  b[8] = (uint8_t)(imm32 >> 16);
  b[9] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 10);
}

/** x86: movl -off(%rbp), %ecx (loop_i32 LCG register-ization). */
int32_t glue_enc_x86_movl_rbp_off_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x8b;
    b[1] = 0x4d;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x8b;
  b[1] = 0x8d;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: movl -off(%rbp), %edx. */
int32_t glue_enc_x86_movl_rbp_off_to_edx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x8b;
    b[1] = 0x55;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x8b;
  b[1] = 0x95;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: movl %ecx, -off(%rbp). */
int32_t glue_enc_x86_movl_ecx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x89;
    b[1] = 0x4d;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x89;
  b[1] = 0x8d;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: movl %edx, -off(%rbp). */
int32_t glue_enc_x86_movl_edx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x89;
    b[1] = 0x55;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x89;
  b[1] = 0x95;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: cmpl $imm32, %ecx. */
int32_t glue_enc_x86_cmpl_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x81;
  b[1] = 0xf9;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: xorl %eax, %eax (LCG s initial value 0). */
int32_t glue_enc_x86_xor_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc0};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: imull $imm32, %edx, %ecx (t = i*C1, i resident in edx). */
int32_t glue_enc_x86_imul_ecx_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x69;
  b[1] = 0xca;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: addl $imm32, %ecx (LCG t += C2). */
int32_t glue_enc_x86_addl_imm_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x81;
  b[1] = 0xc1;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: xorl %ecx, %eax (s ^= t, s resident in eax). */
int32_t glue_enc_x86_xorl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc8};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: incl %edx (LCG i++). */
int32_t glue_enc_x86_incl_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0xff, 0xc2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: cmpl $imm32, %edx (LCG bottom-tested i vs n-1 compare). */
int32_t glue_enc_x86_cmpl_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x81;
  b[1] = 0xfa;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** Emit single LCG body iteration: t=i*C1+C2; s^=t; i++ (edx=i, eax=s, ecx=scratch). */
int32_t glue_emit_lcg_xor_body_x86_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t c1, int32_t c2) {
  if (glue_enc_x86_imul_ecx_edx_imm32(elf_ctx, c1) != 0)
    return -1;
  if (glue_enc_x86_incl_edx(elf_ctx) != 0)
    return -1;
  if (glue_enc_x86_addl_imm_ecx(elf_ctx, c2) != 0)
    return -1;
  if (glue_enc_x86_xorl_ecx_eax(elf_ctx) != 0)
    return -1;
  return 0;
}

/** x86: imull $imm32, %ecx, %eax (t = i*C1, i stays in ecx). */
int32_t glue_enc_x86_imul_eax_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x69;
  b[1] = 0xc1;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: xorl %ecx, %ecx. */
int32_t glue_enc_x86_xor_ecx_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc9};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %edx, %edx. */
int32_t glue_enc_x86_xor_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xd2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: movl %ecx, %eax. */
int32_t glue_enc_x86_movl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x89, 0xc8};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %eax, %edx (LCG s ^= t, s resident in edx). */
int32_t glue_enc_x86_xorl_eax_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: incl %ecx. */
int32_t glue_enc_x86_incl_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0xff, 0xc1};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %eax, -off(%rbp) (s ^= t in-place, avoid t stack slot). */
int32_t glue_enc_x86_xorl_eax_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x31;
    b[1] = 0x45;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x31;
  b[1] = 0x85;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: mov %al, (%rbx,%rax,1). */
int32_t glue_enc_x86_mov_al_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[3] = {0x88, 0x04, 0x03};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3) : -1;
}

/** x86: movzbl (%rbx,%rax,1), %ecx. */
int32_t glue_enc_x86_movzx_ecx_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[4] = {0x0f, 0xb6, 0x0c, 0x03};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 4) : -1;
}

/** x86: add %ecx, -off(%rbp). */
int32_t glue_enc_x86_add_ecx_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp = -off;
  uint8_t b[7];
  if (!elf_ctx)
    return -1;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x01;
    b[1] = 0x4d;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x01;
  b[1] = 0x8d;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: imul %eax, %eax. */
int32_t glue_enc_x86_imul_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[3] = {0x0f, 0xaf, 0xc0};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3) : -1;
}

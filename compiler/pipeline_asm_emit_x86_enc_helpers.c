/**
 * pipeline_asm_emit_x86_enc_helpers.c — x86_64 raw byte encoders for SIMD
 * loop-unroll / LCG fold fast paths (BC 8.3.1 · wave1029).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding x86_64 micro-encoders
 * used by while-fold optimization (LCG xor, u8 fill, struct-pair n2):
 * - glue_enc_x86_cmpl_eax_imm32          (cmpl $imm32, %eax)
 * - glue_enc_x86_imull_imm_eax           (imull $imm32, %eax)
 * - glue_enc_x86_addl_imm_eax            (addl $imm8/imm32, %eax; imm==0 skip)
 * - glue_enc_x86_addl_imm_rbp_off        (addl $imm, -off(%rbp); disp8/disp32)
 * - glue_enc_x86_movl_rbp_off_to_ecx     (movl -off(%rbp), %ecx)
 * - glue_enc_x86_movl_rbp_off_to_edx     (movl -off(%rbp), %edx)
 * - glue_enc_x86_movl_ecx_to_rbp_off     (movl %ecx, -off(%rbp))
 * - glue_enc_x86_movl_edx_to_rbp_off     (movl %edx, -off(%rbp))
 * - glue_enc_x86_cmpl_ecx_imm32          (cmpl $imm32, %ecx)
 * - glue_enc_x86_xor_eax_eax             (xorl %eax, %eax)
 * - glue_enc_x86_imul_ecx_edx_imm32      (imull $imm32, %edx, %ecx)
 * - glue_enc_x86_addl_imm_ecx            (addl $imm32, %ecx)
 * - glue_enc_x86_xorl_ecx_eax            (xorl %ecx, %eax)
 * - glue_enc_x86_incl_edx                (incl %edx)
 * - glue_enc_x86_cmpl_edx_imm32          (cmpl $imm32, %edx)
 * - glue_emit_lcg_xor_body_x86_c         (LCG body: t=i*C1+C2; s^=t; i++)
 * - glue_enc_x86_imul_eax_ecx_imm32      (imull $imm32, %ecx, %eax)
 * - glue_enc_x86_xor_ecx_ecx             (xorl %ecx, %ecx)
 * - glue_enc_x86_xor_edx_edx             (xorl %edx, %edx)
 * - glue_enc_x86_movl_ecx_eax            (movl %ecx, %eax)
 * - glue_enc_x86_xorl_eax_edx            (xorl %eax, %edx)
 * - glue_enc_x86_incl_ecx                (incl %ecx)
 * - glue_enc_x86_xorl_eax_rbp_off        (xorl %eax, -off(%rbp))
 * - glue_enc_x86_mov_al_mem_rbx_rax      (mov %al, (%rbx,%rax,1))
 * - glue_enc_x86_movzx_ecx_mem_rbx_rax   (movzbl (%rbx,%rax,1), %ecx)
 * - glue_enc_x86_add_ecx_rbp_off         (add %ecx, -off(%rbp))
 * - glue_enc_x86_imul_eax_eax            (imul %eax, %eax)
 *
 * G.7: single product-mega x86 micro-encoder face — do not open a second
 * set of raw byte emitters for these patterns outside this leaf.
 * Callers: glue_try_fold_struct_pair_n2_while_elf_c / u8_fill /
 * lcg_xor fold paths in pipeline_glue.c (after this #include site).
 *
 * Dependencies: pipeline_elf_ctx_append_bytes (glue early; available at
 * #include site L7706 which is well past the early helper block).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * former x86 encoder body site (after fold_expr_var_refs_same_c; before
 * glue_expr_var_name_eq_let_idx_c).
 *
 * PLATFORM: LINUX+MACOS x86_64 SysV — raw byte encoders, no arch dispatch.
 * These are x86_64-only fast-path micro-encoders; ARM64 falls back to the
 * generic backend_enc_*_arch path in the fold callers.
 */

/** x86: cmpl $imm32, %eax. */
static int32_t glue_enc_x86_cmpl_eax_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_imull_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_addl_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_addl_imm_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off,
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
static int32_t glue_enc_x86_movl_rbp_off_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
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
static int32_t glue_enc_x86_movl_rbp_off_to_edx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
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
static int32_t glue_enc_x86_movl_ecx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
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
static int32_t glue_enc_x86_movl_edx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
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
static int32_t glue_enc_x86_cmpl_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_xor_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc0};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: imull $imm32, %edx, %ecx (t = i*C1, i resident in edx). */
static int32_t glue_enc_x86_imul_ecx_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_addl_imm_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_xorl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc8};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: incl %edx (LCG i++). */
static int32_t glue_enc_x86_incl_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0xff, 0xc2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: cmpl $imm32, %edx (LCG bottom-tested i vs n-1 compare). */
static int32_t glue_enc_x86_cmpl_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_emit_lcg_xor_body_x86_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t c1, int32_t c2) {
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
static int32_t glue_enc_x86_imul_eax_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
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
static int32_t glue_enc_x86_xor_ecx_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc9};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %edx, %edx. */
static int32_t glue_enc_x86_xor_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xd2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: movl %ecx, %eax. */
static int32_t glue_enc_x86_movl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x89, 0xc8};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %eax, %edx (LCG s ^= t, s resident in edx). */
static int32_t glue_enc_x86_xorl_eax_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: incl %ecx. */
static int32_t glue_enc_x86_incl_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0xff, 0xc1};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %eax, -off(%rbp) (s ^= t in-place, avoid t stack slot). */
static int32_t glue_enc_x86_xorl_eax_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
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
static int32_t glue_enc_x86_mov_al_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[3] = {0x88, 0x04, 0x03};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3) : -1;
}

/** x86: movzbl (%rbx,%rax,1), %ecx. */
static int32_t glue_enc_x86_movzx_ecx_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[4] = {0x0f, 0xb6, 0x0c, 0x03};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 4) : -1;
}

/** x86: add %ecx, -off(%rbp). */
static int32_t glue_enc_x86_add_ecx_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
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
static int32_t glue_enc_x86_imul_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[3] = {0x0f, 0xaf, 0xc0};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3) : -1;
}

/* seeds/backend_x86_64_enc_c.from_x.c
 * G-02f-130 true .x pure helpers.
 * G-02f-129 true .x pure helpers.
 * G-02f-128 true .x pure helpers.
 * G-02f-124 true .x pure helpers.
 * G-02f-102 helper gates.
 * G-02f-101 x86 enc helper gates. — G-02f-15 product TU
 * Product object from this seed; logic still C until full .x port.
 * w910: the fixed-byte arch_x86_64_enc_enc_* bodies live in
 * backend_enc_dispatch_thin.x. This file no longer emits them.
 * w911: thirteen immediate and leftover fixed-byte bodies live in
 * backend_enc_dispatch_thin.x. This file no longer emits them.
 * w912: nineteen rbp displacement and register-immediate bodies live in
 * backend_enc_dispatch_thin.x. This file no longer emits them.
 * w915: x86_enc_u8, x86_enc_u32_le, and x86_enc_bytes live in
 * backend_enc_dispatch_thin.x. This file no longer emits them.
 * Prologue, epilogue, label, jumps, calls, cmp_setcc, and the Win64
 * argument moves still call those three. PLATFORM: SHARED.
 */
/**
 * backend_x86_64_enc_c.c — x86_64 ELF 指令编码 C 体（覆盖 asm_full_link_stubs weak -1）
 *
 * M8 自举 USER_ASM_LINK 链仅 partial+stubs，未链 x86_64_enc.o；强符号在此提供，
 * 端口 arch/x86_64_enc.x。
 */
#include <stdint.h>
#include <string.h>

struct platform_elf_ElfCodegenCtx;

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
extern int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                              int32_t imm_bits);
extern int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
extern int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t pipeline_elf_ctx_pad_code_to_4(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_add_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes);

/* G-02f-441：thin+rest PREFER_X_O — common 函数由 .x -E 提供 thin .o；
 * rest .o 编译时定义 XLANG_BACKEND_X86_64_ENC_C_FROM_X 跳过 common 定义。 */
extern int32_t x86_enc_u8(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t b);
extern int32_t x86_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t x86_enc_bytes(struct platform_elf_ElfCodegenCtx *elf_ctx, const uint8_t *buf, int32_t n);
extern int32_t x86_enc_jcc_rel32(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t opcode2, uint8_t *label,
                                 int32_t label_len);
extern int32_t x86_enc_movq_from_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                         uint8_t disp8_modrm, uint8_t disp32_modrm);
extern int32_t x86_enc_lea_from_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                        uint8_t disp8_modrm, uint8_t disp32_modrm);
extern int32_t x86_enc_movl_from_rbp_neg32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                           uint8_t disp8_modrm, uint8_t disp32_modrm);
extern int32_t x86_enc_store_rax_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t x86_enc_store_r64_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg, int32_t offset);
extern int32_t x86_enc_alu_imm32_to_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, uint8_t op_prefix,
                                        uint8_t reg_modrm);
extern int32_t x86_enc_store_rdx_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);

/** 取 ElfCodegenCtx 字节视图。 */
static uint8_t *x86_enc_ctx_bytes(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return (uint8_t *)elf_ctx;
}

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w915: x86_enc_u8 is defined in backend_enc_dispatch_thin.x.
 * It forwards to backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */




/* w915: x86_enc_u32_le is defined in backend_enc_dispatch_thin.x.
 * It forwards to backend_enc_append_u32_le_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */


/* w915: x86_enc_bytes is defined in backend_enc_dispatch_thin.x.
 * It forwards to pipeline_elf_ctx_append_bytes. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */


#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#define X86_ENC_FIXED(ctx, arr) x86_enc_bytes((ctx), (const uint8_t *)(arr), (int32_t)sizeof(arr))

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/** x86 rel32 条件跳转 + patch（与 x86_64_enc.x enc_jz/enc_jge 一致）。 */
/* G-02f-129：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_jcc_rel32(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t opcode2, uint8_t *label,
                                 int32_t label_len) {
  uint8_t buf[6];
  int32_t rel32_at;
  uint8_t *cb;
  if (!elf_ctx || !label || label_len <= 0)
    return -1;
  cb = x86_enc_ctx_bytes(elf_ctx);
  buf[0] = 0x0F;
  buf[1] = opcode2;
  buf[2] = buf[3] = buf[4] = buf[5] = 0;
  if (pipeline_elf_ctx_append_bytes(cb, buf, 6) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch(cb, rel32_at, label, label_len, 0);
}


/** movq -offset(%rbp), %reg：modrm_reg 为 disp8 第三字节（69=rax, 93=rbx 等）。 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_movq_from_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                         uint8_t disp8_modrm, uint8_t disp32_modrm) {
  int32_t disp;
  uint8_t buf[7];
  disp = 0 - offset;
  if (disp >= -128 && disp <= -1) {
    buf[0] = 72;
    buf[1] = 0x8B;
    buf[2] = disp8_modrm;
    buf[3] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  buf[0] = 72;
  buf[1] = 0x8B;
  buf[2] = disp32_modrm;
  buf[3] = (uint8_t)(disp & 255);
  buf[4] = (uint8_t)((disp >> 8) & 255);
  buf[5] = (uint8_t)((disp >> 16) & 255);
  buf[6] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);

}


/** leaq -offset(%rbp), %reg。 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_lea_from_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                        uint8_t disp8_modrm, uint8_t disp32_modrm) {
  int32_t disp;
  uint8_t buf[7];
  disp = 0 - offset;
  if (disp >= -128 && disp <= -1) {
    buf[0] = 72;
    buf[1] = 0x8D;
    buf[2] = disp8_modrm;
    buf[3] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  buf[0] = 72;
  buf[1] = 0x8D;
  buf[2] = disp32_modrm;
  buf[3] = (uint8_t)(disp & 255);
  buf[4] = (uint8_t)((disp >> 8) & 255);
  buf[5] = (uint8_t)((disp >> 16) & 255);
  buf[6] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);

}


/** movl -offset(%rbp), 32-bit reg（disp8 modrm 在 buf[2]）。 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_movl_from_rbp_neg32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                           uint8_t disp8_modrm, uint8_t disp32_modrm) {
  int32_t disp;
  uint8_t buf[6];
  disp = 0 - offset;
  if (disp >= -128 && disp <= -1) {
    buf[0] = 0x8B;
    buf[1] = disp8_modrm;
    buf[2] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 3);
  }
  buf[0] = 0x8B;
  buf[1] = disp32_modrm;
  buf[2] = (uint8_t)(disp & 255);
  buf[3] = (uint8_t)((disp >> 8) & 255);
  buf[4] = (uint8_t)((disp >> 16) & 255);
  buf[5] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 6);

}


/** movq %rax, -offset(%rbp)。 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_store_rax_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t disp;
  uint8_t buf[7];
  disp = 0 - offset;
  if (disp >= -128 && disp <= -1) {
    buf[0] = 72;
    buf[1] = 0x89;
    buf[2] = 0x45;
    buf[3] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  buf[0] = 72;
  buf[1] = 0x89;
  buf[2] = 0x85;
  buf[3] = (uint8_t)(disp & 255);
  buf[4] = (uint8_t)((disp >> 8) & 255);
  buf[5] = (uint8_t)((disp >> 16) & 255);
  buf[6] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);

}

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* movq %r64, -offset(%rbp). F7 dyn coerce vtable store. PLATFORM: LINUX x86_64. */
int32_t x86_enc_store_r64_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg,
                                     int32_t offset) {
  int32_t disp;
  uint8_t buf[8];
  int32_t lo;
  if (!elf_ctx || reg < 0 || reg > 15)
    return -1;
  disp = 0 - offset;
  lo = reg & 7;
  buf[0] = (reg >= 8) ? 76 : 72;
  buf[1] = 0x89;
  if (disp >= -128 && disp <= -1) {
    buf[2] = (uint8_t)(0x45 + lo * 8);
    buf[3] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  buf[2] = (uint8_t)(0x85 + lo * 8);
  buf[3] = (uint8_t)(disp & 255);
  buf[4] = (uint8_t)((disp >> 8) & 255);
  buf[5] = (uint8_t)((disp >> 16) & 255);
  buf[6] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);
}
#endif

/** add/sub/imul imm32 到 32-bit reg 的通用模板。 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_alu_imm32_to_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, uint8_t op_prefix,
                                        uint8_t reg_modrm) {
  uint8_t buf[6];
  if (imm == 0)
    return 0;
  if (imm >= -128 && imm <= 127) {
    buf[0] = 0x83;
    buf[1] = reg_modrm;
    buf[2] = (uint8_t)imm;
    return x86_enc_bytes(elf_ctx, buf, 3);
  }
  buf[0] = op_prefix;
  buf[1] = reg_modrm;
  buf[2] = (uint8_t)(imm & 255);
  buf[3] = (uint8_t)((imm >> 8) & 255);
  buf[4] = (uint8_t)((imm >> 16) & 255);
  buf[5] = (uint8_t)((imm >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 6);

}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_prologue */
/*
 * 【Why 根源】push/pop %rbx：body 用 rbx 作 array/const 基址却未保存，破坏 SysV 被调方保存；
 *   args_iter_count_c 覆写 next 保存在 rbx 的 it → run-env env_iter Ubuntu exit 1。
 * SysV 16B CALL align (same as backend_x86_64_enc_c.x): after push rbp+push rbx,
 *   RSP≡8; sub imm must be ≡8 mod 16 so body CALL sites have RSP≡0. Else glibc
 *   mktime/tzset/sscanf SEGV (run-time format_timezone). Locals rbp-relative.
 * PLATFORM: SHARED x86_64 SysV. Seed 与 arch/x86_64_enc.x 同语义。
 */
int32_t arch_x86_64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_size) {
  uint8_t mov[3] = {72, 137, 229};
  uint8_t sub[7] = {72, 129, 236, 0, 0, 0, 0};
  int32_t fs_i = frame_size;
  int32_t rem;
  if (!elf_ctx) return -1;
  if (x86_enc_u8(elf_ctx, 85) != 0) return -1; /* push rbp */
  if (X86_ENC_FIXED(elf_ctx, mov) != 0) return -1; /* mov rbp, rsp */
  if (x86_enc_u8(elf_ctx, 83) != 0) return -1; /* push rbx (callee-saved) */
  if (fs_i < 0) fs_i = 0;
  rem = fs_i % 16;
  if (rem != 8) {
    if (rem < 8) fs_i = fs_i + (8 - rem);
    else fs_i = fs_i + (16 - rem + 8);
  }
  sub[3] = (uint8_t)(fs_i & 255);
  sub[4] = (uint8_t)((fs_i >> 8) & 255);
  sub[5] = (uint8_t)((fs_i >> 16) & 255);
  sub[6] = (uint8_t)((fs_i >> 24) & 255);
  return X86_ENC_FIXED(elf_ctx, sub);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_epilogue */
int32_t arch_x86_64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t lea[4] = {72, 141, 101, 248}; /* lea rsp, [rbp-8] */
  if (!elf_ctx) return -1;
  if (X86_ENC_FIXED(elf_ctx, lea) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 91) != 0) return -1; /* pop rbx */
  if (x86_enc_u8(elf_ctx, 93) != 0) return -1; /* pop rbp */
  return x86_enc_u8(elf_ctx, 195); /* ret */
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_label when FROM_X.
 * Ordering: pad_code_to_4 BEFORE emit_code_len (G.7 dual-authority with .x).
 * Hoist of emit_code_len before pad → multi-func SEGV (overload.x). */
int32_t arch_x86_64_enc_enc_label(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func) {
  uint8_t *cb;
  /* Cap 4.2.8: mn[256] holds '_' + up to 255 content (was [128] with k<255 smash). */
  uint8_t mn[256];
  int32_t k;
  int32_t code_len;
  if (!elf_ctx || !name || name_len < 0) return -1;
  cb = x86_enc_ctx_bytes(elf_ctx);
  /* Block 1: pad only. */
  if (is_func != 0 && pipeline_elf_ctx_pad_code_to_4(cb) != 0) return -1;
  /* Block 2: capture after pad. */
  code_len = pipeline_elf_ctx_emit_code_len(cb);
  if (pipeline_elf_ctx_add_label(cb, name, name_len, code_len) != 0) return -1;
  if (is_func == 0) return 0;
  /* Cap 4.2.8: mn u8[256] holds '_' + up to 255 content (was wave580 [128]).
   * PLATFORM: MACOS|DARWIN x86_64 Mach-O export; LINUX bare name. */
  if (pipeline_elf_ctx_macho_leading_underscore(cb) != 0 && name_len > 0 && name_len <= 255 && name[0] != 95) {
    mn[0] = 95;
    k = 0;
    while (k < name_len && k < 255) { mn[k + 1] = name[k]; k = k + 1; }
    return pipeline_elf_ctx_add_sym(cb, mn, name_len + 1, pipeline_elf_ctx_emit_code_len(cb));
  }
  return pipeline_elf_ctx_add_sym(cb, name, name_len, pipeline_elf_ctx_emit_code_len(cb));
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_add_rax_rbx */
/* addl %ebx, %eax — 32-bit add (zero-extends to RAX).
 * Why: X language integer arithmetic defaults to 32-bit (i32/u32/u8/bool).
 *      A 32-bit ADD EAX,EBX zero-extends the result to RAX, giving correct
 *      wrapping semantics for u32 (0xFFFFFFFF + 1 = 0). The prior 64-bit
 *      ADD RAX,RBX (REX.W + 01 D8) did not wrap at 32 bits, breaking
 *      unsigned overflow.
 * Invariant: Must match .x authority x86_64_enc.x::enc_add_rax_rbx.
 *            i64/u64/ptr arithmetic uses enc_rax_plus_rbx_scale1 (64-bit) or
 *            ptr-arith scaled paths, NOT this function.
 * PLATFORM: LINUX|UBUNTU|WINDOWS|x86_64. */
/* w910: arch_x86_64_enc_enc_add_rax_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x01, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_and_rbx_rax.
 * REX.W andq %rbx,%rax — 32-bit andl wiped usize/ptr high 32. */
/* w910: arch_x86_64_enc_enc_and_rbx_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x21, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_or_rbx_rax.
 * REX.W orq %rbx,%rax — 32-bit orl truncated g02f_load_ptr_at (Ubuntu SIGSEGV).
 * PLATFORM: LINUX|UBUNTU|WINDOWS|x86_64. Twin of ARM64 ELF orr x0,x0,x1. */
/* w910: arch_x86_64_enc_enc_or_rbx_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x09, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_xor_rbx_rax.
 * REX.W xorq %rbx,%rax — same high-32 wipe as AND/OR. */
/* w910: arch_x86_64_enc_enc_xor_rbx_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x31, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_mov_rax_to_rbx */
/* w910: arch_x86_64_enc_enc_mov_rax_to_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x89, 0xc3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_mov_rbx_to_rax */
/* w910: arch_x86_64_enc_enc_mov_rbx_to_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x89, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_mov_rbx_to_ecx */
/* w910: arch_x86_64_enc_enc_mov_rbx_to_ecx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x89, 0xd9. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_mov_edx_to_eax */
/* w910: arch_x86_64_enc_enc_mov_edx_to_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x89, 0xd0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_not_eax */
/* w910: arch_x86_64_enc_enc_not_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf7, 0xd0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_neg_eax */
/* w910: arch_x86_64_enc_enc_neg_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf7, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_test_eax_eax */
/* w910: arch_x86_64_enc_enc_test_eax_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x85, 0xc0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_test_rbx_rbx */
/* w910: arch_x86_64_enc_enc_test_rbx_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x85, 0xdb. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** test %edx,%edx — Result `?` 检查第二槽 err（双寄存器返回 ABI）。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_test_edx_edx */
/* w910: arch_x86_64_enc_enc_test_edx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x85, 0xd2. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_cmp_rbx_rax */
/* w910: arch_x86_64_enc_enc_cmp_rbx_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x39, 0xc3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_cmp_rax_rbx */
/* w910: arch_x86_64_enc_enc_cmp_rax_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x39, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_cltd */
/* w910: arch_x86_64_enc_enc_cltd is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x99. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_idiv_rbx */
/* w910: arch_x86_64_enc_enc_idiv_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0xf7, 0xfb. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_imul_rbx_rax */
/* imull %ebx, %eax — 32-bit imul (zero-extends to RAX).
 * Why: Must match .x authority x86_64_enc.x::enc_imul_rbx_rax.
 *      i64/u64/ptr arithmetic uses scaled paths, NOT this function.
 * PLATFORM: LINUX|UBUNTU|WINDOWS|x86_64. */
/* w910: arch_x86_64_enc_enc_imul_rbx_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xaf, 0xc3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_push_rax */
/* w910: arch_x86_64_enc_enc_push_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x50. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_push_rbx */
/* w910: arch_x86_64_enc_enc_push_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x53. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_pop_rbx */
/* w910: arch_x86_64_enc_enc_pop_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x5b. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_pop_rax */
/* w910: arch_x86_64_enc_enc_pop_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x58. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_shl_cl_eax */
/* w910: arch_x86_64_enc_enc_shl_cl_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xd3, 0xe0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_shr_cl_eax */
/* w910: arch_x86_64_enc_enc_shr_cl_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xd3, 0xe8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_sar_cl_eax */
/* w910: arch_x86_64_enc_enc_sar_cl_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xd3, 0xf8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** shlq %cl, %rax — 64-bit 逻辑左移（REX.W=0x48 前缀）。i64/u64 移位须用 64-bit 指令。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_shl_cl_rax */
/* w910: arch_x86_64_enc_enc_shl_cl_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0xd3, 0xe0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** shrq %cl, %rax — 64-bit 逻辑右移（REX.W=0x48 前缀）。u64/usize 逻辑右移保留高 32 位。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_shr_cl_rax */
/* w910: arch_x86_64_enc_enc_shr_cl_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0xd3, 0xe8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** sarq %cl, %rax — 64-bit 算术右移（REX.W=0x48 前缀）。i64/isize 算术右移符号位扩展。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_sar_cl_rax */
/* w910: arch_x86_64_enc_enc_sar_cl_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0xd3, 0xf8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** xorl %edx, %edx — 32-bit 无符号除法前清零 edx（替代 cltd 符号扩展）。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_xor_edx_edx */
/* w910: arch_x86_64_enc_enc_xor_edx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x31, 0xd2. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** divl %ebx — 32-bit 无符号除法（被除数在 edx:eax，除数在 %ebx）。u32 除法必须用 divl。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_div_rbx */
/* w910: arch_x86_64_enc_enc_div_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0xf7, 0xf3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_load_32_from_rax */
/* w910: arch_x86_64_enc_enc_load_32_from_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x8b, 0x00. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_load_64_from_rax */
/* w910: arch_x86_64_enc_enc_load_64_from_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8b, 0x00. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_load_zext8_from_rax */
/* w910: arch_x86_64_enc_enc_load_zext8_from_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xb6, 0x00. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_rax_plus_rbx_scale1 */
/* w910: arch_x86_64_enc_enc_rax_plus_rbx_scale1 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8d, 0x04, 0x18. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_rax_plus_rbx_scale4 */
/* w910: arch_x86_64_enc_enc_rax_plus_rbx_scale4 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8d, 0x04, 0x98. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_rax_plus_rbx_scale8 */
/* w910: arch_x86_64_enc_enc_rax_plus_rbx_scale8 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8d, 0x04, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1 */
/* w910: arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8d, 0x1c, 0x0b. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4 */
/* w910: arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8d, 0x1c, 0x8b. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8 */
/* w910: arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8d, 0x1c, 0xcb. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_add_ecx_edx */
/* w910: arch_x86_64_enc_enc_add_ecx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x01, 0xd1. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_sub_ecx_edx */
/* w910: arch_x86_64_enc_enc_sub_ecx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x29, 0xd1. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_add_ebx_edx */
/* w910: arch_x86_64_enc_enc_add_ebx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x01, 0xd3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_sub_ebx_edx */
/* w910: arch_x86_64_enc_enc_sub_ebx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x29, 0xd3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_imul_ecx_edx.
 * Wave184 root-fix: 0F AF /r IMUL ecx,edx (ModRM 0xCA). Was 0xD1 (IMUL edx,ecx).
 * PLATFORM: SHARED x86_64 SysV — index_scratch primary *= secondary. */
/* w910: arch_x86_64_enc_enc_imul_ecx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xaf, 0xca. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_imul_ebx_edx.
 * Wave184 root-fix: 0F AF /r IMUL ebx,edx (ModRM 0xDA). Was 0xD3 (IMUL edx,ebx).
 * PLATFORM: SHARED x86_64 SysV — INDEX read path rbx *= secondary; scale uses rbx. */
/* w910: arch_x86_64_enc_enc_imul_ebx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xaf, 0xda. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_sub_rbx_rax_then_mov */
/* w910: arch_x86_64_enc_enc_sub_rbx_rax_then_mov is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x29, 0xc3, 0x48, 0x89, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_rsub_ecx_edx */
/* w910: arch_x86_64_enc_enc_rsub_ecx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x29, 0xca, 0x89, 0xd1. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_rsub_ebx_edx */
/* w910: arch_x86_64_enc_enc_rsub_ebx_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x29, 0xda, 0x89, 0xd3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave1: .x provides arch_x86_64_enc_enc_setz_movzbl_eax */
/* w910: arch_x86_64_enc_enc_setz_movzbl_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0x94, 0xc0, 0x0f, 0xb6, 0xc0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_cmp_setcc_movzbl */
int32_t arch_x86_64_enc_enc_cmp_setcc_movzbl(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc) {
  uint8_t op = 148;
  static const uint8_t m[] = {15, 182, 192};
  uint8_t s[3];
  if (!elf_ctx) return -1;
  if (cc == 1) op = 149;
  else if (cc == 2) op = 156;
  else if (cc == 3) op = 158;
  else if (cc == 4) op = 159;
  else if (cc == 5) op = 157;
  else if (cc == 6) op = 146; /* SETB */
  else if (cc == 7) op = 150; /* SETBE */
  else if (cc == 8) op = 151; /* SETA */
  else if (cc == 9) op = 147; /* SETAE */
  s[0] = 15; s[1] = op; s[2] = 192;
  if (x86_enc_bytes(elf_ctx, s, 3) != 0) return -1;
  return x86_enc_bytes(elf_ctx, m, 3);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Stage 10 S3.1 slice 2 (10.1.1): syscall (0F 05). Twin of
 * arch_x86_64_enc_enc_syscall in backend_x86_64_enc_c.x.
 * PLATFORM: LINUX|x86_64 runtime effect; SHARED emit code. */
/* w910: arch_x86_64_enc_enc_syscall is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0x05. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: movl (%rax), %eax (8B 00). Twin of backend_x86_64_enc_c.x. */
/* w910: arch_x86_64_enc_enc_movl_mem_rax_to_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x8b, 0x00. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: movl (%rcx), %eax (8B 01) — *expected while ptr lives elsewhere. */
/* w910: arch_x86_64_enc_enc_movl_mem_rcx_to_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x8b, 0x01. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: xchg %edx, (%rax) (87 10). */
/* w910: arch_x86_64_enc_enc_xchg_edx_mem_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x87, 0x10. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: mov %rax, %rcx (48 89 C1). */
/* w910: arch_x86_64_enc_enc_mov_rax_to_rcx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x89, 0xc1. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: movl %eax, (%rcx) (89 01). */
/* w910: arch_x86_64_enc_enc_movl_eax_to_mem_rcx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x89, 0x01. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: lock cmpxchg %edx, (%rax) (F0 0F B1 10) — kept for completeness. */
/* w910: arch_x86_64_enc_enc_lock_cmpxchg_edx_mem_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf0, 0x0f, 0xb1, 0x10. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: lock cmpxchg %edx, (%rbx) (F0 0F B1 13) — ptr≠rax so eax keeps expected. */
/* w910: arch_x86_64_enc_enc_lock_cmpxchg_edx_mem_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf0, 0x0f, 0xb1, 0x13. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: sete %al (0F 94 C0). */
/* w910: arch_x86_64_enc_enc_sete_al is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0x94, 0xc0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: movzbl %al, %eax (0F B6 C0). */
/* w910: arch_x86_64_enc_enc_movzbl_al_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xb6, 0xc0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice1: mov %eax, %edx (89 C2). */
/* w910: arch_x86_64_enc_enc_mov_eax_to_edx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x89, 0xc2. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice2: movq (%rax), %rax (48 8B 00). */
/* w910: arch_x86_64_enc_enc_movq_mem_rax_to_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8b, 0x00. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice2: xchg %rdx, (%rax) (48 87 10). */
/* w910: arch_x86_64_enc_enc_xchg_rdx_mem_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x87, 0x10. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice2: mov %rax, %rdx (48 89 C2). */
/* w910: arch_x86_64_enc_enc_mov_rax_to_rdx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x89, 0xc2. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice2: movq (%rcx), %rax (48 8B 01). */
/* w910: arch_x86_64_enc_enc_movq_mem_rcx_to_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x8b, 0x01. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice2: movq %rax, (%rcx) (48 89 01). */
/* w910: arch_x86_64_enc_enc_movq_rax_to_mem_rcx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x48, 0x89, 0x01. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice2: lock cmpxchg %rdx, (%rbx) (F0 48 0F B1 13). */
/* w910: arch_x86_64_enc_enc_lock_cmpxchg_rdx_mem_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf0, 0x48, 0x0f, 0xb1, 0x13. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.2: mfence (0F AE F0). */
/* w910: arch_x86_64_enc_enc_mfence is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xae, 0xf0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.2: lfence (0F AE E8). */
/* w910: arch_x86_64_enc_enc_lfence is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xae, 0xe8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.2: sfence (0F AE F8). */
/* w910: arch_x86_64_enc_enc_sfence is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xae, 0xf8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice3: movzwl (%rax), %eax (0F B7 00). */
/* w910: arch_x86_64_enc_enc_movzwl_mem_rax_to_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xb7, 0x00. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice3: xchg %dx, (%rax) (66 87 10). */
/* w910: arch_x86_64_enc_enc_xchg_dx_mem_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x66, 0x87, 0x10. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice3: mov %ax, %dx (66 89 C2). */
/* w910: arch_x86_64_enc_enc_mov_ax_to_dx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x66, 0x89, 0xc2. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice3: movzwl (%rcx), %eax (0F B7 01). */
/* w910: arch_x86_64_enc_enc_movzwl_mem_rcx_to_eax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x0f, 0xb7, 0x01. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice3: movw %ax, (%rcx) (66 89 01). */
/* w910: arch_x86_64_enc_enc_movw_ax_to_mem_rcx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x66, 0x89, 0x01. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* 10.4.1 slice3: lock cmpxchg %dx, (%rbx) (F0 66 0F B1 13). */
/* w910: arch_x86_64_enc_enc_lock_cmpxchg_dx_mem_rbx is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf0, 0x66, 0x0f, 0xb1, 0x13. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Stage 10 S3.1 slice 2 (10.1.1): mov %rax, %r10 (49 89 C2). Twin of
 * arch_x86_64_enc_enc_mov_rax_to_r10 in backend_x86_64_enc_c.x. r10 has no
 * C-ABI mov_rax_to_arg_reg k slot (G.7; do not fork a second register map).
 * PLATFORM: LINUX|x86_64 runtime effect; SHARED emit code. */
/* w910: arch_x86_64_enc_enc_mov_rax_to_r10 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x49, 0x89, 0xc2. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */

/* Stage10 10.2.1 slice7: mov %r10, %rax (4C 89 D0). Twin of
 * arch_x86_64_enc_enc_mov_r10_to_rax in backend_x86_64_enc_c.x.
 * PLATFORM: LINUX|x86_64; SHARED emit. */
/* w910: arch_x86_64_enc_enc_mov_r10_to_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x4c, 0x89, 0xd0. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */

/* Stage10 10.2.3: mov %rax, %r11 (49 89 C3). Twin of
 * arch_x86_64_enc_enc_mov_rax_to_r11 in backend_x86_64_enc_c.x.
 * PLATFORM: SHARED. */
/* w910: arch_x86_64_enc_enc_mov_rax_to_r11 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x49, 0x89, 0xc3. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */

/* Stage10 10.2.3: mov %r11, %rax (4C 89 D8). Twin of
 * arch_x86_64_enc_enc_mov_r11_to_rax in backend_x86_64_enc_c.x.
 * PLATFORM: SHARED. */
/* w910: arch_x86_64_enc_enc_mov_r11_to_rax is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0x4c, 0x89, 0xd8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */

/* Stage10 10.2.3: pause (F3 90). Twin of
 * arch_x86_64_enc_enc_pause in backend_x86_64_enc_c.x.
 * PLATFORM: SHARED. */
/* w910: arch_x86_64_enc_enc_pause is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xf3, 0x90. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */

/* Stage10 10.2.3: int3 (CC). Twin of
 * arch_x86_64_enc_enc_int3 in backend_x86_64_enc_c.x.
 * PLATFORM: SHARED. */
/* w910: arch_x86_64_enc_enc_int3 is defined in backend_enc_dispatch_thin.x.
 * Fixed bytes 0xcc. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_mov_imm32_to_rbx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_ret_imm32 is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_mov_imm64_to_rax is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_cmp_eax_imm32 is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_add_imm_to_rax is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_add_imm_to_rbx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_store_rax_to_rbp is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
/* w912: arch_x86_64_enc_enc_store_r64_to_rbp is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_rax is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_rbx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_lea_rbp_to_rax is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_lea_rbp_to_rbx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_pos_to_rax is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_eax32 is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_ebx32 is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_ecx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_edx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_add_imm_to_ecx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_sub_imm_from_ecx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_add_imm_to_ebx_index is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_sub_imm_from_ebx_index is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_imul_imm_to_ecx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_imul_imm_to_ebx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_mov_arg_reg_to_rax.
 * Mirror enc_mov_rax_to_arg_reg: SysV rdi..r9 vs Win64 rcx,rdx,r8,r9.
 * Prior always-SysV made Option is_some read %rdi while callers passed %rcx
 * → tests/option run=-2. PLATFORM: WINDOWS leftover-PE. */
int32_t arch_x86_64_enc_enc_mov_arg_reg_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  static const uint8_t sysv0[] = {72,137,248}; /* rdi */
  static const uint8_t sysv1[] = {72,137,240}; /* rsi */
  static const uint8_t sysv2[] = {72,137,208}; /* rdx */
  static const uint8_t sysv3[] = {72,137,200}; /* rcx */
  static const uint8_t sysv4[] = {76,137,192}; /* r8 */
  static const uint8_t sysv5[] = {76,137,200}; /* r9 */
  static const uint8_t win0[] = {72,137,200}; /* rcx */
  static const uint8_t win1[] = {72,137,208}; /* rdx */
  static const uint8_t win2[] = {76,137,192}; /* r8 */
  static const uint8_t win3[] = {76,137,200}; /* r9 */
  int32_t idx;
  int32_t is_win;
  if (!elf_ctx) return -1;
  idx = k; if (idx < 0) idx = 0; if (idx > 5) idx = 5;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
  is_win = 1;
#else
  is_win = 0;
#endif
  if (is_win != 0) {
    if (idx == 0) return x86_enc_bytes(elf_ctx, win0, 3);
    if (idx == 1) return x86_enc_bytes(elf_ctx, win1, 3);
    if (idx == 2) return x86_enc_bytes(elf_ctx, win2, 3);
    if (idx == 3) return x86_enc_bytes(elf_ctx, win3, 3);
    /* Win64 has four GP argument registers. Argument 5 is 0x30(%rbp)
     * and argument 6 is 0x38(%rbp) after push %rbp; mov %rbp, %rsp.
     * Homing runs after that prologue. Copying r8/r9 here reused arg2
     * as the 5th formal, so backend_enc_label_arch treated name_len as
     * ta and a later define did not update the forward label.
     * stdlib-import then reported CG002 with .Lf0_2 offset -1.
     * PLATFORM: WINDOWS. */
    if (idx == 4) {
      static const uint8_t win4[] = {0x48, 0x8B, 0x45, 0x30};
      return x86_enc_bytes(elf_ctx, win4, 4);
    }
    {
      static const uint8_t win5[] = {0x48, 0x8B, 0x45, 0x38};
      return x86_enc_bytes(elf_ctx, win5, 4);
    }
  }
  if (idx == 0) return x86_enc_bytes(elf_ctx, sysv0, 3);
  if (idx == 1) return x86_enc_bytes(elf_ctx, sysv1, 3);
  if (idx == 2) return x86_enc_bytes(elf_ctx, sysv2, 3);
  if (idx == 3) return x86_enc_bytes(elf_ctx, sysv3, 3);
  if (idx == 4) return x86_enc_bytes(elf_ctx, sysv4, 3);
  return x86_enc_bytes(elf_ctx, sysv5, 3);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_mov_rax_to_arg_reg */
int32_t arch_x86_64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  /* SysV: rdi,rsi,rdx,rcx,r8,r9. Win64: rcx,rdx,r8,r9. */
  static const uint8_t sysv0[] = {72,137,199};
  static const uint8_t sysv1[] = {72,137,198};
  static const uint8_t sysv2[] = {72,137,194};
  static const uint8_t sysv3[] = {72,137,193};
  static const uint8_t sysv4[] = {73,137,192};
  static const uint8_t sysv5[] = {73,137,193};
  static const uint8_t win0[] = {72,137,193}; /* rcx */
  static const uint8_t win1[] = {72,137,194}; /* rdx */
  static const uint8_t win2[] = {73,137,192}; /* r8 */
  static const uint8_t win3[] = {73,137,193}; /* r9 */
  int32_t idx;
  int32_t is_win;
  if (!elf_ctx) return -1;
  idx = k; if (idx < 0) idx = 0; if (idx > 5) idx = 5;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
  is_win = 1;
#else
  is_win = 0;
#endif
  if (is_win != 0) {
    if (idx == 0) return x86_enc_bytes(elf_ctx, win0, 3);
    if (idx == 1) return x86_enc_bytes(elf_ctx, win1, 3);
    if (idx == 2) return x86_enc_bytes(elf_ctx, win2, 3);
    if (idx == 3) return x86_enc_bytes(elf_ctx, win3, 3);
    /* Outgoing Win64 argument 5 is [rsp+0x20] (32-byte shadow plus the
     * slot) and argument 6 is [rsp+0x28]. The call sequence emits this
     * after the frame subtract, so rsp is the outgoing area. Writing
     * r8/r9 here clobbered argument 3. PLATFORM: WINDOWS. */
    if (idx == 4) {
      static const uint8_t win4[] = {0x48, 0x89, 0x44, 0x24, 0x20};
      return x86_enc_bytes(elf_ctx, win4, 5);
    }
    {
      static const uint8_t win5[] = {0x48, 0x89, 0x44, 0x24, 0x28};
      return x86_enc_bytes(elf_ctx, win5, 5);
    }
  }
  if (idx == 0) return x86_enc_bytes(elf_ctx, sysv0, 3);
  if (idx == 1) return x86_enc_bytes(elf_ctx, sysv1, 3);
  if (idx == 2) return x86_enc_bytes(elf_ctx, sysv2, 3);
  if (idx == 3) return x86_enc_bytes(elf_ctx, sysv3, 3);
  if (idx == 4) return x86_enc_bytes(elf_ctx, sysv4, 3);
  return x86_enc_bytes(elf_ctx, sysv5, 3);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_jz */
int32_t arch_x86_64_enc_enc_jz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 132, label, label_len);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_jeq */
int32_t arch_x86_64_enc_enc_jeq(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 132, label, label_len);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_jge */
int32_t arch_x86_64_enc_enc_jge(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 141, label, label_len);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_jnz */
int32_t arch_x86_64_enc_enc_jnz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 133, label, label_len);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_jmp */
int32_t arch_x86_64_enc_enc_jmp(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  int32_t rel32_at;
  uint8_t *cb;
  if (!elf_ctx || !label || label_len <= 0) return -1;
  cb = x86_enc_ctx_bytes(elf_ctx);
  if (x86_enc_u8(elf_ctx, 233) != 0) return -1;
  if (x86_enc_u32_le(elf_ctx, 0) != 0) return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_ensure_label(cb, label, label_len) != 0) return -1;
  return pipeline_elf_ctx_append_patch(cb, rel32_at, label, label_len, 0);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* Cap residual pure R2 wave2: .x provides arch_x86_64_enc_enc_call */
int32_t arch_x86_64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len) {
  int32_t rel32_at;
  uint8_t *cb;
  uint8_t rn[128];
  int32_t k;
  if (!elf_ctx || !name || name_len <= 0) return -1;
  cb = x86_enc_ctx_bytes(elf_ctx);
  if (x86_enc_u8(elf_ctx, 232) != 0) return -1;
  if (x86_enc_u32_le(elf_ctx, 0) != 0) return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  /* wave580 Cap: rn u8[128] holds '_' + up to 255 content (was 63).
   * PLATFORM: MACOS|DARWIN x86_64 call reloc.
   * Stage 12.0.5 ABI: always prepend '_' even when C name starts with '_'
   * (__error → ___error). Do not skip on name[0]=='_'. */
  if (pipeline_elf_ctx_macho_leading_underscore(cb) != 0 && name_len > 0 && name_len <= 255) {
    rn[0] = 95; k = 0;
    while (k < name_len && k < 255) { rn[k + 1] = name[k]; k = k + 1; }
    return pipeline_elf_ctx_append_reloc(cb, rel32_at, rn, name_len + 1);
  }
  return pipeline_elf_ctx_append_reloc(cb, rel32_at, name, name_len);
}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_add_rsp_imm is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_store_rax_to_rbx_indirect is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_store_rax_to_rbx_offset is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

/** subl %ebx, %eax — 32-bit sub (zero-extends to RAX). */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_sub_rax_rbx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** movq (%rbx), %rax — SysV 16B struct 返回低 8 字节。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_load_qword_from_rbx_to_rax is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** movq 8(%rbx), %rdx — SysV 16B struct 返回高 8 字节。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_load_qword_rbx8_to_rdx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/** movq %rdx, -offset(%rbp)。 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t x86_enc_store_rdx_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t disp;
  uint8_t buf[7];
  disp = 0 - offset;
  if (disp >= -128 && disp <= -1) {
    buf[0] = 72;
    buf[1] = 0x89;
    buf[2] = 0x55;
    buf[3] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  buf[0] = 72;
  buf[1] = 0x89;
  buf[2] = 0x95;
  buf[3] = (uint8_t)(disp & 255);
  buf[4] = (uint8_t)((disp >> 8) & 255);
  buf[5] = (uint8_t)((disp >> 16) & 255);
  buf[6] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);

}
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


/** movq %rdx, -offset(%rbp)（16B struct 第二寄存器落栈）。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_store_rdx_to_rbp is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

/** movq -offset(%rbp), %rdx（16B struct 栈槽高 8 字节）。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w912: arch_x86_64_enc_enc_load_rbp_to_rdx is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

/** movq %rdx, arg_reg[k]（SysV 16B struct 第二 GPR 实参）。 */
#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w911: arch_x86_64_enc_enc_mov_rdx_to_arg_reg is defined in backend_enc_dispatch_thin.x.
 * Bytes go through backend_enc_append_u8_c. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

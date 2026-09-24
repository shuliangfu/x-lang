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
 * w916: arch_x86_64_enc_enc_prologue and arch_x86_64_enc_enc_epilogue
 * live in backend_enc_dispatch_thin.x. This file no longer emits them.
 * w917: arch_x86_64_enc_enc_jz, arch_x86_64_enc_enc_jeq,
 * arch_x86_64_enc_enc_jge, and arch_x86_64_enc_enc_jnz live in
 * backend_enc_dispatch_thin.x. This file no longer emits them.
 * They forward to x86_enc_jcc_rel32. w923 moves that helper and
 * arch_x86_64_enc_enc_jmp into backend_enc_dispatch_thin.x.
 * w920: x86 cmp_setcc lives in backend_enc_dispatch_thin.x.
 * The opcode is a straight-line let. This file no longer emits that
 * symbol. call, label, and the Win64 argument moves stay here.
 * w921: seven unused rbp and alu helpers are no longer emitted.
 * The public rbp and immediate encoders in the thin already append
 * those bytes. call, label, and the Win64 argument moves stay here.
 * w923: x86_enc_jcc_rel32 and arch_x86_64_enc_enc_jmp live in
 * backend_enc_dispatch_thin.x. Each appends its bytes, then reads
 * the code length in a later block. This file no longer emits them.
 * w927: arch_x86_64_enc_enc_label lives in backend_enc_dispatch_thin.x.
 * Pad runs in its own block. The code length is read in a later block.
 * A function export copies with memcpy. This file no longer emits
 * that symbol. call and the Win64 argument moves stay here.
 * w928: arch_x86_64_enc_enc_call lives in backend_enc_dispatch_thin.x.
 * Byte 232 then four zero bytes. The reloc slot is the code length
 * minus 4, read after those bytes. A Mach-O name is one underscore
 * plus the original bytes, copied with memcpy. The underscore is
 * prepended even when the name already starts with underscore.
 * This file no longer emits that symbol. The Win64 argument moves
 * stay here.
 * PLATFORM: SHARED.
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
/* w923: x86_enc_jcc_rel32 is defined in backend_enc_dispatch_thin.x.
 * Six bytes are 15, opcode2, then four zeros. The patch slot is the
 * code length minus 4, read after those bytes. imm bits are 0.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */


/* w921: x86_enc_movq_from_rbp_neg, x86_enc_lea_from_rbp_neg,
 * x86_enc_movl_from_rbp_neg32, x86_enc_store_rax_to_rbp_neg,
 * x86_enc_store_r64_to_rbp_neg, and x86_enc_alu_imm32_to_reg are
 * not emitted. The public rbp and immediate encoders in
 * backend_enc_dispatch_thin.x already append those bytes. No product
 * object calls these helpers. PLATFORM: SHARED. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w916: arch_x86_64_enc_enc_prologue is defined in backend_enc_dispatch_thin.x.
 * push rbp, mov rbp rsp, push rbx, sub rsp imm32 aligned to 8 mod 16.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w916: arch_x86_64_enc_enc_epilogue is defined in backend_enc_dispatch_thin.x.
 * lea rsp [rbp-8], pop rbx, pop rbp, ret. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */


#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w927: arch_x86_64_enc_enc_label is defined in backend_enc_dispatch_thin.x.
 * Pad runs in its own block. The code length is read in a later block.
 * add_label uses that length. A function export may prepend one
 * underscore byte via memcpy, then calls add_sym.
 * A local label returns after add_label.
 * This file no longer emits this symbol.
 * The body does not compare elf_ctx with 0 and does not divide.
 * PLATFORM: SHARED. */
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
 * w952: bytes are cqo 0x48, 0x99. idiv %rbx is REX.W, so cltd (0x99) leaves
 * the high half of rdx clear and a negative dividend traps. Stays strong.
 * PLATFORM: SHARED. The body does not compare elf_ctx with 0 and does not divide. */
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
/* w920: arch_x86_64_enc_enc_cmp_setcc_movzbl is defined in backend_enc_dispatch_thin.x.
 * cc 0..9 select opcodes 148, 149, 156, 158, 159, 157, 146, 150, 151, and 147.
 * Every other cc selects 148. The six bytes are 15, opcode, 192, 15, 182, 192.
 * They go through x86_enc_u8. Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
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
/* w917: arch_x86_64_enc_enc_jz is defined in backend_enc_dispatch_thin.x.
 * It forwards to x86_enc_jcc_rel32 with opcode 132. w923 moves that patch into the thin.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w917: arch_x86_64_enc_enc_jeq is defined in backend_enc_dispatch_thin.x.
 * It forwards to x86_enc_jcc_rel32 with opcode 132. w923 moves that patch into the thin.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w917: arch_x86_64_enc_enc_jge is defined in backend_enc_dispatch_thin.x.
 * It forwards to x86_enc_jcc_rel32 with opcode 141. w923 moves that patch into the thin.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w917: arch_x86_64_enc_enc_jnz is defined in backend_enc_dispatch_thin.x.
 * It forwards to x86_enc_jcc_rel32 with opcode 133. w923 moves that patch into the thin.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w923: arch_x86_64_enc_enc_jmp is defined in backend_enc_dispatch_thin.x.
 * Byte 233 then four zero bytes. The patch slot is the code length
 * minus 4, read after those bytes. imm bits are 0.
 * Stays strong. PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
#endif /* !XLANG_BACKEND_X86_64_ENC_C_FROM_X */

#ifndef XLANG_BACKEND_X86_64_ENC_C_FROM_X
/* w928: arch_x86_64_enc_enc_call is defined in backend_enc_dispatch_thin.x.
 * Byte 232 then four zero bytes. The reloc slot is the code length
 * minus 4, read after those bytes.
 * A Mach-O name is one underscore plus the original bytes, copied
 * with memcpy. The underscore is prepended even when the name
 * already starts with underscore.
 * This file no longer emits that symbol.
 * The Win64 argument moves stay here.
 * PLATFORM: SHARED.
 * The body does not compare elf_ctx with 0 and does not divide. */
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
/* w921: x86_enc_store_rdx_to_rbp_neg is not emitted.
 * arch_x86_64_enc_enc_store_rdx_to_rbp in the thin already appends
 * those bytes. No product object calls this helper. PLATFORM: SHARED. */
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

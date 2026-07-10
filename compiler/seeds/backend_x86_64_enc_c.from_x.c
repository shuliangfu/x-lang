/* seeds/backend_x86_64_enc_c.from_x.c — G-02f-15 product TU
 * Product object from this seed; logic still C until full .x port.
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

/** 取 ElfCodegenCtx 字节视图。 */
static uint8_t *x86_enc_ctx_bytes(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return (uint8_t *)elf_ctx;
}

/** 追加 1 字节机器码。 */
static int32_t x86_enc_u8(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t b) {
  return pipeline_elf_ctx_append_bytes(x86_enc_ctx_bytes(elf_ctx), &b, 1);
}

/** 追加 imm32 小端。 */
static int32_t x86_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  uint8_t buf[4];
  buf[0] = (uint8_t)(imm & 255);
  buf[1] = (uint8_t)((imm >> 8) & 255);
  buf[2] = (uint8_t)((imm >> 16) & 255);
  buf[3] = (uint8_t)((imm >> 24) & 255);
  return pipeline_elf_ctx_append_bytes(x86_enc_ctx_bytes(elf_ctx), buf, 4);
}

/** 追加固定字节序列。 */
static int32_t x86_enc_bytes(struct platform_elf_ElfCodegenCtx *elf_ctx, const uint8_t *buf, int32_t n) {
  return pipeline_elf_ctx_append_bytes(x86_enc_ctx_bytes(elf_ctx), (uint8_t *)buf, n);
}

#define X86_ENC_FIXED(ctx, arr) x86_enc_bytes((ctx), (const uint8_t *)(arr), (int32_t)sizeof(arr))

/** x86 rel32 条件跳转 + patch（与 x86_64_enc.x enc_jz/enc_jge 一致）。 */
static int32_t x86_enc_jcc_rel32(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t opcode2, uint8_t *label,
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
static int32_t x86_enc_movq_from_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
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
static int32_t x86_enc_lea_from_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
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
static int32_t x86_enc_movl_from_rbp_neg32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
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
static int32_t x86_enc_store_rax_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
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

/** add/sub/imul imm32 到 32-bit reg 的通用模板。 */
static int32_t x86_enc_alu_imm32_to_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, uint8_t op_prefix,
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

int32_t arch_x86_64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_size) {
  uint8_t mov[3] = {72, 137, 229};
  uint8_t sub[7] = {72, 129, 236, 0, 0, 0, 0};
  if (!elf_ctx) return -1;
  if (x86_enc_u8(elf_ctx, 85) != 0) return -1;
  if (X86_ENC_FIXED(elf_ctx, mov) != 0) return -1;
  sub[3] = (uint8_t)(frame_size & 255);
  sub[4] = (uint8_t)((frame_size >> 8) & 255);
  sub[5] = (uint8_t)((frame_size >> 16) & 255);
  sub[6] = (uint8_t)((frame_size >> 24) & 255);
  return X86_ENC_FIXED(elf_ctx, sub);
}

int32_t arch_x86_64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t mov[3] = {72, 137, 236};
  if (!elf_ctx) return -1;
  if (X86_ENC_FIXED(elf_ctx, mov) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 93) != 0) return -1;
  return x86_enc_u8(elf_ctx, 195);
}

int32_t arch_x86_64_enc_enc_label(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func) {
  uint8_t *cb;
  uint8_t mn[64];
  int32_t k;
  if (!elf_ctx || !name || name_len < 0) return -1;
  cb = x86_enc_ctx_bytes(elf_ctx);
  if (is_func != 0 && pipeline_elf_ctx_pad_code_to_4(cb) != 0) return -1;
  if (pipeline_elf_ctx_add_label(cb, name, name_len, pipeline_elf_ctx_emit_code_len(cb)) != 0) return -1;
  if (is_func == 0) return 0;
  if (pipeline_elf_ctx_macho_leading_underscore(cb) != 0 && name_len > 0 && name_len <= 63 && name[0] != 95) {
    mn[0] = 95;
    k = 0;
    while (k < name_len && k < 63) { mn[k + 1] = name[k]; k = k + 1; }
    return pipeline_elf_ctx_add_sym(cb, mn, name_len + 1, pipeline_elf_ctx_emit_code_len(cb));
  }
  return pipeline_elf_ctx_add_sym(cb, name, name_len, pipeline_elf_ctx_emit_code_len(cb));
}

int32_t arch_x86_64_enc_enc_add_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 1, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_and_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {33, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_or_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {9, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_xor_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {49, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_mov_rax_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 137, 195};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_mov_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 137, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_mov_rbx_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {137, 217};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_mov_edx_to_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {137, 208};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_not_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {247, 208};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_neg_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {247, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_test_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {133, 192};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_test_rbx_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {133, 219};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** test %edx,%edx — Result `?` 检查第二槽 err（双寄存器返回 ABI）。 */
int32_t arch_x86_64_enc_enc_test_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {0x85, 0xD2};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_cmp_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {57, 195};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_cmp_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {57, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_cltd(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {153};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_idiv_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {247, 251};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_imul_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 15, 175, 195};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_push_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {80};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_push_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {83};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_pop_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {91};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_pop_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {88};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_shl_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {211, 224};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_shr_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {211, 232};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_sar_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {211, 248};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** shlq %cl, %rax — 64-bit 逻辑左移（REX.W=0x48 前缀）。i64/u64 移位须用 64-bit 指令。 */
int32_t arch_x86_64_enc_enc_shl_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 211, 224};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** shrq %cl, %rax — 64-bit 逻辑右移（REX.W=0x48 前缀）。u64/usize 逻辑右移保留高 32 位。 */
int32_t arch_x86_64_enc_enc_shr_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 211, 232};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** sarq %cl, %rax — 64-bit 算术右移（REX.W=0x48 前缀）。i64/isize 算术右移符号位扩展。 */
int32_t arch_x86_64_enc_enc_sar_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 211, 248};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** xorl %edx, %edx — 32-bit 无符号除法前清零 edx（替代 cltd 符号扩展）。 */
int32_t arch_x86_64_enc_enc_xor_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {49, 210};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** divl %ebx — 32-bit 无符号除法（被除数在 edx:eax，除数在 %ebx）。u32 除法必须用 divl。 */
int32_t arch_x86_64_enc_enc_div_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {247, 243};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_load_32_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {139, 0};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_load_64_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 139, 0};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_load_zext8_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {15, 182, 0};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 141, 4, 24};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 141, 4, 152};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 141, 4, 216};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 141, 28, 11};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 141, 28, 139};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 141, 28, 203};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_add_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {1, 209};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_sub_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {41, 209};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_add_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {1, 211};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_sub_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {41, 211};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_imul_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {15, 175, 209};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_imul_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {15, 175, 211};
  if (!elf_ctx) return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

int32_t arch_x86_64_enc_enc_sub_rbx_rax_then_mov(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t sub[] = {72, 41, 195};
  static const uint8_t mov[] = {72, 137, 216};
  if (!elf_ctx) return -1;
  if (x86_enc_bytes(elf_ctx, sub, 3) != 0) return -1;
  return x86_enc_bytes(elf_ctx, mov, 3);
}

int32_t arch_x86_64_enc_enc_rsub_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t sub[] = {41, 202};
  static const uint8_t mov[] = {137, 209};
  if (!elf_ctx) return -1;
  if (x86_enc_bytes(elf_ctx, sub, 2) != 0) return -1;
  return x86_enc_bytes(elf_ctx, mov, 2);
}

int32_t arch_x86_64_enc_enc_rsub_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t sub[] = {41, 218};
  static const uint8_t mov[] = {137, 211};
  if (!elf_ctx) return -1;
  if (x86_enc_bytes(elf_ctx, sub, 2) != 0) return -1;
  return x86_enc_bytes(elf_ctx, mov, 2);
}

int32_t arch_x86_64_enc_enc_setz_movzbl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t s[] = {15, 148, 192};
  static const uint8_t m[] = {15, 182, 192};
  if (!elf_ctx) return -1;
  if (x86_enc_bytes(elf_ctx, s, 3) != 0) return -1;
  return x86_enc_bytes(elf_ctx, m, 3);
}

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
  s[0] = 15; s[1] = op; s[2] = 192;
  if (x86_enc_bytes(elf_ctx, s, 3) != 0) return -1;
  return x86_enc_bytes(elf_ctx, m, 3);
}

int32_t arch_x86_64_enc_enc_mov_imm32_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  if (!elf_ctx) return -1;
  if (x86_enc_u8(elf_ctx, 187) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, imm32);
}

int32_t arch_x86_64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  if (!elf_ctx) return -1;
  if (x86_enc_u8(elf_ctx, 184) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, imm32);
}

int32_t arch_x86_64_enc_enc_mov_imm64_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi) {
  if (!elf_ctx) return -1;
  if (x86_enc_u8(elf_ctx, 72) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 184) != 0) return -1;
  if (x86_enc_u32_le(elf_ctx, lo) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, hi);
}

int32_t arch_x86_64_enc_enc_cmp_eax_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  if (!elf_ctx) return -1;
  if (x86_enc_u8(elf_ctx, 61) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, imm32);
}

int32_t arch_x86_64_enc_enc_add_imm_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  if (!elf_ctx) return -1;
  if (imm == 0) return 0;
  if (x86_enc_u8(elf_ctx, 72) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 5) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, imm);
}

int32_t arch_x86_64_enc_enc_add_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  if (!elf_ctx) return -1;
  if (imm == 0) return 0;
  if (x86_enc_u8(elf_ctx, 72) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 129) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 195) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, imm);
}

int32_t arch_x86_64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_store_rax_to_rbp_neg(elf_ctx, offset);
}

int32_t arch_x86_64_enc_enc_load_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_movq_from_rbp_neg(elf_ctx, offset, 69, 133);
}

int32_t arch_x86_64_enc_enc_load_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_movq_from_rbp_neg(elf_ctx, offset, 93, 157);
}

int32_t arch_x86_64_enc_enc_lea_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_lea_from_rbp_neg(elf_ctx, offset, 69, 133);
}

int32_t arch_x86_64_enc_enc_lea_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_lea_from_rbp_neg(elf_ctx, offset, 93, 157);
}

int32_t arch_x86_64_enc_enc_load_rbp_pos_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos) {
  int32_t disp;
  uint8_t buf[7];
  if (!elf_ctx) return -1;
  disp = off_pos;
  if (disp < 0) disp = 0;
  if (disp <= 127) {
    buf[0] = 72; buf[1] = 0x8B; buf[2] = 0x45; buf[3] = (uint8_t)disp;
    return x86_enc_bytes(elf_ctx, buf, 4);
  }
  buf[0] = 72; buf[1] = 0x8B; buf[2] = 0x85;
  buf[3] = (uint8_t)(disp & 255); buf[4] = (uint8_t)((disp >> 8) & 255);
  buf[5] = (uint8_t)((disp >> 16) & 255); buf[6] = (uint8_t)((disp >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);
}

int32_t arch_x86_64_enc_enc_load_rbp_to_eax32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 69, 133);
}

int32_t arch_x86_64_enc_enc_load_rbp_to_ebx32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 93, 157);
}

int32_t arch_x86_64_enc_enc_load_rbp_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 77, 141);
}

int32_t arch_x86_64_enc_enc_load_rbp_to_edx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx) return -1;
  return x86_enc_movl_from_rbp_neg32(elf_ctx, offset, 85, 149);
}

int32_t arch_x86_64_enc_enc_add_imm_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  if (!elf_ctx) return -1;
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 193);
}

int32_t arch_x86_64_enc_enc_sub_imm_from_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  if (!elf_ctx) return -1;
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 233);
}

int32_t arch_x86_64_enc_enc_add_imm_to_ebx_index(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  if (!elf_ctx) return -1;
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 195);
}

int32_t arch_x86_64_enc_enc_sub_imm_from_ebx_index(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  if (!elf_ctx) return -1;
  return x86_enc_alu_imm32_to_reg(elf_ctx, imm, 129, 235);
}

int32_t arch_x86_64_enc_enc_imul_imm_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  uint8_t buf[6];
  if (!elf_ctx) return -1;
  if (imm <= 1) return 0;
  if (imm >= -128 && imm <= 127) {
    buf[0] = 0x6B; buf[1] = 201; buf[2] = (uint8_t)imm;
    return x86_enc_bytes(elf_ctx, buf, 3);
  }
  buf[0] = 0x69; buf[1] = 201;
  buf[2] = (uint8_t)(imm & 255); buf[3] = (uint8_t)((imm >> 8) & 255);
  buf[4] = (uint8_t)((imm >> 16) & 255); buf[5] = (uint8_t)((imm >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 6);
}

int32_t arch_x86_64_enc_enc_imul_imm_to_ebx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  uint8_t buf[6];
  if (!elf_ctx) return -1;
  if (imm <= 1) return 0;
  if (imm >= -128 && imm <= 127) {
    buf[0] = 0x6B; buf[1] = 219; buf[2] = (uint8_t)imm;
    return x86_enc_bytes(elf_ctx, buf, 3);
  }
  buf[0] = 0x69; buf[1] = 219;
  buf[2] = (uint8_t)(imm & 255); buf[3] = (uint8_t)((imm >> 8) & 255);
  buf[4] = (uint8_t)((imm >> 16) & 255); buf[5] = (uint8_t)((imm >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 6);
}

int32_t arch_x86_64_enc_enc_mov_arg_reg_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  static const uint8_t b0[] = {72,137,248};
  static const uint8_t b1[] = {72,137,240};
  static const uint8_t b2[] = {72,137,208};
  static const uint8_t b3[] = {72,137,200};
  static const uint8_t b4[] = {76,137,192};
  static const uint8_t b5[] = {76,137,200};
  int32_t idx;
  if (!elf_ctx) return -1;
  idx = k; if (idx < 0) idx = 0; if (idx > 5) idx = 5;
  if (idx == 0) return x86_enc_bytes(elf_ctx, b0, 3);
  if (idx == 1) return x86_enc_bytes(elf_ctx, b1, 3);
  if (idx == 2) return x86_enc_bytes(elf_ctx, b2, 3);
  if (idx == 3) return x86_enc_bytes(elf_ctx, b3, 3);
  if (idx == 4) return x86_enc_bytes(elf_ctx, b4, 3);
  return x86_enc_bytes(elf_ctx, b5, 3);
}

int32_t arch_x86_64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  static const uint8_t b0[] = {72,137,199};
  static const uint8_t b1[] = {72,137,198};
  static const uint8_t b2[] = {72,137,194};
  static const uint8_t b3[] = {72,137,193};
  static const uint8_t b4[] = {73,137,192};
  static const uint8_t b5[] = {73,137,193};
  int32_t idx;
  if (!elf_ctx) return -1;
  idx = k; if (idx < 0) idx = 0; if (idx > 5) idx = 5;
  if (idx == 0) return x86_enc_bytes(elf_ctx, b0, 3);
  if (idx == 1) return x86_enc_bytes(elf_ctx, b1, 3);
  if (idx == 2) return x86_enc_bytes(elf_ctx, b2, 3);
  if (idx == 3) return x86_enc_bytes(elf_ctx, b3, 3);
  if (idx == 4) return x86_enc_bytes(elf_ctx, b4, 3);
  return x86_enc_bytes(elf_ctx, b5, 3);
}

int32_t arch_x86_64_enc_enc_jz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 132, label, label_len);
}

int32_t arch_x86_64_enc_enc_jeq(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 132, label, label_len);
}

int32_t arch_x86_64_enc_enc_jge(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 141, label, label_len);
}

int32_t arch_x86_64_enc_enc_jnz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len) {
  if (!elf_ctx) return -1;
  return x86_enc_jcc_rel32(elf_ctx, 133, label, label_len);
}

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

int32_t arch_x86_64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len) {
  int32_t rel32_at;
  uint8_t *cb;
  uint8_t rn[64];
  int32_t k;
  if (!elf_ctx || !name || name_len <= 0) return -1;
  cb = x86_enc_ctx_bytes(elf_ctx);
  if (x86_enc_u8(elf_ctx, 232) != 0) return -1;
  if (x86_enc_u32_le(elf_ctx, 0) != 0) return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_macho_leading_underscore(cb) != 0 && name_len > 0 && name_len <= 63 && name[0] != 95) {
    rn[0] = 95; k = 0;
    while (k < name_len && k < 63) { rn[k + 1] = name[k]; k = k + 1; }
    return pipeline_elf_ctx_append_reloc(cb, rel32_at, rn, name_len + 1);
  }
  return pipeline_elf_ctx_append_reloc(cb, rel32_at, name, name_len);
}

int32_t arch_x86_64_enc_enc_add_rsp_imm(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes) {
  if (!elf_ctx) return -1;
  if (nbytes <= 0) return 0;
  if (nbytes <= 127) {
    if (x86_enc_u8(elf_ctx, 72) != 0) return -1;
    if (x86_enc_u8(elf_ctx, 131) != 0) return -1;
    if (x86_enc_u8(elf_ctx, 196) != 0) return -1;
    return x86_enc_u8(elf_ctx, (uint8_t)nbytes);
  }
  if (x86_enc_u8(elf_ctx, 72) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 129) != 0) return -1;
  if (x86_enc_u8(elf_ctx, 196) != 0) return -1;
  return x86_enc_u32_le(elf_ctx, nbytes);
}

int32_t arch_x86_64_enc_enc_store_rax_to_rbx_indirect(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz) {
  static const uint8_t b1[] = {136, 3};
  static const uint8_t b4[] = {137, 3};
  static const uint8_t b8[] = {72, 137, 3};
  if (!elf_ctx) return -1;
  if (elem_sz == 1) return x86_enc_bytes(elf_ctx, b1, 2);
  if (elem_sz == 4) return x86_enc_bytes(elf_ctx, b4, 2);
  return x86_enc_bytes(elf_ctx, b8, 3);
}

int32_t arch_x86_64_enc_enc_store_rax_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size) {
  uint8_t buf[7];
  if (!elf_ctx) return -1;
  if (store_size == 1) {
    buf[0] = 136; buf[1] = 131;
    buf[2] = (uint8_t)(offset & 255); buf[3] = (uint8_t)((offset >> 8) & 255);
    buf[4] = (uint8_t)((offset >> 16) & 255); buf[5] = (uint8_t)((offset >> 24) & 255);
    return x86_enc_bytes(elf_ctx, buf, 6);
  }
  if (store_size == 4) {
    buf[0] = 137; buf[1] = 131;
    buf[2] = (uint8_t)(offset & 255); buf[3] = (uint8_t)((offset >> 8) & 255);
    buf[4] = (uint8_t)((offset >> 16) & 255); buf[5] = (uint8_t)((offset >> 24) & 255);
    return x86_enc_bytes(elf_ctx, buf, 6);
  }
  buf[0] = 72; buf[1] = 137; buf[2] = 131;
  buf[3] = (uint8_t)(offset & 255); buf[4] = (uint8_t)((offset >> 8) & 255);
  buf[5] = (uint8_t)((offset >> 16) & 255); buf[6] = (uint8_t)((offset >> 24) & 255);
  return x86_enc_bytes(elf_ctx, buf, 7);
}

/** subq %rax, %rbx（rax = rax - rbx；字面量左操作数 SUB 快路径）。 */
int32_t arch_x86_64_enc_enc_sub_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 41, 216};
  if (!elf_ctx)
    return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** movq (%rbx), %rax — SysV 16B struct 返回低 8 字节。 */
int32_t arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 139, 3};
  if (!elf_ctx)
    return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** movq 8(%rbx), %rdx — SysV 16B struct 返回高 8 字节。 */
int32_t arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t ins[] = {72, 139, 83, 8};
  if (!elf_ctx)
    return -1;
  return x86_enc_bytes(elf_ctx, ins, (int32_t)sizeof(ins));
}

/** movq %rdx, -offset(%rbp)。 */
static int32_t x86_enc_store_rdx_to_rbp_neg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
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

/** movq %rdx, -offset(%rbp)（16B struct 第二寄存器落栈）。 */
int32_t arch_x86_64_enc_enc_store_rdx_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx)
    return -1;
  return x86_enc_store_rdx_to_rbp_neg(elf_ctx, offset);
}

/** movq -offset(%rbp), %rdx（16B struct 栈槽高 8 字节）。 */
int32_t arch_x86_64_enc_enc_load_rbp_to_rdx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  if (!elf_ctx)
    return -1;
  return x86_enc_movq_from_rbp_neg(elf_ctx, offset, 85, 149);
}

/** movq %rdx, arg_reg[k]（SysV 16B struct 第二 GPR 实参）。 */
int32_t arch_x86_64_enc_enc_mov_rdx_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  static const uint8_t b0[] = {72, 137, 215};
  static const uint8_t b1[] = {72, 137, 214};
  static const uint8_t b2[] = {72, 137, 210};
  static const uint8_t b3[] = {72, 137, 209};
  static const uint8_t b4[] = {73, 137, 208};
  static const uint8_t b5[] = {73, 137, 209};
  int32_t idx;
  if (!elf_ctx)
    return -1;
  idx = k;
  if (idx < 0)
    idx = 0;
  if (idx > 5)
    idx = 5;
  /** 与 enc_mov_rax_to_arg_reg 对称：目的=arg_reg[k]，源=rdx。 */
  if (idx == 0)
    return x86_enc_bytes(elf_ctx, b0, 3);
  if (idx == 1)
    return x86_enc_bytes(elf_ctx, b1, 3);
  if (idx == 2)
    return x86_enc_bytes(elf_ctx, b2, 3);
  if (idx == 3)
    return x86_enc_bytes(elf_ctx, b3, 3);
  if (idx == 4)
    return x86_enc_bytes(elf_ctx, b4, 3);
  return x86_enc_bytes(elf_ctx, b5, 3);
}

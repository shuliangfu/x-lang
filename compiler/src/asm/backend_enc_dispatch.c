/**
 * backend_enc_dispatch.c — backend_enc_*_arch 的 C 侧 ta 分派
 *
 * M8 自举：backend.su 中 enc_*_arch 改为单行委托本 TU，避免 SU if(ta) 真 emit 产生未绑定 .LfN_ 跳转。
 * 依赖 asm_backend_partial.o 导出的 arch_*_enc_enc_* 符号。
 */
#include <stdint.h>
#include <string.h>

struct platform_elf_ElfCodegenCtx;

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
extern int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                              int32_t imm_bits);

/**
 * x86_64 条件跳转 rel32：0F opcode2 00 00 00 00 + patch（与 x86_64_enc.su enc_jle/enc_jl 一致）。
 * 供 pipeline_glue LCG 计数循环；bootstrap partial.o 未导出 enc_jle/enc_jl 时用 C 路由。
 */
static int32_t backend_enc_x86_jcc_rel32_c(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t opcode2,
                                           uint8_t *label, int32_t label_len) {
  uint8_t buf[6];
  int32_t rel32_at;
  if (!elf_ctx || !label || label_len <= 0)
    return -1;
  buf[0] = 0x0F;
  buf[1] = opcode2;
  buf[2] = 0;
  buf[3] = 0;
  buf[4] = 0;
  buf[5] = 0;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, buf, 6) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len((uint8_t *)elf_ctx) - 4;
  if (pipeline_elf_ctx_ensure_label((uint8_t *)elf_ctx, label, label_len) != 0)
    return -1;
  return pipeline_elf_ctx_append_patch((uint8_t *)elf_ctx, rel32_at, label, label_len, 32);
}

/** x86_64 cdqe；定义见本文件末尾。 */
int32_t arch_x86_64_enc_enc_cdqe_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);

extern int32_t arch_arm64_enc_enc_add_imm_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_add_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_load_rbp_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_rbx_plus_x2_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_rbx_plus_x2_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_rbx_plus_x2_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_add_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_and_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len);
extern int32_t arch_arm64_enc_enc_cltd(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_cmp_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_cmp_setcc_movzbl(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc);
extern int32_t arch_arm64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_idiv_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_imul_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_jeq(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jge(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jmp(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jnz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jne(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_label(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func);
extern int32_t arch_arm64_enc_enc_lea_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_lea_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_32_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_load_64_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_load_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_zext8_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_edx_to_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_imm32_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_arm64_enc_enc_mov_imm64_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi);
extern int32_t arch_arm64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k);
extern int32_t arch_arm64_enc_enc_sub_sp_imm12(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_add_sp_imm12(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_str_x0_sp_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes);
extern int32_t arch_arm64_enc_enc_mov_rax_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_neg_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_not_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_or_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_pop_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_pop_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_sz);
extern int32_t arch_arm64_enc_enc_push_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_push_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_rax_plus_rbx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_rax_plus_rbx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_rax_plus_rbx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_arm64_enc_enc_sar_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_setz_movzbl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_shl_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_shr_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_store_x_reg_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg, int32_t offset);
extern int32_t arch_arm64_enc_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t val);
extern int32_t arch_arm64_enc_enc_store_rax_to_rbx_indirect(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz);
extern int32_t arch_arm64_enc_enc_store_rax_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size);
extern int32_t arch_arm64_enc_enc_sub_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_sub_rbx_rax_then_mov(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_test_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_test_rbx_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_xor_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_imm_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_add_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_a2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_rbx_plus_a2_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rbx_plus_a2_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rbx_plus_a2_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_imm_to_a2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_a3(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_add_a2_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_sub_imm_from_a2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_sub_a2_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rsub_a2_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rsub_rbx_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mul_imm_to_a2(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit);
extern int32_t arch_riscv64_enc_enc_mul_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit);
extern int32_t arch_riscv64_enc_enc_sub_imm_from_rbx_index(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_add_rbx_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_sub_rbx_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mul_a2_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mul_rbx_a3(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_and_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len);
extern int32_t arch_riscv64_enc_enc_cltd(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_cmp_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_cmp_setcc_movzbl(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc);
extern int32_t arch_riscv64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_idiv_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_imul_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_jeq(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jge(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jmp(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jnz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_label(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func);
extern int32_t arch_riscv64_enc_enc_lea_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_lea_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_32_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_load_64_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_zext8_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_edx_to_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_imm32_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_riscv64_enc_enc_mov_imm64_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi);
extern int32_t arch_riscv64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k);
extern int32_t arch_riscv64_enc_enc_mov_rax_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_rbx_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_neg_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_not_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_or_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_pop_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_pop_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_sz);
extern int32_t arch_riscv64_enc_enc_add_sp_imm12(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_push_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_push_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rax_plus_rbx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rax_plus_rbx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_rax_plus_rbx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_riscv64_enc_enc_sar_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_setz_movzbl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_shl_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_shr_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_store_rax_to_rbx_indirect(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz);
extern int32_t arch_riscv64_enc_enc_store_rax_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size);
extern int32_t arch_riscv64_enc_enc_sub_rbx_rax_then_mov(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_test_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_test_rbx_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_riscv64_enc_enc_xor_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_imm_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_imm_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_imm_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_edx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_add_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_sub_imm_from_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_sub_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_rsub_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_rsub_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_imm_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_imul_imm_to_ebx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_imm_to_ebx_index(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_sub_imm_from_ebx_index(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_sub_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_ecx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_ebx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_and_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len);
extern int32_t arch_x86_64_enc_enc_cltd(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_cmp_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_cmp_setcc_movzbl(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc);
extern int32_t arch_x86_64_enc_enc_epilogue(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_idiv_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_jeq(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jge(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jmp(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jnz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jz(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_label(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func);
extern int32_t arch_x86_64_enc_enc_lea_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_lea_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_32_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_64_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_eax32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_ebx32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_zext8_from_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_edx_to_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_imm32_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_mov_imm64_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi);
extern int32_t arch_x86_64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k);
extern int32_t arch_x86_64_enc_enc_mov_rax_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_rbx_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_neg_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_not_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_or_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_pop_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_pop_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_prologue(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_sz);
extern int32_t arch_x86_64_enc_enc_push_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_push_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_rsp_imm(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes);
extern int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale1(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale4(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale8(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_sar_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_setz_movzbl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_shl_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_shr_cl_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_mov_arg_reg_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k);
extern int32_t arch_x86_64_enc_enc_load_rbp_pos_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbx_indirect(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbx_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size);
extern int32_t arch_x86_64_enc_enc_sub_rbx_rax_then_mov(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_test_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_test_rbx_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_xor_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);

/**
 * ta 分派：enc_label_arch
 * S4 freestanding：Linux x86_64 用户 `main` 保持 ELF 裸名 main（与 crt0_user_x86_64.s 一致）。
 */
int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_label(elf_ctx, name, name_len, is_func);
  if (ta == 2)
    return arch_riscv64_enc_enc_label(elf_ctx, name, name_len, is_func);
  return arch_x86_64_enc_enc_label(elf_ctx, name, name_len, is_func);
}

/**
 * ta 分派：enc_prologue_arch
 */
int32_t backend_enc_prologue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_prologue(elf_ctx, frame_sz);
  if (ta == 2)
    return arch_riscv64_enc_enc_prologue(elf_ctx, frame_sz);
  return arch_x86_64_enc_enc_prologue(elf_ctx, frame_sz);
}

/**
 * ta 分派：enc_epilogue_arch
 */
int32_t backend_enc_epilogue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_epilogue(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_epilogue(elf_ctx);
  return arch_x86_64_enc_enc_epilogue(elf_ctx);
}

/**
 * ta 分派：enc_ret_imm32_arch
 */
int32_t backend_enc_ret_imm32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_ret_imm32(elf_ctx, imm32);
  if (ta == 2)
    return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32);
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
}

/**
 * ta 分派：enc_mov_imm32_to_rbx_arch
 */
int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  return arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
}

/**
 * ta 分派：enc_mov_imm64_to_rax_arch
 */
int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  return arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
}

/**
 * ta 分派：enc_push_rax_arch
 */
int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_push_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_push_rax(elf_ctx);
  return arch_x86_64_enc_enc_push_rax(elf_ctx);
}

/**
 * ta 分派：enc_push_rbx_arch
 */
int32_t backend_enc_push_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_push_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_push_rbx(elf_ctx);
  return arch_x86_64_enc_enc_push_rbx(elf_ctx);
}

/**
 * ta 分派：enc_pop_rax_arch
 */
int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_pop_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_pop_rax(elf_ctx);
  return arch_x86_64_enc_enc_pop_rax(elf_ctx);
}

/**
 * ta 分派：enc_pop_rbx_arch
 */
int32_t backend_enc_pop_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_pop_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_pop_rbx(elf_ctx);
  return arch_x86_64_enc_enc_pop_rbx(elf_ctx);
}

/**
 * ta 分派：enc_add_rax_rbx_arch
 */
int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_add_rax_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_rax_rbx(elf_ctx);
  return arch_x86_64_enc_enc_add_rax_rbx(elf_ctx);
}

/**
 * x86：标量 f32 加法 addss（eax/rbx 低 32 位为 IEEE754 单精度，结果回 eax）。
 * movd xmm0,eax; movd xmm1,ebx; addss xmm0,xmm1; movd eax,xmm0
 */
int32_t backend_enc_addss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t movd_xmm1_ebx[4] = {0x66, 0x0f, 0x6e, 0xcb};
  static const uint8_t addss_xmm0_xmm1[4] = {0xf3, 0x0f, 0x58, 0xc1};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm1_ebx, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)addss_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}

/**
 * x86：eax 中 f32 位型截断为 i32（cvttss2si）；输入/输出均在 eax。
 */
int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvttss2si_eax_xmm0[4] = {0xf3, 0x0f, 0x2c, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvttss2si_eax_xmm0, 4);
}

/**
 * x86：rax 中 f64 位型收窄为 f32 位型到 eax（cvtsd2ss）；SysV 形参槽存 f64、用 f32 须转换。
 */
int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  /** movq xmm0,rax 须 66 REX.W 0F 6E；缺 66 会落到 mm0，cvtsd2ss 读 xmm0 得 0。 */
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvtsd2ss_xmm0_xmm0[4] = {0xf2, 0x0f, 0x5a, 0xc0};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtsd2ss_xmm0_xmm0, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}

/**
 * x86：eax 中 i32 转为 f32 位型写回 eax（cvtsi2ss）；return v.len as f32 等。
 */
int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t cvtsi2ss_xmm0_eax[4] = {0xf3, 0x0f, 0x2a, 0xc0};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtsi2ss_xmm0_eax, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}

/**
 * x86：movd xmmK, eax（66 0F 6E C0+K*8）；SysV f32 实参写入 xmm0–xmm7。
 */
int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  static const uint8_t prefix[3] = {0x66, 0x0f, 0x6e};
  uint8_t modrm;
  if (ta != 0 || !elf_ctx || k < 0 || k > 7)
    return -1;
  modrm = (uint8_t)(0xc0 | (k << 3));
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)prefix, 3) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, &modrm, 1);
}

/**
 * x86：movd eax, xmmK（66 0F 7E C0+K*8）；SysV f32 形参从 xmm 落栈槽。
 */
int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  static const uint8_t prefix[3] = {0x66, 0x0f, 0x7e};
  uint8_t modrm;
  if (ta != 0 || !elf_ctx || k < 0 || k > 7)
    return -1;
  modrm = (uint8_t)(0xc0 | (k << 3));
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)prefix, 3) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, &modrm, 1);
}

/**
 * ta 分派：enc_sub_rax_rbx_arch
 */
int32_t backend_enc_sub_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sub_rax_rbx(elf_ctx);
  return -1;
}

/**
 * ta 分派：enc_sub_rbx_rax_then_mov_arch
 */
int32_t backend_enc_sub_rbx_rax_then_mov_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  return arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
}

/**
 * ta 分派：enc_imul_rbx_rax_arch
 */
int32_t backend_enc_imul_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_imul_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx);
}

/**
 * ta 分派：enc_mov_rax_to_rbx_arch
 */
int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx);
  return arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx);
}

/**
 * ta 分派：enc_not_eax_arch
 */
int32_t backend_enc_not_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_not_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_not_eax(elf_ctx);
  return arch_x86_64_enc_enc_not_eax(elf_ctx);
}

/**
 * ta 分派：enc_and_rbx_rax_arch
 */
int32_t backend_enc_and_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_and_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_and_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_and_rbx_rax(elf_ctx);
}

/**
 * ta 分派：enc_or_rbx_rax_arch
 */
int32_t backend_enc_or_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_or_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_or_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_or_rbx_rax(elf_ctx);
}

/**
 * ta 分派：enc_xor_rbx_rax_arch
 */
int32_t backend_enc_xor_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_xor_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx);
}

/**
 * ta 分派：enc_mov_rbx_to_ecx_arch
 */
int32_t backend_enc_mov_rbx_to_ecx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  return arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx);
}

/**
 * ta 分派：enc_shl_cl_eax_arch
 */
int32_t backend_enc_shl_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_shl_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_shl_cl_eax(elf_ctx);
}

/**
 * ta 分派：enc_shr_cl_eax_arch
 */
int32_t backend_enc_shr_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_shr_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_shr_cl_eax(elf_ctx);
}

/**
 * ta 分派：enc_sar_cl_eax_arch
 */
int32_t backend_enc_sar_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sar_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_sar_cl_eax(elf_ctx);
}

/**
 * ta 分派：enc_cltd_arch
 */
int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cltd(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_cltd(elf_ctx);
  return arch_x86_64_enc_enc_cltd(elf_ctx);
}

/**
 * ta 分派：enc_idiv_rbx_arch
 */
int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_idiv_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_idiv_rbx(elf_ctx);
  if (arch_x86_64_enc_enc_cltd(elf_ctx) != 0)
    return -1;
  return arch_x86_64_enc_enc_idiv_rbx(elf_ctx);
}

/**
 * ta 分派：enc_mov_edx_to_eax_arch
 */
int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx);
  return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
}

/**
 * ta 分派：enc_neg_eax_arch
 */
int32_t backend_enc_neg_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_neg_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_neg_eax(elf_ctx);
  return arch_x86_64_enc_enc_neg_eax(elf_ctx);
}

/**
 * ta 分派：enc_test_eax_eax_arch
 */
int32_t backend_enc_test_eax_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_test_eax_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_test_eax_eax(elf_ctx);
  return arch_x86_64_enc_enc_test_eax_eax(elf_ctx);
}

/**
 * ta 分派：enc_test_rbx_rbx_arch（除数零检，preserve rax 被除数）。
 */
int32_t backend_enc_test_rbx_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_test_rbx_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx);
  return arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx);
}

/**
 * ta 分派：enc_setz_movzbl_eax_arch
 */
int32_t backend_enc_setz_movzbl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx);
  return arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx);
}

/**
 * ta 分派：enc_cmp_rbx_rax_arch
 */
int32_t backend_enc_cmp_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx);
}

/**
 * ta 分派：enc_cmp_setcc_movzbl_arch
 */
int32_t backend_enc_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  if (ta == 2)
    return arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  return arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
}

/**
 * ta 分派：enc_store_rax_to_rbp_arch
 */
int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  return arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
}

/**
 * ta 分派：enc_store_x_reg_to_rbp（arm64 形参 x0-x7 落栈）。
 */
int32_t backend_enc_store_x_reg_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg,
                                              int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset);
  return -1;
}

/**
 * ta 分派：enc_load_x29_pos_to_rax（arm64 栈上传参 [x29,#off]）。
 * 在 C 侧用 uint32_t 拼 LDR 机器码，避免 partial 内 i32 大常量被宿主 cc 误加载（0xF93FFFA0）。
 */
int32_t backend_enc_load_x29_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                             int32_t ta) {
  if (ta == 1) {
    int32_t off = off_pos;
    int32_t imm12;
    uint32_t ins;
    if (off < 0)
      off = 0;
    imm12 = off >> 3;
    if (imm12 > 4095)
      imm12 = 4095;
    /** 0xF94003A0 = ldr x0, [x29, #0]；imm12 为字节偏移/8。 */
    ins = 0xF94003A0u | ((uint32_t)imm12 << 10u);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  return -1;
}

/**
 * ta 分派：enc_mov_arg_reg_to_rax（x86 SysV 形参寄存器 → rax）。
 */
int32_t backend_enc_mov_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  if (ta == 0)
    return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k);
  return -1;
}

/**
 * ta 分派：enc_load_rbp_pos_to_rax（x86 栈上传参 [rbp+#off]）。
 */
int32_t backend_enc_load_rbp_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                             int32_t ta) {
  if (ta == 0)
    return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos);
  return -1;
}

/**
 * ta 分派：enc_load_rbp_to_rax_arch
 */
int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
}

/**
 * ta 分派：enc_load_rbp_to_rbx_arch
 */
int32_t backend_enc_load_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx, offset);
  /** x86：movq -off(%rbp),%rbx；disp8 用 modrm 0x5d，disp32 用 0x9d（勿混用，否则后续 emit 字节被当 disp 吞掉）。 */
  if (elf_ctx) {
    int32_t disp = -offset;
    uint8_t b[7];
    if (disp >= -128 && disp <= -1) {
      b[0] = 0x48;
      b[1] = 0x8b;
      b[2] = 0x5d;
      b[3] = (uint8_t)disp;
      return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 4);
    }
    b[0] = 0x48;
    b[1] = 0x8b;
    b[2] = 0x9d;
    b[3] = (uint8_t)disp;
    b[4] = (uint8_t)(disp >> 8);
    b[5] = (uint8_t)(disp >> 16);
    b[6] = (uint8_t)(disp >> 24);
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 7);
  }
  return -1;
}

/**
 * arm64：LDUR w0, [x29, #-offset]（f32/i32 单向量 lane load）。
 */
static int32_t arm64_enc_load_w0_from_rbp_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t simm9;
  int32_t u9;
  int32_t base;
  uint32_t insn;
  if (!elf_ctx || offset < 0)
    return -1;
  simm9 = 0 - offset;
  if (simm9 < -256)
    simm9 = -256;
  u9 = simm9 & 511;
  base = -130023424 - 1073741824;
  insn = (uint32_t)base | ((uint32_t)u9 << 12) | (29u << 5);
  return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)insn);
}

/**
 * x86：movl 取 i32 lane；arm64 f32/i32 lane 用 LDUR w0；其它走 64-bit load。
 */
int32_t backend_enc_load_rbp_lane_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                              int32_t esz, int32_t ta) {
  if (ta == 0 && esz == 4)
    return arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx, offset);
  if (ta == 1 && esz == 4)
    return arm64_enc_load_w0_from_rbp_c(elf_ctx, offset);
  return backend_enc_load_rbp_to_rax_arch(elf_ctx, offset, ta);
}

/**
 * x86：movl 取 i32 lane；其它 arch / 8B lane 走 movq。
 */
int32_t backend_enc_load_rbp_lane_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                              int32_t esz, int32_t ta) {
  if (ta == 0 && esz == 4)
    return arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx, offset);
  return backend_enc_load_rbp_to_rbx_arch(elf_ctx, offset, ta);
}

/**
 * arm64：STUR w0, [x29, #-offset]（f32 局部 let/assign；勿 64 位 str x0 覆盖相邻 4B 槽）。
 */
static int32_t arm64_enc_store_w0_to_rbp_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
  int32_t simm9;
  int32_t u9;
  uint32_t insn;
  if (!elf_ctx || offset < 0)
    return -1;
  simm9 = 0 - offset;
  if (simm9 < -256)
    simm9 = -256;
  u9 = simm9 & 511;
  insn = 0xB8000000u | ((uint32_t)u9 << 12) | (29u << 5);
  return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)insn);
}

/**
 * x86：movl %eax, -off(%rbp)（f32 局部 let/assign store）；arm64 走 STUR w0。
 */
int32_t backend_enc_store_eax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arm64_enc_store_w0_to_rbp_c(elf_ctx, offset);
  if (ta != 0 || !elf_ctx)
    return -1;
  {
    int32_t disp = -offset;
    uint8_t b[7];
    if (disp >= -128 && disp <= -1) {
      b[0] = 0x89;
      b[1] = 0x45;
      b[2] = (uint8_t)disp;
      return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
    }
    b[0] = 0x89;
    b[1] = 0x85;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)(disp >> 8);
    b[4] = (uint8_t)(disp >> 16);
    b[5] = (uint8_t)(disp >> 24);
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
  }
}

/**
 * ta 分派：enc_lea_rbp_to_rax_arch
 */
int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  return arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
}

/**
 * ta 分派：enc_lea_rbp_to_rbx_arch（向量 dst 基址入 rbx，preserve rax）。
 */
int32_t backend_enc_lea_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  return arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
}

/**
 * ta 分派：enc_rax_plus_rbx_scale4_arch
 */
int32_t backend_enc_rax_plus_rbx_scale4_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  return arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
}

/**
 * ta 分派：enc_rax_plus_rbx_scale1_arch
 */
int32_t backend_enc_rax_plus_rbx_scale1_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  return arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
}

/**
 * ta 分派：enc_rax_plus_rbx_scale8_arch
 */
int32_t backend_enc_rax_plus_rbx_scale8_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  return arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
}

/**
 * ta 分派：enc_store_rax_to_rbx_indirect_arch
 */
int32_t backend_enc_store_rax_to_rbx_indirect_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  if (ta == 2)
    return arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  return arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
}

/**
 * ta 分派：enc_load_32_from_rax_arch
 */
int32_t backend_enc_load_32_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1) {
    if (arch_arm64_enc_enc_load_32_from_rax(elf_ctx) != 0)
      return -1;
    return 0;
  }
  if (ta == 2) {
    if (arch_riscv64_enc_enc_load_32_from_rax(elf_ctx) != 0)
      return -1;
    return 0;
  }
  if (arch_x86_64_enc_enc_load_32_from_rax(elf_ctx) != 0)
    return -1;
  /** movl (%rax), %eax 后 cdqe：rax 勿残留指针（SoA/index 读 + binop 共用）。 */
  return arch_x86_64_enc_enc_cdqe_rax(elf_ctx);
}

/**
 * i32 间接 load 后规范化 rax（x86 已由 load_32_from_rax_arch 内建 cdqe）。
 */
int32_t backend_enc_load_i32_indirect_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

/**
 * ta 分派：enc_load_zext8_from_rax_arch
 */
int32_t backend_enc_load_zext8_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx);
  return arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx);
}

/**
 * ta 分派：enc_add_imm_to_rax_arch
 */
int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx, imm);
}

/**
 * ta 分派：enc_add_imm_to_rbx_arch（INDEX 字面量下标偏移，preserve rax 右值）。
 */
int32_t backend_enc_add_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
}

/**
 * ta 分派：INDEX 变量下标 load 到 scratch（arm64 w2 / x86 ecx / riscv a2），勿 clobber rax 右值。
 */
int32_t backend_enc_load_rbp_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                 int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx, offset);
  return arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx, offset);
}

/**
 * ta 分派：rbx 基址 + scratch 下标缩放寻址（base 已在 rbx）。
 */
int32_t backend_enc_rbx_plus_index_scratch_scaled_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz,
                                                        int32_t ta) {
  if (esz == 1) {
    if (ta == 1)
      return arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx);
    if (ta == 2)
      return arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx);
    return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx);
  }
  if (esz == 4) {
    if (ta == 1)
      return arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx);
    if (ta == 2)
      return arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx);
    return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx);
  }
  if (ta == 1)
    return arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx);
  return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx);
}

/**
 * ta 分派：INDEX scratch 下标 + 字面量偏移（var+lit / lit+var add 下标）。
 */
int32_t backend_enc_add_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                   int32_t ta) {
  if (ta == 1) {
    int32_t imm12;
    uint32_t ins;
    if (imm == 0)
      return 0;
    imm12 = imm;
    if (imm12 > 4095)
      imm12 = 4095;
    /** 0x11000442 = add w2,w2,#1；每 +1 步进 1024（C 侧合成，避免 .su -E 失精）。 */
    ins = 285213762u + (uint32_t)((imm12 - 1) << 10);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx, imm);
}

/**
 * ta 分派：INDEX 第二下标 load 到 scratch2（arm64 w3 / x86 edx / riscv a3）。
 */
int32_t backend_enc_load_rbp_index_secondary_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                           int32_t ta) {
  int32_t simm9;
  uint32_t u9;
  uint32_t ins;
  if (ta == 1) {
    simm9 = -offset;
    if (simm9 < -256)
      simm9 = -256;
    u9 = (uint32_t)(simm9 & 511);
    /** LDUR w3, [x29, #-off]；Rt=3。 */
    ins = 0xB8400000u | (u9 << 12u) | (29u << 5u) | 3u;
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx, offset);
  return arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx, offset);
}

/**
 * ta 分派：INDEX scratch 下标 i+j（primary += secondary）。
 */
int32_t backend_enc_index_scratch_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x0B030042u);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_add_ecx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX scratch 下标 var-lit（primary -= imm）。
 */
int32_t backend_enc_sub_imm_from_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                     int32_t ta) {
  if (ta == 1) {
    int32_t imm12;
    uint32_t ins;
    if (imm == 0)
      return 0;
    imm12 = imm;
    if (imm12 > 4095)
      imm12 = 4095;
    /** 0x51000442 = sub w2,w2,#1；每 +1 步进 1024。 */
    ins = 1358955586u + (uint32_t)((imm12 - 1) << 10);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx, imm);
  return arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx, imm);
}

/**
 * ta 分派：INDEX scratch 下标 i-j（primary -= secondary）。
 */
int32_t backend_enc_index_scratch_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B030042u);
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX scratch 下标 secondary - scratch（i-(j+k) 右结合 SUB）。
 */
int32_t backend_enc_index_scratch_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B020062u);
  if (ta == 2)
    return arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX 读路径 secondary - rbx（i-(j+k)）。
 */
int32_t backend_enc_rbx_index_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B010061u);
  if (ta == 2)
    return arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX scratch 下标 × 正字面量（var*lit / lit*var 下标；2≤lit≤65535）。
 * arm64：mov w3,#imm + mul w2,w2,w3；x86：imull $imm,%ecx；riscv：addi a3 + mul a2,a2,a3。
 */
int32_t backend_enc_mul_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit,
                                                   int32_t ta) {
  uint32_t ins;
  if (lit <= 1)
    return 0;
  if (lit > 65535)
    return -1;
  if (ta == 1) {
    /** mov w3, #lit（movz）。 */
    ins = 0x52800000u | ((uint32_t)lit << 5) | 3u;
    if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins) != 0)
      return -1;
    /** mul w2, w2, w3。 */
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x1B037C42u);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx, lit);
  return arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx, lit);
}

/**
 * ta 分派：INDEX 读路径下标（rbx）× 正字面量（return arr[i*lit] 等；2≤lit≤65535）。
 */
int32_t backend_enc_mul_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit, int32_t ta) {
  uint32_t ins;
  if (lit <= 1)
    return 0;
  if (lit > 65535)
    return -1;
  if (ta == 1) {
    ins = 0x52800000u | ((uint32_t)lit << 5) | 3u;
    if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins) != 0)
      return -1;
    /** mul w1, w1, w3（rbx/x1 为 32 位下标）。 */
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x1B037C21u);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx, lit);
  return arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx, lit);
}

/**
 * ta 分派：INDEX 读路径下标（rbx/w1）+ 字面量（return arr[i+lit] 等）。
 */
int32_t backend_enc_add_imm_to_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta) {
  int32_t imm12;
  uint32_t ins;
  if (imm == 0)
    return 0;
  if (ta == 1) {
    imm12 = imm;
    if (imm12 > 4095)
      imm12 = 4095;
    /** 0x11000421 = add w1,w1,#1；每 +1 步进 1024。 */
    ins = 285213729u + (uint32_t)((imm12 - 1) << 10);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx, imm);
}

/**
 * ta 分派：INDEX 读路径下标（rbx）- 字面量（return arr[i-lit] 等）。
 */
int32_t backend_enc_sub_imm_from_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta) {
  int32_t imm12;
  uint32_t ins;
  if (imm == 0)
    return 0;
  if (ta == 1) {
    imm12 = imm;
    if (imm12 > 4095)
      imm12 = 4095;
    /** 0x51000421 = sub w1,w1,#1；每 +1 步进 1024。 */
    ins = 1358955553u + (uint32_t)((imm12 - 1) << 10);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx, imm);
  return arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx, imm);
}

/**
 * ta 分派：INDEX 读路径 i+j（primary rbx += secondary scratch）。
 */
int32_t backend_enc_rbx_index_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x0B030021u);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_add_ebx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX 读路径 i-j（primary rbx -= secondary scratch）。
 */
int32_t backend_enc_rbx_index_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B030021u);
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX assign scratch 下标 i*j（primary scratch *= secondary）。
 */
int32_t backend_enc_index_scratch_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x1B037C42u);
  if (ta == 2)
    return arch_riscv64_enc_enc_mul_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx);
}

/**
 * ta 分派：INDEX 读路径 i*j（primary rbx *= secondary scratch）。
 */
int32_t backend_enc_rbx_index_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x1B037C21u);
  if (ta == 2)
    return arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx);
}

/**
 * ta 分派：enc_load_64_from_rax_arch
 */
int32_t backend_enc_load_64_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_64_from_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_64_from_rax(elf_ctx);
  return arch_x86_64_enc_enc_load_64_from_rax(elf_ctx);
}

/**
 * ta 分派：enc_store_rax_to_rbx_offset_arch
 */
int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  if (ta == 2)
    return arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  return arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
}

/**
 * ta 分派：enc_mov_rbx_to_rax_arch
 */
int32_t backend_enc_mov_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx);
  return arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx);
}

/**
 * ta 分派：enc_jz_arch
 */
int32_t backend_enc_jz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jz(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jz(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jz(elf_ctx, label, label_len);
}

/**
 * ta 分派：enc_jeq_arch
 */
int32_t backend_enc_jeq_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jeq(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jeq(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jeq(elf_ctx, label, label_len);
}

/**
 * ta 分派：enc_jge_arch
 */
int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jge(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jge(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jge(elf_ctx, label, label_len);
}

/**
 * ta 分派：enc_jle_arch（x86 0F 8E；LCG while 回跳，其它 arch 暂不支持）。
 */
int32_t backend_enc_jle_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta != 0)
    return -1;
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 0x8E, label, label_len);
}

/**
 * ta 分派：enc_jl_arch（x86 0F 8C；LCG 2×/4× 展开回跳，其它 arch 暂不支持）。
 */
int32_t backend_enc_jl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta != 0)
    return -1;
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 0x8C, label, label_len);
}

/**
 * ta 分派：enc_jnz_arch
 */
int32_t backend_enc_jnz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jnz(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len);
}

/**
 * ta 分派：enc_jne_arch（arm64 b.ne 用 cmp 标志；x86/riscv 同 jnz）。
 */
int32_t backend_enc_jne_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jne(elf_ctx, label, label_len);
  return backend_enc_jnz_arch(elf_ctx, label, label_len, ta);
}

/**
 * ta 分派：enc_jmp_arch
 */
int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jmp(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jmp(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jmp(elf_ctx, label, label_len);
}

/**
 * ta 分派：enc_mov_rax_to_arg_reg_arch
 */
int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  return arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
}

/**
 * ta 分派：enc_call_arch
 */
int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_call(elf_ctx, name, name_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_call(elf_ctx, name, name_len);
  return arch_x86_64_enc_enc_call(elf_ctx, name, name_len);
}

/**
 * ta 分派：call 后回收 outgoing 栈实参区（x86 add rsp / arm64 add sp）。
 */
int32_t backend_enc_call_stack_cleanup_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes, int32_t ta) {
  if (nbytes <= 0)
    return 0;
  if (ta == 1)
    return arch_arm64_enc_enc_add_sp_imm12(elf_ctx, nbytes);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_sp_imm12(elf_ctx, nbytes);
  return arch_x86_64_enc_enc_add_rsp_imm(elf_ctx, nbytes);
}

/**
 * ta 分派：arm64 预留 outgoing 栈实参区（sub sp）；x86/riscv 由 push 路径处理，nbytes≤0 时 no-op。
 */
int32_t backend_enc_call_stack_reserve_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes, int32_t ta) {
  if (nbytes <= 0)
    return 0;
  if (ta == 1)
    return arch_arm64_enc_enc_sub_sp_imm12(elf_ctx, nbytes);
  return 0;
}

/**
 * ta 分派：arm64 将 x0 写入 [sp+#off] outgoing 槽；其它架构暂不支持。
 */
int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_str_x0_sp_offset(elf_ctx, off_bytes);
  return -1;
}

/**
 * x86_64 cdqe（48 98）：movl (%rax),%eax 后符号扩展 eax→rax，避免 binop 误用残留指针。
 */
int32_t arch_x86_64_enc_enc_cdqe_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t cdqe[2] = {0x48, 0x98};
  if (!elf_ctx)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cdqe, 2);
}

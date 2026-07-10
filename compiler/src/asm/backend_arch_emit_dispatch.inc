/**
 * backend_arch_emit_dispatch.c — backend_arch_emit_* 的 C 侧 ta 分派
 *
 * M8 自举：backend.x arch_emit_* 单行委托本 TU，避免 X if(ta) 真 emit 未绑定跳转。
 */
#include <stdint.h>

struct codegen_CodegenOutBuf;

extern int32_t arch_arm64_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_arm64_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_add_sp_imm(struct codegen_CodegenOutBuf *out, int32_t n);
extern int32_t arch_arm64_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_arm64_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc);
extern int32_t arch_arm64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz);
extern int32_t arch_arm64_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_arm64_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_arm64_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_arm64_emit_ldr_sp_offset_to_wi(struct codegen_CodegenOutBuf *out, int32_t i);
extern int32_t arch_arm64_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_arm64_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_arm64_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_arm64_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi);
extern int32_t arch_arm64_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k);
extern int32_t arch_arm64_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_neg_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_not_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_pop_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_pop_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz);
extern int32_t arch_arm64_emit_push_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_arm64_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_section_text(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_arm64_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz);
extern int32_t arch_arm64_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t offset, int32_t store_size);
extern int32_t arch_arm64_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out);
extern int32_t arch_arm64_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_riscv64_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_riscv64_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc);
extern int32_t arch_riscv64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz);
extern int32_t arch_riscv64_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_riscv64_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_riscv64_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_riscv64_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_riscv64_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_riscv64_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_riscv64_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi);
extern int32_t arch_riscv64_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k);
extern int32_t arch_riscv64_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_neg_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_not_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_pop_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_pop_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz);
extern int32_t arch_riscv64_emit_push_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_riscv64_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_section_text(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_riscv64_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz);
extern int32_t arch_riscv64_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t offset, int32_t store_size);
extern int32_t arch_riscv64_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out);
extern int32_t arch_riscv64_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_x86_64_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_x86_64_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc);
extern int32_t arch_x86_64_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz);
extern int32_t arch_x86_64_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_x86_64_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len);
extern int32_t arch_x86_64_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len);
extern int32_t arch_x86_64_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_x86_64_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_x86_64_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_x86_64_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi);
extern int32_t arch_x86_64_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k);
extern int32_t arch_x86_64_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_neg_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_not_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_pop_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_pop_rbx(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz);
extern int32_t arch_x86_64_emit_push_rax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm);
extern int32_t arch_x86_64_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_section_text(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off);
extern int32_t arch_x86_64_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz);
extern int32_t arch_x86_64_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t offset, int32_t store_size);
extern int32_t arch_x86_64_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out);
extern int32_t arch_x86_64_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out);

/**
 * ta 分派：arch_emit_ret_imm32
 */
int32_t backend_arch_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_ret_imm32(out, imm);
  if (ta == 2)
    return arch_riscv64_emit_ret_imm32(out, imm);
  return arch_x86_64_emit_ret_imm32(out, imm);
}

/**
 * ta 分派：arch_emit_mov_imm64_to_rax
 */
int32_t backend_arch_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_imm64_to_rax(out, lo, hi);
  if (ta == 2)
    return arch_riscv64_emit_mov_imm64_to_rax(out, lo, hi);
  return arch_x86_64_emit_mov_imm64_to_rax(out, lo, hi);
}

/**
 * ta 分派：arch_emit_mov_imm32_to_rbx
 */
int32_t backend_arch_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_imm32_to_rbx(out, imm);
  if (ta == 2)
    return arch_riscv64_emit_mov_imm32_to_rbx(out, imm);
  return arch_x86_64_emit_mov_imm32_to_rbx(out, imm);
}

/**
 * ta 分派：arch_emit_neg_eax
 */
int32_t backend_arch_emit_neg_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_neg_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_neg_eax(out);
  return arch_x86_64_emit_neg_eax(out);
}

/**
 * ta 分派：arch_emit_cmp_rbx_rax
 */
int32_t backend_arch_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_cmp_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_cmp_rbx_rax(out);
  return arch_x86_64_emit_cmp_rbx_rax(out);
}

/**
 * ta 分派：arch_emit_cmp_setcc
 */
int32_t backend_arch_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_cmp_setcc(out, cc);
  if (ta == 2)
    return arch_riscv64_emit_cmp_setcc(out, cc);
  return arch_x86_64_emit_cmp_setcc(out, cc);
}

/**
 * ta 分派：arch_emit_push_rax
 */
int32_t backend_arch_emit_push_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_push_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_push_rax(out);
  return arch_x86_64_emit_push_rax(out);
}

/**
 * ta 分派：arch_emit_pop_rbx
 */
int32_t backend_arch_emit_pop_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_pop_rbx(out);
  if (ta == 2)
    return arch_riscv64_emit_pop_rbx(out);
  return arch_x86_64_emit_pop_rbx(out);
}

/**
 * ta 分派：arch_emit_pop_rax
 */
int32_t backend_arch_emit_pop_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_pop_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_pop_rax(out);
  return arch_x86_64_emit_pop_rax(out);
}

/**
 * ta 分派：arch_emit_add_rax_rbx
 */
int32_t backend_arch_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_add_rax_rbx(out);
  if (ta == 2)
    return arch_riscv64_emit_add_rax_rbx(out);
  return arch_x86_64_emit_add_rax_rbx(out);
}

/**
 * ta 分派：arch_emit_sub_rbx_rax_then_mov
 */
int32_t backend_arch_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_sub_rbx_rax_then_mov(out);
  if (ta == 2)
    return arch_riscv64_emit_sub_rbx_rax_then_mov(out);
  return arch_x86_64_emit_sub_rbx_rax_then_mov(out);
}

/**
 * ta 分派：arch_emit_imul_rbx_rax
 */
int32_t backend_arch_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_imul_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_imul_rbx_rax(out);
  return arch_x86_64_emit_imul_rbx_rax(out);
}

/**
 * ta 分派：arch_emit_mov_rax_to_rbx
 */
int32_t backend_arch_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_rax_to_rbx(out);
  if (ta == 2)
    return arch_riscv64_emit_mov_rax_to_rbx(out);
  return arch_x86_64_emit_mov_rax_to_rbx(out);
}

/**
 * ta 分派：arch_emit_load_rbp_to_rax
 */
int32_t backend_arch_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_rbp_to_rax(out, off);
  if (ta == 2)
    return arch_riscv64_emit_load_rbp_to_rax(out, off);
  return arch_x86_64_emit_load_rbp_to_rax(out, off);
}

/**
 * ta 分派：arch_emit_store_rax_to_rbp
 */
int32_t backend_arch_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_store_rax_to_rbp(out, off);
  if (ta == 2)
    return arch_riscv64_emit_store_rax_to_rbp(out, off);
  return arch_x86_64_emit_store_rax_to_rbp(out, off);
}

/**
 * ta 分派：arch_emit_lea_rbp_to_rax
 */
int32_t backend_arch_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_lea_rbp_to_rax(out, off);
  if (ta == 2)
    return arch_riscv64_emit_lea_rbp_to_rax(out, off);
  return arch_x86_64_emit_lea_rbp_to_rax(out, off);
}

/**
 * ta 分派：arch_emit_rax_plus_rbx_scale4
 */
int32_t backend_arch_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_rax_plus_rbx_scale4(out);
  if (ta == 2)
    return arch_riscv64_emit_rax_plus_rbx_scale4(out);
  return arch_x86_64_emit_rax_plus_rbx_scale4(out);
}

/**
 * ta 分派：arch_emit_rax_plus_rbx_scale1
 */
int32_t backend_arch_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_rax_plus_rbx_scale1(out);
  if (ta == 2)
    return arch_riscv64_emit_rax_plus_rbx_scale1(out);
  return arch_x86_64_emit_rax_plus_rbx_scale1(out);
}

/**
 * ta 分派：arch_emit_rax_plus_rbx_scale8
 */
int32_t backend_arch_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_rax_plus_rbx_scale8(out);
  if (ta == 2)
    return arch_riscv64_emit_rax_plus_rbx_scale8(out);
  return arch_x86_64_emit_rax_plus_rbx_scale8(out);
}

/**
 * ta 分派：arch_emit_store_rax_to_rbx_indirect
 */
int32_t backend_arch_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_store_rax_to_rbx_indirect(out, elem_sz);
  if (ta == 2)
    return arch_riscv64_emit_store_rax_to_rbx_indirect(out, elem_sz);
  return arch_x86_64_emit_store_rax_to_rbx_indirect(out, elem_sz);
}

/**
 * ta 分派：arch_emit_load_32_from_rax
 */
int32_t backend_arch_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_32_from_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_load_32_from_rax(out);
  return arch_x86_64_emit_load_32_from_rax(out);
}

/**
 * ta 分派：arch_emit_load_zext8_from_rax
 */
int32_t backend_arch_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_zext8_from_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_load_zext8_from_rax(out);
  return arch_x86_64_emit_load_zext8_from_rax(out);
}

/**
 * ta 分派：arch_emit_add_imm_to_rax
 */
int32_t backend_arch_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_add_imm_to_rax(out, imm);
  if (ta == 2)
    return arch_riscv64_emit_add_imm_to_rax(out, imm);
  return arch_x86_64_emit_add_imm_to_rax(out, imm);
}

/**
 * ta 分派：arch_emit_load_64_from_rax
 */
int32_t backend_arch_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_64_from_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_load_64_from_rax(out);
  return arch_x86_64_emit_load_64_from_rax(out);
}

/**
 * ta 分派：arch_emit_store_rax_to_rbx_offset
 */
int32_t backend_arch_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t offset, int32_t store_size, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_store_rax_to_rbx_offset(out, offset, store_size);
  if (ta == 2)
    return arch_riscv64_emit_store_rax_to_rbx_offset(out, offset, store_size);
  return arch_x86_64_emit_store_rax_to_rbx_offset(out, offset, store_size);
}

/**
 * ta 分派：arch_emit_mov_rbx_to_rax
 */
int32_t backend_arch_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_rbx_to_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_mov_rbx_to_rax(out);
  return arch_x86_64_emit_mov_rbx_to_rax(out);
}

/**
 * ta 分派：arch_emit_mov_rax_to_arg_reg
 */
int32_t backend_arch_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k, int32_t ta) {
  if (ta == 1)
    return 0;
  if (ta == 2)
    return arch_riscv64_emit_mov_rax_to_arg_reg(out, k);
  return arch_x86_64_emit_mov_rax_to_arg_reg(out, k);
}

/**
 * ta 分派：arch_emit_ldr_sp_offset_to_wi
 */
int32_t backend_arch_emit_ldr_sp_offset_to_wi(struct codegen_CodegenOutBuf *out, int32_t i, int32_t ta) {
  if (ta != 1)
    return 0;
  return arch_arm64_emit_ldr_sp_offset_to_wi(out, i);
}

/**
 * ta 分派：arch_emit_add_sp_imm
 */
int32_t backend_arch_emit_add_sp_imm(struct codegen_CodegenOutBuf *out, int32_t n, int32_t ta) {
  if (ta != 1)
    return 0;
  return arch_arm64_emit_add_sp_imm(out, n);
}

/**
 * ta 分派：arch_emit_call
 */
int32_t backend_arch_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_call(out, name, name_len);
  if (ta == 2)
    return arch_riscv64_emit_call(out, name, name_len);
  return arch_x86_64_emit_call(out, name, name_len);
}

/**
 * ta 分派：arch_emit_jz
 */
int32_t backend_arch_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jz(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jz(out, label, label_len);
  return arch_x86_64_emit_jz(out, label, label_len);
}

/**
 * ta 分派：arch_emit_jeq
 */
int32_t backend_arch_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jeq(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jeq(out, label, label_len);
  return arch_x86_64_emit_jeq(out, label, label_len);
}

/**
 * ta 分派：arch_emit_jmp
 */
int32_t backend_arch_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jmp(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jmp(out, label, label_len);
  return arch_x86_64_emit_jmp(out, label, label_len);
}

/**
 * ta 分派：arch_emit_jnz
 */
int32_t backend_arch_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jnz(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jnz(out, label, label_len);
  return arch_x86_64_emit_jnz(out, label, label_len);
}

/**
 * ta 分派：arch_emit_not_eax
 */
int32_t backend_arch_emit_not_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_not_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_not_eax(out);
  return arch_x86_64_emit_not_eax(out);
}

/**
 * ta 分派：arch_emit_and_rbx_rax
 */
int32_t backend_arch_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_and_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_and_rbx_rax(out);
  return arch_x86_64_emit_and_rbx_rax(out);
}

/**
 * ta 分派：arch_emit_or_rbx_rax
 */
int32_t backend_arch_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_or_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_or_rbx_rax(out);
  return arch_x86_64_emit_or_rbx_rax(out);
}

/**
 * ta 分派：arch_emit_xor_rbx_rax
 */
int32_t backend_arch_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_xor_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_xor_rbx_rax(out);
  return arch_x86_64_emit_xor_rbx_rax(out);
}

/**
 * ta 分派：arch_emit_mov_rbx_to_ecx
 */
int32_t backend_arch_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return 0;
  if (ta == 2)
    return arch_riscv64_emit_mov_rbx_to_ecx(out);
  return arch_x86_64_emit_mov_rbx_to_ecx(out);
}

/**
 * ta 分派：arch_emit_shl_cl_eax
 */
int32_t backend_arch_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_shl_cl_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_shl_cl_eax(out);
  return arch_x86_64_emit_shl_cl_eax(out);
}

/**
 * ta 分派：arch_emit_shr_cl_eax
 */
int32_t backend_arch_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_shr_cl_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_shr_cl_eax(out);
  return arch_x86_64_emit_shr_cl_eax(out);
}

/**
 * ta 分派：arch_emit_sar_cl_eax
 */
int32_t backend_arch_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_sar_cl_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_sar_cl_eax(out);
  return arch_x86_64_emit_sar_cl_eax(out);
}

/**
 * ta 分派：arch_emit_label
 */
int32_t backend_arch_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_label(out, name, name_len);
  if (ta == 2)
    return arch_riscv64_emit_label(out, name, name_len);
  return arch_x86_64_emit_label(out, name, name_len);
}

/**
 * ta 分派：arch_emit_section_text
 */
int32_t backend_arch_emit_section_text(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_section_text(out);
  if (ta == 2)
    return arch_riscv64_emit_section_text(out);
  return arch_x86_64_emit_section_text(out);
}

/**
 * ta 分派：arch_emit_globl
 */
int32_t backend_arch_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_globl(out, name, name_len);
  if (ta == 2)
    return arch_riscv64_emit_globl(out, name, name_len);
  return arch_x86_64_emit_globl(out, name, name_len);
}

/**
 * ta 分派：arch_emit_prologue
 */
int32_t backend_arch_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_prologue(out, frame_sz);
  if (ta == 2)
    return arch_riscv64_emit_prologue(out, frame_sz);
  return arch_x86_64_emit_prologue(out, frame_sz);
}

/**
 * ta 分派：arch_emit_epilogue
 */
int32_t backend_arch_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_epilogue(out, frame_sz);
  if (ta == 2)
    return arch_riscv64_emit_epilogue(out, frame_sz);
  return arch_x86_64_emit_epilogue(out, frame_sz);
}


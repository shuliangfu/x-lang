/* G-02f-9 / R2 full（2026-07-14）：backend_arch_emit_dispatch 真迁
 * Logic source: src/asm/backend_arch_emit_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(full.x) + rest (-DSHUX_BACKEND_ARCH_EMIT_DISPATCH_FROM_X) ld -r
 *   → src/asm/backend_arch_emit_dispatch.o
 * R2: full.x 吃满 47 ta 分派壳；FROM_X 下 rest 业务 T=0（仅 slice_marker）
 * 冷启动/无 PREFER：本文件完整 C 体（含 L2 thin hybrid 的 public 体）
 * L2 thin hybrid（SHUX_L2_ARCH_EMIT_THIN_FROM_X）仍作 full.x 失败时的回退路径。
 * Cap residual: arch_*_emit_* 在 asm_backend_partial / 其它 TU。
 *
 * seeds/backend_arch_emit_dispatch.from_x.c — product arch_emit dispatch TU (cold full C)
 */
#ifndef SHUX_BACKEND_ARCH_EMIT_DISPATCH_FROM_X
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
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifdef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) ;
int32_t backend_arch_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi, int32_t ta) ;
int32_t backend_arch_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) ;
int32_t backend_arch_emit_neg_eax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc, int32_t ta) ;
int32_t backend_arch_emit_push_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_pop_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_pop_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) ;
int32_t backend_arch_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) ;
int32_t backend_arch_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) ;
int32_t backend_arch_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz, int32_t ta) ;
int32_t backend_arch_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) ;
int32_t backend_arch_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t offset, int32_t store_size, int32_t ta) ;
int32_t backend_arch_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k, int32_t ta) ;
int32_t backend_arch_emit_ldr_sp_offset_to_wi(struct codegen_CodegenOutBuf *out, int32_t i, int32_t ta) ;
int32_t backend_arch_emit_add_sp_imm(struct codegen_CodegenOutBuf *out, int32_t n, int32_t ta) ;
int32_t backend_arch_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) ;
int32_t backend_arch_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) ;
int32_t backend_arch_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) ;
int32_t backend_arch_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) ;
int32_t backend_arch_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) ;
int32_t backend_arch_emit_not_eax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) ;
int32_t backend_arch_emit_section_text(struct codegen_CodegenOutBuf *out, int32_t ta) ;
int32_t backend_arch_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) ;
int32_t backend_arch_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta) ;
int32_t backend_arch_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta) ;
#endif

#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_ret_imm32(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_ret_imm32(out, imm);
  if (ta == 2)
    return arch_riscv64_emit_ret_imm32(out, imm);
  return arch_x86_64_emit_ret_imm32(out, imm);
}
#endif

/**
 * ta 分派：arch_emit_mov_imm64_to_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_mov_imm64_to_rax(struct codegen_CodegenOutBuf *out, int32_t lo, int32_t hi, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_imm64_to_rax(out, lo, hi);
  if (ta == 2)
    return arch_riscv64_emit_mov_imm64_to_rax(out, lo, hi);
  return arch_x86_64_emit_mov_imm64_to_rax(out, lo, hi);
}
#endif

/**
 * ta 分派：arch_emit_mov_imm32_to_rbx
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_mov_imm32_to_rbx(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_imm32_to_rbx(out, imm);
  if (ta == 2)
    return arch_riscv64_emit_mov_imm32_to_rbx(out, imm);
  return arch_x86_64_emit_mov_imm32_to_rbx(out, imm);
}
#endif

/**
 * ta 分派：arch_emit_neg_eax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_neg_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_neg_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_neg_eax(out);
  return arch_x86_64_emit_neg_eax(out);
}
#endif

/**
 * ta 分派：arch_emit_cmp_rbx_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_cmp_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_cmp_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_cmp_rbx_rax(out);
  return arch_x86_64_emit_cmp_rbx_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_cmp_setcc
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_cmp_setcc(struct codegen_CodegenOutBuf *out, int32_t cc, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_cmp_setcc(out, cc);
  if (ta == 2)
    return arch_riscv64_emit_cmp_setcc(out, cc);
  return arch_x86_64_emit_cmp_setcc(out, cc);
}
#endif

/**
 * ta 分派：arch_emit_push_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_push_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_push_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_push_rax(out);
  return arch_x86_64_emit_push_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_pop_rbx
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_pop_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_pop_rbx(out);
  if (ta == 2)
    return arch_riscv64_emit_pop_rbx(out);
  return arch_x86_64_emit_pop_rbx(out);
}
#endif

/**
 * ta 分派：arch_emit_pop_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_pop_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_pop_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_pop_rax(out);
  return arch_x86_64_emit_pop_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_add_rax_rbx
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_add_rax_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_add_rax_rbx(out);
  if (ta == 2)
    return arch_riscv64_emit_add_rax_rbx(out);
  return arch_x86_64_emit_add_rax_rbx(out);
}
#endif

/**
 * ta 分派：arch_emit_sub_rbx_rax_then_mov
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_sub_rbx_rax_then_mov(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_sub_rbx_rax_then_mov(out);
  if (ta == 2)
    return arch_riscv64_emit_sub_rbx_rax_then_mov(out);
  return arch_x86_64_emit_sub_rbx_rax_then_mov(out);
}
#endif

/**
 * ta 分派：arch_emit_imul_rbx_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_imul_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_imul_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_imul_rbx_rax(out);
  return arch_x86_64_emit_imul_rbx_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_mov_rax_to_rbx
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_rax_to_rbx(out);
  if (ta == 2)
    return arch_riscv64_emit_mov_rax_to_rbx(out);
  return arch_x86_64_emit_mov_rax_to_rbx(out);
}
#endif

/**
 * ta 分派：arch_emit_load_rbp_to_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_rbp_to_rax(out, off);
  if (ta == 2)
    return arch_riscv64_emit_load_rbp_to_rax(out, off);
  return arch_x86_64_emit_load_rbp_to_rax(out, off);
}
#endif

/**
 * ta 分派：arch_emit_store_rax_to_rbp
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_store_rax_to_rbp(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_store_rax_to_rbp(out, off);
  if (ta == 2)
    return arch_riscv64_emit_store_rax_to_rbp(out, off);
  return arch_x86_64_emit_store_rax_to_rbp(out, off);
}
#endif

/**
 * ta 分派：arch_emit_lea_rbp_to_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_lea_rbp_to_rax(out, off);
  if (ta == 2)
    return arch_riscv64_emit_lea_rbp_to_rax(out, off);
  return arch_x86_64_emit_lea_rbp_to_rax(out, off);
}
#endif

/**
 * ta 分派：arch_emit_rax_plus_rbx_scale4
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_rax_plus_rbx_scale4(out);
  if (ta == 2)
    return arch_riscv64_emit_rax_plus_rbx_scale4(out);
  return arch_x86_64_emit_rax_plus_rbx_scale4(out);
}
#endif

/**
 * ta 分派：arch_emit_rax_plus_rbx_scale1
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_rax_plus_rbx_scale1(out);
  if (ta == 2)
    return arch_riscv64_emit_rax_plus_rbx_scale1(out);
  return arch_x86_64_emit_rax_plus_rbx_scale1(out);
}
#endif

/**
 * ta 分派：arch_emit_rax_plus_rbx_scale8
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_rax_plus_rbx_scale8(out);
  if (ta == 2)
    return arch_riscv64_emit_rax_plus_rbx_scale8(out);
  return arch_x86_64_emit_rax_plus_rbx_scale8(out);
}
#endif

/**
 * ta 分派：arch_emit_store_rax_to_rbx_indirect
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_store_rax_to_rbx_indirect(struct codegen_CodegenOutBuf *out, int32_t elem_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_store_rax_to_rbx_indirect(out, elem_sz);
  if (ta == 2)
    return arch_riscv64_emit_store_rax_to_rbx_indirect(out, elem_sz);
  return arch_x86_64_emit_store_rax_to_rbx_indirect(out, elem_sz);
}
#endif

/**
 * ta 分派：arch_emit_load_32_from_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_load_32_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_32_from_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_load_32_from_rax(out);
  return arch_x86_64_emit_load_32_from_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_load_zext8_from_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_load_zext8_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_zext8_from_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_load_zext8_from_rax(out);
  return arch_x86_64_emit_load_zext8_from_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_add_imm_to_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_add_imm_to_rax(out, imm);
  if (ta == 2)
    return arch_riscv64_emit_add_imm_to_rax(out, imm);
  return arch_x86_64_emit_add_imm_to_rax(out, imm);
}
#endif

/**
 * ta 分派：arch_emit_load_64_from_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_load_64_from_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_load_64_from_rax(out);
  return arch_x86_64_emit_load_64_from_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_store_rax_to_rbx_offset
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_store_rax_to_rbx_offset(struct codegen_CodegenOutBuf *out, int32_t offset, int32_t store_size, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_store_rax_to_rbx_offset(out, offset, store_size);
  if (ta == 2)
    return arch_riscv64_emit_store_rax_to_rbx_offset(out, offset, store_size);
  return arch_x86_64_emit_store_rax_to_rbx_offset(out, offset, store_size);
}
#endif

/**
 * ta 分派：arch_emit_mov_rbx_to_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_mov_rbx_to_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_mov_rbx_to_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_mov_rbx_to_rax(out);
  return arch_x86_64_emit_mov_rbx_to_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_mov_rax_to_arg_reg
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_mov_rax_to_arg_reg(struct codegen_CodegenOutBuf *out, int32_t k, int32_t ta) {
  if (ta == 1)
    return 0;
  if (ta == 2)
    return arch_riscv64_emit_mov_rax_to_arg_reg(out, k);
  return arch_x86_64_emit_mov_rax_to_arg_reg(out, k);
}
#endif

/**
 * ta 分派：arch_emit_ldr_sp_offset_to_wi
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_ldr_sp_offset_to_wi(struct codegen_CodegenOutBuf *out, int32_t i, int32_t ta) {
  if (ta != 1)
    return 0;
  return arch_arm64_emit_ldr_sp_offset_to_wi(out, i);
}
#endif

/**
 * ta 分派：arch_emit_add_sp_imm
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_add_sp_imm(struct codegen_CodegenOutBuf *out, int32_t n, int32_t ta) {
  if (ta != 1)
    return 0;
  return arch_arm64_emit_add_sp_imm(out, n);
}
#endif

/**
 * ta 分派：arch_emit_call
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_call(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_call(out, name, name_len);
  if (ta == 2)
    return arch_riscv64_emit_call(out, name, name_len);
  return arch_x86_64_emit_call(out, name, name_len);
}
#endif

/**
 * ta 分派：arch_emit_jz
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_jz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jz(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jz(out, label, label_len);
  return arch_x86_64_emit_jz(out, label, label_len);
}
#endif

/**
 * ta 分派：arch_emit_jeq
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_jeq(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jeq(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jeq(out, label, label_len);
  return arch_x86_64_emit_jeq(out, label, label_len);
}
#endif

/**
 * ta 分派：arch_emit_jmp
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_jmp(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jmp(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jmp(out, label, label_len);
  return arch_x86_64_emit_jmp(out, label, label_len);
}
#endif

/**
 * ta 分派：arch_emit_jnz
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_jnz(struct codegen_CodegenOutBuf *out, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_jnz(out, label, label_len);
  if (ta == 2)
    return arch_riscv64_emit_jnz(out, label, label_len);
  return arch_x86_64_emit_jnz(out, label, label_len);
}
#endif

/**
 * ta 分派：arch_emit_not_eax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_not_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_not_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_not_eax(out);
  return arch_x86_64_emit_not_eax(out);
}
#endif

/**
 * ta 分派：arch_emit_and_rbx_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_and_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_and_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_and_rbx_rax(out);
  return arch_x86_64_emit_and_rbx_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_or_rbx_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_or_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_or_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_or_rbx_rax(out);
  return arch_x86_64_emit_or_rbx_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_xor_rbx_rax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_xor_rbx_rax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_xor_rbx_rax(out);
  if (ta == 2)
    return arch_riscv64_emit_xor_rbx_rax(out);
  return arch_x86_64_emit_xor_rbx_rax(out);
}
#endif

/**
 * ta 分派：arch_emit_mov_rbx_to_ecx
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_mov_rbx_to_ecx(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return 0;
  if (ta == 2)
    return arch_riscv64_emit_mov_rbx_to_ecx(out);
  return arch_x86_64_emit_mov_rbx_to_ecx(out);
}
#endif

/**
 * ta 分派：arch_emit_shl_cl_eax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_shl_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_shl_cl_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_shl_cl_eax(out);
  return arch_x86_64_emit_shl_cl_eax(out);
}
#endif

/**
 * ta 分派：arch_emit_shr_cl_eax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_shr_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_shr_cl_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_shr_cl_eax(out);
  return arch_x86_64_emit_shr_cl_eax(out);
}
#endif

/**
 * ta 分派：arch_emit_sar_cl_eax
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_sar_cl_eax(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_sar_cl_eax(out);
  if (ta == 2)
    return arch_riscv64_emit_sar_cl_eax(out);
  return arch_x86_64_emit_sar_cl_eax(out);
}
#endif

/**
 * ta 分派：arch_emit_label
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_label(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_label(out, name, name_len);
  if (ta == 2)
    return arch_riscv64_emit_label(out, name, name_len);
  return arch_x86_64_emit_label(out, name, name_len);
}
#endif

/**
 * ta 分派：arch_emit_section_text
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_section_text(struct codegen_CodegenOutBuf *out, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_section_text(out);
  if (ta == 2)
    return arch_riscv64_emit_section_text(out);
  return arch_x86_64_emit_section_text(out);
}
#endif

/**
 * ta 分派：arch_emit_globl
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_globl(struct codegen_CodegenOutBuf *out, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_globl(out, name, name_len);
  if (ta == 2)
    return arch_riscv64_emit_globl(out, name, name_len);
  return arch_x86_64_emit_globl(out, name, name_len);
}
#endif

/**
 * ta 分派：arch_emit_prologue
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_prologue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_prologue(out, frame_sz);
  if (ta == 2)
    return arch_riscv64_emit_prologue(out, frame_sz);
  return arch_x86_64_emit_prologue(out, frame_sz);
}
#endif

/**
 * ta 分派：arch_emit_epilogue
 */
/* G-02f-209：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_ARCH_EMIT_THIN_FROM_X
int32_t backend_arch_emit_epilogue(struct codegen_CodegenOutBuf *out, int32_t frame_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_emit_epilogue(out, frame_sz);
  if (ta == 2)
    return arch_riscv64_emit_epilogue(out, frame_sz);
  return arch_x86_64_emit_epilogue(out, frame_sz);
}
#endif

int backend_arch_emit_dispatch_slice_marker(void) {
    return 1;
}

#else /* SHUX_BACKEND_ARCH_EMIT_DISPATCH_FROM_X：产品 rest 业务 H=0 */
int backend_arch_emit_dispatch_slice_marker(void) {
  return 0;
}
#endif /* SHUX_BACKEND_ARCH_EMIT_DISPATCH_FROM_X */

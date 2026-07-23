/* G-02f-9 / R2 full（2026-07-14）：backend_enc_dispatch 真迁
 * Logic source: src/asm/backend_enc_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(full.x) + rest (-DXLANG_BACKEND_ENC_DISPATCH_FROM_X) ld -r
 *   → src/asm/backend_enc_dispatch.o
 * R2: full.x 吃满 enc/ta 公共业务；FROM_X 下 rest 业务 T=0（仅 slice_marker）
 * 冷启动/无 PREFER：本文件完整 C 体（含 L2 thin hybrid 的 _impl 尾）
 * L2 thin hybrid（XLANG_L2_ENC_DISPATCH_THIN_FROM_X）仍作 full.x 失败时的回退路径。
 *
 * seeds/backend_enc_dispatch.from_x.c — product backend enc dispatch TU (cold full C)
 */
#ifndef XLANG_BACKEND_ENC_DISPATCH_FROM_X
/* G-02f-352～361 / R2 thin full：PREFER hybrid thin 由 src/asm/backend_enc_dispatch_thin.x；
 * rest XLANG_L2_ENC_DISPATCH_THIN_FROM_X（public 门闩→_impl；slice_marker + Cap residual 体）。
 * seeds/backend_enc_dispatch.from_x.c — G-02f-208 enc_dispatch *_arch closed; G-02f-9 product TU
 * G-02f-130 true .x pure helpers.
 * G-02f-127 true .x pure helpers.
 * G-02f-100/101 enc helper gates.
 * Source intent: src/asm/backend_enc_dispatch.x (doc) + this seed (full C body).
 * Product: → src/asm/backend_enc_dispatch.o.
 * Cap residual: *_impl / enc C 尾 in rest.
 */
/**
 * backend_enc_dispatch.c — backend_enc_*_arch 的 C 侧 ta 分派
 *
 * M8 自举：backend.x 中 enc_*_arch 改为单行委托本 TU，避免 X if(ta) 真 emit 产生未绑定 .LfN_ 跳转。
 * 依赖 asm_backend_partial.o 导出的 arch_*_enc_enc_* 符号。
 */
#include <xlang_weak.h>
#include <stdint.h>
#include <string.h>

struct platform_elf_ElfCodegenCtx;

#ifdef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_arm64_add_sp_imm12_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
int32_t backend_enc_arm64_sub_sp_imm12_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm);
int32_t backend_enc_arm64_str_x0_sp_offset_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes);
int32_t arm64_enc_load_w0_from_rbp_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
int32_t arm64_enc_store_w0_to_rbp_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
#define arch_arm64_enc_enc_call arch_arm64_enc_enc_call_impl
#define arch_arm64_enc_enc_add_sp_imm12 arch_arm64_enc_enc_add_sp_imm12_impl
#define arch_arm64_enc_enc_sub_sp_imm12 arch_arm64_enc_enc_sub_sp_imm12_impl
#define arch_arm64_enc_enc_str_x0_sp_offset arch_arm64_enc_enc_str_x0_sp_offset_impl
#define arch_riscv64_enc_enc_call arch_riscv64_enc_enc_call_impl
#define arch_riscv64_enc_enc_mov_rax_to_arg_reg arch_riscv64_enc_enc_mov_rax_to_arg_reg_impl
int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_push_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_pop_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_epilogue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_sub_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_imul_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_not_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_and_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_or_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_xor_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_mov_rbx_to_ecx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_neg_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_test_eax_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_test_rbx_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_shl_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_shr_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_sar_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_shl_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_shr_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_sar_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_setz_movzbl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cmp_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_sub_rbx_rax_then_mov_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cmp_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_div_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_prologue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_sz, int32_t ta);
int32_t backend_enc_ret_imm32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta);
int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta);
int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
int32_t backend_enc_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_lea_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_rax_plus_rbx_scale1_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rax_plus_rbx_scale4_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rax_plus_rbx_scale8_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_load_zext8_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_add_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func, int32_t ta);
int32_t backend_enc_store_rax_to_rbx_indirect_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz, int32_t ta);
int32_t backend_enc_load_32_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_load_i32_indirect_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_load_rbp_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_load_64_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size, int32_t ta);
int32_t backend_enc_mov_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_jz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_jeq_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_jnz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_jne_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_rem_mod_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rem_mod_unsigned_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_call_stack_cleanup_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes, int32_t ta);
int32_t backend_enc_call_stack_reserve_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes, int32_t ta);
int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes, int32_t ta);
int32_t backend_enc_store_x_reg_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg, int32_t offset, int32_t ta);
int32_t backend_enc_load_qword_from_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_load_qword_rbx8_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_store_rdx_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_index_scratch_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_index_scratch_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_index_scratch_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rbx_index_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rbx_index_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rbx_index_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_index_scratch_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_rbx_index_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
int32_t backend_enc_load_rbp_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_mov_rdx_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_mov_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_load_rbp_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos, int32_t ta);
int32_t backend_enc_rbx_plus_index_scratch_scaled_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz, int32_t ta);
int32_t backend_enc_load_rbp_lane_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t esz, int32_t ta);
int32_t backend_enc_jle_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_jl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
int32_t backend_enc_load_x29_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos, int32_t ta);
int32_t backend_enc_add_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_load_rbp_index_secondary_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_sub_imm_from_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_mul_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit, int32_t ta);
int32_t backend_enc_mul_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit, int32_t ta);
int32_t backend_enc_add_imm_to_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_sub_imm_from_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_load_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
int32_t backend_enc_load_rbp_lane_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t esz, int32_t ta);
int32_t backend_enc_addss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_mulss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_subss_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_subss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_divss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvttsd2si_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax → truncated i64 in rax (REX.W cvttss2si); freestanding `as i64/u64` (wave303). */
int32_t backend_enc_cvttss2si_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f64 bits in rax → truncated i64 in rax (REX.W cvttsd2si); freestanding `as i64/u64` (wave303). */
int32_t backend_enc_cvttsd2si_rax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvtsi2ss_eax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** u64 in rax → f32 bits in eax (unsigned seq); freestanding `as f32` when >2^63-1 (wave304). */
int32_t backend_enc_cvtsi2ss_eax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvtsi2sd_rax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvtsi2sd_rax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** u64 in rax → f64 bits in rax (unsigned seq); freestanding `as f64` when >2^63-1 (wave304). */
int32_t backend_enc_cvtsi2sd_rax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta);
int32_t backend_enc_addsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_subsd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_subsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_mulsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_divsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_ucomisd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
int32_t backend_enc_fp_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
int32_t backend_enc_store_eax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta);
#endif

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
extern int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                              int32_t imm_bits);
extern int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);

/**
 * x86_64 条件跳转 rel32：0F opcode2 00 00 00 00 + patch（与 x86_64_enc.x enc_jle/enc_jl 一致）。
 * 供 pipeline_glue LCG 计数循环；bootstrap partial.o 未导出 enc_jle/enc_jl 时用 C 路由。
 */
/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-419：实现体始终 seed；public PREFER 时 thin pure forward */
int32_t backend_enc_x86_jcc_rel32_c_impl(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t opcode2,
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
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_x86_jcc_rel32_c(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t opcode2,
                                           uint8_t *label, int32_t label_len) {
  return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, opcode2, label, label_len);
}
#endif

/* G-02f-127：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-419：实现体始终 seed；public PREFER 时 thin pure forward */
int32_t backend_enc_append_u32_le_c_impl(struct platform_elf_ElfCodegenCtx *elf_ctx, uint32_t word) {
  uint8_t buf[4];
  if (!elf_ctx)
    return -1;
  buf[0] = (uint8_t)(word & 255u);
  buf[1] = (uint8_t)((word >> 8) & 255u);
  buf[2] = (uint8_t)((word >> 16) & 255u);
  buf[3] = (uint8_t)((word >> 24) & 255u);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, buf, 4);
}

#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_append_u32_le_c(struct platform_elf_ElfCodegenCtx *elf_ctx, uint32_t word) {
  return backend_enc_append_u32_le_c_impl(elf_ctx, word);
}
#endif

/* G-02f-361：单字节 append，供 thin f32/xmm / store_eax 无 static 数组路径 */
/* G-02f-419：实现体始终 seed；public PREFER 时 thin pure forward */
int32_t backend_enc_append_u8_c_impl(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t byte) {
  uint8_t b;
  if (!elf_ctx)
    return -1;
  b = (uint8_t)(byte & 255);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, &b, 1);
}

#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_append_u8_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t byte) {
  return backend_enc_append_u8_c_impl(elf_ctx, byte);
}
#endif




/* G-02f-146：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-419：实现体始终 seed；public PREFER 时 thin pure forward */
int32_t backend_enc_arm64_call_c_impl(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len) {
  uint8_t reloc_name[64];
  int32_t at;
  int32_t reloc_len;
  int32_t i;
  int32_t macho_leading_underscore;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  if (backend_enc_append_u32_le_c_impl(elf_ctx, 0x94000000u) != 0)
    return -1;
  at = pipeline_elf_ctx_emit_code_len((uint8_t *)elf_ctx) - 4;
  if (at < 0)
    return -1;
  macho_leading_underscore = *(int32_t *)((uint8_t *)elf_ctx + 598052);
  if (macho_leading_underscore != 0 && name_len <= 63 && name[0] != (uint8_t)'_') {
    reloc_name[0] = (uint8_t)'_';
    for (i = 0; i < name_len && i < 63; i++)
      reloc_name[i + 1] = name[i];
    reloc_len = name_len + 1;
    return pipeline_elf_ctx_append_reloc((uint8_t *)elf_ctx, at, reloc_name, reloc_len);
  }
  return pipeline_elf_ctx_append_reloc((uint8_t *)elf_ctx, at, name, name_len);
}
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_arm64_call_c(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len) {
  return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len);
}
#endif

/* G-02f-127：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_arm64_add_sp_imm12_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  int32_t imm12;
  if (!elf_ctx)
    return -1;
  if (imm <= 0)
    return 0;
  imm12 = imm;
  if (imm12 > 4095)
    imm12 = 4095;
  return backend_enc_append_u32_le_c_impl(elf_ctx, 0x910003ffu | ((uint32_t)imm12 << 10));
}
#endif

/* G-02f-127：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_arm64_sub_sp_imm12_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  int32_t imm12;
  if (!elf_ctx)
    return -1;
  if (imm <= 0)
    return 0;
  imm12 = imm;
  if (imm12 > 4095)
    imm12 = 4095;
  return backend_enc_append_u32_le_c_impl(elf_ctx, 0xd10003ffu | ((uint32_t)imm12 << 10));
}
#endif

/* G-02f-127：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_arm64_str_x0_sp_offset_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes) {
  int32_t off;
  int32_t imm12;
  if (!elf_ctx)
    return -1;
  off = off_bytes;
  if (off < 0)
    off = 0;
  imm12 = off >> 3;
  if (imm12 > 4095)
    imm12 = 4095;
  return backend_enc_append_u32_le_c_impl(elf_ctx, 0xf90003e0u | ((uint32_t)imm12 << 10));
}
#endif





/** x86_64 cdqe；定义见本文件末尾。 */
int32_t arch_x86_64_enc_enc_cdqe_rax_impl(struct platform_elf_ElfCodegenCtx *elf_ctx);

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
extern int32_t arch_x86_64_enc_enc_sub_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
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
extern int32_t arch_arm64_enc_enc_cmp_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_cmp_rax_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
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
extern int32_t arch_x86_64_enc_enc_shl_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_shr_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_sar_cl_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_xor_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_div_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_store_rdx_to_rbp(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_rdx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_mov_rdx_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k);


/*
 * B-strict glue links this dispatch TU on x86_64 without always linking the
 * full arm64/riscv64 encoder objects. Keep non-host arch helpers weak so the
 * host link can resolve them; real encoder objects override these definitions.
 */
XLANG_WEAK int32_t arch_arm64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len) {
  return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len);
}

XLANG_WEAK int32_t arch_arm64_enc_enc_add_sp_imm12(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  return backend_enc_arm64_add_sp_imm12_c(elf_ctx, imm);
}

XLANG_WEAK int32_t arch_arm64_enc_enc_sub_sp_imm12(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm) {
  return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, imm);
}

XLANG_WEAK int32_t arch_arm64_enc_enc_str_x0_sp_offset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes) {
  return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
}

XLANG_WEAK int32_t arch_riscv64_enc_enc_call(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len) {
  (void)elf_ctx;
  (void)name;
  (void)name_len;
  return -1;
}

XLANG_WEAK int32_t arch_riscv64_enc_enc_mov_rax_to_arg_reg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k) {
  (void)elf_ctx;
  (void)k;
  return -1;
}
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
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_func, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_label(elf_ctx, name, name_len, is_func);
  if (ta == 2)
    return arch_riscv64_enc_enc_label(elf_ctx, name, name_len, is_func);
  return arch_x86_64_enc_enc_label(elf_ctx, name, name_len, is_func);
}
#endif


/**
 * ta 分派：enc_prologue_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_prologue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_prologue(elf_ctx, frame_sz);
  if (ta == 2)
    return arch_riscv64_enc_enc_prologue(elf_ctx, frame_sz);
  return arch_x86_64_enc_enc_prologue(elf_ctx, frame_sz);
}
#endif


/**
 * ta 分派：enc_epilogue_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_epilogue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_epilogue(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_epilogue(elf_ctx);
  return arch_x86_64_enc_enc_epilogue(elf_ctx);
}
#endif


/**
 * ta 分派：enc_ret_imm32_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_ret_imm32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_ret_imm32(elf_ctx, imm32);
  if (ta == 2)
    return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32);
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
}
#endif


/**
 * ta 分派：enc_mov_imm32_to_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  return arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
}
#endif


/**
 * ta 分派：enc_mov_imm64_to_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  return arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
}
#endif


/**
 * ta 分派：enc_push_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_push_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_push_rax(elf_ctx);
  return arch_x86_64_enc_enc_push_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_push_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_push_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_push_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_push_rbx(elf_ctx);
  return arch_x86_64_enc_enc_push_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_pop_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_pop_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_pop_rax(elf_ctx);
  return arch_x86_64_enc_enc_pop_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_pop_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_pop_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_pop_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_pop_rbx(elf_ctx);
  return arch_x86_64_enc_enc_pop_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_add_rax_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_add_rax_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_rax_rbx(elf_ctx);
  return arch_x86_64_enc_enc_add_rax_rbx(elf_ctx);
}
#endif


/**
 * x86：标量 f32 加法 addss（eax/rbx 低 32 位为 IEEE754 单精度，结果回 eax）。
 * movd xmm0,eax; movd xmm1,ebx; addss xmm0,xmm1; movd eax,xmm0
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * x86：标量 f32 乘法 mulss（eax/rbx 低 32 位为 IEEE754 单精度，结果回 eax）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `a * b` for f32 (wave294 Cap residual).
 * Root: glue MUL only emitted mulsd when both sides scalar f64; pure f32 fell to imul
 * of IEEE bits → freestanding run=0 (mac host-gcc hid). G.7 next to addss/mulsd.
 * Encoding: movd xmm0,eax; movd xmm1,ebx; mulss xmm0,xmm1 (F3 0F 59 C1); movd eax,xmm0.
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mulss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t movd_xmm1_ebx[4] = {0x66, 0x0f, 0x6e, 0xcb};
  static const uint8_t mulss_xmm0_xmm1[4] = {0xf3, 0x0f, 0x59, 0xc1};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm1_ebx, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)mulss_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}
#endif

/**
 * x86: scalar f32 sub left(rbx)-right(rax) → eax (subss).
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 * Root: glue SUB only emitted subsd when both scalar f64; pure f32 fell to integer sub
 * of IEEE bits → freestanding run=0 (mac host-gcc hid). G.7 next to addss/mulss/subsd.
 * Encoding: movd xmm0,ebx; movd xmm1,eax; subss xmm0,xmm1 (F3 0F 5C C1); movd eax,xmm0.
 */
/* G-02f-208: logic source .x (true migrate); seed keeps same semantics for product cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_subss_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_ebx[4] = {0x66, 0x0f, 0x6e, 0xc3};
  static const uint8_t movd_xmm1_eax[4] = {0x66, 0x0f, 0x6e, 0xc8};
  static const uint8_t subss_xmm0_xmm1[4] = {0xf3, 0x0f, 0x5c, 0xc1};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_ebx, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm1_eax, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)subss_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}
#endif

/**
 * x86: scalar f32 sub left(rax)-right(rbx) → eax (subss).
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `-` (wave298 Cap residual pure).
 * G.7 twin of subss_rbx_rax / subsd_rax_rbx conventions.
 * Encoding: movd xmm0,eax; movd xmm1,ebx; subss xmm0,xmm1; movd eax,xmm0.
 */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_subss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t movd_xmm1_ebx[4] = {0x66, 0x0f, 0x6e, 0xcb};
  static const uint8_t subss_xmm0_xmm1[4] = {0xf3, 0x0f, 0x5c, 0xc1};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm1_ebx, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)subss_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}
#endif

/**
 * x86: scalar f32 div left(rax)/right(rbx) → eax (divss).
 * PLATFORM: LINUX+MACOS x86_64 — freestanding f32 `/` (wave298 Cap residual pure).
 * Root: glue DIV only emitted divsd when both scalar f64; pure f32 fell to idiv
 * of IEEE bits → freestanding run=0 (mac host-gcc hid). G.7 next to mulss/divsd.
 * Encoding: movd xmm0,eax; movd xmm1,ebx; divss xmm0,xmm1 (F3 0F 5E C1); movd eax,xmm0.
 * IEEE Inf/NaN on /0 (no integer div-zero panic).
 */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_divss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t movd_xmm1_ebx[4] = {0x66, 0x0f, 0x6e, 0xcb};
  static const uint8_t divss_xmm0_xmm1[4] = {0xf3, 0x0f, 0x5e, 0xc1};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm1_ebx, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)divss_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}
#endif

/**
 * x86：eax 中 f32 位型截断为 i32（cvttss2si）；输入/输出均在 eax。
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvttss2si_eax_xmm0[4] = {0xf3, 0x0f, 0x2c, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvttss2si_eax_xmm0, 4);
}
#endif

/**
 * x86：rax 中 f64 位型截断为 i32 到 eax（cvttsd2si）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `return (f64_expr) as i32`.
 * Root: without this, EXPR_AS f64→i32 only re-emitted IEEE bits; low 32 of many
 * finite doubles is 0 (e.g. 6.0 / 42.0) → process exit 0 (wave291 Cap residual).
 * Encoding: movq xmm0,rax (66 REX.W 0F 6E C0) ; cvttsd2si eax,xmm0 (F2 0F 2C C0).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvttsd2si_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvttsd2si_eax_xmm0[4] = {0xf2, 0x0f, 0x2c, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvttsd2si_eax_xmm0, 4);
}
#endif

/**
 * x86：eax 中 f32 位型截断为 i64 到 rax（REX.W cvttss2si）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `return (f32) as i64/u64/usize/isize` (wave303).
 * Root: EXPR_AS only wired f32→i32 (eax form); 64-bit targets re-emitted IEEE bits → run=0.
 * Encoding: movd xmm0,eax (66 0F 6E C0) ; cvttss2si rax,xmm0 (F3 48 0F 2C C0).
 * Note: ISA is signed convert; values outside i64 range leave-off (same class as int→float).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvttss2si_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvttss2si_rax_xmm0[5] = {0xf3, 0x48, 0x0f, 0x2c, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvttss2si_rax_xmm0, 5);
}
#endif

/**
 * x86：rax 中 f64 位型截断为 i64 到 rax（REX.W cvttsd2si）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `return (f64) as i64/u64/usize/isize` (wave303).
 * Root: only f64→i32 eax form existed; 64-bit targets re-emitted bits → freestanding run=0.
 * Encoding: movq xmm0,rax (66 REX.W 0F 6E C0) ; cvttsd2si rax,xmm0 (F2 48 0F 2C C0).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvttsd2si_rax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvttsd2si_rax_xmm0[5] = {0xf2, 0x48, 0x0f, 0x2c, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvttsd2si_rax_xmm0, 5);
}
#endif

/**
 * x86：rax 中 f64 位型收窄为 f32 位型到 eax（cvtsd2ss）；SysV 形参槽存 f64、用 f32 须转换。
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * x86：eax 中 i32 转为 f32 位型写回 eax（cvtsi2ss）；return v.len as f32 等。
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t cvtsi2ss_xmm0_eax[4] = {0xf3, 0x0f, 0x2a, 0xc0};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtsi2ss_xmm0_eax, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}
#endif

/**
 * x86：rax 中 i64/u64（i64 范围内）转为 f32 位型写回 eax（REX.W cvtsi2ss）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `let b: f32 = a as f32` from u64/i64 (wave299).
 * Root: TYPE_U64/i64/usize/isize missing from EXPR_AS→f32; 32-bit cvtsi2ss xmm0,eax is wrong
 * for full 64-bit source (same class as wave295 u64→f64). G.7 next to cvtsi2ss i32 / cvtsi2sd i64.
 * Encoding: cvtsi2ss xmm0,rax (F3 48 0F 2A C0) ; movd eax,xmm0 (66 0F 7E C0).
 * Note: ISA is signed convert; values >2^63-1 need a separate unsigned sequence (leave-off).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtsi2ss_eax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t cvtsi2ss_xmm0_rax[5] = {0xf3, 0x48, 0x0f, 0x2a, 0xc0};
  static const uint8_t movd_eax_xmm0[4] = {0x66, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtsi2ss_xmm0_rax, 5) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_eax_xmm0, 4);
}
#endif

/**
 * x86：eax 中 i32 转为 f64 位型写回 rax（cvtsi2sd）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `let b: f64 = a as f64` (wave292).
 * Root: without this, EXPR_AS i32→f64 re-emitted integer bits; mulsd treated
 * denormals → freestanding run=0 (mac host-gcc -o hid). G.7 next to cvtsi2ss.
 * Encoding: cvtsi2sd xmm0,eax (F2 0F 2A C0) ; movq rax,xmm0 (66 REX.W 0F 7E C0).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtsi2sd_rax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t cvtsi2sd_xmm0_eax[4] = {0xf2, 0x0f, 0x2a, 0xc0};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtsi2sd_xmm0_eax, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}
#endif

/**
 * x86：rax 中 i64/u64（i64 范围内）转为 f64 位型写回 rax（REX.W cvtsi2sd）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `let b: f64 = a as f64` from u64/i64 (wave295).
 * Root: TYPE_U64 kind=4 missing from EXPR_AS→f64; 32-bit cvtsi2sd xmm0,eax is wrong for
 * full 64-bit source. G.7 next to cvtsi2sd i32 / cvtss2sd.
 * Encoding: cvtsi2sd xmm0,rax (F2 48 0F 2A C0) ; movq rax,xmm0 (66 REX.W 0F 7E C0).
 * Note: ISA is signed convert; values >2^63-1 need a separate unsigned sequence (leave-off).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtsi2sd_rax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t cvtsi2sd_xmm0_rax[5] = {0xf2, 0x48, 0x0f, 0x2a, 0xc0};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtsi2sd_xmm0_rax, 5) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}
#endif

/**
 * x86：rax 中 u64 无符号转为 f64 位型写回 rax（gcc/clang unsigned convert sequence）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `let b: f64 = a as f64` from u64/usize (wave304).
 * Root: REX.W cvtsi2sd is signed; high bit set → negative double → freestanding run=0.
 * Algorithm (matches gcc -O2 uint64_t→double):
 *   test rax,rax; jns .Lfit;
 *   mov rdx,rax; shr rdx,1; and eax,1; or rdx,rax;
 *   cvtsi2sd xmm0,rdx; addsd xmm0,xmm0; movq rax,xmm0; jmp .Ldone;
 *   .Lfit: cvtsi2sd xmm0,rax; movq rax,xmm0;
 * Fixed rel8 offsets: jns +28, jmp +10 (no labels / no second path).
 * G.7 next to signed backend_enc_cvtsi2sd_rax_from_i64_arch.
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtsi2sd_rax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  /* test; jns; high; jmp; fit — total 43 bytes; jns rel8=0x1c; jmp rel8=0x0a */
  static const uint8_t seq[43] = {
      0x48, 0x85, 0xc0,                   /* test rax,rax */
      0x79, 0x1c,                         /* jns +28 → .Lfit */
      0x48, 0x89, 0xc2,                   /* mov rdx,rax */
      0x48, 0xd1, 0xea,                   /* shr rdx,1 */
      0x83, 0xe0, 0x01,                   /* and eax,1 */
      0x48, 0x09, 0xc2,                   /* or rdx,rax */
      0xf2, 0x48, 0x0f, 0x2a, 0xc2,       /* cvtsi2sd xmm0,rdx */
      0xf2, 0x0f, 0x58, 0xc0,             /* addsd xmm0,xmm0 */
      0x66, 0x48, 0x0f, 0x7e, 0xc0,       /* movq rax,xmm0 */
      0xeb, 0x0a,                         /* jmp +10 → .Ldone */
      0xf2, 0x48, 0x0f, 0x2a, 0xc0,       /* .Lfit: cvtsi2sd xmm0,rax */
      0x66, 0x48, 0x0f, 0x7e, 0xc0        /* movq rax,xmm0 */
  };
  if (ta != 0 || !elf_ctx)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)seq, 43);
}
#endif

/**
 * x86：rax 中 u64 无符号转为 f32 位型写回 eax（unsigned convert sequence）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `let b: f32 = a as f32` from u64/usize (wave304).
 * Same algorithm as u64→f64 with cvtsi2ss/addss/movd. jns +27, jmp +9.
 * G.7 next to signed backend_enc_cvtsi2ss_eax_from_i64_arch.
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtsi2ss_eax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  /* test; jns; high; jmp; fit — total 41 bytes; jns rel8=0x1b; jmp rel8=0x09 */
  static const uint8_t seq[41] = {
      0x48, 0x85, 0xc0,                   /* test rax,rax */
      0x79, 0x1b,                         /* jns +27 → .Lfit */
      0x48, 0x89, 0xc2,                   /* mov rdx,rax */
      0x48, 0xd1, 0xea,                   /* shr rdx,1 */
      0x83, 0xe0, 0x01,                   /* and eax,1 */
      0x48, 0x09, 0xc2,                   /* or rdx,rax */
      0xf3, 0x48, 0x0f, 0x2a, 0xc2,       /* cvtsi2ss xmm0,rdx */
      0xf3, 0x0f, 0x58, 0xc0,             /* addss xmm0,xmm0 */
      0x66, 0x0f, 0x7e, 0xc0,             /* movd eax,xmm0 */
      0xeb, 0x09,                         /* jmp +9 → .Ldone */
      0xf3, 0x48, 0x0f, 0x2a, 0xc0,       /* .Lfit: cvtsi2ss xmm0,rax */
      0x66, 0x0f, 0x7e, 0xc0              /* movd eax,xmm0 */
  };
  if (ta != 0 || !elf_ctx)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)seq, 41);
}
#endif

/**
 * x86：eax 中 f32 位型扩展为 f64 位型写回 rax（cvtss2sd）。
 * PLATFORM: LINUX+MACOS x86_64 — freestanding `let y: f64 = x as f64` (wave293).
 * Root: without this, EXPR_AS f32→f64 re-emitted f32 bits; cvttsd2si/mulsd treated
 * those bits as IEEE f64 → freestanding run=0 (mac host-gcc hid). G.7 next to cvtsd2ss.
 * Encoding: movd xmm0,eax (66 0F 6E C0) ; cvtss2sd xmm0,xmm0 (F3 0F 5A C0) ;
 *           movq rax,xmm0 (66 REX.W 0F 7E C0).
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movd_xmm0_eax[4] = {0x66, 0x0f, 0x6e, 0xc0};
  static const uint8_t cvtss2sd_xmm0_xmm0[4] = {0xf3, 0x0f, 0x5a, 0xc0};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movd_xmm0_eax, 4) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cvtss2sd_xmm0_xmm0, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}
#endif

/**
 * x86：movd xmmK, eax（66 0F 6E C0+K*8）；SysV f32 实参写入 xmm0–xmm7。
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * x86：movd eax, xmmK（66 0F 7E C0+K*8）；SysV f32 形参从 xmm 落栈槽。
 */
/* G-02f-208：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — movq xmmK, rax (66 REX.W 0F 6E /r).
 * f64 bits in GPR → SSE arg/return register. Always in seed rest (not thin-gated).
 */
int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  static const uint8_t prefix[4] = {0x66, 0x48, 0x0f, 0x6e};
  uint8_t modrm;
  if (ta != 0 || !elf_ctx || k < 0 || k > 7)
    return -1;
  modrm = (uint8_t)(0xc0 | (k << 3));
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)prefix, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, &modrm, 1);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — movq rax, xmmK (66 REX.W 0F 7E /r).
 * Harvest f64 SysV return (xmm0) or param into internal rax-bits convention.
 */
int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  static const uint8_t prefix[4] = {0x66, 0x48, 0x0f, 0x7e};
  uint8_t modrm;
  if (ta != 0 || !elf_ctx || k < 0 || k > 7)
    return -1;
  modrm = (uint8_t)(0xc0 | (k << 3));
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)prefix, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, &modrm, 1);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — scalar f64 add: rax + rbx → rax (IEEE bits in GPRs).
 * movq xmm0,rax; movq xmm1,rbx; addsd xmm0,xmm1; movq rax,xmm0
 */
int32_t backend_enc_addsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t movq_xmm1_rbx[5] = {0x66, 0x48, 0x0f, 0x6e, 0xcb};
  static const uint8_t addsd_xmm0_xmm1[4] = {0xf2, 0x0f, 0x58, 0xc1};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm1_rbx, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)addsd_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — scalar f64 sub: rbx - rax → rax (left in rbx, right in rax).
 * movq xmm0,rbx; movq xmm1,rax; subsd xmm0,xmm1; movq rax,xmm0
 */
int32_t backend_enc_subsd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rbx[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc3};
  static const uint8_t movq_xmm1_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc8};
  static const uint8_t subsd_xmm0_xmm1[4] = {0xf2, 0x0f, 0x5c, 0xc1};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rbx, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm1_rax, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)subsd_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — scalar f64 sub: rax - rbx → rax (left in rax, right in rbx).
 */
int32_t backend_enc_subsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t movq_xmm1_rbx[5] = {0x66, 0x48, 0x0f, 0x6e, 0xcb};
  static const uint8_t subsd_xmm0_xmm1[4] = {0xf2, 0x0f, 0x5c, 0xc1};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm1_rbx, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)subsd_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — scalar f64 mul: rax * rbx → rax (IEEE bits in GPRs).
 * movq xmm0,rax; movq xmm1,rbx; mulsd xmm0,xmm1; movq rax,xmm0
 * G.7: same authority as addsd/subsd (not a parallel imul path for floats).
 */
int32_t backend_enc_mulsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t movq_xmm1_rbx[5] = {0x66, 0x48, 0x0f, 0x6e, 0xcb};
  static const uint8_t mulsd_xmm0_xmm1[4] = {0xf2, 0x0f, 0x59, 0xc1};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm1_rbx, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)mulsd_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — scalar f64 div: rax / rbx → rax (IEEE bits in GPRs).
 * movq xmm0,rax; movq xmm1,rbx; divsd xmm0,xmm1; movq rax,xmm0
 * G.7: same authority as mulsd/addsd (not integer idiv on IEEE bit patterns).
 * Div-by-zero yields IEEE Inf/NaN; do not emit integer div-zero panic before this.
 */
int32_t backend_enc_divsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc0};
  static const uint8_t movq_xmm1_rbx[5] = {0x66, 0x48, 0x0f, 0x6e, 0xcb};
  static const uint8_t divsd_xmm0_xmm1[4] = {0xf2, 0x0f, 0x5e, 0xc1};
  static const uint8_t movq_rax_xmm0[5] = {0x66, 0x48, 0x0f, 0x7e, 0xc0};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rax, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm1_rbx, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)divsd_xmm0_xmm1, 4) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_rax_xmm0, 5);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 — ordered f64 compare: left in rbx, right in rax (IEEE bits).
 * movq xmm0,rbx; movq xmm1,rax; ucomisd xmm0,xmm1
 * Flags use CF/ZF (not SF); pair with backend_enc_fp_cmp_setcc_movzbl_arch.
 * Signed cmpq of IEEE bits reverses order among negatives — do not use cmpq for f64.
 */
int32_t backend_enc_ucomisd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  static const uint8_t movq_xmm0_rbx[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc3};
  static const uint8_t movq_xmm1_rax[5] = {0x66, 0x48, 0x0f, 0x6e, 0xc8};
  static const uint8_t ucomisd_xmm0_xmm1[4] = {0x66, 0x0f, 0x2e, 0xc1};
  if (ta != 0 || !elf_ctx)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm0_rbx, 5) != 0)
    return -1;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movq_xmm1_rax, 5) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)ucomisd_xmm0_xmm1, 4);
}

/**
 * PLATFORM: LINUX+MACOS x86_64 — setcc after ucomisd/comisd (CF/ZF based).
 * cc: 0=eq 1=ne 2=lt(b) 3=le(be) 4=gt(a) 5=ge(ae); then movzbl %al,%eax.
 * Integer setl/setle/setg/setge read SF/OF and are wrong after ucomisd.
 */
int32_t backend_enc_fp_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta) {
  uint8_t op = 0x94; /* sete */
  static const uint8_t movzbl_al_eax[3] = {0x0f, 0xb6, 0xc0};
  uint8_t s[3];
  if (ta != 0 || !elf_ctx)
    return -1;
  if (cc == 1)
    op = 0x95; /* setne */
  else if (cc == 2)
    op = 0x92; /* setb  = CF (below / less) */
  else if (cc == 3)
    op = 0x96; /* setbe = CF|ZF */
  else if (cc == 4)
    op = 0x97; /* seta  = !CF & !ZF */
  else if (cc == 5)
    op = 0x93; /* setae = !CF */
  else if (cc != 0)
    return -1;
  s[0] = 0x0f;
  s[1] = op;
  s[2] = 0xc0;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, s, 3) != 0)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)movzbl_al_eax, 3);
}

/**
 * ta 分派：enc_sub_rax_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_sub_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sub_rax_rbx(elf_ctx);
  if (ta == 2)
    return -1;
  return arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_sub_rbx_rax_then_mov_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_sub_rbx_rax_then_mov_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  return arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
}
#endif


/**
 * ta 分派：enc_imul_rbx_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_imul_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_imul_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_mov_rax_to_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx);
  return arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_not_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_not_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_not_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_not_eax(elf_ctx);
  return arch_x86_64_enc_enc_not_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_and_rbx_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_and_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_and_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_and_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_and_rbx_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_or_rbx_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_or_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_or_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_or_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_or_rbx_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_xor_rbx_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_xor_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_xor_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_mov_rbx_to_ecx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_rbx_to_ecx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  return arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_shl_cl_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_shl_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_shl_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_shl_cl_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_shr_cl_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_shr_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_shr_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_shr_cl_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_sar_cl_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_sar_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sar_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_sar_cl_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_shl_cl_rax_arch（64-bit 逻辑左移）。
 * arm64/riscv64 暂复用 32-bit 路径（寄存器宽度由操作数类型隐式决定），x86_64 显式发射 REX.W 前缀。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_shl_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_shl_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_shl_cl_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_shr_cl_rax_arch（64-bit 逻辑右移）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_shr_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_shr_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_shr_cl_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_sar_cl_rax_arch（64-bit 算术右移）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_sar_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_sar_cl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx);
  return arch_x86_64_enc_enc_sar_cl_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_cltd_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cltd(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_cltd(elf_ctx);
  return arch_x86_64_enc_enc_cltd(elf_ctx);
}
#endif


/**
 * ta 分派：enc_idiv_rbx_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_idiv_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_idiv_rbx(elf_ctx);
  if (arch_x86_64_enc_enc_cltd(elf_ctx) != 0)
    return -1;
  return arch_x86_64_enc_enc_idiv_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_div_rbx_arch（32-bit 无符号除法）。
 * x86_64 路径发射 xor_edx_edx + div_rbx；arm64/riscv64 暂复用 idiv（TODO: 加 udiv/divu）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_div_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_idiv_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_idiv_rbx(elf_ctx);
  if (arch_x86_64_enc_enc_xor_edx_edx(elf_ctx) != 0)
    return -1;
  return arch_x86_64_enc_enc_div_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_mov_edx_to_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx);
  return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
}
#endif


/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rem_mod_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
  if (backend_enc_cltd_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_idiv_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}
#endif

/**
 * 无符号取模（u32 % n）：xor_edx_edx + div + mov_edx_to_eax。
 * div 后余数在 edx，mov_edx_to_eax 取余数到 eax。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rem_mod_unsigned_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
  if (backend_enc_div_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}
#endif

/**
 * ta 分派：enc_neg_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_neg_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_neg_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_neg_eax(elf_ctx);
  return arch_x86_64_enc_enc_neg_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_test_eax_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_test_eax_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_test_eax_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_test_eax_eax(elf_ctx);
  return arch_x86_64_enc_enc_test_eax_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_test_rbx_rbx_arch（除数零检，preserve rax 被除数）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_test_rbx_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_test_rbx_rbx(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx);
  return arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_setz_movzbl_eax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_setz_movzbl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx);
  return arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_cmp_rbx_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cmp_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx);
  return arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_cmp_rax_rbx_arch（rax - rbx；INDEX 下标 < 0 检查用）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cmp_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx);
  if (ta == 2)
    return -1;
  return arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx);
}
#endif


/**
 * ta 分派：enc_cmp_setcc_movzbl_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  if (ta == 2)
    return arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  return arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
}
#endif


/**
 * ta 分派：enc_store_rax_to_rbp_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  return arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
}
#endif


/**
 * ta 分派：enc_store_rdx_to_rbp_arch（SysV x86 16B struct 第二 half）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_store_rdx_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta != 0)
    return -1;
  return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset);
}
#endif

/**
 * ta 分派：enc_load_qword_from_rbx_to_rax_arch（16B struct return 低 half）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_qword_from_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta != 0)
    return -1;
  return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx);
}
#endif

/**
 * ta 分派：enc_load_qword_rbx8_to_rdx_arch（16B struct return 高 half）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_qword_rbx8_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta != 0)
    return -1;
  return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx);
}
#endif

/**
 * ta 分派：enc_load_rbp_to_rdx_arch（16B struct 栈槽高 half）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_rbp_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta != 0)
    return -1;
  return arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx, offset);
}
#endif

/**
 * ta 分派：enc_mov_rdx_to_arg_reg_arch（SysV 16B struct 第二 GPR 实参）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_rdx_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  if (ta != 0)
    return -1;
  return arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx, k);
}
#endif

/**
 * ta 分派：enc_store_x_reg_to_rbp（arm64 形参 x0-x7 落栈）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_store_x_reg_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg,
                                              int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset);
  return -1;
}
#endif

/**
 * ta 分派：enc_load_x29_pos_to_rax（arm64 栈上传参 [x29,#off]）。
 * 在 C 侧用 uint32_t 拼 LDR 机器码，避免 partial 内 i32 大常量被宿主 cc 误加载（0xF93FFFA0）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：enc_mov_arg_reg_to_rax（x86 SysV 形参寄存器 → rax）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  if (ta == 0)
    return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k);
  return -1;
}
#endif

/**
 * ta 分派：enc_load_rbp_pos_to_rax（x86 栈上传参 [rbp+#off]）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_rbp_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                             int32_t ta) {
  if (ta == 0)
    return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos);
  return -1;
}
#endif

/**
 * ta 分派：enc_load_rbp_to_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
}
#endif


/**
 * ta 分派：enc_load_rbp_to_rbx_arch
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * arm64：LDUR w0, [x29, #-offset]（f32/i32 单向量 lane load）。
 */
/* G-02f-127：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t arm64_enc_load_w0_from_rbp_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
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
#endif





/**
 * x86：movl 取 i32 lane；arm64 f32/i32 lane 用 LDUR w0；其它走 64-bit load。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_rbp_lane_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                              int32_t esz, int32_t ta) {
  if (ta == 0 && esz == 4)
    return arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx, offset);
  if (ta == 1 && esz == 4)
    return arm64_enc_load_w0_from_rbp_c(elf_ctx, offset);
  return backend_enc_load_rbp_to_rax_arch(elf_ctx, offset, ta);
}
#endif

/**
 * x86：movl 取 i32 lane；其它 arch / 8B lane 走 movq。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_rbp_lane_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                              int32_t esz, int32_t ta) {
  if (ta == 0 && esz == 4)
    return arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx, offset);
  return backend_enc_load_rbp_to_rbx_arch(elf_ctx, offset, ta);
}
#endif

/**
 * arm64：STUR w0, [x29, #-offset]（f32 局部 let/assign；勿 64 位 str x0 覆盖相邻 4B 槽）。
 */
/* G-02f-127：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t arm64_enc_store_w0_to_rbp_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset) {
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
#endif





/**
 * x86：movl %eax, -off(%rbp)（f32 局部 let/assign store）；arm64 走 STUR w0。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：enc_lea_rbp_to_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  return arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
}
#endif


/**
 * ta 分派：enc_lea_rbp_to_rbx_arch（向量 dst 基址入 rbx，preserve rax）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_lea_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  return arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
}
#endif


/**
 * ta 分派：enc_rax_plus_rbx_scale4_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rax_plus_rbx_scale4_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  return arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
}
#endif


/**
 * ta 分派：enc_rax_plus_rbx_scale1_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rax_plus_rbx_scale1_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  return arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
}
#endif


/**
 * ta 分派：enc_rax_plus_rbx_scale8_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rax_plus_rbx_scale8_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  return arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
}
#endif


/**
 * ta 分派：enc_store_rax_to_rbx_indirect_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_store_rax_to_rbx_indirect_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  if (ta == 2)
    return arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  return arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
}
#endif

/**
 * ta 分派：enc_load_32_from_rax_arch
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
  return arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx);
}
#endif

/**
 * i32 间接 load 后规范化 rax（x86 已由 load_32_from_rax_arch 内建 cdqe）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_i32_indirect_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}
#endif

/**
 * ta 分派：enc_load_zext8_from_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_zext8_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx);
  return arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx);
}
#endif


/**
 * ta 分派：enc_add_imm_to_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx, imm);
}
#endif


/**
 * ta 分派：enc_add_imm_to_rbx_arch（INDEX 字面量下标偏移，preserve rax 右值）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_add_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
}
#endif


/**
 * ta 分派：INDEX 变量下标 load 到 scratch（arm64 w2 / x86 ecx / riscv a2），勿 clobber rax 右值。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_rbp_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                 int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx, offset);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx, offset);
  return arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx, offset);
}
#endif

/**
 * ta 分派：rbx 基址 + scratch 下标缩放寻址（base 已在 rbx）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX scratch 下标 + 字面量偏移（var+lit / lit+var add 下标）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
    /** 0x11000442 = add w2,w2,#1；每 +1 步进 1024（C 侧合成，避免 .x -E 失精）。 */
    ins = 285213762u + (uint32_t)((imm12 - 1) << 10);
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)ins);
  }
  if (ta == 2)
    return arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx, imm);
  return arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx, imm);
}
#endif

/**
 * ta 分派：INDEX 第二下标 load 到 scratch2（arm64 w3 / x86 edx / riscv a3）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX scratch 下标 i+j（primary += secondary）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_index_scratch_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x0B030042u);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_add_ecx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX scratch 下标 var-lit（primary -= imm）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX scratch 下标 i-j（primary -= secondary）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_index_scratch_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B030042u);
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX scratch 下标 secondary - scratch（i-(j+k) 右结合 SUB）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_index_scratch_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B020062u);
  if (ta == 2)
    return arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX 读路径 secondary - rbx（i-(j+k)）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rbx_index_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B010061u);
  if (ta == 2)
    return arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX scratch 下标 × 正字面量（var*lit / lit*var 下标；2≤lit≤65535）。
 * arm64：mov w3,#imm + mul w2,w2,w3；x86：imull $imm,%ecx；riscv：addi a3 + mul a2,a2,a3。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX 读路径下标（rbx）× 正字面量（return arr[i*lit] 等；2≤lit≤65535）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX 读路径下标（rbx/w1）+ 字面量（return arr[i+lit] 等）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX 读路径下标（rbx）- 字面量（return arr[i-lit] 等）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
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
#endif

/**
 * ta 分派：INDEX 读路径 i+j（primary rbx += secondary scratch）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rbx_index_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x0B030021u);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_add_ebx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX 读路径 i-j（primary rbx -= secondary scratch）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rbx_index_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4B030021u);
  if (ta == 2)
    return arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX assign scratch 下标 i*j（primary scratch *= secondary）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_index_scratch_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x1B037C42u);
  if (ta == 2)
    return arch_riscv64_enc_enc_mul_a2_a3(elf_ctx);
  return arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：INDEX 读路径 i*j（primary rbx *= secondary scratch）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_rbx_index_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x1B037C21u);
  if (ta == 2)
    return arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx);
  return arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx);
}
#endif

/**
 * ta 分派：enc_load_64_from_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_load_64_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_load_64_from_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_load_64_from_rax(elf_ctx);
  return arch_x86_64_enc_enc_load_64_from_rax(elf_ctx);
}
#endif

/**
 * ta 分派：enc_store_rax_to_rbx_offset_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset, int32_t store_size, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  if (ta == 2)
    return arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  return arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
}
#endif

/**
 * ta 分派：enc_mov_rbx_to_rax_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx);
  return arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx);
}
#endif

/**
 * ta 分派：enc_jz_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jz(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jz(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jz(elf_ctx, label, label_len);
}
#endif

/**
 * ta 分派：enc_jeq_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jeq_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jeq(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jeq(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jeq(elf_ctx, label, label_len);
}
#endif

/**
 * ta 分派：enc_jge_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jge(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jge(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jge(elf_ctx, label, label_len);
}
#endif

/**
 * ta 分派：enc_jle_arch（x86 0F 8E；LCG while 回跳，其它 arch 暂不支持）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jle_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta != 0)
    return -1;
  return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, 0x8E, label, label_len);
}
#endif

/**
 * ta 分派：enc_jl_arch（x86 0F 8C；LCG 2×/4× 展开回跳，其它 arch 暂不支持）。
 */
/* G-02f-207：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta != 0)
    return -1;
  return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, 0x8C, label, label_len);
}
#endif

/**
 * ta 分派：enc_jnz_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jnz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jnz(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len);
}
#endif

/**
 * ta 分派：enc_jne_arch（arm64 b.ne 用 cmp 标志；x86/riscv 同 jnz）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jne_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jne(elf_ctx, label, label_len);
  return backend_enc_jnz_arch(elf_ctx, label, label_len, ta);
}
#endif

/**
 * ta 分派：enc_jmp_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_jmp(elf_ctx, label, label_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_jmp(elf_ctx, label, label_len);
  return arch_x86_64_enc_enc_jmp(elf_ctx, label, label_len);
}
#endif

/**
 * ta 分派：enc_mov_rax_to_arg_reg_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k, int32_t ta) {
  if (ta == 1)
    return arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  if (ta == 2)
    return arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  return arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
}
#endif

/**
 * ta 分派：enc_call_arch
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta) {
  if (ta == 1)
    return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len);
  if (ta == 2)
    return arch_riscv64_enc_enc_call(elf_ctx, name, name_len);
  return arch_x86_64_enc_enc_call(elf_ctx, name, name_len);
}
#endif

/**
 * ta 分派：call 后回收 outgoing 栈实参区（x86 add rsp / arm64 add sp）。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_call_stack_cleanup_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes, int32_t ta) {
  if (nbytes <= 0)
    return 0;
  if (ta == 1)
    return backend_enc_arm64_add_sp_imm12_c(elf_ctx, nbytes);
  if (ta == 2)
    return arch_riscv64_enc_enc_add_sp_imm12(elf_ctx, nbytes);
  return arch_x86_64_enc_enc_add_rsp_imm(elf_ctx, nbytes);
}
#endif

/**
 * ta 分派：arm64 预留 outgoing 栈实参区（sub sp）；x86/riscv 由 push 路径处理，nbytes≤0 时 no-op。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_call_stack_reserve_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t nbytes, int32_t ta) {
  if (nbytes <= 0)
    return 0;
  if (ta == 1)
    return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, nbytes);
  return 0;
}
#endif

/**
 * ta 分派：arm64 将 x0 写入 [sp+#off] outgoing 槽；其它架构暂不支持。
 */
/* G-02f-206：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes, int32_t ta) {
  if (ta == 1)
    return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
  return -1;
}
#endif

/**
 * x86_64 cdqe（48 98）：movl (%rax),%eax 后符号扩展 eax→rax，避免 binop 误用残留指针。
 */
/* G-02f-419：实现体始终 seed；public PREFER 时 thin pure forward */
int32_t arch_x86_64_enc_enc_cdqe_rax_impl(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  static const uint8_t cdqe[2] = {0x48, 0x98};
  if (!elf_ctx)
    return -1;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)cdqe, 2);
}
#ifndef XLANG_L2_ENC_DISPATCH_THIN_FROM_X
int32_t arch_x86_64_enc_enc_cdqe_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  return arch_x86_64_enc_enc_cdqe_rax_impl(elf_ctx);
}
#endif

int backend_enc_dispatch_slice_marker(void) {
    return 1;
}

#else /* XLANG_BACKEND_ENC_DISPATCH_FROM_X：产品 rest 业务 H=0 */
int backend_enc_dispatch_slice_marker(void) {
  return 0;
}
#endif /* XLANG_BACKEND_ENC_DISPATCH_FROM_X */

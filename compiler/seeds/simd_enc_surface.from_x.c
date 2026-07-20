/* seeds/simd_enc_surface.from_x.c
 * R2 full surface — isomorphic with src/asm/simd_enc.x
 * Product PREFER_X_O: g05_try_x_to_o(simd_enc.x) + hybrid rest
 *   seeds/simd_enc.from_x.c (-DSHUX_SIMD_ENC_FROM_X) ld -r
 * R2: full.x 吃满 pure/insn/try_hw 公共业务；FROM_X rest 仅 slice_marker（业务 H=0）
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./shux -E ... src/asm/simd_enc.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t simd_enc_x_doc_anchor(void);
extern uint32_t simd_arm64_ins_v1_from_v0_s(int32_t dst_lane, int32_t src_lane);
extern int32_t simd_arm64_rbp_lea_off_128half(int32_t slot, int32_t half, int32_t esz);
extern int32_t simd_append_disp32(uint8_t * elf, int32_t disp);
extern int32_t simd_append(uint8_t * elf, uint8_t * bytes, int32_t n);
extern int32_t simd_append_u32_le(uint8_t * elf, uint32_t word);
extern int32_t simd_x86_addps_xmm0_xmm1(uint8_t * elf);
extern int32_t simd_x86_mulps_xmm0_xmm1(uint8_t * elf);
extern int32_t simd_x86_paddd_xmm0_xmm1(uint8_t * elf);
extern int32_t simd_x86_psubd_xmm0_xmm1(uint8_t * elf);
extern int32_t simd_x86_pmulld_xmm0_xmm1(uint8_t * elf);
extern int32_t simd_x86_vpaddd_ymm0_ymm1(uint8_t * elf);
extern int32_t simd_x86_vpsubd_ymm0_ymm1(uint8_t * elf);
extern int32_t simd_x86_vpmulld_ymm0_ymm1(uint8_t * elf);
extern int32_t simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(uint8_t * elf);
extern int32_t simd_x86_movups_xmm0_to_rbx_rax4(uint8_t * elf);
extern int32_t simd_x86_movups_xmm0_from_rbx_rax4(uint8_t * elf);
extern int32_t simd_x86_movups_xmm1_from_rbx_rax4(uint8_t * elf);
extern int32_t simd_x86_vmovups_ymm0_from_rbx_rax4(uint8_t * elf);
extern int32_t simd_x86_vmovups_ymm1_from_rbx_rax4(uint8_t * elf);
extern int32_t simd_x86_vmovups_ymm0_to_rbx_rax4(uint8_t * elf);
extern int32_t simd_x86_movups_xmm0_from_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_movups_xmm1_from_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_movups_xmm0_to_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_vmovups_ymm0_from_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_vmovups_ymm1_from_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_vmovups_ymm0_to_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_movups_xmm2_from_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_pshufd_xmm0_imm8(uint8_t * elf, int32_t imm8);
extern int32_t simd_x86_vpshufd_ymm0_imm8(uint8_t * elf, int32_t imm8);
extern int32_t simd_x86_vmovups_ymm2_from_rbp(uint8_t * elf, int32_t disp);
extern int32_t simd_x86_pxor_xmm3_xmm3(uint8_t * elf);
extern int32_t simd_x86_pcmpgtd_xmm2_xmm3(uint8_t * elf);
extern int32_t simd_x86_pand_xmm0_xmm2(uint8_t * elf);
extern int32_t simd_x86_pandn_xmm2_xmm1(uint8_t * elf);
extern int32_t simd_x86_por_xmm0_xmm2(uint8_t * elf);
extern int32_t simd_x86_xorps_xmm3_xmm3(uint8_t * elf);
extern int32_t simd_x86_cmpgtps_xmm2_xmm3(uint8_t * elf);
extern int32_t simd_x86_andps_xmm0_xmm2(uint8_t * elf);
extern int32_t simd_x86_andnps_xmm2_xmm1(uint8_t * elf);
extern int32_t simd_x86_orps_xmm0_xmm2(uint8_t * elf);
extern int32_t simd_x86_vpxor_ymm3_ymm3(uint8_t * elf);
extern int32_t simd_x86_vpcmpgtd_ymm2_ymm3(uint8_t * elf);
extern int32_t simd_x86_vpand_ymm0_ymm2(uint8_t * elf);
extern int32_t simd_x86_vpandn_ymm2_ymm1(uint8_t * elf);
extern int32_t simd_x86_vpor_ymm0_ymm2(uint8_t * elf);
extern int32_t simd_x86_vxorps_ymm3_ymm3(uint8_t * elf);
extern int32_t simd_x86_vcmpgtps_ymm2_ymm3(uint8_t * elf);
extern int32_t simd_x86_vandps_ymm0_ymm2(uint8_t * elf);
extern int32_t simd_x86_vandnps_ymm2_ymm1(uint8_t * elf);
extern int32_t simd_x86_vorps_ymm0_ymm2(uint8_t * elf);
extern int32_t simd_x86_pshufd_xmm1_xmm0(uint8_t * elf, uint8_t imm);
extern int32_t simd_rbp_disp32(int32_t slot_off, int32_t lanes, int32_t esz);
extern int32_t simd_enc_try_hw_vector_iadd_isub_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features, int32_t is_sub);
extern int32_t simd_enc_try_hw_vector_iadd_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_hw_vector_isub_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_hw_vector_imul_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_hw_vector_fadd_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_hw_vector_fmul_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_hw_vector_fma_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_c, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_x86_xorps_xmm0_zero(uint8_t * elf_ctx);
extern int32_t simd_enc_x86_movups_xmm1_rbp_disp(uint8_t * elf_ctx, int32_t disp);
extern int32_t simd_enc_x86_addps_xmm0_xmm1(uint8_t * elf_ctx);
extern int32_t simd_enc_x86_horizontal_addps_xmm0(uint8_t * elf_ctx);
extern int32_t simd_enc_x86_movss_xmm0_rbp_disp(uint8_t * elf_ctx, int32_t disp);
extern int32_t simd_enc_f32_soa_col_movups_xmm1_at_idx(uint8_t * elf_ctx, int32_t off_col0, int32_t off_i, int32_t ta);
extern int32_t simd_arm64_pshufd_imm8_128_rbp(uint8_t * elf_ctx, int32_t lea_src, int32_t lea_dst, int32_t imm8, int32_t ta);
extern int32_t simd_arm64_select_128_rbp(uint8_t * elf_ctx, int32_t lea_mask, int32_t lea_a, int32_t lea_b, int32_t lea_dst, int32_t is_f32, int32_t ta);
extern int32_t simd_enc_emit_i32_select_xmm_seq(uint8_t * elf_ctx);
extern int32_t simd_enc_emit_f32_select_xmm_seq(uint8_t * elf_ctx);
extern int32_t simd_enc_emit_i32_select_ymm_seq(uint8_t * elf_ctx);
extern int32_t simd_enc_emit_f32_select_ymm_seq(uint8_t * elf_ctx);
extern int32_t simd_enc_try_hw_vector_binop_rbp_at_idx(uint8_t * elf_ctx, int32_t off_a, int32_t off_b, int32_t off_d, int32_t off_i, int32_t array_n, int32_t binop_ko, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_pshufd_rbp(uint8_t * elf_ctx, int32_t slot_off_src, int32_t slot_off_dst, int32_t imm8, int32_t lanes, int32_t ta, uint32_t cpu_features);
extern int32_t simd_enc_try_hw_vector_select_rbp(uint8_t * elf_ctx, int32_t slot_off_mask, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t is_f32, int32_t ta, uint32_t cpu_features);
int32_t simd_enc_x_doc_anchor(void) {
  return 0;
}
uint32_t simd_arm64_ins_v1_from_v0_s(int32_t dst_lane, int32_t src_lane) {
  int32_t d = (dst_lane & 3);
  int32_t s = (src_lane & 3);
  int32_t enc = (((1846018048 | (d <<19)) | (s <<13)) | 1025);
  return enc;
}
int32_t simd_arm64_rbp_lea_off_128half(int32_t slot, int32_t half, int32_t esz) {
  if ((slot < 0)) {
    return slot;
  }
  if ((esz <=0)) {
    return slot;
  }
  if ((half < 0)) {
    return slot;
  }
  return (slot - ((half * 4) * esz));
}
int32_t simd_append_disp32(uint8_t * elf, int32_t disp) {
  int32_t r = 0;
  {
    (void)((r = simd_append_u32_le(elf, ((uint32_t)(disp)))));
  }
  return r;
}
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t * ctx, uint8_t * ptr, int32_t n);
int32_t simd_append(uint8_t * elf, uint8_t * bytes, int32_t n) {
  if ((elf ==0)) {
    return (0 - 1);
  }
  if ((bytes ==0)) {
    return (0 - 1);
  }
  if ((n <=0)) {
    return (0 - 1);
  }
  int32_t r = 0;
  {
    (void)((r = pipeline_elf_ctx_append_bytes(elf, bytes, n)));
  }
  return r;
}
int32_t simd_append_u32_le(uint8_t * elf, uint32_t word) {
  uint8_t b0 = ((uint8_t)((word & 255)));
  uint8_t b1 = ((uint8_t)(((word / 256) & 255)));
  uint8_t b2 = ((uint8_t)(((word / 65536) & 255)));
  uint8_t b3 = ((uint8_t)(((word / 16777216) & 255)));
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  return r;
}
int32_t simd_x86_addps_xmm0_xmm1(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 88;
  uint8_t b2 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_mulps_xmm0_xmm1(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 89;
  uint8_t b2 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_paddd_xmm0_xmm1(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 254;
  uint8_t b3 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_psubd_xmm0_xmm1(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 250;
  uint8_t b3 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_pmulld_xmm0_xmm1(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 56;
  uint8_t b3 = 64;
  uint8_t b4 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpaddd_ymm0_ymm1(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 253;
  uint8_t b2 = 254;
  uint8_t b3 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpsubd_ymm0_ymm1(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 253;
  uint8_t b2 = 250;
  uint8_t b3 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpmulld_ymm0_ymm1(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 253;
  uint8_t b2 = 64;
  uint8_t b3 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(uint8_t * elf) {
  uint8_t b0 = 196;
  uint8_t b1 = 226;
  uint8_t b2 = 113;
  uint8_t b3 = 169;
  uint8_t b4 = 193;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_movups_xmm0_to_rbx_rax4(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 248;
  uint8_t b2 = 17;
  uint8_t b3 = 4;
  uint8_t b4 = 131;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_movups_xmm0_from_rbx_rax4(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 248;
  uint8_t b2 = 16;
  uint8_t b3 = 4;
  uint8_t b4 = 131;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_movups_xmm1_from_rbx_rax4(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 240;
  uint8_t b2 = 16;
  uint8_t b3 = 4;
  uint8_t b4 = 131;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm0_from_rbx_rax4(uint8_t * elf) {
  uint8_t b0 = 196;
  uint8_t b1 = 226;
  uint8_t b2 = 125;
  uint8_t b3 = 16;
  uint8_t b4 = 4;
  uint8_t b5 = 131;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b5), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm1_from_rbx_rax4(uint8_t * elf) {
  uint8_t b0 = 196;
  uint8_t b1 = 226;
  uint8_t b2 = 117;
  uint8_t b3 = 16;
  uint8_t b4 = 4;
  uint8_t b5 = 131;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b5), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm0_to_rbx_rax4(uint8_t * elf) {
  uint8_t b0 = 196;
  uint8_t b1 = 226;
  uint8_t b2 = 125;
  uint8_t b3 = 17;
  uint8_t b4 = 4;
  uint8_t b5 = 131;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b4), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b5), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_movups_xmm0_from_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 15;
  uint8_t b1 = 16;
  uint8_t b2 = 133;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_movups_xmm1_from_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 15;
  uint8_t b1 = 16;
  uint8_t b2 = 141;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_movups_xmm0_to_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 15;
  uint8_t b1 = 17;
  uint8_t b2 = 133;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm0_from_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 197;
  uint8_t b1 = 254;
  uint8_t b2 = 16;
  uint8_t b3 = 133;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm1_from_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 197;
  uint8_t b1 = 254;
  uint8_t b2 = 16;
  uint8_t b3 = 141;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm0_to_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 197;
  uint8_t b1 = 254;
  uint8_t b2 = 17;
  uint8_t b3 = 133;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_movups_xmm2_from_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 15;
  uint8_t b1 = 16;
  uint8_t b2 = 149;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_pshufd_xmm0_imm8(uint8_t * elf, int32_t imm8) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 112;
  uint8_t b3 = 192;
  uint8_t ib = ((uint8_t)((imm8 & 255)));
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(ib), 1)));
  }
  return r;
}
int32_t simd_x86_vpshufd_ymm0_imm8(uint8_t * elf, int32_t imm8) {
  uint8_t b0 = 197;
  uint8_t b1 = 254;
  uint8_t b2 = 112;
  uint8_t b3 = 192;
  uint8_t ib = ((uint8_t)((imm8 & 255)));
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(ib), 1)));
  }
  return r;
}
int32_t simd_x86_vmovups_ymm2_from_rbp(uint8_t * elf, int32_t disp) {
  uint8_t b0 = 197;
  uint8_t b1 = 254;
  uint8_t b2 = 16;
  uint8_t b3 = 149;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf, disp)));
  }
  return r;
}
int32_t simd_x86_pxor_xmm3_xmm3(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 239;
  uint8_t b3 = 219;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_pcmpgtd_xmm2_xmm3(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 102;
  uint8_t b3 = 211;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_pand_xmm0_xmm2(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 219;
  uint8_t b3 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_pandn_xmm2_xmm1(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 223;
  uint8_t b3 = 209;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_por_xmm0_xmm2(uint8_t * elf) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 235;
  uint8_t b3 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_xorps_xmm3_xmm3(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 87;
  uint8_t b2 = 219;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_cmpgtps_xmm2_xmm3(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 85;
  uint8_t b2 = 211;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_andps_xmm0_xmm2(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 84;
  uint8_t b2 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_andnps_xmm2_xmm1(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 85;
  uint8_t b2 = 209;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_orps_xmm0_xmm2(uint8_t * elf) {
  uint8_t b0 = 15;
  uint8_t b1 = 86;
  uint8_t b2 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpxor_ymm3_ymm3(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 245;
  uint8_t b2 = 119;
  uint8_t b3 = 219;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpcmpgtd_ymm2_ymm3(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 237;
  uint8_t b2 = 102;
  uint8_t b3 = 211;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpand_ymm0_ymm2(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 229;
  uint8_t b2 = 219;
  uint8_t b3 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpandn_ymm2_ymm1(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 229;
  uint8_t b2 = 223;
  uint8_t b3 = 209;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vpor_ymm0_ymm2(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 229;
  uint8_t b2 = 235;
  uint8_t b3 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vxorps_ymm3_ymm3(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 240;
  uint8_t b2 = 87;
  uint8_t b3 = 219;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vcmpgtps_ymm2_ymm3(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 232;
  uint8_t b2 = 87;
  uint8_t b3 = 211;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vandps_ymm0_ymm2(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 224;
  uint8_t b2 = 84;
  uint8_t b3 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vandnps_ymm2_ymm1(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 232;
  uint8_t b2 = 85;
  uint8_t b3 = 209;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_vorps_ymm0_ymm2(uint8_t * elf) {
  uint8_t b0 = 197;
  uint8_t b1 = 224;
  uint8_t b2 = 86;
  uint8_t b3 = 194;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b3), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = 0));
  }
  return r;
}
int32_t simd_x86_pshufd_xmm1_xmm0(uint8_t * elf, uint8_t imm) {
  uint8_t b0 = 102;
  uint8_t b1 = 15;
  uint8_t b2 = 112;
  uint8_t modrm = 200;
  uint8_t ib = imm;
  int32_t r = 0;
  {
    (void)((r = simd_append(elf, &(b0), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b1), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(b2), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(modrm), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append(elf, &(ib), 1)));
  }
  return r;
}
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
int32_t simd_rbp_disp32(int32_t slot_off, int32_t lanes, int32_t esz) {
  if ((slot_off < 0)) {
    return 0;
  }
  return (0 - slot_off);
}
int32_t simd_enc_try_hw_vector_iadd_isub_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features, int32_t is_sub) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_a < 0)) {
    return (0 - 1);
  }
  if ((slot_off_b < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  if ((esz !=4)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  int32_t da = simd_rbp_disp32(slot_off_a, lanes, esz);
  int32_t db = simd_rbp_disp32(slot_off_b, lanes, esz);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if ((lanes ==8)) {
    if (((cpu_features & 8) !=0)) {
      if ((simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) !=0)) {
        return (0 - 1);
      }
      if ((is_sub !=0)) {
        if ((simd_x86_vpsubd_ymm0_ymm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((simd_x86_vpaddd_ymm0_ymm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      }
      if ((simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  if ((lanes ==4)) {
    if (((cpu_features & 1) !=0)) {
      if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, da) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
        return (0 - 1);
      }
      if ((is_sub !=0)) {
        if ((simd_x86_psubd_xmm0_xmm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((simd_x86_paddd_xmm0_xmm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      }
      if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  return (0 - 1);
}
int32_t simd_enc_try_hw_vector_iadd_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, 0);
}
int32_t simd_enc_try_hw_vector_isub_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, 1);
}
int32_t simd_enc_try_hw_vector_imul_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_a < 0)) {
    return (0 - 1);
  }
  if ((slot_off_b < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  if ((esz !=4)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  int32_t da = simd_rbp_disp32(slot_off_a, lanes, esz);
  int32_t db = simd_rbp_disp32(slot_off_b, lanes, esz);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if ((lanes ==8)) {
    if (((cpu_features & 8) !=0)) {
      if ((simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vpmulld_ymm0_ymm1(elf_ctx) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  if ((lanes ==4)) {
    if (((cpu_features & 2) !=0)) {
      if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, da) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_pmulld_xmm0_xmm1(elf_ctx) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  return (0 - 1);
}
int32_t simd_enc_try_hw_vector_fadd_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_a < 0)) {
    return (0 - 1);
  }
  if ((slot_off_b < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  if ((esz !=4)) {
    return (0 - 1);
  }
  if ((lanes !=4)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if (((cpu_features & 1) ==0)) {
    return (0 - 1);
  }
  int32_t da = simd_rbp_disp32(slot_off_a, lanes, esz);
  int32_t db = simd_rbp_disp32(slot_off_b, lanes, esz);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, da) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_addps_xmm0_xmm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_try_hw_vector_fmul_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_a < 0)) {
    return (0 - 1);
  }
  if ((slot_off_b < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  if ((esz !=4)) {
    return (0 - 1);
  }
  if ((lanes !=4)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if (((cpu_features & 1) ==0)) {
    return (0 - 1);
  }
  int32_t da = simd_rbp_disp32(slot_off_a, lanes, esz);
  int32_t db = simd_rbp_disp32(slot_off_b, lanes, esz);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, da) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_mulps_xmm0_xmm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_try_hw_vector_fma_rbp(uint8_t * elf_ctx, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_c, int32_t slot_off_dst, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_a < 0)) {
    return (0 - 1);
  }
  if ((slot_off_b < 0)) {
    return (0 - 1);
  }
  if ((slot_off_c < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  if ((esz !=4)) {
    return (0 - 1);
  }
  if ((lanes !=4)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if (((cpu_features & 1) ==0)) {
    return (0 - 1);
  }
  int32_t da = simd_rbp_disp32(slot_off_a, lanes, esz);
  int32_t db = simd_rbp_disp32(slot_off_b, lanes, esz);
  int32_t dc = simd_rbp_disp32(slot_off_c, lanes, esz);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if (((cpu_features & 128) !=0)) {
    if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, da) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_movups_xmm2_from_rbp(elf_ctx, dc) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf_ctx) !=0)) {
      return (0 - 1);
    }
  } else {
    if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, dc) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_mulps_xmm0_xmm1(elf_ctx) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, da) !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_addps_xmm0_xmm1(elf_ctx) !=0)) {
      return (0 - 1);
    }
  }
  if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_x86_xorps_xmm0_zero(uint8_t * elf_ctx) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t insn[3] = {};
    (void)(((insn)[0] = 15));
    (void)(((insn)[1] = 87));
    (void)(((insn)[2] = 192));
    return simd_append(elf_ctx, &((insn)[0]), 3);
  }
  return (0 - 1);
}
int32_t simd_enc_x86_movups_xmm1_rbp_disp(uint8_t * elf_ctx, int32_t disp) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  return simd_x86_movups_xmm1_from_rbp(elf_ctx, disp);
}
int32_t simd_enc_x86_addps_xmm0_xmm1(uint8_t * elf_ctx) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  return simd_x86_addps_xmm0_xmm1(elf_ctx);
}
int32_t simd_enc_x86_horizontal_addps_xmm0(uint8_t * elf_ctx) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((simd_x86_pshufd_xmm1_xmm0(elf_ctx, ((uint8_t)(238))) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_addps_xmm0_xmm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_pshufd_xmm1_xmm0(elf_ctx, ((uint8_t)(85))) !=0)) {
    return (0 - 1);
  }
  return simd_x86_addps_xmm0_xmm1(elf_ctx);
}
int32_t simd_enc_x86_movss_xmm0_rbp_disp(uint8_t * elf_ctx, int32_t disp) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  uint8_t prefix[3] = {};
  (void)(((prefix)[0] = 243));
  (void)(((prefix)[1] = 15));
  (void)(((prefix)[2] = 17));
  int32_t r = 0;
  {
    (void)((r = simd_append(elf_ctx, &((prefix)[0]), 3)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  uint8_t modrm = 133;
  {
    (void)((r = simd_append(elf_ctx, &(modrm), 1)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  {
    (void)((r = simd_append_disp32(elf_ctx, disp)));
  }
  return r;
}
int32_t simd_enc_f32_soa_col_movups_xmm1_at_idx(uint8_t * elf_ctx, int32_t off_col0, int32_t off_i, int32_t ta) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((off_col0 < 0)) {
    return (0 - 1);
  }
  if ((off_i < 0)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  int32_t re1 = 0;
  {
    (void)((re1 = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((re1 !=0)) {
    return (0 - 1);
  }
  int32_t re2 = 0;
  {
    (void)((re2 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, off_col0, ta)));
  }
  if ((re2 !=0)) {
    return (0 - 1);
  }
  uint8_t insn[4] = {};
  (void)(((insn)[0] = 15));
  (void)(((insn)[1] = 16));
  (void)(((insn)[2] = 12));
  (void)(((insn)[3] = 131));
  int32_t r = 0;
  {
    (void)((r = simd_append(elf_ctx, &((insn)[0]), 4)));
  }
  if ((r !=0)) {
    return (0 - 1);
  }
  return 0;
}
extern int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
int32_t simd_arm64_pshufd_imm8_128_rbp(uint8_t * elf_ctx, int32_t lea_src, int32_t lea_dst, int32_t imm8, int32_t ta) {
  int32_t re3 = 0;
  {
    (void)((re3 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_src, ta)));
  }
  if ((re3 !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1279293440) !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1319115777) !=0)) {
    return (0 - 1);
  }
  int32_t li = 0;
  while ((li < 4)) {
    int32_t shift = (li * 2);
    int32_t tmp = imm8;
    int32_t k = 0;
    while ((k < shift)) {
      (void)((tmp = (tmp / 2)));
      (void)((k = (k + 1)));
    }
    int32_t src_lane = (tmp & 3);
    uint32_t ins = simd_arm64_ins_v1_from_v0_s(li, src_lane);
    if ((simd_append_u32_le(elf_ctx, ins) !=0)) {
      return (0 - 1);
    }
    (void)((li = (li + 1)));
  }
  int32_t re4 = 0;
  {
    (void)((re4 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_dst, ta)));
  }
  if ((re4 !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1275099137) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_arm64_select_128_rbp(uint8_t * elf_ctx, int32_t lea_mask, int32_t lea_a, int32_t lea_b, int32_t lea_dst, int32_t is_f32, int32_t ta) {
  int32_t re5 = 0;
  {
    (void)((re5 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_mask, ta)));
  }
  if ((re5 !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1279293440) !=0)) {
    return (0 - 1);
  }
  int32_t re6 = 0;
  {
    (void)((re6 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_a, ta)));
  }
  if ((re6 !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1279293441) !=0)) {
    return (0 - 1);
  }
  int32_t re7 = 0;
  {
    (void)((re7 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_b, ta)));
  }
  if ((re7 !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1279293442) !=0)) {
    return (0 - 1);
  }
  if ((is_f32 !=0)) {
    if ((simd_append_u32_le(elf_ctx, 1319159811) !=0)) {
      return (0 - 1);
    }
    if ((simd_append_u32_le(elf_ctx, 1856117795) !=0)) {
      return (0 - 1);
    }
  } else {
    if ((simd_append_u32_le(elf_ctx, 1319143427) !=0)) {
      return (0 - 1);
    }
    if ((simd_append_u32_le(elf_ctx, 1851923491) !=0)) {
      return (0 - 1);
    }
  }
  int32_t re8 = 0;
  {
    (void)((re8 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_dst, ta)));
  }
  if ((re8 !=0)) {
    return (0 - 1);
  }
  if ((simd_append_u32_le(elf_ctx, 1275099139) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_emit_i32_select_xmm_seq(uint8_t * elf_ctx) {
  if ((simd_x86_pxor_xmm3_xmm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_pcmpgtd_xmm2_xmm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_pand_xmm0_xmm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_pandn_xmm2_xmm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_por_xmm0_xmm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_emit_f32_select_xmm_seq(uint8_t * elf_ctx) {
  if ((simd_x86_xorps_xmm3_xmm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_cmpgtps_xmm2_xmm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_andps_xmm0_xmm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_andnps_xmm2_xmm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_orps_xmm0_xmm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_emit_i32_select_ymm_seq(uint8_t * elf_ctx) {
  if ((simd_x86_vpxor_ymm3_ymm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vpcmpgtd_ymm2_ymm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vpand_ymm0_ymm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vpandn_ymm2_ymm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vpor_ymm0_ymm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_emit_f32_select_ymm_seq(uint8_t * elf_ctx) {
  if ((simd_x86_vxorps_ymm3_ymm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vcmpgtps_ymm2_ymm3(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vandps_ymm0_ymm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vandnps_ymm2_ymm1(elf_ctx) !=0)) {
    return (0 - 1);
  }
  if ((simd_x86_vorps_ymm0_ymm2(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t simd_enc_try_hw_vector_binop_rbp_at_idx(uint8_t * elf_ctx, int32_t off_a, int32_t off_b, int32_t off_d, int32_t off_i, int32_t array_n, int32_t binop_ko, int32_t lanes, int32_t esz, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((off_a < 0)) {
    return (0 - 1);
  }
  if ((off_b < 0)) {
    return (0 - 1);
  }
  if ((off_d < 0)) {
    return (0 - 1);
  }
  if ((off_i < 0)) {
    return (0 - 1);
  }
  if ((array_n <=0)) {
    return (0 - 1);
  }
  if ((esz !=4)) {
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  int32_t elem0_a = (off_a - ((array_n - 1) * esz));
  int32_t elem0_b = (off_b - ((array_n - 1) * esz));
  int32_t elem0_d = (off_d - ((array_n - 1) * esz));
  int32_t re9 = 0;
  {
    (void)((re9 = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta)));
  }
  if ((re9 !=0)) {
    return (0 - 1);
  }
  int32_t re10 = 0;
  {
    (void)((re10 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_a, ta)));
  }
  if ((re10 !=0)) {
    return (0 - 1);
  }
  if ((lanes ==8)) {
    if (((cpu_features & 8) !=0)) {
      int32_t re11 = 0;
      int32_t re12 = 0;
      if ((simd_x86_vmovups_ymm0_from_rbx_rax4(elf_ctx) !=0)) {
        return (0 - 1);
      }
      {
        (void)((re11 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_b, ta)));
      }
      if ((re11 !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm1_from_rbx_rax4(elf_ctx) !=0)) {
        return (0 - 1);
      }
      if ((binop_ko ==5)) {
        if ((simd_x86_vpsubd_ymm0_ymm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((binop_ko ==6)) {
          if ((simd_x86_vpmulld_ymm0_ymm1(elf_ctx) !=0)) {
            return (0 - 1);
          }
        } else {
          if ((simd_x86_vpaddd_ymm0_ymm1(elf_ctx) !=0)) {
            return (0 - 1);
          }
        }
      }
      {
        (void)((re12 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_d, ta)));
      }
      if ((re12 !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm0_to_rbx_rax4(elf_ctx) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  if ((lanes ==4)) {
    int32_t re13 = 0;
    int32_t re14 = 0;
    if ((binop_ko ==6)) {
      if (((cpu_features & 2) ==0)) {
        return (0 - 1);
      }
    } else {
      if (((cpu_features & 1) ==0)) {
        return (0 - 1);
      }
    }
    if ((simd_x86_movups_xmm0_from_rbx_rax4(elf_ctx) !=0)) {
      return (0 - 1);
    }
    {
      (void)((re13 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_b, ta)));
    }
    if ((re13 !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_movups_xmm1_from_rbx_rax4(elf_ctx) !=0)) {
      return (0 - 1);
    }
    if ((binop_ko ==5)) {
      if ((simd_x86_psubd_xmm0_xmm1(elf_ctx) !=0)) {
        return (0 - 1);
      }
    } else {
      if ((binop_ko ==6)) {
        if ((simd_x86_pmulld_xmm0_xmm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((simd_x86_paddd_xmm0_xmm1(elf_ctx) !=0)) {
          return (0 - 1);
        }
      }
    }
    {
      (void)((re14 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_d, ta)));
    }
    if ((re14 !=0)) {
      return (0 - 1);
    }
    if ((simd_x86_movups_xmm0_to_rbx_rax4(elf_ctx) !=0)) {
      return (0 - 1);
    }
    return 0;
  }
  return (0 - 1);
}
int32_t simd_enc_try_pshufd_rbp(uint8_t * elf_ctx, int32_t slot_off_src, int32_t slot_off_dst, int32_t imm8, int32_t lanes, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_src < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  int32_t ds = simd_rbp_disp32(slot_off_src, lanes, 4);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, 4);
  if ((ta ==1)) {
    if (((cpu_features & 256) ==0)) {
      return (0 - 1);
    }
    (void)((ds = simd_arm64_rbp_lea_off_128half(slot_off_src, 0, 4)));
    (void)((dd = simd_arm64_rbp_lea_off_128half(slot_off_dst, 0, 4)));
    if ((lanes ==4)) {
      return simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds, dd, imm8, ta);
    }
    if ((lanes ==8)) {
      int32_t ds1 = simd_arm64_rbp_lea_off_128half(slot_off_src, 1, 4);
      int32_t dd1 = simd_arm64_rbp_lea_off_128half(slot_off_dst, 1, 4);
      if ((simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds, dd, imm8, ta) !=0)) {
        return (0 - 1);
      }
      if ((simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds1, dd1, imm8, ta) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((lanes ==8)) {
    if (((cpu_features & 8) !=0)) {
      if ((simd_x86_vmovups_ymm0_from_rbp(elf_ctx, ds) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vpshufd_ymm0_imm8(elf_ctx, imm8) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  if ((lanes ==4)) {
    if (((cpu_features & 1) !=0)) {
      if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, ds) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_pshufd_xmm0_imm8(elf_ctx, imm8) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  return (0 - 1);
}
int32_t simd_enc_try_hw_vector_select_rbp(uint8_t * elf_ctx, int32_t slot_off_mask, int32_t slot_off_a, int32_t slot_off_b, int32_t slot_off_dst, int32_t lanes, int32_t is_f32, int32_t ta, uint32_t cpu_features) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((slot_off_mask < 0)) {
    return (0 - 1);
  }
  if ((slot_off_a < 0)) {
    return (0 - 1);
  }
  if ((slot_off_b < 0)) {
    return (0 - 1);
  }
  if ((slot_off_dst < 0)) {
    return (0 - 1);
  }
  int32_t dm = simd_rbp_disp32(slot_off_mask, lanes, 4);
  int32_t da = simd_rbp_disp32(slot_off_a, lanes, 4);
  int32_t db = simd_rbp_disp32(slot_off_b, lanes, 4);
  int32_t dd = simd_rbp_disp32(slot_off_dst, lanes, 4);
  if ((ta ==1)) {
    if (((cpu_features & 256) ==0)) {
      return (0 - 1);
    }
    (void)((dm = simd_arm64_rbp_lea_off_128half(slot_off_mask, 0, 4)));
    (void)((da = simd_arm64_rbp_lea_off_128half(slot_off_a, 0, 4)));
    (void)((db = simd_arm64_rbp_lea_off_128half(slot_off_b, 0, 4)));
    (void)((dd = simd_arm64_rbp_lea_off_128half(slot_off_dst, 0, 4)));
    if ((lanes ==4)) {
      return simd_arm64_select_128_rbp(elf_ctx, dm, da, db, dd, is_f32, ta);
    }
    if ((lanes ==8)) {
      int32_t dm1 = simd_arm64_rbp_lea_off_128half(slot_off_mask, 1, 4);
      int32_t da1 = simd_arm64_rbp_lea_off_128half(slot_off_a, 1, 4);
      int32_t db1 = simd_arm64_rbp_lea_off_128half(slot_off_b, 1, 4);
      int32_t dd1 = simd_arm64_rbp_lea_off_128half(slot_off_dst, 1, 4);
      if ((simd_arm64_select_128_rbp(elf_ctx, dm, da, db, dd, is_f32, ta) !=0)) {
        return (0 - 1);
      }
      if ((simd_arm64_select_128_rbp(elf_ctx, dm1, da1, db1, dd1, is_f32, ta) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
    return (0 - 1);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((lanes ==8)) {
    if (((cpu_features & 8) !=0)) {
      if ((simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_vmovups_ymm2_from_rbp(elf_ctx, dm) !=0)) {
        return (0 - 1);
      }
      if ((is_f32 !=0)) {
        if ((simd_enc_emit_f32_select_ymm_seq(elf_ctx) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((simd_enc_emit_i32_select_ymm_seq(elf_ctx) !=0)) {
          return (0 - 1);
        }
      }
      if ((simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  if ((lanes ==4)) {
    if (((cpu_features & 1) !=0)) {
      if ((simd_x86_movups_xmm0_from_rbp(elf_ctx, da) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_movups_xmm1_from_rbp(elf_ctx, db) !=0)) {
        return (0 - 1);
      }
      if ((simd_x86_movups_xmm2_from_rbp(elf_ctx, dm) !=0)) {
        return (0 - 1);
      }
      if ((is_f32 !=0)) {
        if ((simd_enc_emit_f32_select_xmm_seq(elf_ctx) !=0)) {
          return (0 - 1);
        }
      } else {
        if ((simd_enc_emit_i32_select_xmm_seq(elf_ctx) !=0)) {
          return (0 - 1);
        }
      }
      if ((simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) !=0)) {
        return (0 - 1);
      }
      return 0;
    }
  }
  return (0 - 1);
}

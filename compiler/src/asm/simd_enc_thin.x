// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_SIMD_ENC_THIN_FROM_X）ld -r → simd_enc.o
// See implementation.
// See implementation.
// See implementation.
//

// arm64 INS encoding: 0x6E040000 | ((dst&3)<<19) | ((src&3)<<13) | 0x401
#[no_mangle]
/** Exported function `simd_arm64_ins_v1_from_v0_s`.
 * Implements `simd_arm64_ins_v1_from_v0_s`.
 * @param dst_lane i32
 * @param src_lane i32
 * @return u32
 */
export function simd_arm64_ins_v1_from_v0_s(dst_lane: i32, src_lane: i32): u32 {
  let d: i32 = dst_lane & 3;
  let s: i32 = src_lane & 3;
  let enc: i32 = 1846018048 | (d << 19) | (s << 13) | 1025;
  return enc;
}

// arm64 128-bit half lea positive off（sub x29,#off）
#[no_mangle]
/** Exported function `simd_arm64_rbp_lea_off_128half`.
 * Implements `simd_arm64_rbp_lea_off_128half`.
 * @param slot i32
 * @param half i32
 * @param esz i32
 * @return i32
 */
export function simd_arm64_rbp_lea_off_128half(slot: i32, half: i32, esz: i32): i32 {
  if (slot < 0) {
    return slot;
  }
  if (esz <= 0) {
    return slot;
  }
  if (half < 0) {
    return slot;
  }
  return slot - half * 4 * esz;
}

// simd_rbp_disp32: see function docblock below.
#[no_mangle]
/** Exported function `simd_rbp_disp32`.
 * Implements `simd_rbp_disp32`.
 * @param slot_off i32
 * @param lanes i32
 * @param esz i32
 * @return i32
 */
export function simd_rbp_disp32(slot_off: i32, lanes: i32, esz: i32): i32 {
  if (slot_off < 0) {
    return 0;
  }
  return 0 - slot_off;
}

// ---- G-02f-385/390–399：append / insn → seed impl ----
export extern "C" function simd_append_impl(elf_ctx: *u8, bytes: *u8, n: i32): i32;
export extern "C" function simd_append_disp32_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_addps_xmm0_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_paddd_xmm0_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_psubd_xmm0_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpsubd_ymm0_ymm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpaddd_ymm0_ymm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_mulps_xmm0_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_pmulld_xmm0_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpmulld_ymm0_ymm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_pxor_xmm3_xmm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_pcmpgtd_xmm2_xmm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_pand_xmm0_xmm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_pandn_xmm2_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_por_xmm0_xmm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_xorps_xmm3_xmm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_cmpgtps_xmm2_xmm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_andps_xmm0_xmm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_andnps_xmm2_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_orps_xmm0_xmm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpxor_ymm3_ymm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpcmpgtd_ymm2_ymm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpand_ymm0_ymm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpandn_ymm2_ymm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vpor_ymm0_ymm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vxorps_ymm3_ymm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vcmpgtps_ymm2_ymm3_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vandps_ymm0_ymm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vandnps_ymm2_ymm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vorps_ymm0_ymm2_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vmovups_ymm0_from_rbx_rax4_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vmovups_ymm1_from_rbx_rax4_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_vmovups_ymm0_to_rbx_rax4_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_movups_xmm0_from_rbx_rax4_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_movups_xmm1_from_rbx_rax4_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_movups_xmm0_to_rbx_rax4_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_movups_xmm0_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_movups_xmm1_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_movups_xmm0_to_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_vmovups_ymm0_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_vmovups_ymm1_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_vmovups_ymm0_to_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_movups_xmm2_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_x86_vmovups_ymm2_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_enc_x86_xorps_xmm0_zero_impl(elf_ctx: *u8): i32;
export extern "C" function simd_enc_x86_movups_xmm1_rbp_disp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_enc_x86_addps_xmm0_xmm1_impl(elf_ctx: *u8): i32;
export extern "C" function simd_enc_try_hw_vector_iadd_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_enc_try_hw_vector_isub_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_append_u32_le_impl(elf_ctx: *u8, word: u32): i32;
export extern "C" function simd_x86_pshufd_xmm0_imm8_impl(elf_ctx: *u8, imm8: i32): i32;
export extern "C" function simd_x86_vpshufd_ymm0_imm8_impl(elf_ctx: *u8, imm8: i32): i32;

#[no_mangle]
/** Exported function `simd_append`.
 * Implements `simd_append`.
 * @param elf_ctx *u8
 * @param bytes *u8
 * @param n i32
 * @return i32
 */
export function simd_append(elf_ctx: *u8, bytes: *u8, n: i32): i32 {
  unsafe {
    return simd_append_impl(elf_ctx, bytes, n);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_append_disp32`.
 * Implements `simd_append_disp32`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_append_disp32(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_append_disp32_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_addps_xmm0_xmm1`.
 * Implements `simd_x86_addps_xmm0_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_addps_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_addps_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_paddd_xmm0_xmm1`.
 * Implements `simd_x86_paddd_xmm0_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_paddd_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_paddd_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_psubd_xmm0_xmm1`.
 * Implements `simd_x86_psubd_xmm0_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_psubd_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_psubd_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpsubd_ymm0_ymm1`.
 * Implements `simd_x86_vpsubd_ymm0_ymm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpsubd_ymm0_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpsubd_ymm0_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpaddd_ymm0_ymm1`.
 * Implements `simd_x86_vpaddd_ymm0_ymm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpaddd_ymm0_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpaddd_ymm0_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_mulps_xmm0_xmm1`.
 * Implements `simd_x86_mulps_xmm0_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_mulps_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_mulps_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pmulld_xmm0_xmm1`.
 * Implements `simd_x86_pmulld_xmm0_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_pmulld_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pmulld_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpmulld_ymm0_ymm1`.
 * Implements `simd_x86_vpmulld_ymm0_ymm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpmulld_ymm0_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpmulld_ymm0_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vfmadd231ps_xmm0_xmm1_xmm2`.
 * Implements `simd_x86_vfmadd231ps_xmm0_xmm1_xmm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pxor_xmm3_xmm3`.
 * Implements `simd_x86_pxor_xmm3_xmm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_pxor_xmm3_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pxor_xmm3_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pcmpgtd_xmm2_xmm3`.
 * Comparison/utility `simd_x86_pcmpgtd_xmm2_xmm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_pcmpgtd_xmm2_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pcmpgtd_xmm2_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pand_xmm0_xmm2`.
 * Implements `simd_x86_pand_xmm0_xmm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_pand_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pand_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pandn_xmm2_xmm1`.
 * Implements `simd_x86_pandn_xmm2_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_pandn_xmm2_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pandn_xmm2_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_por_xmm0_xmm2`.
 * Implements `simd_x86_por_xmm0_xmm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_por_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_por_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_xorps_xmm3_xmm3`.
 * Implements `simd_x86_xorps_xmm3_xmm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_xorps_xmm3_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_xorps_xmm3_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_cmpgtps_xmm2_xmm3`.
 * Comparison/utility `simd_x86_cmpgtps_xmm2_xmm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_cmpgtps_xmm2_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_cmpgtps_xmm2_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_andps_xmm0_xmm2`.
 * Implements `simd_x86_andps_xmm0_xmm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_andps_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_andps_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_andnps_xmm2_xmm1`.
 * Implements `simd_x86_andnps_xmm2_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_andnps_xmm2_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_andnps_xmm2_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_orps_xmm0_xmm2`.
 * Implements `simd_x86_orps_xmm0_xmm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_orps_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_orps_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpxor_ymm3_ymm3`.
 * Implements `simd_x86_vpxor_ymm3_ymm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpxor_ymm3_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpxor_ymm3_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpcmpgtd_ymm2_ymm3`.
 * Comparison/utility `simd_x86_vpcmpgtd_ymm2_ymm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpcmpgtd_ymm2_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpcmpgtd_ymm2_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpand_ymm0_ymm2`.
 * Implements `simd_x86_vpand_ymm0_ymm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpand_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpand_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpandn_ymm2_ymm1`.
 * Implements `simd_x86_vpandn_ymm2_ymm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpandn_ymm2_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpandn_ymm2_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpor_ymm0_ymm2`.
 * Implements `simd_x86_vpor_ymm0_ymm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vpor_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpor_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vxorps_ymm3_ymm3`.
 * Implements `simd_x86_vxorps_ymm3_ymm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vxorps_ymm3_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vxorps_ymm3_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vcmpgtps_ymm2_ymm3`.
 * Comparison/utility `simd_x86_vcmpgtps_ymm2_ymm3`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vcmpgtps_ymm2_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vcmpgtps_ymm2_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vandps_ymm0_ymm2`.
 * Implements `simd_x86_vandps_ymm0_ymm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vandps_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vandps_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vandnps_ymm2_ymm1`.
 * Implements `simd_x86_vandnps_ymm2_ymm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vandnps_ymm2_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vandnps_ymm2_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vorps_ymm0_ymm2`.
 * Implements `simd_x86_vorps_ymm0_ymm2`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vorps_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vorps_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm0_from_rbx_rax4`.
 * Implements `simd_x86_vmovups_ymm0_from_rbx_rax4`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vmovups_ymm0_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm1_from_rbx_rax4`.
 * Implements `simd_x86_vmovups_ymm1_from_rbx_rax4`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vmovups_ymm1_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vmovups_ymm1_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm0_to_rbx_rax4`.
 * Implements `simd_x86_vmovups_ymm0_to_rbx_rax4`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_vmovups_ymm0_to_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_to_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm0_from_rbx_rax4`.
 * Implements `simd_x86_movups_xmm0_from_rbx_rax4`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_movups_xmm0_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_movups_xmm0_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm1_from_rbx_rax4`.
 * Implements `simd_x86_movups_xmm1_from_rbx_rax4`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_movups_xmm1_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_movups_xmm1_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm0_to_rbx_rax4`.
 * Implements `simd_x86_movups_xmm0_to_rbx_rax4`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_x86_movups_xmm0_to_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_movups_xmm0_to_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm0_from_rbp`.
 * Implements `simd_x86_movups_xmm0_from_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_movups_xmm0_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm0_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm1_from_rbp`.
 * Implements `simd_x86_movups_xmm1_from_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_movups_xmm1_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm1_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm0_to_rbp`.
 * Implements `simd_x86_movups_xmm0_to_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_movups_xmm0_to_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm0_to_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm0_from_rbp`.
 * Implements `simd_x86_vmovups_ymm0_from_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_vmovups_ymm0_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm1_from_rbp`.
 * Implements `simd_x86_vmovups_ymm1_from_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_vmovups_ymm1_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm1_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm0_to_rbp`.
 * Implements `simd_x86_vmovups_ymm0_to_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_vmovups_ymm0_to_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_to_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_movups_xmm2_from_rbp`.
 * Implements `simd_x86_movups_xmm2_from_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_movups_xmm2_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm2_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vmovups_ymm2_from_rbp`.
 * Implements `simd_x86_vmovups_ymm2_from_rbp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_x86_vmovups_ymm2_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm2_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_x86_xorps_xmm0_zero`.
 * Implements `simd_enc_x86_xorps_xmm0_zero`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_x86_xorps_xmm0_zero(elf_ctx: *u8): i32 {
  unsafe {
    return simd_enc_x86_xorps_xmm0_zero_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_x86_movups_xmm1_rbp_disp`.
 * Implements `simd_enc_x86_movups_xmm1_rbp_disp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_enc_x86_movups_xmm1_rbp_disp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_enc_x86_movups_xmm1_rbp_disp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_x86_addps_xmm0_xmm1`.
 * Implements `simd_enc_x86_addps_xmm0_xmm1`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_x86_addps_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_enc_x86_addps_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_iadd_rbp`.
 * Implements `simd_enc_try_hw_vector_iadd_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_iadd_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe {
    return simd_enc_try_hw_vector_iadd_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_isub_rbp`.
 * Implements `simd_enc_try_hw_vector_isub_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_isub_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe {
    return simd_enc_try_hw_vector_isub_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_append_u32_le`.
 * Implements `simd_append_u32_le`.
 * @param elf_ctx *u8
 * @param word u32
 * @return i32
 */
export function simd_append_u32_le(elf_ctx: *u8, word: u32): i32 {
  unsafe {
    return simd_append_u32_le_impl(elf_ctx, word);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pshufd_xmm0_imm8`.
 * Implements `simd_x86_pshufd_xmm0_imm8`.
 * @param elf_ctx *u8
 * @param imm8 i32
 * @return i32
 */
export function simd_x86_pshufd_xmm0_imm8(elf_ctx: *u8, imm8: i32): i32 {
  unsafe {
    return simd_x86_pshufd_xmm0_imm8_impl(elf_ctx, imm8);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_vpshufd_ymm0_imm8`.
 * Implements `simd_x86_vpshufd_ymm0_imm8`.
 * @param elf_ctx *u8
 * @param imm8 i32
 * @return i32
 */
export function simd_x86_vpshufd_ymm0_imm8(elf_ctx: *u8, imm8: i32): i32 {
  unsafe {
    return simd_x86_vpshufd_ymm0_imm8_impl(elf_ctx, imm8);
  }
  return 0 - 1;
}

// ---- G-02f-417：select seq + pshufd/hadd/movss/soa → seed impl ----
export extern "C" function simd_enc_emit_i32_select_xmm_seq_impl(elf_ctx: *u8): i32;
export extern "C" function simd_enc_emit_f32_select_xmm_seq_impl(elf_ctx: *u8): i32;
export extern "C" function simd_enc_emit_i32_select_ymm_seq_impl(elf_ctx: *u8): i32;
export extern "C" function simd_enc_emit_f32_select_ymm_seq_impl(elf_ctx: *u8): i32;
export extern "C" function simd_x86_pshufd_xmm1_xmm0_impl(elf_ctx: *u8, imm: u8): i32;
export extern "C" function simd_enc_x86_horizontal_addps_xmm0_impl(elf_ctx: *u8): i32;
export extern "C" function simd_enc_x86_movss_xmm0_rbp_disp_impl(elf_ctx: *u8, disp: i32): i32;
export extern "C" function simd_enc_f32_soa_col_movups_xmm1_at_idx_impl(elf_ctx: *u8, off_col0: i32, off_i: i32, ta: i32): i32;

#[no_mangle]
/** Exported function `simd_enc_emit_i32_select_xmm_seq`.
 * Implements `simd_enc_emit_i32_select_xmm_seq`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_emit_i32_select_xmm_seq(elf_ctx: *u8): i32 {
  unsafe { return simd_enc_emit_i32_select_xmm_seq_impl(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_emit_f32_select_xmm_seq`.
 * Implements `simd_enc_emit_f32_select_xmm_seq`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_emit_f32_select_xmm_seq(elf_ctx: *u8): i32 {
  unsafe { return simd_enc_emit_f32_select_xmm_seq_impl(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_emit_i32_select_ymm_seq`.
 * Implements `simd_enc_emit_i32_select_ymm_seq`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_emit_i32_select_ymm_seq(elf_ctx: *u8): i32 {
  unsafe { return simd_enc_emit_i32_select_ymm_seq_impl(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_emit_f32_select_ymm_seq`.
 * Implements `simd_enc_emit_f32_select_ymm_seq`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_emit_f32_select_ymm_seq(elf_ctx: *u8): i32 {
  unsafe { return simd_enc_emit_f32_select_ymm_seq_impl(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_x86_pshufd_xmm1_xmm0`.
 * Implements `simd_x86_pshufd_xmm1_xmm0`.
 * @param elf_ctx *u8
 * @param imm u8
 * @return i32
 */
export function simd_x86_pshufd_xmm1_xmm0(elf_ctx: *u8, imm: u8): i32 {
  unsafe { return simd_x86_pshufd_xmm1_xmm0_impl(elf_ctx, imm); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_x86_horizontal_addps_xmm0`.
 * Implements `simd_enc_x86_horizontal_addps_xmm0`.
 * @param elf_ctx *u8
 * @return i32
 */
export function simd_enc_x86_horizontal_addps_xmm0(elf_ctx: *u8): i32 {
  unsafe { return simd_enc_x86_horizontal_addps_xmm0_impl(elf_ctx); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_x86_movss_xmm0_rbp_disp`.
 * Implements `simd_enc_x86_movss_xmm0_rbp_disp`.
 * @param elf_ctx *u8
 * @param disp i32
 * @return i32
 */
export function simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx: *u8, disp: i32): i32 {
  unsafe { return simd_enc_x86_movss_xmm0_rbp_disp_impl(elf_ctx, disp); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_f32_soa_col_movups_xmm1_at_idx`.
 * Implements `simd_enc_f32_soa_col_movups_xmm1_at_idx`.
 * @param elf_ctx *u8
 * @param off_col0 i32
 * @param off_i i32
 * @param ta i32
 * @return i32
 */
export function simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx: *u8, off_col0: i32, off_i: i32, ta: i32): i32 {
  unsafe { return simd_enc_f32_soa_col_movups_xmm1_at_idx_impl(elf_ctx, off_col0, off_i, ta); }
  return 0 - 1;
}

// ---- G-02f-418：try_hw / arm64 pshufd-select closeout → seed impl ----
export extern "C" function simd_enc_try_hw_vector_iadd_isub_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32, is_sub: i32): i32;
export extern "C" function simd_enc_try_hw_vector_imul_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_enc_try_hw_vector_fadd_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_enc_try_hw_vector_fmul_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_enc_try_hw_vector_fma_rbp_impl(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_c: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_enc_try_hw_vector_binop_rbp_at_idx_impl(elf_ctx: *u8, off_a: i32, off_b: i32, off_d: i32, off_i: i32, array_n: i32, binop_ko: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_arm64_pshufd_imm8_128_rbp_impl(elf_ctx: *u8, lea_src: i32, lea_dst: i32, imm8: i32, ta: i32): i32;
export extern "C" function simd_arm64_select_128_rbp_impl(elf_ctx: *u8, lea_mask: i32, lea_a: i32, lea_b: i32, lea_dst: i32, is_f32: i32, ta: i32): i32;
export extern "C" function simd_enc_try_pshufd_rbp_impl(elf_ctx: *u8, slot_off_src: i32, slot_off_dst: i32, imm8: i32, lanes: i32, ta: i32, cpu_features: u32): i32;
export extern "C" function simd_enc_try_hw_vector_select_rbp_impl(elf_ctx: *u8, slot_off_mask: i32, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, is_f32: i32, ta: i32, cpu_features: u32): i32;

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_iadd_isub_rbp`.
 * Implements `simd_enc_try_hw_vector_iadd_isub_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @param is_sub i32
 * @return i32
 */
export function simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32, is_sub: i32): i32 {
  unsafe { return simd_enc_try_hw_vector_iadd_isub_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, is_sub); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_imul_rbp`.
 * Implements `simd_enc_try_hw_vector_imul_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_imul_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_hw_vector_imul_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_fadd_rbp`.
 * Implements `simd_enc_try_hw_vector_fadd_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_fadd_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_hw_vector_fadd_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_fmul_rbp`.
 * Implements `simd_enc_try_hw_vector_fmul_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_fmul_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_hw_vector_fmul_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_fma_rbp`.
 * Implements `simd_enc_try_hw_vector_fma_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_c i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_fma_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_c: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_hw_vector_fma_rbp_impl(elf_ctx, slot_off_a, slot_off_b, slot_off_c, slot_off_dst, lanes, esz, ta, cpu_features); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_binop_rbp_at_idx`.
 * Implements `simd_enc_try_hw_vector_binop_rbp_at_idx`.
 * @param elf_ctx *u8
 * @param off_a i32
 * @param off_b i32
 * @param off_d i32
 * @param off_i i32
 * @param array_n i32
 * @param binop_ko i32
 * @param lanes i32
 * @param esz i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_binop_rbp_at_idx(elf_ctx: *u8, off_a: i32, off_b: i32, off_d: i32, off_i: i32, array_n: i32, binop_ko: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_hw_vector_binop_rbp_at_idx_impl(elf_ctx, off_a, off_b, off_d, off_i, array_n, binop_ko, lanes, esz, ta, cpu_features); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_arm64_pshufd_imm8_128_rbp`.
 * Implements `simd_arm64_pshufd_imm8_128_rbp`.
 * @param elf_ctx *u8
 * @param lea_src i32
 * @param lea_dst i32
 * @param imm8 i32
 * @param ta i32
 * @return i32
 */
export function simd_arm64_pshufd_imm8_128_rbp(elf_ctx: *u8, lea_src: i32, lea_dst: i32, imm8: i32, ta: i32): i32 {
  unsafe { return simd_arm64_pshufd_imm8_128_rbp_impl(elf_ctx, lea_src, lea_dst, imm8, ta); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_arm64_select_128_rbp`.
 * Implements `simd_arm64_select_128_rbp`.
 * @param elf_ctx *u8
 * @param lea_mask i32
 * @param lea_a i32
 * @param lea_b i32
 * @param lea_dst i32
 * @param is_f32 i32
 * @param ta i32
 * @return i32
 */
export function simd_arm64_select_128_rbp(elf_ctx: *u8, lea_mask: i32, lea_a: i32, lea_b: i32, lea_dst: i32, is_f32: i32, ta: i32): i32 {
  unsafe { return simd_arm64_select_128_rbp_impl(elf_ctx, lea_mask, lea_a, lea_b, lea_dst, is_f32, ta); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_pshufd_rbp`.
 * Implements `simd_enc_try_pshufd_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_src i32
 * @param slot_off_dst i32
 * @param imm8 i32
 * @param lanes i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_pshufd_rbp(elf_ctx: *u8, slot_off_src: i32, slot_off_dst: i32, imm8: i32, lanes: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_pshufd_rbp_impl(elf_ctx, slot_off_src, slot_off_dst, imm8, lanes, ta, cpu_features); }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `simd_enc_try_hw_vector_select_rbp`.
 * Implements `simd_enc_try_hw_vector_select_rbp`.
 * @param elf_ctx *u8
 * @param slot_off_mask i32
 * @param slot_off_a i32
 * @param slot_off_b i32
 * @param slot_off_dst i32
 * @param lanes i32
 * @param is_f32 i32
 * @param ta i32
 * @param cpu_features u32
 * @return i32
 */
export function simd_enc_try_hw_vector_select_rbp(elf_ctx: *u8, slot_off_mask: i32, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, is_f32: i32, ta: i32, cpu_features: u32): i32 {
  unsafe { return simd_enc_try_hw_vector_select_rbp_impl(elf_ctx, slot_off_mask, slot_off_a, slot_off_b, slot_off_dst, lanes, is_f32, ta, cpu_features); }
  return 0 - 1;
}

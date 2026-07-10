// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-348/385/390–397：simd_enc L2 thin — pure 编码助手 + insn forward（46 门闩）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_SIMD_ENC_THIN_FROM_X）ld -r → simd_enc.o
// 完整逻辑对照：src/asm/simd_enc.x；产品默认仍整 seed。
//

// arm64 INS encoding: 0x6E040000 | ((dst&3)<<19) | ((src&3)<<13) | 0x401
#[no_mangle]
function simd_arm64_ins_v1_from_v0_s(dst_lane: i32, src_lane: i32): u32 {
  let d: i32 = dst_lane & 3;
  let s: i32 = src_lane & 3;
  let enc: i32 = 1846018048 | (d << 19) | (s << 13) | 1025;
  return enc;
}

// arm64 128-bit half lea positive off（sub x29,#off）
#[no_mangle]
function simd_arm64_rbp_lea_off_128half(slot: i32, half: i32, esz: i32): i32 {
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

// rbp disp：负 slot → 0；否则 -slot（lanes/esz 保留 ABI，产品 seed 同语义）
#[no_mangle]
function simd_rbp_disp32(slot_off: i32, lanes: i32, esz: i32): i32 {
  if (slot_off < 0) {
    return 0;
  }
  return 0 - slot_off;
}

// ---- G-02f-385/390–397：append / insn → seed impl ----
extern "C" function simd_append_impl(elf_ctx: *u8, bytes: *u8, n: i32): i32;
extern "C" function simd_append_disp32_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_addps_xmm0_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_paddd_xmm0_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_psubd_xmm0_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpsubd_ymm0_ymm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpaddd_ymm0_ymm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_mulps_xmm0_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_pmulld_xmm0_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpmulld_ymm0_ymm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_pxor_xmm3_xmm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_pcmpgtd_xmm2_xmm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_pand_xmm0_xmm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_pandn_xmm2_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_por_xmm0_xmm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_xorps_xmm3_xmm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_cmpgtps_xmm2_xmm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_andps_xmm0_xmm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_andnps_xmm2_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_orps_xmm0_xmm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpxor_ymm3_ymm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpcmpgtd_ymm2_ymm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpand_ymm0_ymm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpandn_ymm2_ymm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vpor_ymm0_ymm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vxorps_ymm3_ymm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vcmpgtps_ymm2_ymm3_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vandps_ymm0_ymm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vandnps_ymm2_ymm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vorps_ymm0_ymm2_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vmovups_ymm0_from_rbx_rax4_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vmovups_ymm1_from_rbx_rax4_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_vmovups_ymm0_to_rbx_rax4_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_movups_xmm0_from_rbx_rax4_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_movups_xmm1_from_rbx_rax4_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_movups_xmm0_to_rbx_rax4_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_movups_xmm0_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_movups_xmm1_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_movups_xmm0_to_rbp_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_vmovups_ymm0_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_vmovups_ymm1_from_rbp_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_vmovups_ymm0_to_rbp_impl(elf_ctx: *u8, disp: i32): i32;

#[no_mangle]
function simd_append(elf_ctx: *u8, bytes: *u8, n: i32): i32 {
  unsafe {
    return simd_append_impl(elf_ctx, bytes, n);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_append_disp32(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_append_disp32_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_addps_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_addps_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_paddd_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_paddd_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_psubd_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_psubd_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpsubd_ymm0_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpsubd_ymm0_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpaddd_ymm0_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpaddd_ymm0_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_mulps_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_mulps_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pmulld_xmm0_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pmulld_xmm0_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpmulld_ymm0_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpmulld_ymm0_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pxor_xmm3_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pxor_xmm3_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pcmpgtd_xmm2_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pcmpgtd_xmm2_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pand_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pand_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pandn_xmm2_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_pandn_xmm2_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_por_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_por_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_xorps_xmm3_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_xorps_xmm3_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_cmpgtps_xmm2_xmm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_cmpgtps_xmm2_xmm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_andps_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_andps_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_andnps_xmm2_xmm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_andnps_xmm2_xmm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_orps_xmm0_xmm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_orps_xmm0_xmm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpxor_ymm3_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpxor_ymm3_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpcmpgtd_ymm2_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpcmpgtd_ymm2_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpand_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpand_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpandn_ymm2_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpandn_ymm2_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpor_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vpor_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vxorps_ymm3_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vxorps_ymm3_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vcmpgtps_ymm2_ymm3(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vcmpgtps_ymm2_ymm3_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vandps_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vandps_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vandnps_ymm2_ymm1(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vandnps_ymm2_ymm1_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vorps_ymm0_ymm2(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vorps_ymm0_ymm2_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm1_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vmovups_ymm1_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_to_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_to_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_movups_xmm0_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm1_from_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_movups_xmm1_from_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_to_rbx_rax4(elf_ctx: *u8): i32 {
  unsafe {
    return simd_x86_movups_xmm0_to_rbx_rax4_impl(elf_ctx);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm0_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm1_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm1_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_to_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_movups_xmm0_to_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm1_from_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm1_from_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_to_rbp(elf_ctx: *u8, disp: i32): i32 {
  unsafe {
    return simd_x86_vmovups_ymm0_to_rbp_impl(elf_ctx, disp);
  }
  return 0 - 1;
}

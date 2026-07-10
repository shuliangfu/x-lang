// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-7：simd_enc 产品源迁 seeds/simd_enc.from_x.c（纯编码，无 OS #if）。
// 本文件为语义对照 / 后续真迁 .x 的入口说明；全量 opcode 表仍在 seed C。
// 产品：cc seeds/simd_enc.from_x.c → src/asm/simd_enc.o
//
// 导出（C ABI，见 include/simd_enc.h）：
//   simd_enc_try_hw_vector_*_rbp / pshufd / select / 低层 x86 enc helpers 等。

// 占位：避免空 TU；产品不链本 .x 生成物。
function simd_enc_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108：+ rbp/append/x86 movups/padd 薄门闩。

extern "C" function simd_append_impl(elf: *u8, bytes: *u8, n: i32): i32;
extern "C" function simd_append_disp32_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_movups_xmm0_from_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_movups_xmm1_from_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_addps_xmm0_xmm1_impl(elf: *u8): i32;
extern "C" function simd_x86_paddd_xmm0_xmm1_impl(elf: *u8): i32;
extern "C" function simd_x86_movups_xmm0_to_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_vmovups_ymm0_from_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_vmovups_ymm1_from_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_vpaddd_ymm0_ymm1_impl(elf: *u8): i32;
extern "C" function simd_x86_vmovups_ymm0_to_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_psubd_xmm0_xmm1_impl(elf: *u8): i32;
extern "C" function simd_x86_vpsubd_ymm0_ymm1_impl(elf: *u8): i32;

/* ---- G-02f-108：simd_enc low-level helpers 门闩 ---- */




#[no_mangle]
function simd_append(elf: *u8, bytes: *u8, n: i32): i32 {
  unsafe { return simd_append_impl(elf, bytes, n); }
  return 0;
}

#[no_mangle]
function simd_append_disp32(elf: *u8, disp: i32): i32 {
  unsafe { return simd_append_disp32_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_movups_xmm0_from_rbp(elf: *u8, disp: i32): i32 {
  unsafe { return simd_x86_movups_xmm0_from_rbp_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_movups_xmm1_from_rbp(elf: *u8, disp: i32): i32 {
  unsafe { return simd_x86_movups_xmm1_from_rbp_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_addps_xmm0_xmm1(elf: *u8): i32 {
  unsafe { return simd_x86_addps_xmm0_xmm1_impl(elf); }
  return 0;
}

#[no_mangle]
function simd_x86_paddd_xmm0_xmm1(elf: *u8): i32 {
  unsafe { return simd_x86_paddd_xmm0_xmm1_impl(elf); }
  return 0;
}

#[no_mangle]
function simd_x86_movups_xmm0_to_rbp(elf: *u8, disp: i32): i32 {
  unsafe { return simd_x86_movups_xmm0_to_rbp_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_from_rbp(elf: *u8, disp: i32): i32 {
  unsafe { return simd_x86_vmovups_ymm0_from_rbp_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_vmovups_ymm1_from_rbp(elf: *u8, disp: i32): i32 {
  unsafe { return simd_x86_vmovups_ymm1_from_rbp_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_vpaddd_ymm0_ymm1(elf: *u8): i32 {
  unsafe { return simd_x86_vpaddd_ymm0_ymm1_impl(elf); }
  return 0;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_to_rbp(elf: *u8, disp: i32): i32 {
  unsafe { return simd_x86_vmovups_ymm0_to_rbp_impl(elf, disp); }
  return 0;
}

#[no_mangle]
function simd_x86_psubd_xmm0_xmm1(elf: *u8): i32 {
  unsafe { return simd_x86_psubd_xmm0_xmm1_impl(elf); }
  return 0;
}

#[no_mangle]
function simd_x86_vpsubd_ymm0_ymm1(elf: *u8): i32 {
  unsafe { return simd_x86_vpsubd_ymm0_ymm1_impl(elf); }
  return 0;
}

// G-02f-109：+ mul/vfmadd/rbx_rax4/pshufd/select 薄门闩。

extern "C" function simd_x86_pmulld_xmm0_xmm1_impl(elf: *u8): i32;
extern "C" function simd_x86_vpmulld_ymm0_ymm1_impl(elf: *u8): i32;
extern "C" function simd_x86_mulps_xmm0_xmm1_impl(elf: *u8): i32;
extern "C" function simd_x86_movups_xmm2_from_rbp_impl(elf: *u8, disp: i32): i32;
extern "C" function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl(elf: *u8): i32;
extern "C" function simd_x86_vmovups_ymm0_from_rbx_rax4_impl(elf: *u8): i32;
extern "C" function simd_x86_vmovups_ymm1_from_rbx_rax4_impl(elf: *u8): i32;
extern "C" function simd_x86_vmovups_ymm0_to_rbx_rax4_impl(elf: *u8): i32;
extern "C" function simd_x86_movups_xmm0_from_rbx_rax4_impl(elf: *u8): i32;
extern "C" function simd_x86_movups_xmm1_from_rbx_rax4_impl(elf: *u8): i32;
extern "C" function simd_x86_movups_xmm0_to_rbx_rax4_impl(elf: *u8): i32;
extern "C" function simd_append_u32_le_impl(elf: *u8, word: u32): i32;
extern "C" function simd_arm64_ins_v1_from_v0_s_impl(dst: i32, src: i32): u32;
extern "C" function simd_arm64_pshufd_imm8_128_rbp_impl(elf: *u8, lea_src: i32, lea_dst: i32, imm8: i32): i32;
extern "C" function simd_arm64_select_128_rbp_impl(elf: *u8, lea_mask: i32, lea_a: i32, lea_b: i32): i32;
extern "C" function simd_x86_pshufd_xmm0_imm8_impl(elf: *u8, imm8: i32): i32;
extern "C" function simd_x86_vpshufd_ymm0_imm8_impl(elf: *u8, imm8: i32): i32;

/* ---- G-02f-109：simd_enc more ops 门闩 ---- */

#[no_mangle]
function simd_x86_pmulld_xmm0_xmm1(elf: *u8): i32 { unsafe { return simd_x86_pmulld_xmm0_xmm1_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_vpmulld_ymm0_ymm1(elf: *u8): i32 { unsafe { return simd_x86_vpmulld_ymm0_ymm1_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_mulps_xmm0_xmm1(elf: *u8): i32 { unsafe { return simd_x86_mulps_xmm0_xmm1_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_movups_xmm2_from_rbp(elf: *u8, disp: i32): i32 { unsafe { return simd_x86_movups_xmm2_from_rbp_impl(elf, disp); } return 0; }
#[no_mangle]
function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf: *u8): i32 { unsafe { return simd_x86_vfmadd231ps_xmm0_xmm1_xmm2_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_vmovups_ymm0_from_rbx_rax4(elf: *u8): i32 { unsafe { return simd_x86_vmovups_ymm0_from_rbx_rax4_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_vmovups_ymm1_from_rbx_rax4(elf: *u8): i32 { unsafe { return simd_x86_vmovups_ymm1_from_rbx_rax4_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_vmovups_ymm0_to_rbx_rax4(elf: *u8): i32 { unsafe { return simd_x86_vmovups_ymm0_to_rbx_rax4_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_movups_xmm0_from_rbx_rax4(elf: *u8): i32 { unsafe { return simd_x86_movups_xmm0_from_rbx_rax4_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_movups_xmm1_from_rbx_rax4(elf: *u8): i32 { unsafe { return simd_x86_movups_xmm1_from_rbx_rax4_impl(elf); } return 0; }
#[no_mangle]
function simd_x86_movups_xmm0_to_rbx_rax4(elf: *u8): i32 { unsafe { return simd_x86_movups_xmm0_to_rbx_rax4_impl(elf); } return 0; }
#[no_mangle]
function simd_append_u32_le(elf: *u8, word: u32): i32 { unsafe { return simd_append_u32_le_impl(elf, word); } return 0; }

// G-02f-115：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function simd_arm64_ins_v1_from_v0_s(dst_lane: i32, src_lane: i32): u32 {
  // Encoding: 0x6E040000 | ((dst_lane&3)<<19) | ((src_lane&3)<<13) | 0x401
  // Keep arithmetic form; seed C uses bitwise OR equivalent.
  let d: i32 = dst_lane & 3;
  let s: i32 = src_lane & 3;
  let enc: i32 = 1846018048 | (d << 19) | (s << 13) | 1025;
  return enc;
}

// G-02f-120：simd_arm64_rbp_lea_off_128half 真迁 .x

#[no_mangle]
function simd_arm64_rbp_lea_off_128half(slot: i32, half: i32, esz: i32): i32 {
  if (slot < 0) { return slot; }
  if (esz <= 0) { return slot; }
  if (half < 0) { return slot; }
  return slot - half * 4 * esz;
}

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

extern "C" function simd_rbp_disp32_impl(slot: i32, lanes: i32, esz: i32): i32;
extern "C" function simd_arm64_rbp_lea_off_128half_impl(slot: i32, half: i32, esz: i32): i32;
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
function simd_rbp_disp32(slot: i32, lanes: i32, esz: i32): i32 {
  unsafe { return simd_rbp_disp32_impl(slot, lanes, esz); }
  return 0;
}

#[no_mangle]
function simd_arm64_rbp_lea_off_128half(slot: i32, half: i32, esz: i32): i32 {
  unsafe { return simd_arm64_rbp_lea_off_128half_impl(slot, half, esz); }
  return 0;
}

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

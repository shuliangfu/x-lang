// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-348/385：simd_enc L2 thin — pure 编码助手（无 elf append / 无栈字节数组）。
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

// ---- G-02f-385：append / disp32 / addps / paddd → seed impl ----
extern "C" function simd_append_impl(elf_ctx: *u8, bytes: *u8, n: i32): i32;
extern "C" function simd_append_disp32_impl(elf_ctx: *u8, disp: i32): i32;
extern "C" function simd_x86_addps_xmm0_xmm1_impl(elf_ctx: *u8): i32;
extern "C" function simd_x86_paddd_xmm0_xmm1_impl(elf_ctx: *u8): i32;

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

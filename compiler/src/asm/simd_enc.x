// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-7：simd_enc 产品源迁 seeds/simd_enc.from_x.c（纯编码，无 OS #if）。
// 本文件为语义对照 / 后续真迁 .x 的入口说明；全量 opcode 表仍在 seed C。
// 产品：cc seeds/simd_enc.from_x.c → src/asm/simd_enc.o
//
// 导出（C ABI，见 include/simd_enc.h）：
//   simd_enc_try_hw_vector_*_rbp / pshufd / select / 低层 x86 enc helpers 等。
// G-02f-211：try_hw fadd/fmul/fma/imul/iadd 与 x86 短壳真迁 .x。
// G-02f-212：binop@idx / pshufd / select + arm64 128 壳真迁；simd_enc 主路径闭合。

// 占位：避免空 TU；产品不链本 .x 生成物。
export function simd_enc_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108：+ rbp/append/x86 movups/padd 薄门闩。


/* ---- G-02f-108：simd_enc low-level helpers 门闩 ---- */






























// G-02f-109：+ mul/vfmadd/rbx_rax4/pshufd/select 薄门闩。

export extern "C" function simd_arm64_ins_v1_from_v0_s_impl(dst: i32, src: i32): u32;
export extern "C" function simd_arm64_pshufd_imm8_128_rbp_impl(elf: *u8, lea_src: i32, lea_dst: i32, imm8: i32): i32;
export extern "C" function simd_arm64_select_128_rbp_impl(elf: *u8, lea_mask: i32, lea_a: i32, lea_b: i32): i32;

/* ---- G-02f-109：simd_enc more ops 门闩 ---- */














// G-02f-115：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
export function simd_arm64_ins_v1_from_v0_s(dst_lane: i32, src_lane: i32): u32 {
  // Encoding: 0x6E040000 | ((dst_lane&3)<<19) | ((src_lane&3)<<13) | 0x401
  // Keep arithmetic form; seed C uses bitwise OR equivalent.
  let d: i32 = dst_lane & 3;
  let s: i32 = src_lane & 3;
  let enc: i32 = 1846018048 | (d << 19) | (s << 13) | 1025;
  return enc;
}

// G-02f-120：simd_arm64_rbp_lea_off_128half 真迁 .x

#[no_mangle]
export function simd_arm64_rbp_lea_off_128half(slot: i32, half: i32, esz: i32): i32 {
  if (slot < 0) { return slot; }
  if (esz <= 0) { return slot; }
  if (half < 0) { return slot; }
  return slot - half * 4 * esz;
}

// G-02f-122：simd_append_disp32 真迁 .x（与 simd_append_u32_le 同 LE 编码）

#[no_mangle]
export function simd_append_disp32(elf: *u8, disp: i32): i32 {
  let r: i32 = 0;
  unsafe { r = simd_append_u32_le(elf, disp as u32); }
  return r;
}

// G-02f-123：simd_append / simd_append_u32_le 真迁 .x

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

#[no_mangle]
export function simd_append(elf: *u8, bytes: *u8, n: i32): i32 {
  if (elf == 0) { return 0 - 1; }
  if (bytes == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  let r: i32 = 0;
  unsafe { r = pipeline_elf_ctx_append_bytes(elf, bytes, n); }
  return r;
}

#[no_mangle]
export function simd_append_u32_le(elf: *u8, word: u32): i32 {
  let b0: u8 = (word & 255) as u8;
  let b1: u8 = ((word / 256) & 255) as u8;
  let b2: u8 = ((word / 65536) & 255) as u8;
  let b3: u8 = ((word / 16777216) & 255) as u8;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  return r;
}

// G-02f-124：simd 固定指令 / rbp+disp 真迁 .x

#[no_mangle]
export function simd_x86_addps_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 88;
  let b2: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_mulps_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 89;
  let b2: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_paddd_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 254;
  let b3: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_psubd_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 250;
  let b3: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_pmulld_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 56;
  let b3: u8 = 64;
  let b4: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpaddd_ymm0_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 253;
  let b2: u8 = 254;
  let b3: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpsubd_ymm0_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 253;
  let b2: u8 = 250;
  let b3: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpmulld_ymm0_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 253;
  let b2: u8 = 64;
  let b3: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 113;
  let b3: u8 = 169;
  let b4: u8 = 193;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_movups_xmm0_to_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 248;
  let b2: u8 = 17;
  let b3: u8 = 4;
  let b4: u8 = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_movups_xmm0_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 248;
  let b2: u8 = 16;
  let b3: u8 = 4;
  let b4: u8 = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_movups_xmm1_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 240;
  let b2: u8 = 16;
  let b3: u8 = 4;
  let b4: u8 = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vmovups_ymm0_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 125;
  let b3: u8 = 16;
  let b4: u8 = 4;
  let b5: u8 = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b5, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vmovups_ymm1_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 117;
  let b3: u8 = 16;
  let b4: u8 = 4;
  let b5: u8 = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b5, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vmovups_ymm0_to_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 125;
  let b3: u8 = 17;
  let b4: u8 = 4;
  let b5: u8 = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b4, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b5, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_movups_xmm0_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 16;
  let b2: u8 = 133;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_movups_xmm1_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 16;
  let b2: u8 = 141;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_movups_xmm0_to_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 17;
  let b2: u8 = 133;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_vmovups_ymm0_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 16;
  let b3: u8 = 133;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_vmovups_ymm1_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 16;
  let b3: u8 = 141;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_vmovups_ymm0_to_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 17;
  let b3: u8 = 133;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

// G-02f-125：更多 simd 固定/disp 指令真迁 .x

#[no_mangle]
export function simd_x86_movups_xmm2_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 16;
  let b2: u8 = 149;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_pshufd_xmm0_imm8(elf: *u8, imm8: i32): i32 {
  let b0: u8 = 0x66;
  let b1: u8 = 0x0f;
  let b2: u8 = 0x70;
  let b3: u8 = 0xc0;
  let ib: u8 = (imm8 & 255) as u8;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &ib, 1); }
  return r;
}


#[no_mangle]
export function simd_x86_vpshufd_ymm0_imm8(elf: *u8, imm8: i32): i32 {
  let b0: u8 = 0xc5;
  let b1: u8 = 0xfe;
  let b2: u8 = 0x70;
  let b3: u8 = 0xc0;
  let ib: u8 = (imm8 & 255) as u8;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &ib, 1); }
  return r;
}


#[no_mangle]
export function simd_x86_vmovups_ymm2_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 16;
  let b3: u8 = 149;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf, disp); }
  return r;
}

#[no_mangle]
export function simd_x86_pxor_xmm3_xmm3(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 239;
  let b3: u8 = 219;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_pcmpgtd_xmm2_xmm3(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 102;
  let b3: u8 = 211;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_pand_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 219;
  let b3: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_pandn_xmm2_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 223;
  let b3: u8 = 209;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_por_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 235;
  let b3: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_xorps_xmm3_xmm3(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 87;
  let b2: u8 = 219;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_cmpgtps_xmm2_xmm3(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 85;
  let b2: u8 = 211;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_andps_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 84;
  let b2: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_andnps_xmm2_xmm1(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 85;
  let b2: u8 = 209;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_orps_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 86;
  let b2: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpxor_ymm3_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 245;
  let b2: u8 = 119;
  let b3: u8 = 219;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpcmpgtd_ymm2_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 237;
  let b2: u8 = 102;
  let b3: u8 = 211;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpand_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 229;
  let b2: u8 = 219;
  let b3: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpandn_ymm2_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 229;
  let b2: u8 = 223;
  let b3: u8 = 209;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vpor_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 229;
  let b2: u8 = 235;
  let b3: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vxorps_ymm3_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 240;
  let b2: u8 = 87;
  let b3: u8 = 219;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vcmpgtps_ymm2_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 232;
  let b2: u8 = 87;
  let b3: u8 = 211;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vandps_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 224;
  let b2: u8 = 84;
  let b3: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vandnps_ymm2_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 232;
  let b2: u8 = 85;
  let b3: u8 = 209;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_vorps_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 224;
  let b2: u8 = 86;
  let b3: u8 = 194;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b3, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = 0; }
  return r;
}

#[no_mangle]
export function simd_x86_pshufd_xmm1_xmm0(elf: *u8, imm: u8): i32 {
  let b0: u8 = 0x66;
  let b1: u8 = 0x0f;
  let b2: u8 = 0x70;
  let modrm: u8 = 0xc8;
  let ib: u8 = imm;
  let r: i32 = 0;
  unsafe { r = simd_append(elf, &b0, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b1, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &b2, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &modrm, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append(elf, &ib, 1); }
  return r;
}

/* ---- G-02f-211：try_hw vector + x86 short shells ---- */

// feature bits from target_cpu.h
// SSE2=1 SSE41=2 AVX2=8 FMA=128

export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

// G-02f-211：disp = -slot_off（lanes/esz 忽略）
#[no_mangle]
export function simd_rbp_disp32(slot_off: i32, lanes: i32, esz: i32): i32 {
  if (slot_off < 0) { return 0; }
  return 0 - slot_off;
}

// G-02f-211：整型向量 add/sub 公共路径
#[no_mangle]
export function simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32, is_sub: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_a < 0) { return 0 - 1; }
  if (slot_off_b < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  if (esz != 4) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  let da: i32 = simd_rbp_disp32(slot_off_a, lanes, esz);
  let db: i32 = simd_rbp_disp32(slot_off_b, lanes, esz);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, esz);
  // AVX2 = 8
  if (lanes == 8) {
    if ((cpu_features & 8) != 0) {
      if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
      if (is_sub != 0) {
        if (simd_x86_vpsubd_ymm0_ymm1(elf_ctx) != 0) { return 0 - 1; }
      } else {
        if (simd_x86_vpaddd_ymm0_ymm1(elf_ctx) != 0) { return 0 - 1; }
      }
      if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  // SSE2 = 1
  if (lanes == 4) {
    if ((cpu_features & 1) != 0) {
      if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
      if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
      if (is_sub != 0) {
        if (simd_x86_psubd_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
      } else {
        if (simd_x86_paddd_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
      }
      if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  return 0 - 1;
}

#[no_mangle]
export function simd_enc_try_hw_vector_iadd_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, 0);
}

#[no_mangle]
export function simd_enc_try_hw_vector_isub_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, 1);
}

#[no_mangle]
export function simd_enc_try_hw_vector_imul_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_a < 0) { return 0 - 1; }
  if (slot_off_b < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  if (esz != 4) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  let da: i32 = simd_rbp_disp32(slot_off_a, lanes, esz);
  let db: i32 = simd_rbp_disp32(slot_off_b, lanes, esz);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if (lanes == 8) {
    if ((cpu_features & 8) != 0) {
      if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
      if (simd_x86_vpmulld_ymm0_ymm1(elf_ctx) != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  // SSE41 = 2
  if (lanes == 4) {
    if ((cpu_features & 2) != 0) {
      if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
      if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
      if (simd_x86_pmulld_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
      if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  return 0 - 1;
}

#[no_mangle]
export function simd_enc_try_hw_vector_fadd_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_a < 0) { return 0 - 1; }
  if (slot_off_b < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  if (esz != 4) { return 0 - 1; }
  if (lanes != 4) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  if ((cpu_features & 1) == 0) { return 0 - 1; }
  let da: i32 = simd_rbp_disp32(slot_off_a, lanes, esz);
  let db: i32 = simd_rbp_disp32(slot_off_b, lanes, esz);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
  if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
  if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
  return 0;
}

#[no_mangle]
export function simd_enc_try_hw_vector_fmul_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_a < 0) { return 0 - 1; }
  if (slot_off_b < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  if (esz != 4) { return 0 - 1; }
  if (lanes != 4) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  if ((cpu_features & 1) == 0) { return 0 - 1; }
  let da: i32 = simd_rbp_disp32(slot_off_a, lanes, esz);
  let db: i32 = simd_rbp_disp32(slot_off_b, lanes, esz);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, esz);
  if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
  if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
  if (simd_x86_mulps_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
  return 0;
}

#[no_mangle]
export function simd_enc_try_hw_vector_fma_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_c: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_a < 0) { return 0 - 1; }
  if (slot_off_b < 0) { return 0 - 1; }
  if (slot_off_c < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  if (esz != 4) { return 0 - 1; }
  if (lanes != 4) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  if ((cpu_features & 1) == 0) { return 0 - 1; }
  let da: i32 = simd_rbp_disp32(slot_off_a, lanes, esz);
  let db: i32 = simd_rbp_disp32(slot_off_b, lanes, esz);
  let dc: i32 = simd_rbp_disp32(slot_off_c, lanes, esz);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, esz);
  // FMA = 128
  if ((cpu_features & 128) != 0) {
    if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
    if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
    if (simd_x86_movups_xmm2_from_rbp(elf_ctx, dc) != 0) { return 0 - 1; }
    if (simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf_ctx) != 0) { return 0 - 1; }
  } else {
    if (simd_x86_movups_xmm0_from_rbp(elf_ctx, dc) != 0) { return 0 - 1; }
    if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
    if (simd_x86_mulps_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
    if (simd_x86_movups_xmm1_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
    if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
  }
  if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
  return 0;
}

// G-02f-211：xorps xmm0,xmm0
#[no_mangle]
export function simd_enc_x86_xorps_xmm0_zero(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let insn: u8[3] = [];
    insn[0] = 15; insn[1] = 87; insn[2] = 192;
    return simd_append(elf_ctx, &insn[0], 3);
  }
  return 0 - 1;
}

#[no_mangle]
export function simd_enc_x86_movups_xmm1_rbp_disp(elf_ctx: *u8, disp: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return simd_x86_movups_xmm1_from_rbp(elf_ctx, disp);
}

#[no_mangle]
export function simd_enc_x86_addps_xmm0_xmm1(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return simd_x86_addps_xmm0_xmm1(elf_ctx);
}

#[no_mangle]
export function simd_enc_x86_horizontal_addps_xmm0(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  // 0xee=238, 0x55=85
  if (simd_x86_pshufd_xmm1_xmm0(elf_ctx, 238 as u8) != 0) { return 0 - 1; }
  if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_pshufd_xmm1_xmm0(elf_ctx, 85 as u8) != 0) { return 0 - 1; }
  return simd_x86_addps_xmm0_xmm1(elf_ctx);
}

#[no_mangle]
export function simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx: *u8, disp: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  let prefix: u8[3] = [];
  prefix[0] = 243; prefix[1] = 15; prefix[2] = 17;
  let r: i32 = 0;
  unsafe { r = simd_append(elf_ctx, &prefix[0], 3); }
  if (r != 0) { return 0 - 1; }
  let modrm: u8 = 133;
  unsafe { r = simd_append(elf_ctx, &modrm, 1); }
  if (r != 0) { return 0 - 1; }
  unsafe { r = simd_append_disp32(elf_ctx, disp); }
  return r;
}

#[no_mangle]
export function simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx: *u8, off_col0: i32, off_i: i32, ta: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (off_col0 < 0) { return 0 - 1; }
  if (off_i < 0) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  let re1: i32 = 0;
  unsafe { re1 = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (re1 != 0) { return 0 - 1; }
  let re2: i32 = 0;
  unsafe { re2 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, off_col0, ta); }
  if (re2 != 0) { return 0 - 1; }
  let insn: u8[4] = [];
  insn[0] = 15; insn[1] = 16; insn[2] = 12; insn[3] = 131;
  let r: i32 = 0;
  unsafe { r = simd_append(elf_ctx, &insn[0], 4); }
  if (r != 0) { return 0 - 1; }
  return 0;
}

/* ---- G-02f-212：binop@idx / pshufd / select ---- */

export extern "C" function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

// feature: SSE2=1 SSE41=2 AVX2=8 NEON=256 FMA=128

// G-02f-212：arm64 pshufd-imm8 128-bit half
#[no_mangle]
export function simd_arm64_pshufd_imm8_128_rbp(elf_ctx: *u8, lea_src: i32, lea_dst: i32, imm8: i32, ta: i32): i32 {
  let re3: i32 = 0;
  unsafe { re3 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_src, ta); }
  if (re3 != 0) { return 0 - 1; }
  // ld1 {v0.4s}, [x0]
  if (simd_append_u32_le(elf_ctx, 1279293440) != 0) { return 0 - 1; }
  // mov v1.16b, v0.16b
  if (simd_append_u32_le(elf_ctx, 1319115777) != 0) { return 0 - 1; }
  let li: i32 = 0;
  while (li < 4) {
    let shift: i32 = li * 2;
    let tmp: i32 = imm8;
    let k: i32 = 0;
    while (k < shift) {
      tmp = tmp / 2;
      k = k + 1;
    }
    let src_lane: i32 = tmp & 3;
    let ins: u32 = simd_arm64_ins_v1_from_v0_s(li, src_lane);
    if (simd_append_u32_le(elf_ctx, ins) != 0) { return 0 - 1; }
    li = li + 1;
  }
  let re4: i32 = 0;
  unsafe { re4 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_dst, ta); }
  if (re4 != 0) { return 0 - 1; }
  // st1 {v1.4s}, [x0]
  if (simd_append_u32_le(elf_ctx, 1275099137) != 0) { return 0 - 1; }
  return 0;
}

// G-02f-212：arm64 select 128
#[no_mangle]
export function simd_arm64_select_128_rbp(elf_ctx: *u8, lea_mask: i32, lea_a: i32, lea_b: i32, lea_dst: i32, is_f32: i32, ta: i32): i32 {
  let re5: i32 = 0;
  unsafe { re5 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_mask, ta); }
  if (re5 != 0) { return 0 - 1; }
  if (simd_append_u32_le(elf_ctx, 1279293440) != 0) { return 0 - 1; } // ld1 v0
  let re6: i32 = 0;
  unsafe { re6 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_a, ta); }
  if (re6 != 0) { return 0 - 1; }
  if (simd_append_u32_le(elf_ctx, 1279293441) != 0) { return 0 - 1; } // ld1 v1
  let re7: i32 = 0;
  unsafe { re7 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_b, ta); }
  if (re7 != 0) { return 0 - 1; }
  if (simd_append_u32_le(elf_ctx, 1279293442) != 0) { return 0 - 1; } // ld1 v2
  if (is_f32 != 0) {
    if (simd_append_u32_le(elf_ctx, 1319159811) != 0) { return 0 - 1; } // fcmgt
    if (simd_append_u32_le(elf_ctx, 1856117795) != 0) { return 0 - 1; } // bit
  } else {
    if (simd_append_u32_le(elf_ctx, 1319143427) != 0) { return 0 - 1; } // cmgt
    if (simd_append_u32_le(elf_ctx, 1851923491) != 0) { return 0 - 1; } // bsl
  }
  let re8: i32 = 0;
  unsafe { re8 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, lea_dst, ta); }
  if (re8 != 0) { return 0 - 1; }
  if (simd_append_u32_le(elf_ctx, 1275099139) != 0) { return 0 - 1; } // st1 v3
  return 0;
}

// G-02f-212：select seq
#[no_mangle]
export function simd_enc_emit_i32_select_xmm_seq(elf_ctx: *u8): i32 {
  if (simd_x86_pxor_xmm3_xmm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_pcmpgtd_xmm2_xmm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_pand_xmm0_xmm2(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_pandn_xmm2_xmm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_por_xmm0_xmm2(elf_ctx) != 0) { return 0 - 1; }
  return 0;
}

#[no_mangle]
export function simd_enc_emit_f32_select_xmm_seq(elf_ctx: *u8): i32 {
  if (simd_x86_xorps_xmm3_xmm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_cmpgtps_xmm2_xmm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_andps_xmm0_xmm2(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_andnps_xmm2_xmm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_orps_xmm0_xmm2(elf_ctx) != 0) { return 0 - 1; }
  return 0;
}

#[no_mangle]
export function simd_enc_emit_i32_select_ymm_seq(elf_ctx: *u8): i32 {
  if (simd_x86_vpxor_ymm3_ymm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vpcmpgtd_ymm2_ymm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vpand_ymm0_ymm2(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vpandn_ymm2_ymm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vpor_ymm0_ymm2(elf_ctx) != 0) { return 0 - 1; }
  return 0;
}

#[no_mangle]
export function simd_enc_emit_f32_select_ymm_seq(elf_ctx: *u8): i32 {
  if (simd_x86_vxorps_ymm3_ymm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vcmpgtps_ymm2_ymm3(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vandps_ymm0_ymm2(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vandnps_ymm2_ymm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_vorps_ymm0_ymm2(elf_ctx) != 0) { return 0 - 1; }
  return 0;
}

// G-02f-212：indexed binop
#[no_mangle]
export function simd_enc_try_hw_vector_binop_rbp_at_idx(elf_ctx: *u8, off_a: i32, off_b: i32, off_d: i32, off_i: i32, array_n: i32, binop_ko: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (off_a < 0) { return 0 - 1; }
  if (off_b < 0) { return 0 - 1; }
  if (off_d < 0) { return 0 - 1; }
  if (off_i < 0) { return 0 - 1; }
  if (array_n <= 0) { return 0 - 1; }
  if (esz != 4) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  let elem0_a: i32 = off_a - (array_n - 1) * esz;
  let elem0_b: i32 = off_b - (array_n - 1) * esz;
  let elem0_d: i32 = off_d - (array_n - 1) * esz;
  let re9: i32 = 0;
  unsafe { re9 = backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta); }
  if (re9 != 0) { return 0 - 1; }
  let re10: i32 = 0;
  unsafe { re10 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_a, ta); }
  if (re10 != 0) { return 0 - 1; }
  if (lanes == 8) {
    if ((cpu_features & 8) != 0) {
      if (simd_x86_vmovups_ymm0_from_rbx_rax4(elf_ctx) != 0) { return 0 - 1; }
      let re11: i32 = 0;
      unsafe { re11 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_b, ta); }
      if (re11 != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm1_from_rbx_rax4(elf_ctx) != 0) { return 0 - 1; }
      if (binop_ko == 5) {
        if (simd_x86_vpsubd_ymm0_ymm1(elf_ctx) != 0) { return 0 - 1; }
      } else if (binop_ko == 6) {
        if (simd_x86_vpmulld_ymm0_ymm1(elf_ctx) != 0) { return 0 - 1; }
      } else {
        if (simd_x86_vpaddd_ymm0_ymm1(elf_ctx) != 0) { return 0 - 1; }
      }
      let re12: i32 = 0;
      unsafe { re12 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_d, ta); }
      if (re12 != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm0_to_rbx_rax4(elf_ctx) != 0) { return 0 - 1; }
      return 0;
    }
  }
  if (lanes == 4) {
    if (binop_ko == 6) {
      if ((cpu_features & 2) == 0) { return 0 - 1; }
    } else {
      if ((cpu_features & 1) == 0) { return 0 - 1; }
    }
    if (simd_x86_movups_xmm0_from_rbx_rax4(elf_ctx) != 0) { return 0 - 1; }
    let re13: i32 = 0;
    unsafe { re13 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_b, ta); }
    if (re13 != 0) { return 0 - 1; }
    if (simd_x86_movups_xmm1_from_rbx_rax4(elf_ctx) != 0) { return 0 - 1; }
    if (binop_ko == 5) {
      if (simd_x86_psubd_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
    } else if (binop_ko == 6) {
      if (simd_x86_pmulld_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
    } else {
      if (simd_x86_paddd_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
    }
    let re14: i32 = 0;
    unsafe { re14 = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, elem0_d, ta); }
    if (re14 != 0) { return 0 - 1; }
    if (simd_x86_movups_xmm0_to_rbx_rax4(elf_ctx) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

// G-02f-212：pshufd rbp
#[no_mangle]
export function simd_enc_try_pshufd_rbp(elf_ctx: *u8, slot_off_src: i32, slot_off_dst: i32, imm8: i32, lanes: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_src < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  let ds: i32 = simd_rbp_disp32(slot_off_src, lanes, 4);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, 4);
  if (ta == 1) {
    // NEON = 256
    if ((cpu_features & 256) == 0) { return 0 - 1; }
    ds = simd_arm64_rbp_lea_off_128half(slot_off_src, 0, 4);
    dd = simd_arm64_rbp_lea_off_128half(slot_off_dst, 0, 4);
    if (lanes == 4) {
      return simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds, dd, imm8, ta);
    }
    if (lanes == 8) {
      let ds1: i32 = simd_arm64_rbp_lea_off_128half(slot_off_src, 1, 4);
      let dd1: i32 = simd_arm64_rbp_lea_off_128half(slot_off_dst, 1, 4);
      if (simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds, dd, imm8, ta) != 0) { return 0 - 1; }
      if (simd_arm64_pshufd_imm8_128_rbp(elf_ctx, ds1, dd1, imm8, ta) != 0) { return 0 - 1; }
      return 0;
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  if (lanes == 8) {
    if ((cpu_features & 8) != 0) {
      if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, ds) != 0) { return 0 - 1; }
      if (simd_x86_vpshufd_ymm0_imm8(elf_ctx, imm8) != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  if (lanes == 4) {
    if ((cpu_features & 1) != 0) {
      if (simd_x86_movups_xmm0_from_rbp(elf_ctx, ds) != 0) { return 0 - 1; }
      if (simd_x86_pshufd_xmm0_imm8(elf_ctx, imm8) != 0) { return 0 - 1; }
      if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  return 0 - 1;
}

// G-02f-212：select rbp
#[no_mangle]
export function simd_enc_try_hw_vector_select_rbp(elf_ctx: *u8, slot_off_mask: i32, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, is_f32: i32, ta: i32, cpu_features: u32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (slot_off_mask < 0) { return 0 - 1; }
  if (slot_off_a < 0) { return 0 - 1; }
  if (slot_off_b < 0) { return 0 - 1; }
  if (slot_off_dst < 0) { return 0 - 1; }
  let dm: i32 = simd_rbp_disp32(slot_off_mask, lanes, 4);
  let da: i32 = simd_rbp_disp32(slot_off_a, lanes, 4);
  let db: i32 = simd_rbp_disp32(slot_off_b, lanes, 4);
  let dd: i32 = simd_rbp_disp32(slot_off_dst, lanes, 4);
  if (ta == 1) {
    if ((cpu_features & 256) == 0) { return 0 - 1; }
    dm = simd_arm64_rbp_lea_off_128half(slot_off_mask, 0, 4);
    da = simd_arm64_rbp_lea_off_128half(slot_off_a, 0, 4);
    db = simd_arm64_rbp_lea_off_128half(slot_off_b, 0, 4);
    dd = simd_arm64_rbp_lea_off_128half(slot_off_dst, 0, 4);
    if (lanes == 4) {
      return simd_arm64_select_128_rbp(elf_ctx, dm, da, db, dd, is_f32, ta);
    }
    if (lanes == 8) {
      let dm1: i32 = simd_arm64_rbp_lea_off_128half(slot_off_mask, 1, 4);
      let da1: i32 = simd_arm64_rbp_lea_off_128half(slot_off_a, 1, 4);
      let db1: i32 = simd_arm64_rbp_lea_off_128half(slot_off_b, 1, 4);
      let dd1: i32 = simd_arm64_rbp_lea_off_128half(slot_off_dst, 1, 4);
      if (simd_arm64_select_128_rbp(elf_ctx, dm, da, db, dd, is_f32, ta) != 0) { return 0 - 1; }
      if (simd_arm64_select_128_rbp(elf_ctx, dm1, da1, db1, dd1, is_f32, ta) != 0) { return 0 - 1; }
      return 0;
    }
    return 0 - 1;
  }
  if (ta != 0) { return 0 - 1; }
  if (lanes == 8) {
    if ((cpu_features & 8) != 0) {
      if (simd_x86_vmovups_ymm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
      if (simd_x86_vmovups_ymm2_from_rbp(elf_ctx, dm) != 0) { return 0 - 1; }
      if (is_f32 != 0) {
        if (simd_enc_emit_f32_select_ymm_seq(elf_ctx) != 0) { return 0 - 1; }
      } else {
        if (simd_enc_emit_i32_select_ymm_seq(elf_ctx) != 0) { return 0 - 1; }
      }
      if (simd_x86_vmovups_ymm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  if (lanes == 4) {
    if ((cpu_features & 1) != 0) {
      if (simd_x86_movups_xmm0_from_rbp(elf_ctx, da) != 0) { return 0 - 1; }
      if (simd_x86_movups_xmm1_from_rbp(elf_ctx, db) != 0) { return 0 - 1; }
      if (simd_x86_movups_xmm2_from_rbp(elf_ctx, dm) != 0) { return 0 - 1; }
      if (is_f32 != 0) {
        if (simd_enc_emit_f32_select_xmm_seq(elf_ctx) != 0) { return 0 - 1; }
      } else {
        if (simd_enc_emit_i32_select_xmm_seq(elf_ctx) != 0) { return 0 - 1; }
      }
      if (simd_x86_movups_xmm0_to_rbp(elf_ctx, dd) != 0) { return 0 - 1; }
      return 0;
    }
  }
  return 0 - 1;
}

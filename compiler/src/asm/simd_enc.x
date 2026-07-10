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

// 占位：避免空 TU；产品不链本 .x 生成物。
function simd_enc_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108：+ rbp/append/x86 movups/padd 薄门闩。


/* ---- G-02f-108：simd_enc low-level helpers 门闩 ---- */






























// G-02f-109：+ mul/vfmadd/rbx_rax4/pshufd/select 薄门闩。

extern "C" function simd_arm64_ins_v1_from_v0_s_impl(dst: i32, src: i32): u32;
extern "C" function simd_arm64_pshufd_imm8_128_rbp_impl(elf: *u8, lea_src: i32, lea_dst: i32, imm8: i32): i32;
extern "C" function simd_arm64_select_128_rbp_impl(elf: *u8, lea_mask: i32, lea_a: i32, lea_b: i32): i32;

/* ---- G-02f-109：simd_enc more ops 门闩 ---- */














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

// G-02f-122：simd_append_disp32 真迁 .x（与 simd_append_u32_le 同 LE 编码）

#[no_mangle]
function simd_append_disp32(elf: *u8, disp: i32): i32 {
  unsafe {
    return simd_append_u32_le(elf, disp as u32);
  }
  return 0 - 1;
}

// G-02f-123：simd_append / simd_append_u32_le 真迁 .x

extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

#[no_mangle]
function simd_append(elf: *u8, bytes: *u8, n: i32): i32 {
  if (elf == 0) { return 0 - 1; }
  if (bytes == 0) { return 0 - 1; }
  if (n <= 0) { return 0 - 1; }
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf, bytes, n);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_append_u32_le(elf: *u8, word: u32): i32 {
  let b0: u8 = (word & 255) as u8;
  let b1: u8 = ((word / 256) & 255) as u8;
  let b2: u8 = ((word / 65536) & 255) as u8;
  let b3: u8 = ((word / 16777216) & 255) as u8;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return simd_append(elf, &b3, 1);
  }
  return 0 - 1;
}

// G-02f-124：simd 固定指令 / rbp+disp 真迁 .x

#[no_mangle]
function simd_x86_addps_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 88;
  let b2: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_mulps_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 89;
  let b2: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_paddd_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 254;
  let b3: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_psubd_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 250;
  let b3: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pmulld_xmm0_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 56;
  let b3: u8 = 64;
  let b4: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpaddd_ymm0_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 253;
  let b2: u8 = 254;
  let b3: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpsubd_ymm0_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 253;
  let b2: u8 = 250;
  let b3: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpmulld_ymm0_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 253;
  let b2: u8 = 64;
  let b3: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vfmadd231ps_xmm0_xmm1_xmm2(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 113;
  let b3: u8 = 169;
  let b4: u8 = 193;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_to_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 248;
  let b2: u8 = 17;
  let b3: u8 = 4;
  let b4: u8 = 131;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 248;
  let b2: u8 = 16;
  let b3: u8 = 4;
  let b4: u8 = 131;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm1_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 240;
  let b2: u8 = 16;
  let b3: u8 = 4;
  let b4: u8 = 131;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 125;
  let b3: u8 = 16;
  let b4: u8 = 4;
  let b5: u8 = 131;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b5, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm1_from_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 117;
  let b3: u8 = 16;
  let b4: u8 = 4;
  let b5: u8 = 131;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b5, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_to_rbx_rax4(elf: *u8): i32 {
  let b0: u8 = 196;
  let b1: u8 = 226;
  let b2: u8 = 125;
  let b3: u8 = 17;
  let b4: u8 = 4;
  let b5: u8 = 131;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b4, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b5, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 16;
  let b2: u8 = 133;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm1_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 16;
  let b2: u8 = 141;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_movups_xmm0_to_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 17;
  let b2: u8 = 133;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 16;
  let b3: u8 = 133;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm1_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 16;
  let b3: u8 = 141;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vmovups_ymm0_to_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 17;
  let b3: u8 = 133;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

// G-02f-125：更多 simd 固定/disp 指令真迁 .x

#[no_mangle]
function simd_x86_movups_xmm2_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 15;
  let b1: u8 = 16;
  let b2: u8 = 149;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pshufd_xmm0_imm8(elf: *u8, imm8: i32): i32 {
  let b0: u8 = 0x66;
  let b1: u8 = 0x0f;
  let b2: u8 = 0x70;
  let b3: u8 = 0xc0;
  let ib: u8 = (imm8 & 255) as u8;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return simd_append(elf, &ib, 1);
  }
  return 0 - 1;
}


#[no_mangle]
function simd_x86_vpshufd_ymm0_imm8(elf: *u8, imm8: i32): i32 {
  let b0: u8 = 0xc5;
  let b1: u8 = 0xfe;
  let b2: u8 = 0x70;
  let b3: u8 = 0xc0;
  let ib: u8 = (imm8 & 255) as u8;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return simd_append(elf, &ib, 1);
  }
  return 0 - 1;
}


#[no_mangle]
function simd_x86_vmovups_ymm2_from_rbp(elf: *u8, disp: i32): i32 {
  let b0: u8 = 197;
  let b1: u8 = 254;
  let b2: u8 = 16;
  let b3: u8 = 149;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pxor_xmm3_xmm3(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 239;
  let b3: u8 = 219;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pcmpgtd_xmm2_xmm3(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 102;
  let b3: u8 = 211;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pand_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 219;
  let b3: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pandn_xmm2_xmm1(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 223;
  let b3: u8 = 209;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_por_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 102;
  let b1: u8 = 15;
  let b2: u8 = 235;
  let b3: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_xorps_xmm3_xmm3(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 87;
  let b2: u8 = 219;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_cmpgtps_xmm2_xmm3(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 85;
  let b2: u8 = 211;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_andps_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 84;
  let b2: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_andnps_xmm2_xmm1(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 85;
  let b2: u8 = 209;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_orps_xmm0_xmm2(elf: *u8): i32 {
  let b0: u8 = 15;
  let b1: u8 = 86;
  let b2: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpxor_ymm3_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 245;
  let b2: u8 = 119;
  let b3: u8 = 219;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpcmpgtd_ymm2_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 237;
  let b2: u8 = 102;
  let b3: u8 = 211;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpand_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 229;
  let b2: u8 = 219;
  let b3: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpandn_ymm2_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 229;
  let b2: u8 = 223;
  let b3: u8 = 209;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vpor_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 229;
  let b2: u8 = 235;
  let b3: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vxorps_ymm3_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 240;
  let b2: u8 = 87;
  let b3: u8 = 219;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vcmpgtps_ymm2_ymm3(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 232;
  let b2: u8 = 87;
  let b3: u8 = 211;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vandps_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 224;
  let b2: u8 = 84;
  let b3: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vandnps_ymm2_ymm1(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 232;
  let b2: u8 = 85;
  let b3: u8 = 209;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_vorps_ymm0_ymm2(elf: *u8): i32 {
  let b0: u8 = 197;
  let b1: u8 = 224;
  let b2: u8 = 86;
  let b3: u8 = 194;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b3, 1) != 0) { return 0 - 1; }
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function simd_x86_pshufd_xmm1_xmm0(elf: *u8, imm: u8): i32 {
  let b0: u8 = 0x66;
  let b1: u8 = 0x0f;
  let b2: u8 = 0x70;
  let modrm: u8 = 0xc8;
  let ib: u8 = imm;
  unsafe {
    if (simd_append(elf, &b0, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b1, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &b2, 1) != 0) { return 0 - 1; }
    if (simd_append(elf, &modrm, 1) != 0) { return 0 - 1; }
    return simd_append(elf, &ib, 1);
  }
  return 0 - 1;
}

/* ---- G-02f-211：try_hw vector + x86 short shells ---- */

// feature bits from target_cpu.h
// SSE2=1 SSE41=2 AVX2=8 FMA=128

extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
extern "C" function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

// G-02f-211：disp = -slot_off（lanes/esz 忽略）
#[no_mangle]
function simd_rbp_disp32(slot_off: i32, lanes: i32, esz: i32): i32 {
  if (slot_off < 0) { return 0; }
  return 0 - slot_off;
}

// G-02f-211：整型向量 add/sub 公共路径
#[no_mangle]
function simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32, is_sub: i32): i32 {
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
function simd_enc_try_hw_vector_iadd_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, 0);
}

#[no_mangle]
function simd_enc_try_hw_vector_isub_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
  return simd_enc_try_hw_vector_iadd_isub_rbp(elf_ctx, slot_off_a, slot_off_b, slot_off_dst, lanes, esz, ta, cpu_features, 1);
}

#[no_mangle]
function simd_enc_try_hw_vector_imul_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
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
function simd_enc_try_hw_vector_fadd_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
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
function simd_enc_try_hw_vector_fmul_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
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
function simd_enc_try_hw_vector_fma_rbp(elf_ctx: *u8, slot_off_a: i32, slot_off_b: i32, slot_off_c: i32, slot_off_dst: i32, lanes: i32, esz: i32, ta: i32, cpu_features: u32): i32 {
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
function simd_enc_x86_xorps_xmm0_zero(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let insn: u8[3] = [];
    insn[0] = 15; insn[1] = 87; insn[2] = 192;
    return simd_append(elf_ctx, &insn[0], 3);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_enc_x86_movups_xmm1_rbp_disp(elf_ctx: *u8, disp: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return simd_x86_movups_xmm1_from_rbp(elf_ctx, disp);
}

#[no_mangle]
function simd_enc_x86_addps_xmm0_xmm1(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  return simd_x86_addps_xmm0_xmm1(elf_ctx);
}

#[no_mangle]
function simd_enc_x86_horizontal_addps_xmm0(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  // 0xee=238, 0x55=85
  if (simd_x86_pshufd_xmm1_xmm0(elf_ctx, 238 as u8) != 0) { return 0 - 1; }
  if (simd_x86_addps_xmm0_xmm1(elf_ctx) != 0) { return 0 - 1; }
  if (simd_x86_pshufd_xmm1_xmm0(elf_ctx, 85 as u8) != 0) { return 0 - 1; }
  return simd_x86_addps_xmm0_xmm1(elf_ctx);
}

#[no_mangle]
function simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx: *u8, disp: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    let prefix: u8[3] = [];
    prefix[0] = 243; prefix[1] = 15; prefix[2] = 17;
    if (simd_append(elf_ctx, &prefix[0], 3) != 0) { return 0 - 1; }
    let modrm: u8 = 133;
    if (simd_append(elf_ctx, &modrm, 1) != 0) { return 0 - 1; }
    return simd_append_disp32(elf_ctx, disp);
  }
  return 0 - 1;
}

#[no_mangle]
function simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx: *u8, off_col0: i32, off_i: i32, ta: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  if (off_col0 < 0) { return 0 - 1; }
  if (off_i < 0) { return 0 - 1; }
  if (ta != 0) { return 0 - 1; }
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0) { return 0 - 1; }
  if (backend_enc_lea_rbp_to_rbx_arch(elf_ctx, off_col0, ta) != 0) { return 0 - 1; }
  unsafe {
    let insn: u8[4] = [];
    insn[0] = 15; insn[1] = 16; insn[2] = 12; insn[3] = 131;
    if (simd_append(elf_ctx, &insn[0], 4) != 0) { return 0 - 1; }
  }
  return 0;
}

// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：backend_x86_64_enc_c 产品源迁 seeds/backend_x86_64_enc_c.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/backend_x86_64_enc_c.from_x.c → src/asm/backend_x86_64_enc_c.o
// G-02f-101：+ x86_enc_u8 / u32_le / bytes / jcc_rel32 薄门闩。
// G-02f-102：+ movq/lea/movl/store/alu rbp helpers 薄门闩。

extern "C" function x86_enc_jcc_rel32_impl(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32;
extern "C" function x86_enc_movq_from_rbp_neg_impl(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32;
extern "C" function x86_enc_lea_from_rbp_neg_impl(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32;
extern "C" function x86_enc_movl_from_rbp_neg32_impl(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32;
extern "C" function x86_enc_store_rax_to_rbp_neg_impl(elf_ctx: *u8, offset: i32): i32;
extern "C" function x86_enc_alu_imm32_to_reg_impl(elf_ctx: *u8, imm: i32, op_prefix: u8, reg_modrm: u8): i32;
extern "C" function x86_enc_store_rdx_to_rbp_neg_impl(elf_ctx: *u8, offset: i32): i32;

function backend_x86_64_enc_c_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-101：x86 enc primitive 门闩 ---- */

#[no_mangle]
function x86_enc_jcc_rel32(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32 {
  unsafe {
    return x86_enc_jcc_rel32_impl(elf_ctx, opcode2, label, label_len);
  }
  return 0 - 1;
}

/* ---- G-02f-102：x86 rbp/alu helpers 门闩 ---- */

#[no_mangle]
function x86_enc_movq_from_rbp_neg(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32 {
  unsafe {
    return x86_enc_movq_from_rbp_neg_impl(elf_ctx, offset, disp8_modrm, disp32_modrm);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_lea_from_rbp_neg(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32 {
  unsafe {
    return x86_enc_lea_from_rbp_neg_impl(elf_ctx, offset, disp8_modrm, disp32_modrm);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_movl_from_rbp_neg32(elf_ctx: *u8, offset: i32, disp8_modrm: u8, disp32_modrm: u8): i32 {
  unsafe {
    return x86_enc_movl_from_rbp_neg32_impl(elf_ctx, offset, disp8_modrm, disp32_modrm);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_store_rax_to_rbp_neg(elf_ctx: *u8, offset: i32): i32 {
  unsafe {
    return x86_enc_store_rax_to_rbp_neg_impl(elf_ctx, offset);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_alu_imm32_to_reg(elf_ctx: *u8, imm: i32, op_prefix: u8, reg_modrm: u8): i32 {
  unsafe {
    return x86_enc_alu_imm32_to_reg_impl(elf_ctx, imm, op_prefix, reg_modrm);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_store_rdx_to_rbp_neg(elf_ctx: *u8, offset: i32): i32 {
  unsafe {
    return x86_enc_store_rdx_to_rbp_neg_impl(elf_ctx, offset);
  }
  return 0 - 1;
}

// G-02f-124：x86_enc_u8 / x86_enc_bytes 真迁 .x
// G-02f-128：x86_enc_u32_le 真迁 .x

extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;

#[no_mangle]
function x86_enc_u8(elf_ctx: *u8, b: u8): i32 {
  let bb: u8 = b;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &bb, 1);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_bytes(elf_ctx: *u8, buf: *u8, n: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, buf, n);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_u32_le(elf_ctx: *u8, imm: i32): i32 {
  // 小端 4 字节；imm 按两补码位型写入
  let w: u32 = imm as u32;
  let b0: u8 = (w & 255) as u8;
  let b1: u8 = ((w / 256) & 255) as u8;
  let b2: u8 = ((w / 65536) & 255) as u8;
  let b3: u8 = ((w / 16777216) & 255) as u8;
  unsafe {
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b2, 1) != 0) { return 0 - 1; }
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b3, 1);
  }
  return 0 - 1;
}


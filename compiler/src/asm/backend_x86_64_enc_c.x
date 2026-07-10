// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：backend_x86_64_enc_c 产品源迁 seeds/backend_x86_64_enc_c.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/backend_x86_64_enc_c.from_x.c → src/asm/backend_x86_64_enc_c.o
// G-02f-101：+ x86_enc_u8 / u32_le / bytes / jcc_rel32 薄门闩。

extern "C" function x86_enc_u8_impl(elf_ctx: *u8, b: u8): i32;
extern "C" function x86_enc_u32_le_impl(elf_ctx: *u8, imm: i32): i32;
extern "C" function x86_enc_bytes_impl(elf_ctx: *u8, buf: *u8, n: i32): i32;
extern "C" function x86_enc_jcc_rel32_impl(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32;

function backend_x86_64_enc_c_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-101：x86 enc primitive 门闩 ---- */

#[no_mangle]
function x86_enc_u8(elf_ctx: *u8, b: u8): i32 {
  unsafe {
    return x86_enc_u8_impl(elf_ctx, b);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_u32_le(elf_ctx: *u8, imm: i32): i32 {
  unsafe {
    return x86_enc_u32_le_impl(elf_ctx, imm);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_bytes(elf_ctx: *u8, buf: *u8, n: i32): i32 {
  unsafe {
    return x86_enc_bytes_impl(elf_ctx, buf, n);
  }
  return 0 - 1;
}

#[no_mangle]
function x86_enc_jcc_rel32(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32 {
  unsafe {
    return x86_enc_jcc_rel32_impl(elf_ctx, opcode2, label, label_len);
  }
  return 0 - 1;
}

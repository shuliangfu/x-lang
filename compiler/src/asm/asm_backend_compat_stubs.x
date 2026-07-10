// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：asm_backend_compat_stubs 产品源迁 seeds/asm_backend_compat_stubs.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/asm_backend_compat_stubs.from_x.c → src/asm/asm_backend_compat_stubs.o
// G-02f-99：+ format_u32 / elf append u32 / arm64 mov imm32 薄门闩。

extern "C" function shu_format_u32_to_buf_impl(buf: *u8, off: i32, max: i32, u: u32): i32;
extern "C" function shu_elf_ctx_append_u32_le_impl(elf_ctx: *u8, word: u32): i32;
extern "C" function shu_arm64_mov_imm32_to_w0_c_impl(elf_ctx: *u8, imm32: i32): i32;

function asm_backend_compat_stubs_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-99：format / elf append / arm64 mov 门闩 ---- */

#[no_mangle]
function shu_format_u32_to_buf(buf: *u8, off: i32, max: i32, u: u32): i32 {
  unsafe {
    return shu_format_u32_to_buf_impl(buf, off, max, u);
  }
  return 0 - 1;
}

#[no_mangle]
function shu_elf_ctx_append_u32_le(elf_ctx: *u8, word: u32): i32 {
  unsafe {
    return shu_elf_ctx_append_u32_le_impl(elf_ctx, word);
  }
  return 0 - 1;
}

#[no_mangle]
function shu_arm64_mov_imm32_to_w0_c(elf_ctx: *u8, imm32: i32): i32 {
  unsafe {
    return shu_arm64_mov_imm32_to_w0_c_impl(elf_ctx, imm32);
  }
  return 0 - 1;
}

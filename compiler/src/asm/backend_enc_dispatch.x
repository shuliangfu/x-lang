// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_enc_dispatch 产品源迁 seeds/backend_enc_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_enc_dispatch.from_x.c → src/asm/backend_enc_dispatch.o
// G-02f-100：+ x86 jcc / append_u32 / arm64 call/add/sub/str 薄门闩。

extern "C" function backend_enc_x86_jcc_rel32_c_impl(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32;
extern "C" function backend_enc_append_u32_le_c_impl(elf_ctx: *u8, word: u32): i32;
extern "C" function backend_enc_arm64_call_c_impl(elf_ctx: *u8, name: *u8, name_len: i32): i32;
extern "C" function backend_enc_arm64_add_sp_imm12_c_impl(elf_ctx: *u8, imm: i32): i32;
extern "C" function backend_enc_arm64_sub_sp_imm12_c_impl(elf_ctx: *u8, imm: i32): i32;
extern "C" function backend_enc_arm64_str_x0_sp_offset_c_impl(elf_ctx: *u8, off_bytes: i32): i32;

function backend_enc_dispatch_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-100：enc helper 门闩 ---- */

#[no_mangle]
function backend_enc_x86_jcc_rel32_c(elf_ctx: *u8, opcode2: u8, label: *u8, label_len: i32): i32 {
  unsafe {
    return backend_enc_x86_jcc_rel32_c_impl(elf_ctx, opcode2, label, label_len);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32 {
  unsafe {
    return backend_enc_append_u32_le_c_impl(elf_ctx, word);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_arm64_call_c(elf_ctx: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    return backend_enc_arm64_call_c_impl(elf_ctx, name, name_len);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  unsafe {
    return backend_enc_arm64_add_sp_imm12_c_impl(elf_ctx, imm);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_arm64_sub_sp_imm12_c(elf_ctx: *u8, imm: i32): i32 {
  unsafe {
    return backend_enc_arm64_sub_sp_imm12_c_impl(elf_ctx, imm);
  }
  return 0 - 1;
}

#[no_mangle]
function backend_enc_arm64_str_x0_sp_offset_c(elf_ctx: *u8, off_bytes: i32): i32 {
  unsafe {
    return backend_enc_arm64_str_x0_sp_offset_c_impl(elf_ctx, off_bytes);
  }
  return 0 - 1;
}

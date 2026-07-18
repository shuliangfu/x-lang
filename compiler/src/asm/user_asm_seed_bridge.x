// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：user_asm_seed_bridge 产品源迁 seeds/user_asm_seed_bridge.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/user_asm_seed_bridge.from_x.c → src/asm/user_asm_seed_bridge.o
// G-02f-97：+ debug/trace/elf_ctx helpers 薄门闩。
// G-02f-98：+ reject_empty_text / macho/coff writer 薄门闩。

export extern "C" function seed_asm_debug_enabled_impl(): i32;
export extern "C" function seed_asm_emit_trace_enabled_impl(): i32;
export extern "C" function seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx: *u8, on: i32): void;
export extern "C" function seed_asm_reject_empty_elf_text_impl(module: *u8, elf_ctx: *u8): i32;
export extern "C" function seed_platform_macho_write_macho_o_to_buf_impl(elf_ctx: *u8, out_buf: *u8): i32;
export extern "C" function seed_platform_coff_write_coff_o_to_buf_impl(elf_ctx: *u8, out_buf: *u8): i32;

export function user_asm_seed_bridge_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-97：debug / trace / elf_ctx 门闩 ---- */



#[no_mangle]
export function seed_elf_ctx_set_macho_leading_underscore(elf_ctx: *u8, on: i32): void {
  unsafe {
    seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx, on);
  }
}



/* ---- G-02f-98：reject empty / platform writer 门闩 ---- */

#[no_mangle]
export function seed_asm_reject_empty_elf_text(module: *u8, elf_ctx: *u8): i32 {
  unsafe {
    return seed_asm_reject_empty_elf_text_impl(module, elf_ctx);
  }
  return 0;
}

#[no_mangle]
export function seed_platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return seed_platform_macho_write_macho_o_to_buf_impl(elf_ctx, out_buf);
  }
  return 0 - 1;
}

#[no_mangle]
export function seed_platform_coff_write_coff_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return seed_platform_coff_write_coff_o_to_buf_impl(elf_ctx, out_buf);
  }
  return 0 - 1;
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）
// G-02f-442：seed_asm_debug_enabled / seed_asm_emit_trace_enabled 改回薄门闩
//   （shux -E 将字符串字面量转为 struct shulang_slice_uint8_t，与 getenv(const char*) 类型冲突，
//    无法 cc 编译；待 SHUX 支持零终止字符串字面量后再真迁）

#[no_mangle]
export function seed_asm_debug_enabled(): i32 {
  unsafe {
    return seed_asm_debug_enabled_impl();
  }
  return 0;
}

#[no_mangle]
export function seed_asm_emit_trace_enabled(): i32 {
  unsafe {
    return seed_asm_emit_trace_enabled_impl();
  }
  return 0;
}

// G-02f-120：seed_elf_ctx_code_len 真迁 .x

#[no_mangle]
export function seed_elf_ctx_code_len(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0; }
  unsafe {
    let p: *i32 = elf_ctx as *i32;
    return p[0];
  }
  return 0;
}

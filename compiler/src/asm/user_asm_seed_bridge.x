// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：user_asm_seed_bridge 产品源迁 seeds/user_asm_seed_bridge.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/user_asm_seed_bridge.from_x.c → src/asm/user_asm_seed_bridge.o
// G-02f-97：+ debug/trace/elf_ctx helpers 薄门闩。

extern "C" function seed_asm_debug_enabled_impl(): i32;
extern "C" function seed_asm_emit_trace_enabled_impl(): i32;
extern "C" function seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx: *u8, on: i32): void;
extern "C" function seed_elf_ctx_code_len_impl(elf_ctx: *u8): i32;

function user_asm_seed_bridge_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-97：debug / trace / elf_ctx 门闩 ---- */

#[no_mangle]
function seed_asm_debug_enabled(): i32 {
  unsafe {
    return seed_asm_debug_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function seed_asm_emit_trace_enabled(): i32 {
  unsafe {
    return seed_asm_emit_trace_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function seed_elf_ctx_set_macho_leading_underscore(elf_ctx: *u8, on: i32): void {
  unsafe {
    seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx, on);
  }
}

#[no_mangle]
function seed_elf_ctx_code_len(elf_ctx: *u8): i32 {
  unsafe {
    return seed_elf_ctx_code_len_impl(elf_ctx);
  }
  return 0;
}

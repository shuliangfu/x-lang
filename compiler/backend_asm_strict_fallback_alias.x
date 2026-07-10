// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24：真迁 .x — non-WPO strict 链 backend_* 强桥 → pipeline_backend_*_c。
// 指针均为不透明 *u8（与 C 侧 struct* ABI 同宽）。

extern "C" function pipeline_backend_asm_codegen_ast_c(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32;
extern "C" function pipeline_backend_asm_codegen_ast_to_elf_c(module: *u8, arena: *u8, elf_ctx: *u8,
                                                              ctx: *u8): i32;

#[no_mangle]
function backend_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_backend_asm_codegen_ast_c(module, arena, out, ctx);
    return r;
  }
  return 0;
}

#[no_mangle]
function backend_asm_codegen_ast_to_elf(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_backend_asm_codegen_ast_to_elf_c(module, arena, elf_ctx, ctx);
    return r;
  }
  return 0;
}

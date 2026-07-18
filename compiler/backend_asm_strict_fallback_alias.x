// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-24： .x — non-WPO strict  backend_*  → pipeline_backend_*_c。
//  *u8（ C  struct* ABI ）。

extern "C" function pipeline_backend_asm_codegen_ast_c(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32;
extern "C" function pipeline_backend_asm_codegen_ast_to_elf_c(module: *u8, arena: *u8, elf_ctx: *u8,
                                                              ctx: *u8): i32;

/** Function `backend_asm_codegen_ast`.
 * Purpose: implements `backend_asm_codegen_ast`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function backend_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_backend_asm_codegen_ast_c(module, arena, out, ctx);
    return r;
  }
  return 0;
}

/** Function `backend_asm_codegen_ast_to_elf`.
 * Purpose: implements `backend_asm_codegen_ast_to_elf`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function backend_asm_codegen_ast_to_elf(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_backend_asm_codegen_ast_to_elf_c(module, arena, elf_ctx, ctx);
    return r;
  }
  return 0;
}

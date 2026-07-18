// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-25： .x — backend_wpo  → glue/seed backend_*（strict WPO）。
//  *u8（ C struct* ABI ）。
// ：./shux-c -E → seeds/backend_asm_bare_link_alias.from_x.c

extern "C" function asm_codegen_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32;
extern "C" function asm_codegen_ast_to_elf(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32;
extern "C" function emit_expr_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
extern "C" function emit_block_body_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32;

/** Function `backend_asm_codegen_ast`.
 * Purpose: implements `backend_asm_codegen_ast`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function backend_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = asm_codegen_ast(module, arena, out, ctx);
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
    let r: i32 = asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
    return r;
  }
  return 0;
}

/** Function `backend_emit_expr_elf`.
 * Purpose: implements `backend_emit_expr_elf`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function backend_emit_expr_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let r: i32 = emit_expr_elf(arena, elf_ctx, expr_ref, ctx, ta);
    return r;
  }
  return 0;
}

/** Function `backend_emit_block_body_elf`.
 * Purpose: implements `backend_emit_block_body_elf`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function backend_emit_block_body_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let r: i32 = emit_block_body_elf(arena, elf_ctx, block_ref, ctx, ta);
    return r;
  }
  return 0;
}

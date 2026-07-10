// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-25：真迁 .x — ast.x 裸名 → pipeline_glue ast_ast_*。
// arena 等以 *u8 表示；产品：./shux-c -E → seeds/ast_asm_bare_link_alias.from_x.c

extern "C" function ast_ast_block_final_expr_ref(a: *u8, br: i32): i32;
extern "C" function ast_ast_block_region_body_ref(a: *u8, br: i32, ri: i32): i32;
extern "C" function ast_ast_block_const_init_ref(a: *u8, br: i32, ci: i32): i32;
extern "C" function ast_ast_block_const_type_ref(a: *u8, br: i32, ci: i32): i32;
extern "C" function ast_ast_block_let_init_ref(a: *u8, br: i32, li: i32): i32;
extern "C" function ast_ast_block_let_type_ref(a: *u8, br: i32, li: i32): i32;
extern "C" function ast_ast_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32;
extern "C" function ast_ast_block_while_cond_ref(a: *u8, br: i32, wi: i32): i32;
extern "C" function ast_ast_block_while_body_ref(a: *u8, br: i32, wi: i32): i32;
extern "C" function ast_ast_block_for_init_ref(a: *u8, br: i32, fi: i32): i32;
extern "C" function ast_ast_block_for_cond_ref(a: *u8, br: i32, fi: i32): i32;
extern "C" function ast_ast_block_for_step_ref(a: *u8, br: i32, fi: i32): i32;
extern "C" function ast_ast_block_for_body_ref(a: *u8, br: i32, fi: i32): i32;
extern "C" function ast_ast_block_if_cond_ref(a: *u8, br: i32, ii: i32): i32;
extern "C" function ast_ast_block_if_then_body_ref(a: *u8, br: i32, ii: i32): i32;
extern "C" function ast_ast_block_if_else_body_ref(a: *u8, br: i32, ii: i32): i32;
extern "C" function ast_ast_block_resolve_var_to_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32;

#[no_mangle]
function ast_block_final_expr_ref(a: *u8, br: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_final_expr_ref(a, br); return r; }
  return 0;
}
#[no_mangle]
function ast_block_region_body_ref(a: *u8, br: i32, ri: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_region_body_ref(a, br, ri); return r; }
  return 0;
}
#[no_mangle]
function ast_block_const_init_ref(a: *u8, br: i32, ci: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_const_init_ref(a, br, ci); return r; }
  return 0;
}
#[no_mangle]
function ast_block_const_type_ref(a: *u8, br: i32, ci: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_const_type_ref(a, br, ci); return r; }
  return 0;
}
#[no_mangle]
function ast_block_let_init_ref(a: *u8, br: i32, li: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_let_init_ref(a, br, li); return r; }
  return 0;
}
#[no_mangle]
function ast_block_let_type_ref(a: *u8, br: i32, li: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_let_type_ref(a, br, li); return r; }
  return 0;
}
#[no_mangle]
function ast_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_expr_stmt_ref(a, br, ei); return r; }
  return 0;
}
#[no_mangle]
function ast_block_while_cond_ref(a: *u8, br: i32, wi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_while_cond_ref(a, br, wi); return r; }
  return 0;
}
#[no_mangle]
function ast_block_while_body_ref(a: *u8, br: i32, wi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_while_body_ref(a, br, wi); return r; }
  return 0;
}
#[no_mangle]
function ast_block_for_init_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_init_ref(a, br, fi); return r; }
  return 0;
}
#[no_mangle]
function ast_block_for_cond_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_cond_ref(a, br, fi); return r; }
  return 0;
}
#[no_mangle]
function ast_block_for_step_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_step_ref(a, br, fi); return r; }
  return 0;
}
#[no_mangle]
function ast_block_for_body_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_body_ref(a, br, fi); return r; }
  return 0;
}
#[no_mangle]
function ast_block_if_cond_ref(a: *u8, br: i32, ii: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_if_cond_ref(a, br, ii); return r; }
  return 0;
}
#[no_mangle]
function ast_block_if_then_body_ref(a: *u8, br: i32, ii: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_if_then_body_ref(a, br, ii); return r; }
  return 0;
}
#[no_mangle]
function ast_block_if_else_body_ref(a: *u8, br: i32, ii: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_if_else_body_ref(a, br, ii); return r; }
  return 0;
}
#[no_mangle]
function ast_block_resolve_var_to_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_resolve_var_to_type_ref(a, block_ref, vname, vlen); return r; }
  return 0;
}

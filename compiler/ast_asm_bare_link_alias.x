// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-25： .x — ast.x  → pipeline_glue ast_ast_*。
// arena  *u8 ；：./shux-c -E → seeds/ast_asm_bare_link_alias.from_x.c

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

/** Function `ast_block_final_expr_ref`.
 * Purpose: implements `ast_block_final_expr_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_final_expr_ref(a: *u8, br: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_final_expr_ref(a, br); return r; }
  return 0;
}
/** Function `ast_block_region_body_ref`.
 * Purpose: implements `ast_block_region_body_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_region_body_ref(a: *u8, br: i32, ri: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_region_body_ref(a, br, ri); return r; }
  return 0;
}
/** Function `ast_block_const_init_ref`.
 * Purpose: implements `ast_block_const_init_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_const_init_ref(a: *u8, br: i32, ci: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_const_init_ref(a, br, ci); return r; }
  return 0;
}
/** Function `ast_block_const_type_ref`.
 * Purpose: implements `ast_block_const_type_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_const_type_ref(a: *u8, br: i32, ci: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_const_type_ref(a, br, ci); return r; }
  return 0;
}
/** Function `ast_block_let_init_ref`.
 * Purpose: implements `ast_block_let_init_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_let_init_ref(a: *u8, br: i32, li: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_let_init_ref(a, br, li); return r; }
  return 0;
}
/** Function `ast_block_let_type_ref`.
 * Purpose: implements `ast_block_let_type_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_let_type_ref(a: *u8, br: i32, li: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_let_type_ref(a, br, li); return r; }
  return 0;
}
/** Function `ast_block_expr_stmt_ref`.
 * Purpose: implements `ast_block_expr_stmt_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_expr_stmt_ref(a, br, ei); return r; }
  return 0;
}
/** Function `ast_block_while_cond_ref`.
 * Purpose: implements `ast_block_while_cond_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_while_cond_ref(a: *u8, br: i32, wi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_while_cond_ref(a, br, wi); return r; }
  return 0;
}
/** Function `ast_block_while_body_ref`.
 * Purpose: implements `ast_block_while_body_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_while_body_ref(a: *u8, br: i32, wi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_while_body_ref(a, br, wi); return r; }
  return 0;
}
/** Function `ast_block_for_init_ref`.
 * Purpose: implements `ast_block_for_init_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_for_init_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_init_ref(a, br, fi); return r; }
  return 0;
}
/** Function `ast_block_for_cond_ref`.
 * Purpose: implements `ast_block_for_cond_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_for_cond_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_cond_ref(a, br, fi); return r; }
  return 0;
}
/** Function `ast_block_for_step_ref`.
 * Purpose: implements `ast_block_for_step_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_for_step_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_step_ref(a, br, fi); return r; }
  return 0;
}
/** Function `ast_block_for_body_ref`.
 * Purpose: implements `ast_block_for_body_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_for_body_ref(a: *u8, br: i32, fi: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_for_body_ref(a, br, fi); return r; }
  return 0;
}
/** Function `ast_block_if_cond_ref`.
 * Purpose: implements `ast_block_if_cond_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_if_cond_ref(a: *u8, br: i32, ii: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_if_cond_ref(a, br, ii); return r; }
  return 0;
}
/** Function `ast_block_if_then_body_ref`.
 * Purpose: implements `ast_block_if_then_body_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_if_then_body_ref(a: *u8, br: i32, ii: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_if_then_body_ref(a, br, ii); return r; }
  return 0;
}
/** Function `ast_block_if_else_body_ref`.
 * Purpose: implements `ast_block_if_else_body_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_if_else_body_ref(a: *u8, br: i32, ii: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_if_else_body_ref(a, br, ii); return r; }
  return 0;
}
/** Function `ast_block_resolve_var_to_type_ref`.
 * Purpose: implements `ast_block_resolve_var_to_type_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_block_resolve_var_to_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  unsafe { let r: i32 = ast_ast_block_resolve_var_to_type_ref(a, block_ref, vname, vlen); return r; }
  return 0;
}

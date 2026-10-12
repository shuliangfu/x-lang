// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_binop_set.x — checklist 6.2 / w1535.
// One writer for Expr.binop_left_ref and Expr.binop_right_ref.
// Offsets are locked to W278_Expr: left at 292, right at 296.
// pthin_expr_binop.x, pthin_expr_ternary.x, pthin_ctrl.x, and
// pthin_fn_block.x only call this symbol. Do not copy the stores.
// The C seed and the generated Class CB stub are not the product
// writer. Product g05 does not host-cc either of them.
// A store through *u8 writes one byte, so each i32 is memcpy'd.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/** Arena expr slot. Null when the ref is out of range. */
extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;

/**
 * Write Expr.binop_left_ref and Expr.binop_right_ref.
 * Call after pipeline_expr_set_common_zeros_c. A null arena, a
 * non-positive ref, or a null slot returns without writing.
 * @param a *u8 — AST arena; null returns
 * @param er i32 — expr ref; <=0 returns
 * @param left_ref i32 — left child ref
 * @param right_ref i32 — right child ref
 * @return void
 * PLATFORM: SHARED. Offsets 292 and 296.
 */
#[no_mangle]
export function pipeline_expr_set_binop_operands_c(a: *u8, er: i32, left_ref: i32, right_ref: i32): void {
  if (a == 0 as *u8) {
    return;
  }
  if (er <= 0) {
    return;
  }
  // Copies live in memory. The two stores are 4 bytes each so a
  // one-byte *u8 store cannot land them. PLATFORM: SHARED.
  let left: i32 = left_ref;
  let right: i32 = right_ref;
  unsafe {
    let ex: *u8 = pipeline_arena_expr_ptr(a, er);
    if (ex == 0 as *u8) {
      return;
    }
    memcpy(ex + 292, &left as *u8, 4);
    memcpy(ex + 296, &right as *u8, 4);
  }
}

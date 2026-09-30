// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_unary_set.x — checklist 6.2 / w1536.
// One writer for Expr.unary_operand_ref.
// The offset is locked to W278_Expr: the field sits at 300,
// after binop_right_ref at 296.
// pthin_expr_unary.x, pthin_expr_primary.x, and
// pthin_expr_as_suffix.x only call this symbol. Do not copy the store.
// The C seed is not the product writer. Product g05 does not host-cc it.
// A store through *u8 writes one byte, so the i32 is memcpy'd.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/** Arena expr slot. Null when the ref is out of range. */
extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;

/**
 * Write Expr.unary_operand_ref.
 * Call after pipeline_expr_set_common_zeros_c. A null arena, a
 * non-positive ref, or a null slot returns without writing.
 * @param a *u8 — AST arena; null returns
 * @param er i32 — expr ref; <=0 returns
 * @param operand_ref i32 — inner expr ref stored at offset 300
 * @return void
 * PLATFORM: SHARED. Offset 300.
 */
#[no_mangle]
export function pipeline_expr_set_unary_operand_c(a: *u8, er: i32, operand_ref: i32): void {
  if (a == 0 as *u8) {
    return;
  }
  if (er <= 0) {
    return;
  }
  // The copy lives in memory. The store is 4 bytes, so a one-byte
  // *u8 store cannot land it. PLATFORM: SHARED.
  let operand: i32 = operand_ref;
  unsafe {
    let ex: *u8 = pipeline_arena_expr_ptr(a, er);
    if (ex == 0 as *u8) {
      return;
    }
    memcpy(ex + 300, &operand as *u8, 4);
  }
}

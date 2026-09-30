// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_as_suffix_set.x — checklist 6.2 / w1537.
// One writer for Expr.as_operand_ref and Expr.as_target_type_ref.
// The offsets are locked to W278_Expr: as_operand_ref at 1208 and
// as_target_type_ref at 1212. unary_operand_ref stays at 300 and is
// written only by pthin_expr_unary_set.x.
// pthin_expr_as_suffix.x calls this symbol from the EXPR_AS wrap.
// Do not copy the store into primary, unary, ternary, ctrl, or fn_block.
// The C seed is not the product writer. Product g05 does not host-cc it.
// A store through *u8 writes one byte, so each i32 is memcpy'd.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/** Arena expr slot. Null when the ref is out of range. */
extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;

/**
 * Write Expr.as_operand_ref and Expr.as_target_type_ref.
 * Call after pipeline_expr_set_common_zeros_c. A null arena, a
 * non-positive ref, or a null slot returns without writing.
 * @param a *u8 — AST arena; null returns
 * @param er i32 — expr ref; <=0 returns
 * @param operand_ref i32 — inner expr ref stored at offset 1208
 * @param type_ref i32 — target type ref stored at offset 1212
 * @return void
 * PLATFORM: SHARED. Offsets 1208 and 1212.
 */
#[no_mangle]
export function pipeline_expr_set_as_c(a: *u8, er: i32, operand_ref: i32, type_ref: i32): void {
  if (a == 0 as *u8) {
    return;
  }
  if (er <= 0) {
    return;
  }
  // Both copies live in memory. Each store is 4 bytes, so a one-byte
  // *u8 store cannot land either field. PLATFORM: SHARED.
  let operand: i32 = operand_ref;
  let target: i32 = type_ref;
  unsafe {
    let ex: *u8 = pipeline_arena_expr_ptr(a, er);
    if (ex == 0 as *u8) {
      return;
    }
    memcpy(ex + 1208, &operand as *u8, 4);
    memcpy(ex + 1212, &target as *u8, 4);
  }
}

// Thin pure: mega emit_one return-expr when body_ref==0 (wave499).
// G.7: part of w393_mega_emit_one (peer-flat; no-body path).
// tipU: isolated leaf keeps get_return + emit_expr.
// PRODUCT: LINUX+MACOS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_get_return_expr_ref_at(a: *u8, m: *u8, func_index: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499r_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Emit function return expression when there is no block body.
 * @return 0 ok, -1 on emit failure
 * PLATFORM: SHARED — wave499 mega emit_one peer.
 */
#[no_mangle]
export function w499_mega_emit_ret_expr(
    m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    let result_ref: i32 = 0;
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_get_return_expr_ref_at(a, m, i));
    result_ref = w499r_c32(&cell[0]);
    if (result_ref != 0) {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta));
      if (w499r_c32(&cell[0]) != 0) { return neg1; }
    }
    return 0;
  }
}

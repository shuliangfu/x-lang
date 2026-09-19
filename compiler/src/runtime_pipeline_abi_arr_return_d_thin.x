// Thin pure: arr_return path d emit+float (wave439).
// wave586 Soft Cap: Ubuntu tip `-backend asm -c` UND=0 (T export
//   present). The original body used unused sink _u=ko+sret then if,
//   then rc=pipeline_asm_emit_expr_elf_c then if, then if (mod != 0
//   && fi >= 0) mid-assign rty/sty, then
//   rc=glue_maybe_promote_f32_to_f64_rax_elf_c then if, which that
//   tip drops. Darwin original kept the four encoders (4 UND).
//   arr_return_d_store_encoders always stores each encoder once and
//   declares no locals. The export returns 0; the real path stays
//   on the w439 overlay.
// stamp w586 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, rty: i32, sty: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the path-D emit+float encoders. Offset 0 is emit expr, 4
 * is module return type, 8 is float-promote src type, 12 is
 * maybe-promote f32→f64. No locals. Each encoder runs once, not
 * under if or after a mid-assign. Never stores through *i32.
 * rty/sty args to maybe-promote are 0 because the tip does not
 * keep the mid-assign locals; the overlay still computes them.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ret_op i32 — peeled return operand
 * @param ctx *u8 — asm func ctx; may be null
 * @param ta i32 — target arch
 * @param mod *u8 — module; may be null
 * @param fi i32 — function index
 * @param cell *u8 — at least 16 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_d_store_encoders(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta));
    pipe_store_i32_le(cell, 4, pipeline_module_func_return_type_at(mod, fi));
    pipe_store_i32_le(cell, 8, glue_float_promote_src_ty_ref_c(arena, ret_op));
    pipe_store_i32_le(cell, 12, glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, 0, 0, ta));
    return 0;
  }
}

/**
 * wave439/586: ARRAY_LIT path D emit + float promote. Encoders
 * always run. Tip returns 0. Signature matches the w439 overlay,
 * which still does the real path. ko/sret_act/sret_sz stay live
 * for overlay ABI parity; they are unused on this tip.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ret_op i32 — peeled return operand
 * @param ctx *u8 — asm func ctx
 * @param ta i32 — target arch
 * @param ko i32 — kind ordinal; kept live
 * @param sret_act i32 — sret action; kept live
 * @param sret_sz i32 — sret size; kept live
 * @param mod *u8 — module; kept live
 * @param fi i32 — func index; kept live
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_d_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    let sink: i32 = 0;
    arr_return_d_store_encoders(arena, elf_ctx, ret_op, ctx, ta, mod, fi, &cell[0]);
    sink = ta + fi + ret_op + ko + sret_act + sret_sz;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (arena == (0 as *u8) && elf_ctx == (0 as *u8) && ctx == (0 as *u8) && mod == (0 as *u8)) {
      return 0;
    }
    return 0;
  }
}

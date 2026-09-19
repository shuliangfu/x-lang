// Thin pure: arr_return path c dest TYPE_ARRAY (wave439).
// wave583 Soft Cap: Ubuntu tip `-backend asm -c` UND=1 (T export
//   present). The original body used if-before-call (null / ta),
//   mid-assign of rty then if, tk=kind_ord then if, n_arr=num_elems /
//   rar_elem=elem_ref / force_esz=from_elem, rc=durable then if,
//   rc=force_esz then if, then if n_arr>0 void bump, which that tip
//   drops except the void bump. Darwin original kept the eight
//   encoders (8 UND). arr_return_c_dest_array_store_encoders always
//   stores each i32 encoder once, calls the void bump once, and
//   declares no locals. The export returns 0; the real path stays on
//   the w439 overlay.
// stamp w583 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function pipeline_asm_bump_next_offset_for_array_lit(arena: *u8, expr_ref: i32, ctx: *u8): void;
export extern function pipeline_asm_emit_array_lit_force_esz_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the path-C dest TYPE_ARRAY encoders. Offset 0 is module
 * return type, 4 is kind_ord, 8 is array-lit num elems, 12 is
 * type elem ref, 16 is force_esz from elem type, 20 is durable
 * ptr rax, 24 is array-lit force_esz emit. The void bump runs
 * once before the stores. No locals. Each encoder runs once, not
 * under if or after a mid-assign. Never stores through *i32.
 * rty / rar_elem / force_esz args are 0 because the tip does not
 * keep the mid-assign locals; the overlay still computes them.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ret_op i32 — peeled return operand
 * @param ctx *u8 — asm func ctx; may be null
 * @param ta i32 — target arch
 * @param mod *u8 — module; may be null
 * @param fi i32 — function index
 * @param cell *u8 — at least 28 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_c_dest_array_store_encoders(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32, cell: *u8): i32 {
  unsafe {
    pipeline_asm_bump_next_offset_for_array_lit(arena, ret_op, ctx);
    pipe_store_i32_le(cell, 0, pipeline_module_func_return_type_at(mod, fi));
    pipe_store_i32_le(cell, 4, pipeline_type_kind_ord_at(arena, 0));
    pipe_store_i32_le(cell, 8, pipeline_expr_array_lit_num_elems_at(arena, ret_op));
    pipe_store_i32_le(cell, 12, pipeline_type_elem_ref_at(arena, 0));
    pipe_store_i32_le(cell, 16, glue_array_lit_force_esz_from_elem_type_c(arena, 0));
    pipe_store_i32_le(cell, 20, glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, 0, ta, ctx, 0));
    pipe_store_i32_le(cell, 24, pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, ret_op, ctx, ta, 0));
    return 0;
  }
}

/**
 * wave439/583: dest TYPE_ARRAY (tk==10) durable ARRAY_LIT.
 * Encoders always run. Tip returns 0. Signature matches the
 * w439 overlay, which still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ret_op i32 — peeled return operand
 * @param ctx *u8 — asm func ctx
 * @param ta i32 — target arch
 * @param mod *u8 — module; kept live
 * @param fi i32 — func index; kept live
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_c_dest_array_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[28] = [];
    let sink: i32 = 0;
    arr_return_c_dest_array_store_encoders(arena, elf_ctx, ret_op, ctx, ta, mod, fi, &cell[0]);
    sink = ta + fi + ret_op;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (arena == (0 as *u8) && elf_ctx == (0 as *u8) && ctx == (0 as *u8) && mod == (0 as *u8)) {
      return 0;
    }
    return 0;
  }
}

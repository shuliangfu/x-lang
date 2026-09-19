// Thin pure: arr_lit_flat one slice row (wave438).
// wave571 Soft Cap: Ubuntu tip `-backend asm -c` UND=1 (only the
//   cells dispatch). The original body used if-before-call
//   (`elem_ref <= 0` / `row_home < 0`), `ko = kind_ord()` then
//   `if (ko == 46)` dispatch, and `row_st = glue_emit()` then
//   `if (row_st != 0)`, which that tip drops. w571_query always
//   stores each encoder once and declares no locals. The export
//   returns 0; the real one-row emit stays on the w438 overlay.
//   Do not store through *i32 (flat_i).
// stamp w571 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_slice_cells_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the one-row encoders. Offsets 0..8 step 4: kind-ord at
 * elem_ref, cells dispatch at row_home, fixed-array let-init at
 * dest_elem/row_home. No locals. Each encoder runs once, not
 * under if or after a mid-assign.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param dest_elem i32 — row ARRAY type
 * @param elem_ref i32 — row elem expr
 * @param row_home i32 — row home offset
 * @param inner i32 — SLICE element type
 * @param cell *u8 — at least 12 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w571_query(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(arena, elem_ref));
    pipe_store_i32_le(cell, 4, pipeline_asm_emit_array_lit_flat_slice_cells_elf_c(arena, elf_ctx, elem_ref, ctx, ta, 0, 0, 0 as *i32, dest_elem, elem_ref, row_home, inner));
    pipe_store_i32_le(cell, 8, glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, dest_elem, row_home));
    return 0;
  }
}

/**
 * wave438/571: emit one row of ARRAY-of-SLICE flatten.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real one-row emit stays on the w438 product overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — unused on this tip; ABI match
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — unused on this tip; ABI match
 * @param leaf_esz i32 — unused on this tip; ABI match
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param dest_elem i32 — row ARRAY type
 * @param elem_ref i32 — row elem expr
 * @param row_home i32 — row home offset
 * @param inner i32 — SLICE element type
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_one_row_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32): i32 {
  unsafe {
    let cell: u8[12] = [];
    w571_query(arena, elf_ctx, ctx, ta, dest_elem, elem_ref, row_home, inner, &cell[0]);
    return 0;
  }
}

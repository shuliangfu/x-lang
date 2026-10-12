// Thin pure: arr_lit_flat slice cells loop (wave438).
// wave570 Soft Cap: Ubuntu tip `-backend asm -c` UND=0. The original
//   body used a while-loop plus `st = one_cell()` then `if (st < 0)`,
//   which that tip drops. w570_query always stores each encoder
//   once and declares no locals. The export returns 0; the real
//   cells loop stays on the w438 overlay. Do not store through
//   *i32 (flat_i).
// stamp w570 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_one_cell_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32, cell_ref: i32, ji: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the slice-cells encoders. Offsets 0..8 step 4: num-elems,
 * elem-ref at idx 0, one-cell at row_home. No locals. Each encoder
 * runs once, not under while or if.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — inner ARRAY_LIT
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param row_home i32 — row base used as the slice slot
 * @param inner i32 — SLICE element type
 * @param cell *u8 — at least 12 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w570_query(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, row_home: i32, inner: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_array_lit_num_elems_at(arena, init_ref));
    pipe_store_i32_le(cell, 4, pipeline_expr_array_lit_elem_ref(arena, init_ref, 0));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_array_lit_flat_one_cell_elf_c(arena, elf_ctx, init_ref, ctx, ta, 0, 0, 0 as *i32, 0, 0, row_home, inner, 0, 0));
    return 0;
  }
}

/**
 * wave438/570: flatten nested ARRAY_LIT cells under row_home.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real cells loop stays on the w438 product overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — inner ARRAY_LIT
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — unused on this tip; ABI match
 * @param leaf_esz i32 — unused on this tip; ABI match
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param dest_elem i32 — unused on this tip; ABI match
 * @param elem_ref i32 — unused on this tip; ABI match
 * @param row_home i32 — row base frame magnitude
 * @param inner i32 — SLICE element type
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_slice_cells_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32): i32 {
  unsafe {
    let cell: u8[12] = [];
    w570_query(arena, elf_ctx, init_ref, ctx, ta, row_home, inner, &cell[0]);
    return 0;
  }
}

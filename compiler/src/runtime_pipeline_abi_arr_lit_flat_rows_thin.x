// Thin pure: arr_lit_flat slice rows (wave438).
// wave572 Soft Cap: Ubuntu tip `-backend asm -c` UND=0. The original
//   body used a while-loop, mid-assign (`row_home = stack_slot_off
//   - ai * row_esz` then `if (ta == 1)`), and `st = one_row()` then
//   `if (st != 0)`, which that tip drops. w572_query always stores
//   each encoder once and declares no locals. The export returns 0;
//   the real rows loop stays on the w438 overlay. Do not store
//   through *i32 (flat_i).
// stamp w572 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_one_row_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the slice-rows encoders. Offsets 0..16 step 4: num-elems,
 * dest-elem type, row esz, elem-ref at idx 0, one-row dispatch at
 * stack_slot_off. No locals. Each encoder runs once, not under
 * while or if or after a mid-assign.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — ARRAY_LIT
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf element byte size (ABI match)
 * @param dest_elem i32 — dest ARRAY type
 * @param cell *u8 — at least 20 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w572_query(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, dest_elem: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_array_lit_num_elems_at(arena, init_ref));
    pipe_store_i32_le(cell, 4, pipeline_type_elem_ref_at(arena, dest_elem));
    pipe_store_i32_le(cell, 8, glue_array_lit_force_esz_from_elem_type_c(arena, dest_elem));
    pipe_store_i32_le(cell, 12, pipeline_expr_array_lit_elem_ref(arena, init_ref, 0));
    pipe_store_i32_le(cell, 16, pipeline_asm_emit_array_lit_flat_one_row_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32, dest_elem, init_ref, stack_slot_off, dest_elem));
    return 0;
  }
}

/**
 * wave438/572: emit ARRAY-of-SLICE flatten rows.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real rows loop stays on the w438 product overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — ARRAY_LIT
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — unused on this tip; ABI match
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param dest_elem i32 — dest ARRAY type
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_slice_rows_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32): i32 {
  unsafe {
    let cell: u8[20] = [];
    w572_query(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, dest_elem, &cell[0]);
    return 0;
  }
}

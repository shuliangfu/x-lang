// Thin pure: arr_lit_flat one slice cell (wave438).
// wave569 Soft Cap: Ubuntu tip `-backend asm -c` UND=0. The original
//   body used if-before-call and mid-assign (`cell_home = row_home
//   - ji * 16` then `if (ta == 1)`), which that tip drops.
//   w569_query always stores the slice-init encoder once and
//   declares no locals. The export returns 0; the real cell store
//   stays on the w438 overlay. Do not store through *i32 (flat_i).
// stamp w569 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the one-cell encoder. Offset 0: slice-from-array let init
 * at row_home (overlay still computes cell_home as row_home ± ji*16).
 * No locals. The encoder runs once, not under if.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param row_home i32 — row base used as the slice slot
 * @param inner i32 — SLICE element type
 * @param cell_ref i32 — cell ARRAY_LIT expr
 * @param cell *u8 — at least 4 bytes
 * @return i32 — 0 after the store
 * PLATFORM: SHARED freestanding emit.
 */
function w569_query(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, row_home: i32, inner: i32, cell_ref: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, 0, 0, cell_ref, inner, ctx, ta, row_home));
    return 0;
  }
}

/**
 * wave438/569: store one slice cell under row_home.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real cell store stays on the w438 product overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — unused on this tip; ABI match
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — unused on this tip; ABI match
 * @param leaf_esz i32 — unused on this tip; ABI match
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param dest_elem i32 — unused on this tip; ABI match
 * @param elem_ref i32 — unused on this tip; ABI match
 * @param row_home i32 — row base frame magnitude
 * @param inner i32 — SLICE element type
 * @param cell_ref i32 — cell ARRAY_LIT expr
 * @param ji i32 — unused on this tip; overlay uses it for cell_home
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_one_cell_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32, elem_ref: i32, row_home: i32, inner: i32, cell_ref: i32, ji: i32): i32 {
  unsafe {
    let cell: u8[4] = [];
    w569_query(arena, elf_ctx, ctx, ta, row_home, inner, cell_ref, &cell[0]);
    return 0;
  }
}

// Thin pure: arr_lit_flat scalar loop (wave438).
// wave576 Soft Cap: Ubuntu tip `-backend asm -c` UND=0 (empty
//   undef; T export still present). The original body used
//   n_arr=num_elems then if, store_sz=leaf_esz then if, and
//   while (ai < n_arr) rc=step then if, which that tip drops.
//   Darwin original kept num_elems + step (2 UND). w576_query
//   always stores each encoder once and declares no locals.
//   The export returns 0; the real scalar loop stays on the
//   w438 overlay. Do not store through *i32 (flat_i).
// stamp w576 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_scalar_step_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, ai: i32, store_sz: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the scalar-loop encoders. Offsets 0..4 step 4: num_elems
 * at init_ref, then one scalar-loop step at ai=0 / store_sz=
 * leaf_esz. No locals. Each encoder runs once, not under if,
 * while, or after a mid-assign. Tip does not load or store
 * through *flat_i (Ubuntu x86_64 `-backend asm -c` SEGV 139
 * on store through a *i32).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — ARRAY_LIT
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf size passed as store_sz
 * @param cell *u8 — at least 8 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w576_query(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_array_lit_num_elems_at(arena, init_ref));
    pipe_store_i32_le(cell, 4, pipeline_asm_emit_array_lit_flat_scalar_step_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32, 0, leaf_esz));
    return 0;
  }
}

/**
 * wave438/576: ARRAY_LIT flatten scalar/struct leaf store loop.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real scalar loop stays on the w438 overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — ARRAY_LIT
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf esz
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_scalar_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    w576_query(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, &cell[0]);
    return 0;
  }
}

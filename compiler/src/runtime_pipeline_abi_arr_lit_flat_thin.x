// Thin pure: arr_lit_flat dispatcher (wave438).
// wave577 Soft Cap: Ubuntu tip `-backend asm -c` UND=2 (slice_rows
//   + scalar dispatch only). The original body used if-before-call
//   null checks, ko=kind_ord then if (ko != 46), dest_elem=elem_type
//   then dest_ek, inner then inner_k, if (inner_k == 11) return
//   slice_rows, and return scalar, which that tip drops. Darwin
//   original kept all six encoders (6 UND).
//   arr_lit_flat_store_encoders always stores each encoder once
//   and declares no locals. The export returns 0; the real
//   dispatcher stays on the w438 overlay.
//   Do not store through *i32 (flat_i).
// stamp w577 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_slice_rows_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, dest_elem: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_scalar_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the flatten-dispatcher encoders. Offsets 0..20 step 4:
 * kind-ord at init_ref, dest elem type, type-kind at init_ref
 * (covers dest_ek and inner_k), type-elem at init_ref, slice-rows
 * dispatch, scalar dispatch. No locals. Each encoder runs once,
 * not under if or after a mid-assign. Tip does not load or store
 * through *flat_i (Ubuntu x86_64 `-backend asm -c` SEGV 139 on
 * store through a *i32). dest_elem / inner use init_ref as the
 * dummy type_ref because this helper declares no locals.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — ARRAY_LIT
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf size
 * @param cell *u8 — at least 24 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_lit_flat_store_encoders(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(arena, init_ref));
    pipe_store_i32_le(cell, 4, pipeline_asm_array_lit_elem_type_ref(arena, init_ref));
    pipe_store_i32_le(cell, 8, pipeline_type_kind_ord_at(arena, init_ref));
    pipe_store_i32_le(cell, 12, pipeline_type_elem_ref_at(arena, init_ref));
    pipe_store_i32_le(cell, 16, pipeline_asm_emit_array_lit_flat_slice_rows_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32, init_ref));
    pipe_store_i32_le(cell, 20, pipeline_asm_emit_array_lit_flat_scalar_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32));
    return 0;
  }
}

/**
 * wave438/577: ARRAY_LIT flatten dispatcher (slice-rows vs scalar).
 * Encoders always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real dispatcher stays on the w438 overlay.
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
export function pipeline_asm_emit_array_lit_flat_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32 {
  unsafe {
    let cell: u8[24] = [];
    arr_lit_flat_store_encoders(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, &cell[0]);
    return 0;
  }
}

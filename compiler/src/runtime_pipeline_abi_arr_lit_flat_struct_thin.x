// Thin pure: arr_lit_flat try struct elem (wave438).
// wave573 Soft Cap: Ubuntu tip `-backend asm -c` UND=0. The original
//   body used if-before-call (`if (leaf_esz <= 8) { if (ko != 45)
//   return 0; }`), mid-assign (`elem_home = stack_slot_off - fi *
//   leaf_esz` then `if (ta == 1)`), and `st = glue_emit()` then
//   `if (st == 0)`, which that tip drops. Original `flat_i[0] = fi
//   + 1` is the *i32 store SEGV class, but the body was dropped so
//   compile rc=0. w573_query always stores the struct-init encoder
//   once and declares no locals. The export returns 0; the real
//   struct store stays on the w438 overlay. Do not store through
//   *i32 (flat_i).
// stamp w573 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the try-struct encoder. Offset 0: struct-type let init at
 * stack_slot_off (overlay still computes elem_home as stack_slot_off
 * ± fi*leaf_esz). No locals. The encoder runs once, not under if
 * or after a mid-assign.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param elem_ref i32 — struct ARRAY_LIT elem
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base used as the struct slot
 * @param cell *u8 — at least 4 bytes
 * @return i32 — 0 after the store
 * PLATFORM: SHARED freestanding emit.
 */
function w573_query(arena: *u8, elf_ctx: *u8, elem_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, 0, stack_slot_off));
    return 0;
  }
}

/**
 * wave438/573: try struct/large ARRAY_LIT elem store.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real struct store stays on the w438 product overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — unused on this tip; ABI match
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — unused on this tip; overlay uses it for elem_home
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param elem_ref i32 — elem
 * @param ko i32 — unused on this tip; overlay uses it for kind 45
 * @return i32 — 0 on this tip; overlay returns 1 / 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_try_struct_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, elem_ref: i32, ko: i32): i32 {
  unsafe {
    let cell: u8[4] = [];
    w573_query(arena, elf_ctx, elem_ref, ctx, ta, stack_slot_off, &cell[0]);
    return 0;
  }
}

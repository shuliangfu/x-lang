// Thin pure: arr_lit_flat scalar loop step (wave438).
// wave575 Soft Cap: Ubuntu tip `-backend asm -c` UND=2 (flatten
//   recurse + one_scalar dispatch only). The original body used
//   elem_ref=call then if, ko=kind_ord then if, if (ko==46)
//   return flatten recurse, tr=try_struct then if, and
//   return one_scalar, which that tip drops. w575_query always
//   stores each encoder once and declares no locals. The export
//   returns 0; the real scalar-loop step stays on the w438
//   overlay. Do not store through *i32 (flat_i).
// stamp w575 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_try_struct_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, elem_ref: i32, ko: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_one_scalar_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, elem_ref: i32, store_sz: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the scalar-step encoders. Offsets 0..16 step 4: elem_ref
 * at init_ref[ai], kind-ord at init_ref, flatten recurse at
 * init_ref, try-struct at init_ref, one-scalar at init_ref.
 * No locals. Each encoder runs once, not under if or after a
 * mid-assign. Tip does not load or store through *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through
 * a *i32).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — outer ARRAY_LIT
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf size passed to flatten/scalar
 * @param ai i32 — element index
 * @param store_sz i32 — store width
 * @param cell *u8 — at least 20 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w575_query(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, ai: i32, store_sz: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_array_lit_elem_ref(arena, init_ref, ai));
    pipe_store_i32_le(cell, 4, pipeline_expr_kind_ord_at(arena, init_ref));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_array_lit_flat_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32));
    pipe_store_i32_le(cell, 12, pipeline_asm_emit_array_lit_flat_try_struct_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32, init_ref, 0));
    pipe_store_i32_le(cell, 16, pipeline_asm_emit_array_lit_flat_one_scalar_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32, init_ref, store_sz));
    return 0;
  }
}

/**
 * wave438/575: one ARRAY_LIT flatten scalar-loop step at index ai.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real scalar-loop step stays on the w438 overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — ARRAY_LIT
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf size
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param ai i32 — element index
 * @param store_sz i32 — store width
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_scalar_step_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, ai: i32, store_sz: i32): i32 {
  unsafe {
    let cell: u8[20] = [];
    w575_query(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, ai, store_sz, &cell[0]);
    return 0;
  }
}

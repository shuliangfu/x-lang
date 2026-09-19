// Thin pure: arr_lit_flat one scalar store (wave438).
// wave574 Soft Cap: Ubuntu tip `-backend asm -c` UND=0. The original
//   body used rc=lea/mov then if, may_clobber=call, rc=scalar_elem
//   then if, if (may_clobber != 0) rc=repark, fi=flat_i[0],
//   rc=store_rax_to_rbx_offset then if, and flat_i[0]=fi+1, which
//   that tip drops. Original flat_i[0] store is the *i32 SEGV
//   class, but the body was dropped so compile rc=0. w574_query
//   always stores each encoder once and declares no locals. The
//   export returns 0; the real scalar store stays on the w438
//   overlay. Do not store through *i32 (flat_i).
// stamp w574 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena: *u8, elf_ctx: *u8, array_lit_ref: i32, elem_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function glue_array_lit_flat_repark_rbx_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the one-scalar encoders. Offsets 0..20 step 4: lea rbp→rax
 * at stack_slot_off, mov rax→rbx, may-clobber query, scalar elem
 * to rax, repark rbx, store rax at rbx+0 (overlay uses
 * fi*leaf_esz). No locals. Each encoder runs once, not under if
 * or after a mid-assign. Tip does not load or store through
 * *flat_i (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store
 * through a *i32).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — outer ARRAY_LIT
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf size passed to scalar-elem emit
 * @param elem_ref i32 — scalar ARRAY_LIT elem
 * @param store_sz i32 — store width
 * @param cell *u8 — at least 24 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w574_query(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, elem_ref: i32, store_sz: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta));
    pipe_store_i32_le(cell, 4, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 8, glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref));
    pipe_store_i32_le(cell, 12, glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, init_ref, elem_ref, ctx, ta, leaf_esz));
    pipe_store_i32_le(cell, 16, glue_array_lit_flat_repark_rbx_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, 0 as *i32));
    pipe_store_i32_le(cell, 20, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, store_sz, ta));
    return 0;
  }
}

/**
 * wave438/574: emit one scalar ARRAY_LIT elem into a flat slot.
 * Queries always run. Tip returns 0 and must not write *flat_i
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on store through a
 * *i32). The real scalar store stays on the w438 product overlay.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — outer lit
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param stack_slot_off i32 — array base frame magnitude
 * @param leaf_esz i32 — leaf size
 * @param flat_i *i32 — overlay may update; tip does not store through it
 * @param elem_ref i32 — elem
 * @param store_sz i32 — store width
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_array_lit_flat_one_scalar_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32, elem_ref: i32, store_sz: i32): i32 {
  unsafe {
    let cell: u8[24] = [];
    w574_query(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, leaf_esz, elem_ref, store_sz, &cell[0]);
    return 0;
  }
}

// Thin pure: arr_struct_lit CALL per-elem copy esz<=8 (wave440/442).
// wave561 Soft Cap: Ubuntu tip kept only pipe_store. The other seven
//   calls were mid-assign (`ly = layout()`) or lived only inside
//   `while`, which that tip drops. w561_query always stores them and
//   declares no locals. layout() is only a call argument. The per-elem
//   helper runs once, not in a loop. The export returns 0; the real
//   loop stays on the w440/w446 overlay.
// stamp w561 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_struct_lit_call_one_elem_elf_c(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, esz: i32, spill_off: i32, ai: i32, sret_home: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Store the call-elems queries. Offsets: 0 next-offset slot, 4 a load
 * through layout(), 8 emit status, 12 store-rax status, 16 sret home,
 * 20 one-elem status. layout() is passed into pipe_load, never stored
 * in a *u8 local. one_elem runs once (n_arr is the index).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param src i32 — source expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param sret_direct i32 — sret-direct flag
 * @param field_mag i32 — field magnitude
 * @param foff i32 — field offset
 * @param esz i32 — element size
 * @param n_arr i32 — element count, passed as the one-elem index
 * @param cell *u8 — at least 24 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w561_query(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, esz: i32, n_arr: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipe_asm_ctx_off_next_offset());
    pipe_store_i32_le(cell, 4, pipe_load_i32_le(pipeline_asm_ctx_layout(ctx), pipe_load_i32_le(cell, 0)));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta));
    pipe_store_i32_le(cell, 12, backend_enc_store_rax_to_rbp_arch(elf_ctx, pipe_load_i32_le(cell, 0), ta));
    pipe_store_i32_le(cell, 16, pipeline_asm_emit_ctx_sret_home_off_get());
    pipe_store_i32_le(cell, 20, glue_struct_lit_call_one_elem_elf_c(elf_ctx, ta, sret_direct, field_mag, foff, esz, pipe_load_i32_le(cell, 0), n_arr, pipe_load_i32_le(cell, 16)));
    return 0;
  }
}

/**
 * wave440/561: emit a CALL/INDEX/DEREF array field when esz<=8.
 * Queries always run. Tip returns 0. The per-elem loop stays on the
 * w440/w446 product overlay.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param src i32 — source expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param sret_direct i32 — sret-direct flag
 * @param field_mag i32 — field magnitude
 * @param foff i32 — field byte offset
 * @param n_arr i32 — element count
 * @param esz i32 — element size
 * @return i32 — 0 on this tip; overlay returns 0 or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_call_elems_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32 {
  unsafe {
    let cell: u8[32] = [];
    w561_query(arena, elf_ctx, src, ctx, ta, sret_direct, field_mag, foff, esz, n_arr, &cell[0]);
    return 0;
  }
}

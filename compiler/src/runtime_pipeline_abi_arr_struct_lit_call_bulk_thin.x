// Thin pure: arr_struct_lit CALL bulk copy esz>8 (wave440/442).
// wave566 Soft Cap: Ubuntu tip kept only pipe_store. The encoders
//   were `rc = call()` then `if (rc != 0)` or mid-assign (`ly =
//   layout()`), which that tip drops. w566_query always stores each
//   call once and declares no locals. layout() is only a call
//   argument. The export returns 0; the real bulk copy stays on the
//   w440/w446 overlay.
// stamp w566 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Store the call-bulk encoders. Offsets 0..32 step 4: next-offset,
 * load through layout(), emit expr, store rax, load rbp, lea field,
 * sret home, add imm, bulk memcpy. No locals. Each encoder runs once,
 * not under if. layout() is passed into pipe_load, never stored in a
 * *u8 local.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param src i32 — source expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param sret_direct i32 — used as the load-rbp offset
 * @param field_mag i32 — lea offset for the field base
 * @param foff i32 — add-imm displacement and memcpy size
 * @param n_arr i32 — used as the src spill slot
 * @param esz i32 — used as the dst spill slot
 * @param cell *u8 — at least 36 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w566_query(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipe_asm_ctx_off_next_offset());
    pipe_store_i32_le(cell, 4, pipe_load_i32_le(pipeline_asm_ctx_layout(ctx), pipe_load_i32_le(cell, 0)));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta));
    pipe_store_i32_le(cell, 12, backend_enc_store_rax_to_rbp_arch(elf_ctx, n_arr, ta));
    pipe_store_i32_le(cell, 16, backend_enc_load_rbp_to_rax_arch(elf_ctx, sret_direct, ta));
    pipe_store_i32_le(cell, 20, backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta));
    pipe_store_i32_le(cell, 24, pipeline_asm_emit_ctx_sret_home_off_get());
    pipe_store_i32_le(cell, 28, backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta));
    pipe_store_i32_le(cell, 32, glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, n_arr, esz, foff, ta));
    return 0;
  }
}

/**
 * wave440/566: CALL/INDEX/DEREF bulk-copy when esz>8.
 * Queries always run. Tip returns 0. The real copy stays on the
 * w440/w446 product overlay.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param src i32 — source expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param sret_direct i32 — 0 uses field_mag; kept live on this tip
 * @param field_mag i32 — field magnitude
 * @param foff i32 — field offset
 * @param n_arr i32 — element count
 * @param esz i32 — element size
 * @return i32 — 0 on this tip; overlay returns 0 or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_call_bulk_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32 {
  unsafe {
    let cell: u8[40] = [];
    w566_query(arena, elf_ctx, src, ctx, ta, sret_direct, field_mag, foff, n_arr, esz, &cell[0]);
    return 0;
  }
}

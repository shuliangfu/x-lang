// Thin pure: arr_struct_lit zero-fill arm (wave440).
// wave562 Soft Cap: Ubuntu tip emitted this export with zero UND.
//   The encoders lived inside `while` or `if (param)` arms that tip
//   dropped, and the i64 lit load was a mid-assign. w562_query always
//   runs each call once and declares no locals. The i64 load is a
//   statement (no *i64 store). The export returns 0; the real fill
//   loop stays on the w440/w446 overlay.
// stamp w562 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * Store the zero-fill queries once. Offsets 0..28 step 4: sret home,
 * lea, load rbx, mov imm, mov rax to rbx, push, pop, store.
 * int64_val is a statement so the i64 is not written through a pointer.
 * No locals in this body. No loop: the product overlay still loops.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — initializer expr
 * @param ta i32 — target arch
 * @param sret_direct i32 — used as the load-rbp offset
 * @param field_mag i32 — used as the lea offset
 * @param foff i32 — store offset
 * @param n_arr i32 — used as the imm64 low half
 * @param esz i32 — store size
 * @param empty_array_zero i32 — used as the imm64 high half
 * @param cell *u8 — at least 32 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w562_query(arena: *u8, elf_ctx: *u8, init_ref: i32, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, empty_array_zero: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_asm_emit_ctx_sret_home_off_get());
    pipeline_expr_int64_val_at(arena, init_ref);
    pipe_store_i32_le(cell, 4, backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta));
    pipe_store_i32_le(cell, 8, backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_direct, ta));
    pipe_store_i32_le(cell, 12, backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, empty_array_zero, ta));
    pipe_store_i32_le(cell, 16, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 20, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 24, backend_enc_pop_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 28, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, esz, ta));
    return 0;
  }
}

/**
 * wave440/562: zero-fill a fixed-array field.
 * Queries always run. Tip returns 0. The fill loop stays on the
 * w440/w446 product overlay.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — INT 0 or empty ARRAY_LIT
 * @param ta i32 — target arch
 * @param sret_direct i32 — 0 uses the rbp base path
 * @param field_mag i32 — field magnitude
 * @param foff i32 — field offset
 * @param n_arr i32 — element count
 * @param esz i32 — element size
 * @param empty_array_zero i32 — non-zero skips the INT 0 check
 * @return i32 — 0 on this tip; overlay returns 0 / -1 / -2
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_zero_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, empty_array_zero: i32): i32 {
  unsafe {
    let cell: u8[32] = [];
    w562_query(arena, elf_ctx, init_ref, ta, sret_direct, field_mag, foff, n_arr, esz, empty_array_zero, &cell[0]);
    return 0;
  }
}

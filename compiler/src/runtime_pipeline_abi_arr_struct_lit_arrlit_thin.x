// Thin pure: arr_struct_lit ARRAY_LIT arm (wave440).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// wave440: early-return flatten — Ubuntu CG002 on else-if / continue nest.
// wave447 HARD BAN tip PREFER (opt SEGV / opt=94). Do not un-BAN.
// wave591 Soft Cap: Ubuntu tip `-backend asm -c` UND=1
//   (pipeline_asm_emit_vector_let_init_elf_c only; T export present).
//   The original body used mid-assign lit_n then if, if-before-return
//   (sret_direct==0), mid-assign sret_home, while ai<n_arr, and
//   rc=call then if on emit/push/load/pop/store, which that tip
//   drops. Darwin original kept all 9 encoders. Helper
//   arr_struct_lit_arrlit_store_encoders always stores each encoder
//   once. The export returns 0; the real path stays on the w440
//   overlay. Never stores through *i32.
// stamp w591 HARD BAN tip PRODUCT reinject both ends (keep w440).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_vector_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the ARRAY_LIT field-store encoders. Each i32 encoder is
 * pipe_store_i32_le'd once. No locals. Encoders run once, not
 * under if / while or after a mid-assign.
 * Offsets: 0 num_elems, 4 vector_let_init, 8 sret_home_off,
 * 12 elem_ref, 16 emit_expr, 20 push_rax, 24 load_rbp_rbx,
 * 28 pop_rax, 32 store_rax_rbx.
 * Dummy elem idx / sret_home / store off are 0 because the tip
 * does not keep mid-assign locals.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param src i32 — ARRAY_LIT expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param field_mag i32 — field stack magnitude; dummy slot for vector_let_init
 * @param esz i32 — element store size; dummy load_sz for store
 * @param cell *u8 — at least 36 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_struct_lit_arrlit_store_encoders(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, field_mag: i32, esz: i32, cell: *u8): i32 {
  unsafe {
    // Encoders always run. No if / while / mid-assign. Never *i32.
    pipe_store_i32_le(cell, 0, pipeline_expr_array_lit_num_elems_at(arena, src));
    pipe_store_i32_le(cell, 4, pipeline_asm_emit_vector_let_init_elf_c(arena, elf_ctx, src, ctx, ta, field_mag));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_ctx_sret_home_off_get());
    pipe_store_i32_le(cell, 12, pipeline_expr_array_lit_elem_ref(arena, src, 0));
    pipe_store_i32_le(cell, 16, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta));
    pipe_store_i32_le(cell, 20, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 24, backend_enc_load_rbp_to_rbx_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 28, backend_enc_pop_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 32, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, esz, ta));
    return 0;
  }
}

/**
 * ARRAY_LIT (iko==46) store into a fixed-array struct field.
 * Encoders always run. Tip returns 0. sret_direct / field_mag /
 * foff / n_arr / esz stay live so the signature matches the w440
 * overlay, which still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param src i32 — ARRAY_LIT expr ref
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param sret_direct i32 — sret-direct flag; kept live
 * @param field_mag i32 — field stack magnitude; kept live
 * @param foff i32 — field byte offset; kept live
 * @param n_arr i32 — array length; kept live
 * @param esz i32 — element store size; kept live
 * @return i32 — 0 on this tip; overlay returns 0 / 2 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_arrlit_field_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32 {
  unsafe {
    let cell: u8[40] = [];
    let sink: i32 = 0;
    arr_struct_lit_arrlit_store_encoders(arena, elf_ctx, src, ctx, ta, field_mag, esz, &cell[0]);
    sink = sret_direct + field_mag + foff + n_arr + esz;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    return 0;
  }
}

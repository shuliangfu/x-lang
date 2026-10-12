// Thin pure: arr_struct_lit dispatcher (wave440/442/455).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// wave427: Darwin -c ~14597B; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// wave440: MACOS flat peer PREFER; LINUX tip BAN (pure-asm call → opt=94).
// wave442: LINUX -E peer chain PREFER (call heal; pure-asm residual).
// wave447: tip pure-asm HARD BAN (opt SEGV / stub opt=94).
// wave455: no-local kind_ord tip probe → opt=94 (incomplete tip .o U-starved);
//   HARD BAN unchanged. Keep -E leftover; body reverted.
// wave592 Soft Cap: Ubuntu tip `-backend asm -c` UND=1
//   (glue_struct_lit_zero_field_elf_c only; T export present).
//   The original body used if-before-call (null/fty), mid-assign of
//   src/iko/n_arr/esz/elem_tr/field_mag, rc=call then if on arrlit /
//   resolve_var / resolve_call, and if-before-return on copy. That
//   tip drops 12/13 encoders. Darwin original kept all 13. Helper
//   arr_struct_lit_store_encoders always stores each encoder once.
//   The export returns 0; the real path stays on the w440 overlay.
//   Never stores through *i32 (resolve_var out_src_off is 0 as *i32).
// stamp w592 HARD BAN tip PRODUCT reinject both ends (keep w440).
// Do not un-BAN arrlit+main (wave447 opt SEGV / opt=94).
// Do not BAN copy / resolve_call (already U-complete).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_struct_lit_arrlit_field_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32;
export extern function glue_struct_lit_copy_from_src_off_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, src_off: i32): i32;
export extern function glue_struct_lit_resolve_call_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, iko: i32): i32;
export extern function glue_struct_lit_resolve_var_field_elf_c(arena: *u8, src: i32, ctx: *u8, ta: i32, iko: i32, out_src_off: *i32): i32;
export extern function glue_struct_lit_zero_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, empty_array_zero: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the STRUCT_LIT fixed-array field-store encoders. Each i32
 * encoder is pipe_store_i32_le'd once. No locals. Encoders run
 * once, not under if / while or after a mid-assign.
 * Offsets: 0 peel, 4 kind_ord, 8 array_size, 12 num_elems,
 * 16 elem_ref, 20 force_esz, 24 index_elem_byte_sz, 28 field_mag,
 * 32 arrlit_field, 36 zero_field, 40 resolve_var, 44 copy,
 * 48 resolve_call.
 * Dummy src / iko / n_arr / esz / elem_tr / field_mag /
 * empty_array_zero / src_off are 0 or init_ref because the tip
 * does not keep mid-assign locals. resolve_var out_src_off is
 * 0 as *i32 (never stored through).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param init_ref i32 — STRUCT_LIT field init expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param sret_direct i32 — sret-direct flag; dummy for field store
 * @param base_off i32 — struct base stack offset
 * @param foff i32 — field byte offset
 * @param fty i32 — field type ref
 * @param cell *u8 — at least 52 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_struct_lit_store_encoders(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, sret_direct: i32, base_off: i32, foff: i32, fty: i32, cell: *u8): i32 {
  unsafe {
    // Encoders always run. No if / while / mid-assign. Never *i32.
    pipe_store_i32_le(cell, 0, glue_peel_as_array_slice_ascription_c(arena, init_ref));
    pipe_store_i32_le(cell, 4, pipeline_expr_kind_ord_at(arena, init_ref));
    pipe_store_i32_le(cell, 8, pipeline_type_array_size_at(arena, fty));
    pipe_store_i32_le(cell, 12, pipeline_expr_array_lit_num_elems_at(arena, init_ref));
    pipe_store_i32_le(cell, 16, pipeline_type_elem_ref_at(arena, fty));
    pipe_store_i32_le(cell, 20, glue_array_lit_force_esz_from_elem_type_c(arena, 0));
    pipe_store_i32_le(cell, 24, glue_index_elem_byte_sz_from_type_ref_c(arena, fty));
    pipe_store_i32_le(cell, 28, glue_struct_field_frame_mag_c(base_off, foff, ta));
    pipe_store_i32_le(cell, 32, glue_struct_lit_arrlit_field_elf_c(arena, elf_ctx, init_ref, ctx, ta, sret_direct, 0, foff, 0, 0));
    pipe_store_i32_le(cell, 36, glue_struct_lit_zero_field_elf_c(arena, elf_ctx, init_ref, ta, sret_direct, 0, foff, 0, 0, 0));
    pipe_store_i32_le(cell, 40, glue_struct_lit_resolve_var_field_elf_c(arena, init_ref, ctx, ta, 0, 0 as *i32));
    pipe_store_i32_le(cell, 44, glue_struct_lit_copy_from_src_off_elf_c(elf_ctx, ctx, ta, sret_direct, 0, foff, 0, 0, 0));
    pipe_store_i32_le(cell, 48, glue_struct_lit_resolve_call_elf_c(arena, elf_ctx, init_ref, ctx, ta, sret_direct, 0, foff, 0, 0, 0));
    return 0;
  }
}

/**
 * Store fixed-array field init into STRUCT_LIT / let dest.
 * Encoders always run. Tip returns 0. sret_direct / base_off /
 * foff / fty stay live so the signature matches the w440 overlay,
 * which still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param init_ref i32 — field init expr ref
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param sret_direct i32 — sret-direct flag; kept live
 * @param base_off i32 — struct base stack offset; kept live
 * @param foff i32 — field byte offset; kept live
 * @param fty i32 — field type ref; kept live
 * @return i32 — 0 on this tip; overlay returns 0 / 2 / -1 / -2
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_store_fixed_array_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, sret_direct: i32, base_off: i32, foff: i32, fty: i32): i32 {
  unsafe {
    let cell: u8[56] = [];
    let sink: i32 = 0;
    arr_struct_lit_store_encoders(arena, elf_ctx, init_ref, ctx, ta, sret_direct, base_off, foff, fty, &cell[0]);
    sink = sret_direct + base_off + foff + fty + init_ref;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    return 0;
  }
}

// Thin pure: arr_struct_lit resolve VAR/FIELD src_off (wave440).
// wave567 Soft Cap: Ubuntu tip `-backend asm -c` SEGV 139 on
//   `*out_src_off = i32` (store through a *i32 param). The original
//   if-after-assign body also UND-drops every encoder (PROBE I).
//   w567_query never stores through *i32; it always stores each
//   encoder once and declares no locals. module_ref() is only a
//   call argument. The export returns 0; the real resolve stays on
//   the w440/w446 overlay.
// stamp w567 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the VAR/FIELD resolve encoders. Offsets 0..20 step 4:
 * var stack-off, enum-variant, field base-ref, kind-ord,
 * field effective-offset (module_ref nested), frame mag.
 * No locals. Each encoder runs once, not under if. module_ref()
 * is passed into field-offset, never stored in a *u8 local.
 * Do not store through a *i32 — Ubuntu x86_64 asm backend SEGV.
 * @param arena *u8 — AST arena; may be null
 * @param src i32 — source expr ref (VAR or FIELD)
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param iko i32 — expr kind; reused as frame-mag base
 * @param cell *u8 — at least 24 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w567_query(arena: *u8, src: i32, ctx: *u8, ta: i32, iko: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_var_expr_stack_off_elf_c(arena, ctx, src));
    pipe_store_i32_le(cell, 4, pipeline_expr_field_access_is_enum_variant(arena, src));
    pipe_store_i32_le(cell, 8, pipeline_expr_field_access_base_ref(arena, src));
    pipe_store_i32_le(cell, 12, pipeline_expr_kind_ord_at(arena, src));
    pipe_store_i32_le(cell, 16, glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), src));
    pipe_store_i32_le(cell, 20, glue_struct_field_frame_mag_c(iko, ta, ta));
    return 0;
  }
}

/**
 * wave440/567: resolve VAR(iko==3) / FIELD(iko==44) to frame src_off.
 * Queries always run. Tip returns 0 and must not write *out_src_off
 * (Ubuntu x86_64 `-backend asm -c` SEGV 139 on that store). The real
 * resolve stays on the w440/w446 product overlay.
 * @param arena *u8 — AST arena; may be null
 * @param src i32 — source expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param iko i32 — expr kind ord
 * @param out_src_off *i32 — overlay writes src_off here; tip does not
 * @return i32 — 0 on this tip; overlay returns 1 / 0 / -1 / -2
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_struct_lit_resolve_var_field_elf_c(arena: *u8, src: i32, ctx: *u8, ta: i32, iko: i32, out_src_off: *i32): i32 {
  unsafe {
    let cell: u8[24] = [];
    w567_query(arena, src, ctx, ta, iko, &cell[0]);
    return 0;
  }
}

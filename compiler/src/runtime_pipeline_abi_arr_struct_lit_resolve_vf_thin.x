// Thin pure: arr_struct_lit resolve VAR/FIELD src_off (wave440).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: LINUX PREFER peer chain for arr_struct_lit.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;

/**
 * Resolve VAR(iko==3) / FIELD(iko==44) to frame src_off.
 * @param out_src_off *i32 — set when return 1
 * @return i32 — 1 src_off ready; 0 not this iko; -1/-2 error/unsupported
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_resolve_var_field_elf_c(arena: *u8, src: i32, ctx: *u8, ta: i32, iko: i32, out_src_off: *i32): i32 {
  unsafe {
    let src_off: i32 = 0;
    let is_enum: i32 = 0;
    let var_base: i32 = 0;
    let ko_base: i32 = 0;
    let var_off: i32 = 0;
    let field_off: i32 = 0;
    let mod: *u8 = 0 as *u8;
    if (out_src_off == (0 as *i32)) {
      return 0 - 1;
    }
    if (iko == 3) {
      src_off = glue_var_expr_stack_off_elf_c(arena, ctx, src);
      *out_src_off = src_off;
      return 1;
    }
    if (iko != 44) {
      return 0;
    }
    is_enum = pipeline_expr_field_access_is_enum_variant(arena, src);
    if (is_enum != 0) {
      return 0 - 2;
    }
    var_base = pipeline_expr_field_access_base_ref(arena, src);
    if (var_base <= 0) {
      return 0 - 2;
    }
    ko_base = pipeline_expr_kind_ord_at(arena, var_base);
    if (ko_base != 3) {
      return 0 - 2;
    }
    var_off = glue_var_expr_stack_off_elf_c(arena, ctx, var_base);
    if (var_off < 0) {
      return 0 - 1;
    }
    mod = pipeline_asm_emit_module_ref_c();
    field_off = glue_field_access_effective_offset_c(arena, mod, src);
    if (field_off < 0) {
      field_off = 0;
    }
    src_off = glue_struct_field_frame_mag_c(var_off, field_off, ta);
    if (src_off < 0) {
      return 0 - 1;
    }
    *out_src_off = src_off;
    return 1;
  }
}

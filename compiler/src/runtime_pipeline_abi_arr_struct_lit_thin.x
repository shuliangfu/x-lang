// Thin pure: arr_struct_lit dispatcher (wave440/442).
// G.7: body MUST match glue_struct_lit_store_fixed_array_field_elf_c (peer-flat).
// wave427: Darwin -c ~14597B; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// wave440: MACOS flat peer PREFER; LINUX tip BAN (pure-asm call → opt=94).
// wave442: LINUX -E peer chain PREFER (call heal; pure-asm residual).
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

/**
 * Store fixed-array field init into STRUCT_LIT / let dest.
 * @return i32 — 0 handled; -1 error; -2 unsupported init
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_struct_lit_store_fixed_array_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, sret_direct: i32, base_off: i32, foff: i32, fty: i32): i32 {
  unsafe {
    let iko: i32 = 0;
    let n_arr: i32 = 0;
    let esz: i32 = 0;
    let elem_tr: i32 = 0;
    let field_mag: i32 = 0;
    let src: i32 = 0;
    let empty_array_zero: i32 = 0;
    let src_off: i32 = 0;
    let rc: i32 = 0;
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0 || fty <= 0) {
      return 0 - 1;
    }
    src = glue_peel_as_array_slice_ascription_c(arena, init_ref);
    if (src <= 0) {
      src = init_ref;
    }
    iko = pipeline_expr_kind_ord_at(arena, src);
    n_arr = pipeline_type_array_size_at(arena, fty);
    if (n_arr <= 0 && iko == 46) {
      n_arr = pipeline_expr_array_lit_num_elems_at(arena, src);
    }
    if (n_arr <= 0) {
      return 0 - 1;
    }
    elem_tr = pipeline_type_elem_ref_at(arena, fty);
    esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_tr);
    if (esz <= 0) {
      esz = glue_index_elem_byte_sz_from_type_ref_c(arena, fty);
    }
    if (esz <= 0) {
      esz = 4;
    }
    field_mag = 0;
    if (sret_direct == 0) {
      field_mag = glue_struct_field_frame_mag_c(base_off, foff, ta);
      if (field_mag < 0) {
        return 0 - 1;
      }
    }
    empty_array_zero = 0;
    if (iko == 46) {
      rc = glue_struct_lit_arrlit_field_elf_c(arena, elf_ctx, src, ctx, ta, sret_direct, field_mag, foff, n_arr, esz);
      if (rc == 2) {
        empty_array_zero = 1;
      } else {
        return rc;
      }
    }
    if (iko == 0 || empty_array_zero != 0) {
      return glue_struct_lit_zero_field_elf_c(arena, elf_ctx, init_ref, ta, sret_direct, field_mag, foff, n_arr, esz, empty_array_zero);
    }
    src_off = 0 - 1;
    rc = glue_struct_lit_resolve_var_field_elf_c(arena, src, ctx, ta, iko, &src_off);
    if (rc < 0) {
      return rc;
    }
    if (rc == 1) {
      if (src_off >= 0) {
        return glue_struct_lit_copy_from_src_off_elf_c(elf_ctx, ctx, ta, sret_direct, field_mag, foff, n_arr, esz, src_off);
      }
      return 0 - 2;
    }
    rc = glue_struct_lit_resolve_call_elf_c(arena, elf_ctx, src, ctx, ta, sret_direct, field_mag, foff, n_arr, esz, iko);
    if (rc == (0 - 3)) {
      return 0 - 2;
    }
    return rc;
  }
}

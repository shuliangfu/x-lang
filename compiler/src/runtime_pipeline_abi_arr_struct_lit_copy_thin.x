// Thin pure: arr_struct_lit copy dispatcher (wave440).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: LINUX PREFER peer chain for arr_struct_lit.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_struct_lit_copy_bulk_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, src_off: i32): i32;
export extern function glue_struct_lit_copy_elems_elf_c(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, src_off: i32): i32;

/**
 * Copy n_arr*esz from frame src_off into field.
 * @return i32 — 0 ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_copy_from_src_off_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, src_off: i32): i32 {
  unsafe {
    if (src_off < 0) {
      return 0 - 1;
    }
    if (esz > 8) {
      return glue_struct_lit_copy_bulk_elf_c(elf_ctx, ctx, ta, sret_direct, field_mag, foff, n_arr, esz, src_off);
    }
    return glue_struct_lit_copy_elems_elf_c(elf_ctx, ta, sret_direct, field_mag, foff, n_arr, esz, src_off);
  }
}

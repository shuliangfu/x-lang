// Thin pure: arr_struct_lit CALL dispatcher (wave440/442).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: MACOS pure-asm / LINUX -E peer chain (w442 call heal).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_struct_lit_call_bulk_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32;
export extern function glue_struct_lit_call_elems_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32;

/**
 * CALL/METHOD/INDEX/DEREF resolve+copy dispatcher.
 * @return i32 — 0 handled; -1 error; -3 not this iko
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_resolve_call_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32, iko: i32): i32 {
  unsafe {
    if (iko != 48 && iko != 49 && iko != 47 && iko != 52) {
      return 0 - 3;
    }
    if (esz > 8) {
      return glue_struct_lit_call_bulk_elf_c(arena, elf_ctx, src, ctx, ta, sret_direct, field_mag, foff, n_arr, esz);
    }
    return glue_struct_lit_call_elems_elf_c(arena, elf_ctx, src, ctx, ta, sret_direct, field_mag, foff, n_arr, esz);
  }
}

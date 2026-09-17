// Thin pure: arr_return path c dispatcher (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl Path C.
// PRODUCT: LINUX PREFER peer chain for arr_return.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_return_path_c_dest_array_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_c_fallback_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_c_slice_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32;

/**
 * Path C: ARRAY_LIT + module — durable TYPE_ARRAY / dual-GP TYPE_SLICE / fallback.
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_c_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    let _u: i32 = 0;
    _u = sret_act + sret_sz;
    if (_u < (0 - 2000000000)) {
      return 0 - 1;
    }
    if (arena == (0 as *u8) || ctx == (0 as *u8) || elf_ctx == (0 as *u8)) {
      return 0;
    }
    if (ta != 0 && ta != 1) {
      return 0;
    }
    if (ko != 46 || mod == (0 as *u8) || fi < 0) {
      return 0;
    }
    // Prefer dest-ARRAY, then SLICE, then fallback (original order).
    rc = glue_emit_return_path_c_dest_array_elf_c(arena, elf_ctx, ret_op, ctx, ta, mod, fi);
    if (rc != 0) {
      return rc;
    }
    rc = glue_emit_return_path_c_slice_elf_c(arena, elf_ctx, ret_op, ctx, ta, mod, fi);
    if (rc != 0) {
      return rc;
    }
    return glue_emit_return_path_c_fallback_elf_c(arena, elf_ctx, ret_op, ctx, ta, mod, fi);
  }
}

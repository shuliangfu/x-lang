// Thin pure: arr_return path c dispatcher (wave439/w477/w510).
// G.7: part of pipeline_asm_emit_return_elf_impl Path C.
// PRODUCT: LINUX PREFER peer chain for arr_return (dest/slice/fallback stay).
// wave477: tip no-local HARD BAN (tip U claimed 3/3; product reinject → L2 CG002).
// wave510: tipU 1/3→3/3 — mid `rc=dest/slice()` drop; pipe-cell heal; tip
//   PRODUCT reinject HARD BAN formalized (stamp w510; keep w439 leftover).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_return_path_c_dest_array_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_c_fallback_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_c_slice_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, mod: *u8, fi: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Path C: ARRAY_LIT + module — durable TYPE_ARRAY / dual-GP TYPE_SLICE / fallback.
 * wave510: ban mid `rc=dest/slice()`; pipe-store (tip keeps U).
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_c_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[4] = [];
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
    /* Prefer dest-ARRAY, then SLICE, then fallback (original order). */
    pipe_store_i32_le(&cell[0], 0, glue_emit_return_path_c_dest_array_elf_c(arena, elf_ctx, ret_op, ctx, ta, mod, fi));
    if (pipe_load_i32_le(&cell[0], 0) != 0) {
      return pipe_load_i32_le(&cell[0], 0);
    }
    pipe_store_i32_le(&cell[0], 0, glue_emit_return_path_c_slice_elf_c(arena, elf_ctx, ret_op, ctx, ta, mod, fi));
    if (pipe_load_i32_le(&cell[0], 0) != 0) {
      return pipe_load_i32_le(&cell[0], 0);
    }
    return glue_emit_return_path_c_fallback_elf_c(arena, elf_ctx, ret_op, ctx, ta, mod, fi);
  }
}

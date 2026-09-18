// Thin pure: arr_return path b0 dispatcher (wave439/w477/w510).
// G.7: part of pipeline_asm_emit_return_elf_impl Path B0.
// PRODUCT: LINUX PREFER peer chain for arr_return (prep/durable stay).
// wave477: tip no-local HARD BAN (tip U claimed 2/2; product reinject → L2 CG002).
// wave510: tipU 1/2→2/2 — mid `rc=prep()` drop; pipe-cell heal; tip PRODUCT
//   reinject HARD BAN formalized (stamp w510; keep w439 leftover overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_return_path_b0_durable_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, n_arr: i32, force_esz: i32, slice_ty: i32): i32;
export extern function glue_emit_return_path_b0_prep_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, mod: *u8, fi: i32, out_n: *i32, out_esz: *i32, out_slice_ty: *i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Path B0: already-typed [N]T VAR/FIELD/INDEX → []T or T[N].
 * wave510: ban mid `rc=prep()`; pipe-store prep result (tip keeps U).
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_b0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[4] = [];
    let n_arr: i32 = 0;
    let force_esz: i32 = 0;
    let slice_ty: i32 = 0;
    let _u: i32 = 0;
    _u = sret_act + sret_sz;
    if (_u < (0 - 2000000000)) {
      return 0 - 1;
    }
    pipe_store_i32_le(&cell[0], 0, glue_emit_return_path_b0_prep_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, mod, fi, &n_arr, &force_esz, &slice_ty));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return pipe_load_i32_le(&cell[0], 0);
    }
    return glue_emit_return_path_b0_durable_elf_c(arena, elf_ctx, ctx, ta, n_arr, force_esz, slice_ty);
  }
}

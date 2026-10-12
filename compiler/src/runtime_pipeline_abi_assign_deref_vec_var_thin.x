// Thin pure: DEREF vec_var leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
// wave533 Soft Cap: tipU heal — pipe-cell mid `var_off/rc=call()`;
//   compare via `if (pipe_load…)` (ban mid load U-starve); stamp w533
//   HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only 禁 prefer).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, dest_off: i32, nbytes: i32, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * DEREF SIMD dest from VAR rhs via lea+memcpy dest-in-rbx.
 * Soft Cap tipU: extern call as arg to pipe_store; branch on pipe_load.
 * Preconditions: dest already in rbx; nbytes/rko from caller.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_vec_var_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32): i32 {
  let cell: u8[4] = [];
  if (nbytes < 8) {
    return 0 - 3;
  }
  if (rko_pre != 3) {
    return 0 - 3;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_var_expr_stack_off_elf_c(arena, ctx, right_ref));
    if (pipe_load_i32_le(&cell[0], 0) < 0) { return 0 - 3; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, pipe_load_i32_le(&cell[0], 0), ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta));
    if (pipe_load_i32_le(&cell[0], 0) != 0) { return 0 - 1; }
  }
  return 0;
}

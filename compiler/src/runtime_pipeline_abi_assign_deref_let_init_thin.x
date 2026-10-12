// Thin pure: DEREF let_init leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
// wave533 Soft Cap: tipU heal — pipe-cell mid `arr_st=glue_emit_*()`;
//   compare via `if (pipe_load==…)` (ban mid load U-starve); stamp w533
//   HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only 禁 prefer).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * DEREF TYPE_ARRAY then TYPE_NAMED/SLICE let-init into dest-in-rbx.
 * Soft Cap tipU: glue call as arg to pipe_store; branch on pipe_load (no mid assign).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_let_init_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, ltr: i32): i32 {
  let cell: u8[4] = [];
  if (ltk == 10) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3));
      if (pipe_load_i32_le(&cell[0], 0) == 0) { return 0; }
      if (pipe_load_i32_le(&cell[0], 0) == (0 - 1)) { return 0 - 1; }
    }
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3));
    if (pipe_load_i32_le(&cell[0], 0) == 0) { return 0; }
    if (pipe_load_i32_le(&cell[0], 0) == (0 - 1)) { return 0 - 1; }
  }
  return 0 - 3;
}

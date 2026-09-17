// Thin pure: DEREF array/struct let-init dest-in-rbx (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;

/**
 * DEREF TYPE_ARRAY then TYPE_NAMED/SLICE let-init into dest-in-rbx.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_let_init_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltk: i32, ltr: i32): i32 {
  unsafe {
    let arr_st: i32 = 0;
    if (ltk == 10) {
      arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
      if (arr_st == 0) {
        return 0;
      }
      if (arr_st == 0 - 1) {
        return 0 - 1;
      }
    }
    arr_st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
    if (arr_st == 0) {
      return 0;
    }
    if (arr_st == 0 - 1) {
      return 0 - 1;
    }
    return 0 - 3;
  }
}

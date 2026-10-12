// Thin pure: assign emit FIELD sub-peer ptr gate (wave441/w476).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD path.
// wave476: gate+struct+array split (monolith CG002). Tip U=2/2.
//   PRODUCT inject: LINUX PREFER (stamp w476); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_field_ptr_struct_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_field_ptr_array_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * FIELD assign through pointer / INDEX / *T — try struct then array peer.
 * wave476: no-local — peer 0/-1 cascade; ban `let x=call()`.
 * @return i32 — 0 ok; -1 fail; -3 not this peer
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_ptr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    if (glue_emit_assign_field_ptr_struct_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_ptr_struct_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_emit_assign_field_ptr_array_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_ptr_array_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    return 0 - 3;
  }
}

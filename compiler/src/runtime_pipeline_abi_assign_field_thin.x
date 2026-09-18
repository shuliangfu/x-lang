// Thin pure: assign emit FIELD arm dispatcher (wave441/457).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c FIELD path (peer-flat).
// wave457: no-local tip probe → tip .o U-starved (drops var_root/ptr U);
//   L2 5/5 is false coverage — HARD BAN tip PREFER; stay -E leftover.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_field_var_root_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_field_ptr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_field_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * FIELD lvalue assign arm — flat peer dispatch.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let is_enum: i32 = 0;
    let rc: i32 = 0;
    is_enum = pipeline_expr_field_access_is_enum_variant(arena, left_ref);
    if (is_enum != 0) {
      return 0 - 1;
    }
    rc = glue_emit_assign_field_var_root_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_field_ptr_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    return glue_emit_assign_field_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}

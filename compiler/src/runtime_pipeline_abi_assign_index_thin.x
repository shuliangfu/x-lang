// Thin pure: assign INDEX arm dispatcher (wave441).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c INDEX path (peer-flat).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_index_struct_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_simd_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_named_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_bulk_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_generic_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * INDEX lvalue assign arm — flat peer dispatch.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    rc = glue_emit_assign_index_struct_lit_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_index_simd_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_index_named_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_index_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_index_bulk_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0 - 3) {
      return rc;
    }
    return glue_emit_assign_index_generic_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}

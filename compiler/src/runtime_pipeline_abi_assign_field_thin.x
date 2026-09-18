// Thin pure: assign emit FIELD arm dispatcher (wave441/457/459).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c FIELD path (peer-flat).
// wave457: prior no-local probe still U-starved under `let rc = call()` form;
//   L2 5/5 was false coverage — HARD BAN tip PREFER; stayed -E leftover.
// wave459: eq-cascade no-local (same class as w458 field_var_stores /
//   w451 var / w454 to_rax) — Ubuntu tip U=4/4; LINUX product PREFER.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_field_var_root_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_field_ptr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_field_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * FIELD lvalue assign arm — flat peer dispatch.
 * wave459: no-local eq-cascade (no `let rc = call()` / no let-bound
 *   is_enum); tip otherwise drops var_root/ptr U (U-starved 假绿).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_expr_field_access_is_enum_variant(arena, left_ref) != 0) {
      return 0 - 1;
    }
    // var_root try — success / hard-fail without let-bound call result
    if (glue_emit_assign_field_var_root_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_var_root_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    // ptr try
    if (glue_emit_assign_field_ptr_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_ptr_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) == (0 - 1)) {
      return 0 - 1;
    }
    return glue_emit_assign_field_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}

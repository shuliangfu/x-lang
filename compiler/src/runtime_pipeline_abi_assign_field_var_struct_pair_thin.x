// Thin pure: FIELD VAR-root struct 9..16B size gate (wave475).
// G.7: part of glue_emit_assign_field_var_struct_elf_c (peer-flat).
// wave475: no-local tip U=4/4. PRODUCT inject: LINUX PREFER (stamp w475); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_emit_assign_field_var_struct_store_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, off: i32): i32;

/**
 * Struct pair size gate — if size in (8,16] via simple or named layout → store.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_struct_pair_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, off: i32): i32 {
  unsafe {
    if (glue_type_size_simple(glue_emit_module_from_ctx(ctx), arena, ltr, 0) > 8) {
      if (glue_type_size_simple(glue_emit_module_from_ctx(ctx), arena, ltr, 0) <= 16) {
        return glue_emit_assign_field_var_struct_store_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, ltr, off);
      }
    }
    if (glue_type_named_layout_size_any_module_elf_c(arena, ltr) > 8) {
      if (glue_type_named_layout_size_any_module_elf_c(arena, ltr) <= 16) {
        return glue_emit_assign_field_var_struct_store_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, ltr, off);
      }
    }
    return 0 - 3;
  }
}

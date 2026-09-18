// Thin pure: VAR try_let — array/vector/struct let-init arms (wave473).
// G.7: part of glue_emit_assign_var_elf_c (peer-flat).
// wave473: no-local tip U=7/7. PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, let_ty_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;

/**
 * VAR try_let — TYPE_ARRAY(10) / vector / STRUCT(8) let-init; kill slot on hit.
 * wave473: no-local — stack_off/decl via re-call; return -3 if none matched.
 * @return i32 — 0 handled; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_try_let_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 10) {
      if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref)) == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
        return 0;
      }
    }
    if (glue_var_decl_type_ref_elf_c(arena, ctx, left_ref) > 0) {
      if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
        return 0;
      }
    }
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 8) {
      if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref)) == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
        return 0;
      }
    }
    return 0 - 3;
  }
}

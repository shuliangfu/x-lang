// Thin pure: INDEX STRUCT_LIT into TYPE_ARRAY[lit] (wave441/463).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.
// wave441b: LINUX product via -E (tip `let base_tr/rc = call()` drops mid
//   peers → U-starved: only cache_clear U; L2 假绿 if PREFER).
// wave463: no-local re-call reshape (same class as w458–w462) — Ubuntu tip
//   U=6/6; LINUX product PREFER. elem_home via re-call stack_off ± lit*esz.

export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_struct_lit_fields_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * STRUCT_LIT into TYPE_ARRAY base with lit index — frame elem_home path.
 * wave463: no-local — re-call type_ref/stack_off; no `let x = call()` binds.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_struct_lit_arr_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    let lit_slot: i32[1] = [];
    if (glue_var_decl_type_ref_elf_c(arena, ctx, base_ref) <= 0) {
      return 0 - 3;
    }
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, base_ref)) != 10) {
      return 0 - 3;
    }
    if (pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]) == 0) {
      return 0 - 3;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) < 0) {
      return 0 - 3;
    }
    if (ta == 1) {
      if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_slot[0] * esz < 0) {
        return 0 - 3;
      }
      if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_slot[0] * esz) != 0) {
        return 0 - 3;
      }
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_slot[0] * esz < 0) {
      return 0 - 3;
    }
    if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_slot[0] * esz) != 0) {
      return 0 - 3;
    }
    glue_index_assign_addr_cache_clear();
    return 0;
  }
}

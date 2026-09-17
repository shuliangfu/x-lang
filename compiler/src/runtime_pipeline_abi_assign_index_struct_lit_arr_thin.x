// Thin pure: INDEX STRUCT_LIT into TYPE_ARRAY[lit] (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_struct_lit_fields_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * STRUCT_LIT into TYPE_ARRAY base with lit index — frame elem_home path.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_struct_lit_arr_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    let base_tr: i32 = 0;
    let base_tk: i32 = 0;
    let cmp_lit: i32 = 0;
    let lit_slot: i32[1] = [];
    let lit_imm: i32 = 0;
    let base_off: i32 = 0;
    let elem_home: i32 = 0;
    let rc: i32 = 0;
    base_tr = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
    if (base_tr <= 0) {
      return 0 - 3;
    }
    base_tk = pipeline_type_kind_ord_at(arena, base_tr);
    if (base_tk != 10) {
      return 0 - 3;
    }
    cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
    if (cmp_lit == 0) {
      return 0 - 3;
    }
    lit_imm = lit_slot[0];
    base_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
    if (base_off < 0) {
      return 0 - 3;
    }
    if (ta == 1) {
      elem_home = base_off + lit_imm * esz;
    } else {
      elem_home = base_off - lit_imm * esz;
    }
    if (elem_home < 0) {
      return 0 - 3;
    }
    rc = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, elem_home);
    if (rc != 0) {
      return 0 - 3;
    }
    glue_index_assign_addr_cache_clear();
    return 0;
  }
}

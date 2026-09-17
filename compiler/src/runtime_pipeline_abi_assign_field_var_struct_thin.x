// Thin pure: FIELD VAR-root TYPE_NAMED struct/16B pair (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;

/**
 * FIELD VAR-root TYPE_NAMED struct let-init + optional 9..16B dual-GP store.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_struct_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32 {
  unsafe {
    let mod: *u8 = 0 as *u8;
    let ltr: i32 = 0;
    let ltk: i32 = 0;
    let arr_st: i32 = 0;
    let store_sz: i32 = 0;
    let rty: i32 = 0;
    let rc: i32 = 0;
    if (hit == 0) {
      return 0 - 3;
    }
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    mod = pipeline_asm_emit_module_ref_c();
    ltr = glue_field_access_field_type_ref_c(arena, mod, left_ref);
    if (ltr <= 0) {
      return 0 - 3;
    }
    ltk = pipeline_type_kind_ord_at(arena, ltr);
    if (ltk != 8) {
      return 0 - 3;
    }
    arr_st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, off);
    if (arr_st == 0) {
      return 0;
    }
    if (arr_st == 0 - 1) {
      return 0 - 1;
    }
    mod = glue_emit_module_from_ctx(ctx);
    store_sz = glue_type_size_simple(mod, arena, ltr, 0);
    rty = glue_type_named_layout_size_any_module_elf_c(arena, ltr);
    if (rty > store_sz) {
      store_sz = rty;
    }
    if (store_sz <= 8) {
      return 0 - 3;
    }
    if (store_sz > 16) {
      return 0 - 3;
    }
    rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_store_retval_pair_to_rbp_elf_c(mod, arena, elf_ctx, ltr, off, ta, right_ref, ctx);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
}

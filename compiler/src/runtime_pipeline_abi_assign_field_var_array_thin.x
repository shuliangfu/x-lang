// Thin pure: FIELD VAR-root TYPE_ARRAY dest-in-rbx (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;

/**
 * FIELD VAR-root TYPE_ARRAY (`bag.one = [w]`) via lea+dest-in-rbx let-init.
 * On arr_st==-2 returns -4 so caller skips depth-1 scalar (hit cleared).
 * @return i32 — 0 ok; -1 err; -3 not handled; -4 skip scalar
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32 {
  unsafe {
    let mod: *u8 = 0 as *u8;
    let ltr: i32 = 0;
    let ltk: i32 = 0;
    let rc: i32 = 0;
    let arr_st: i32 = 0;
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
    if (ltk != 10) {
      return 0 - 3;
    }
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3);
    if (arr_st == 0) {
      return 0;
    }
    if (arr_st == 0 - 1) {
      return 0 - 1;
    }
    // -2: skip scalar store (same as hit=0 in monolithic path).
    return 0 - 4;
  }
}

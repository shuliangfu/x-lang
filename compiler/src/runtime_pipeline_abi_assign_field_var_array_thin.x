// Thin pure: FIELD VAR-root TYPE_ARRAY dest-in-rbx (wave441/w475).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// wave475: no-local tip U=6/6. PRODUCT inject: LINUX PREFER (stamp w475); MACOS skip.
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
 * wave475: no-local — ban let-bound call results.
 * @return i32 — 0 ok; -1 err; -3 not handled; -4 skip scalar
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32 {
  unsafe {
    if (hit == 0) {
      return 0 - 3;
    }
    if (ta != 0) {
      if (ta != 1) {
        return 0 - 3;
      }
    }
    if (glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref) <= 0) {
      return 0 - 3;
    }
    if (pipeline_type_kind_ord_at(arena, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref)) != 10) {
      return 0 - 3;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), 0 - 3) == 0) {
      return 0;
    }
    if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), 0 - 3) == (0 - 1)) {
      return 0 - 1;
    }
    return 0 - 4;
  }
}

// Thin pure: INDEX STRUCT_LIT dest-in-rbx (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_struct_lit_fields_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * STRUCT_LIT via eff-addr dest-in-rbx (ARRAY runtime idx or SLICE).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_struct_lit_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    let base_tr: i32 = 0;
    let base_tk: i32 = 0;
    let cmp_lit: i32 = 0;
    let lit_slot: i32[1] = [];
    let rc: i32 = 0;
    let use_rbx: i32 = 0;
    base_tr = glue_var_decl_type_ref_elf_c(arena, ctx, base_ref);
    if (base_tr > 0) {
      base_tk = pipeline_type_kind_ord_at(arena, base_tr);
    } else {
      base_tk = 0;
    }
    if (base_tk == 10) {
      cmp_lit = pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]);
      if (cmp_lit != 0) {
        return 0 - 3;
      }
      use_rbx = 1;
    }
    if (base_tk == 11) {
      use_rbx = 1;
    }
    if (use_rbx == 0) {
      return 0 - 3;
    }
    rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    rc = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0 - 3);
    if (rc != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    glue_index_assign_addr_cache_clear();
    return 0;
  }
}

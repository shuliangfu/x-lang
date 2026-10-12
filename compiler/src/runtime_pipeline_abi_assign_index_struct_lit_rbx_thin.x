// Thin pure: INDEX STRUCT_LIT dest-in-rbx (wave441/w465).
// wave465: no-local shared emit — tip drops mid-peer U on `let x=call()` /
//   dual full-body ARRAY|SLICE tails (v1 missing cmp_lit U). Guards then
//   one scaled+mov+struct_lit path → Ubuntu tip U=7/7.
// PRODUCT inject: LINUX PREFER (stamp w465); MACOS skip (g05 mega UNDEF peers).
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
 * wave465: no-local — re-call type_ref/kind; ARRAY lit idx early-out via
 *   cmp_lit; SLICE/ARRAY-non-lit share one scaled+mov+fields emit (no
 *   `let rc = call()`). Tip otherwise drops mid-peer U.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_struct_lit_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    let lit_slot: i32[1] = [];
    if (glue_var_decl_type_ref_elf_c(arena, ctx, base_ref) <= 0) {
      return 0 - 3;
    }
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, base_ref)) == 10) {
      if (pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]) != 0) {
        return 0 - 3;
      }
    } else {
      if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, base_ref)) != 11) {
        return 0 - 3;
      }
    }
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0 - 3) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    glue_index_assign_addr_cache_clear();
    return 0;
  }
}

// Thin pure: DEREF scalar leaf (wave441 peer).
// G.7: match mega / assign_deref dispatcher peer arm.
// wave449: LINUX PREFER tip pure-asm (product si green).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32;

/**
 * DEREF scalar push/pop + store through *p.
 * @return i32 — 0 ok; -1 err
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    let tr: i32 = 0;
    let store_sz: i32 = 0;
    rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    store_sz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    if (store_sz <= 0) {
      store_sz = 4;
    }
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, store_sz, ta);
  }
}

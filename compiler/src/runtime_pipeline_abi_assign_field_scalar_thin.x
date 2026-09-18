// Thin pure: assign emit FIELD sub-peer scalar (wave441/w476).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD path.
// wave476: strip dead externs; no-local (ban let-bound call / giant stack).
//   Tip was U=0/171 (zero reloc). PRODUCT inject: LINUX PREFER (stamp w476); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_field_access_load_byte_sz(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32;

/**
 * FIELD scalar assign — RHS→rax, push, lvalue→rbx, pop, store indirect by load_sz.
 * wave476: no-local — ban `let x=call()` / giant locals; store sz via nested call.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref), ta);
  }
}

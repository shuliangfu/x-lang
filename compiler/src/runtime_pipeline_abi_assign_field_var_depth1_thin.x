// Thin pure: FIELD VAR-root depth-1 scalar store (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * Depth-1 scalar store on a value VAR FIELD dest.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_depth1_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    if (chain_n != 1) {
      return 0 - 3;
    }
    if (hit == 0) {
      return 0 - 3;
    }
    rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, walk_cur, var_off, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, field_off, load_sz, ta);
  }
}

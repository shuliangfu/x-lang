// Thin pure: INDEX esz>8 bulk copy — CALL/METHOD rhs (wave468).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX bulk path (peer-flat;
//   twin of bulk_lval under bulk dispatcher).
// wave441b: monolithic bulk tip `let x=call()` U-starved (3/12).
// wave468: call peer — spill pair + temp home + struct init + lea +
//   scaled + mem copy; no `let x=call()` / no `slot[0]=call()`.
//   Tip U=9/9. PRODUCT: LINUX PREFER with dispatcher+lval peer.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function asg_thin_load_i32_le(base: *u8, off: i32): i32;
export extern function asg_thin_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function asg_thin_ctx_off_next_offset(): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, nbytes: i32, ta: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX esz>8 bulk spill copy for CALL/METHOD rhs (post-setup).
 * wave468: no-local — after +32 spill bump, bump +(esz+7)&-8 for temp;
 *   src = next-nbytes-16, dst = next-nbytes; emit via `if (call()!=0)`.
 * @param esz i32 — element byte size (>8)
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_bulk_call_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    if (esz <= 8) {
      return 0 - 3;
    }
    if (asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) + 32 < asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset())) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    // next = N+32; src = N+16; dst = N+32
    asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) + 32);
    if (asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) + ((esz + 7) & (0 - 8)) < asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset())) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    // next = N+32+nbytes; temp = next
    asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) + ((esz + 7) & (0 - 8)));
    if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, 0, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset())) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()), ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    // src = next - nbytes - 16
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) - 16 - ((esz + 7) & (0 - 8)), ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    // dst = next - nbytes
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) - ((esz + 7) & (0 - 8)), ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) - 16 - ((esz + 7) & (0 - 8)), asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset()) - ((esz + 7) & (0 - 8)), esz, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    glue_index_assign_addr_cache_clear();
    return 0;
  }
}

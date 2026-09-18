// Thin pure: INDEX generic scaled-addr fallback (wave471).
// G.7: after try/try2 miss — clear cache, scaled lea, mov rbx, finish.
// wave471: scaled peer — no-local; Tip U=4/4.
//   PRODUCT: LINUX PREFER with disp+try+try2.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_index_assign_finish_store_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32, ta: i32): i32;

/**
 * INDEX generic scaled fallback — eff_addr_scaled → rbx → finish_store.
 * wave471: no-local via `if (call()!=0)`; clears addr cache first.
 * @return i32 — 0 ok; -1 err
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_generic_scaled_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    glue_index_assign_addr_cache_clear();
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
  }
}

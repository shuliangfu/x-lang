// Thin pure: INDEX TYPE_NAMED body after setup/resolve (wave467).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX NAMED path (peer-flat;
//   same split as index_simd body under dispatcher — wave466).
// wave441b: monolithic named tip `let x=call()` U-starved (1/8).
// wave467: body leaf — esz>8 + TYPE_NAMED(ltk==8) + scaled+mov+struct init.
//   Tip U=5/5. PRODUCT: LINUX PREFER with dispatcher.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX TYPE_NAMED dest via dest-in-rbx struct let-init (post-resolve).
 * wave467: no-local — esz/ltk guards + scaled lea + mov rbx via
 *   `if (call()!=0)`; struct init via 0/-1 eq-cascade (no `let x=call()`).
 * @param ltr i32 — resolved TYPE_NAMED element type ref (>0)
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_named_body_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32 {
  unsafe {
    if (esz <= 8) {
      return 0 - 3;
    }
    if (ltr <= 0) {
      return 0 - 3;
    }
    if (pipeline_type_kind_ord_at(arena, ltr) != 8) {
      return 0 - 3;
    }
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3) == 0) {
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3) == (0 - 1)) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    return 0 - 3;
  }
}

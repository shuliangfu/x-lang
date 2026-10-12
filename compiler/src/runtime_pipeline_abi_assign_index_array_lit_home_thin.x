// Thin pure: INDEX TYPE_ARRAY lit-VAR home emit (wave469).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX array lit path
//   (peer-flat; lea+mov+init after mid resolves elem_home).
// wave441b: monolithic lit tip `let x=call()` U-starved (1/9).
// wave469: home peer — lea(home)+mov rbx+fixed-array let-init;
//   no lit*esz co-located (drops lea U). Tip U=4/4.
//   PRODUCT: LINUX PREFER with gate+mid.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX TYPE_ARRAY lit dest via lea+mov rbx + fixed-array let-init.
 * wave469: no-local — home already resolved by mid peer; emit via
 *   `if (call()!=0)` / 0/-1 eq-cascade (no `let x=call()`).
 * @param home i32 — frame elem home (must be >=0)
 * @return i32 — 0 ok; -1 err; -3 not handled; -4 handled-skip (hit set)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_lit_home_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, home: i32): i32 {
  unsafe {
    if (home < 0) {
      return 0 - 3;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3) == 0) {
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3) == (0 - 1)) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    // lit path took lea but let-init fell through (-2): skip rbx twin (hit=1).
    return 0 - 4;
  }
}

// Thin pure: INDEX generic try_* complex cascade (wave471).
// G.7: twin of generic_try — 3-op / mul-lit index addr tries.
// wave471: try2 peer — eq-cascade no-local; Tip U=11/11.
//   PRODUCT: LINUX PREFER with disp+try+scaled.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_index_assign_finish_store_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32, ta: i32): i32;

/**
 * INDEX generic try_* complex — 3-op / mul-lit addr→rbx then finish_store.
 * wave471: no-local eq-cascade (no `let x=call()`). Caller gates esz.
 * @return i32 — 0 ok; -1 err from finish; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_generic_try2_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    if (glue_try_index_var_plus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_add3_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_plus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_subadd3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_subsub3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_add3_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    return 0 - 3;
  }
}

// Thin pure: INDEX SIMD body after setup/resolve (wave466).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX SIMD path (peer-flat;
//   same split pattern as array_lit / array_rbx under array dispatcher).
// wave441b: monolithic simd tip `let x=call()` U-starved (1/9).
// wave466: body leaf — no setup; lit*nbytes home via re-call stack_off
//   (struct_lit_arr class). Tip U=5/5. PRODUCT: LINUX PREFER with dispatcher.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_off: i32, type_ref: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * INDEX SIMD/vector dest via lit VAR frame elem_home (post-resolve).
 * wave466: no-local — lanes/lit via out-slots; stack_off re-called for
 *   ± lit*(lanes*esz) home; vector init via 0/-1 eq-cascade (no
 *   `let x = call()`). Tip otherwise drops mid-peer U when co-located
 *   with setup in one leaf.
 * @param ltr i32 — resolved element / vector type ref (>0)
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_simd_body_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, ltr: i32): i32 {
  unsafe {
    let lit_slot: i32[1] = [];
    let n_arr: i32[1] = [];
    let store_sz: i32[1] = [];
    if (ltr <= 0) {
      return 0 - 3;
    }
    if (glue_vector_type_lanes_esz_c(arena, ltr, &n_arr[0], &store_sz[0]) != 0) {
      return 0 - 3;
    }
    if (n_arr[0] <= 0) {
      return 0 - 3;
    }
    if (store_sz[0] <= 0) {
      return 0 - 3;
    }
    if (pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]) == 0) {
      return 0 - 3;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) < 0) {
      return 0 - 3;
    }
    if ((n_arr[0] * store_sz[0]) <= 0) {
      return 0 - 3;
    }
    if (ta == 1) {
      if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_slot[0] * (n_arr[0] * store_sz[0]) < 0) {
        return 0 - 3;
      }
      if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_slot[0] * (n_arr[0] * store_sz[0]), ltr) == 0) {
        glue_index_assign_addr_cache_clear();
        return 0;
      }
      if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_slot[0] * (n_arr[0] * store_sz[0]), ltr) == (0 - 1)) {
        glue_index_assign_addr_cache_clear();
        return 0 - 1;
      }
      return 0 - 3;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_slot[0] * (n_arr[0] * store_sz[0]) < 0) {
      return 0 - 3;
    }
    if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_slot[0] * (n_arr[0] * store_sz[0]), ltr) == 0) {
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_slot[0] * (n_arr[0] * store_sz[0]), ltr) == (0 - 1)) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    return 0 - 3;
  }
}

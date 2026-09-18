// Thin pure: FIELD VAR-root stores dispatcher (wave441/458).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// wave441b: LINUX product via -E (tip `let rc = call()` dropped mid-calls →
//   U-starved: only depth1 U; L2 假绿 if PREFER).
// wave458: no-local eq-cascade reshape — tip must not bind call results to
//   `let` (same class as w451 var / w454 to_rax). Success path is one call
//   per peer (`if (peer() == 0) return 0`); -1 / -3 fallthrough may re-call
//   (peers are try-style: -3 = no side effects). Gate: Ubuntu tip U=4/4.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_field_var_simd_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;
export extern function glue_emit_assign_field_var_struct_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;
export extern function glue_emit_assign_field_var_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;
export extern function glue_emit_assign_field_var_depth1_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;

/**
 * Dispatch FIELD VAR-root typed stores (simd → struct → array → depth1).
 * wave458: no-local eq-cascade (no `let rc = call()`); tip otherwise drops
 *   mid-peer calls and keeps only depth1 U (U-starved 假绿).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_stores_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32 {
  unsafe {
    // simd try — success / hard-fail without let-bound call result
    if (glue_emit_assign_field_var_simd_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_var_simd_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == (0 - 1)) {
      return 0 - 1;
    }
    // struct try
    if (glue_emit_assign_field_var_struct_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_var_struct_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == (0 - 1)) {
      return 0 - 1;
    }
    // array try — -4 means hit cleared; surface as -3 (skip depth1)
    if (glue_emit_assign_field_var_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == (0 - 4)) {
      return 0 - 3;
    }
    if (glue_emit_assign_field_var_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == 0) {
      return 0;
    }
    if (glue_emit_assign_field_var_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n) == (0 - 1)) {
      return 0 - 1;
    }
    return glue_emit_assign_field_var_depth1_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n);
  }
}

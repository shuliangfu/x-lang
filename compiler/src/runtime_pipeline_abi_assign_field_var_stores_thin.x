// Thin pure: FIELD VAR-root stores dispatcher (wave441).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_assign_field_var_simd_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;
export extern function glue_emit_assign_field_var_struct_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;
export extern function glue_emit_assign_field_var_array_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;
export extern function glue_emit_assign_field_var_depth1_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;

/**
 * Dispatch FIELD VAR-root typed stores (simd → struct → array → depth1).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_stores_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    rc = glue_emit_assign_field_var_simd_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_field_var_struct_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n);
    if (rc != 0 - 3) {
      return rc;
    }
    rc = glue_emit_assign_field_var_array_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n);
    if (rc == 0 - 4) {
      // Array path cleared hit — skip depth-1 scalar.
      return 0 - 3;
    }
    if (rc != 0 - 3) {
      return rc;
    }
    return glue_emit_assign_field_var_depth1_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, hit, off, field_off, load_sz, walk_cur, var_off, chain_n);
  }
}

// Thin pure: INDEX TYPE_ARRAY lit-VAR mid home resolve (wave469).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX array lit path
//   (peer-flat; between gate and home emit).
// wave441b: monolithic lit tip U-starved; co-locating lit*stride with
//   lea/gates drops mid-peer U / empties .o (total_bytes dual-tail).
// wave469: mid peer — esz-only stride (same class as w464 array_rbx);
//   re-call stack_off ± lit*esz into home peer. Tip U=2/2.
//   PRODUCT: LINUX PREFER with gate+home.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_assign_index_array_lit_home_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, home: i32): i32;

/**
 * INDEX TYPE_ARRAY lit mid — resolve elem_home via esz stride, call home.
 * wave469: no-local — stack_off re-called for ± lit_imm*esz; no
 *   `let x=call()`; no total_bytes dual-tail (tip empties .o).
 * @param lit_imm i32 — literal index (from gate out-slot)
 * @param esz i32 — element byte size (>0)
 * @return i32 — forwarded from home peer
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_lit_mid_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, ltr: i32, lit_imm: i32, esz: i32): i32 {
  unsafe {
    if (esz <= 0) {
      return 0 - 3;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) < 0) {
      return 0 - 3;
    }
    if (ta == 1) {
      if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_imm * esz < 0) {
        return 0 - 3;
      }
      return glue_emit_assign_index_array_lit_home_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) + lit_imm * esz);
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_imm * esz < 0) {
      return 0 - 3;
    }
    return glue_emit_assign_index_array_lit_home_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, glue_var_expr_stack_off_elf_c(arena, ctx, base_ref) - lit_imm * esz);
  }
}

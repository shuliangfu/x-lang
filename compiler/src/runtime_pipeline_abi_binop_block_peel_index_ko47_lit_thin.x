// Thin pure: INDEX ko47 lit-index miss arm (wave479).
// G.7: part of glue_binop_index_ko47_clobbers_rbx (peer-flat).
// wave479: tip U=2/2. PRODUCT inject: LINUX PREFER (stamp w479); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32;

/**
 * Return 0 if INDEX index is i32 lit (base+imm*esz path); else 1.
 * wave479: no-local — stack cell for out_imm; ban `let x=call()`.
 * @return i32 — 0 no-clobber lit; 1 clobber
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_index_ko47_lit_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let lit_imm: i32 = 0;
    if (pipeline_expr_index_index_ref(arena, expr_ref) > 0) {
      if (pipeline_asm_cmp_expr_lit_i32_at(arena, pipeline_expr_index_index_ref(arena, expr_ref), &lit_imm) != 0) {
        return 0;
      }
    }
    return 1;
  }
}

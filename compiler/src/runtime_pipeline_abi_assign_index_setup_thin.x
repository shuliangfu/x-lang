// Thin pure: INDEX arm setup (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;

/**
 * Fill INDEX setup outs: esz, base_ref, idx_ref, rko, ako, base_kind.
 * @return i32 — 0 ok; -1 bad refs
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32 {
  unsafe {
    let base_ref: i32 = 0;
    let idx_ref: i32 = 0;
    base_ref = pipeline_expr_index_base_ref(arena, left_ref);
    idx_ref = pipeline_expr_index_index_ref(arena, left_ref);
    if (base_ref <= 0) {
      return 0 - 1;
    }
    if (idx_ref <= 0) {
      return 0 - 1;
    }
    out_esz[0] = pipeline_asm_index_elem_byte_sz_c(arena, left_ref);
    out_base[0] = base_ref;
    out_idx[0] = idx_ref;
    out_rko[0] = pipeline_expr_kind_ord_at(arena, right_ref);
    out_ako[0] = pipeline_expr_kind_ord_at(arena, expr_ref);
    out_bk[0] = pipeline_expr_kind_ord_at(arena, base_ref);
    return 0;
  }
}

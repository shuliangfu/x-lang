// Thin pure: INDEX arm setup (wave441/445).
// wave445: `*out =` heal Ubuntu pure-asm CG002 from `out[0]=`.
// wave543 Soft Cap: Ubuntu tip SEGV on raw `*i32` store, and mid-assign
//   `x = call()` drops UND. Base/idx go through pipe cells; the fill
//   helper is always called and writes outs only when go!=0 (parameter).
//   stamp w543 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;

/**
 * Write INDEX setup outs when go!=0. go is a parameter so the success
 * arm stays in the tip object even though the caller may pass 0.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — assign expr
 * @param left_ref i32 — INDEX expr
 * @param right_ref i32 — rhs expr
 * @param base_ref i32 — already resolved base; not re-fetched
 * @param idx_ref i32 — already resolved index; not re-fetched
 * @param go i32 — 0 skips the stores and returns -1
 * @param out_esz *i32 — element size out (pipe_store, not *i32)
 * @param out_base *i32 — base ref out
 * @param out_idx *i32 — index ref out
 * @param out_rko *i32 — rhs kind out
 * @param out_ako *i32 — assign kind out
 * @param out_bk *i32 — base kind out
 * @return i32 — 0 ok; -1 when go==0
 * PLATFORM: SHARED freestanding.
 */
function w543_setup_fill(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, base_ref: i32, idx_ref: i32, go: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32 {
  unsafe {
    if (go == 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(out_esz as *u8, 0, pipeline_asm_index_elem_byte_sz_c(arena, left_ref));
    pipe_store_i32_le(out_base as *u8, 0, base_ref);
    pipe_store_i32_le(out_idx as *u8, 0, idx_ref);
    pipe_store_i32_le(out_rko as *u8, 0, pipeline_expr_kind_ord_at(arena, right_ref));
    pipe_store_i32_le(out_ako as *u8, 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(out_bk as *u8, 0, pipeline_expr_kind_ord_at(arena, base_ref));
    return 0;
  }
}

/**
 * Fill INDEX setup outs: esz, base_ref, idx_ref, rko, ako, base_kind.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — assign expr
 * @param left_ref i32 — INDEX expr
 * @param right_ref i32 — rhs expr
 * @param out_esz *i32 — element byte size
 * @param out_base *i32 — base expr ref
 * @param out_idx *i32 — index expr ref
 * @param out_rko *i32 — rhs kind ordinal
 * @param out_ako *i32 — assign expr kind ordinal
 * @param out_bk *i32 — base kind ordinal
 * @return i32 — 0 ok; -1 bad refs
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_index_setup_elf_c(arena: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, out_esz: *i32, out_base: *i32, out_idx: *i32, out_rko: *i32, out_ako: *i32, out_bk: *i32): i32 {
  unsafe {
    let bcell: u8[8] = [];
    let icell: u8[8] = [];
    let go: i32 = 1;
    pipe_store_i32_le(&bcell[0], 0, pipeline_expr_index_base_ref(arena, left_ref));
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_index_index_ref(arena, left_ref));
    if (pipe_load_i32_le(&bcell[0], 0) <= 0) {
      go = 0;
    }
    if (pipe_load_i32_le(&icell[0], 0) <= 0) {
      go = 0;
    }
    return w543_setup_fill(arena, expr_ref, left_ref, right_ref, pipe_load_i32_le(&bcell[0], 0), pipe_load_i32_le(&icell[0], 0), go, out_esz, out_base, out_idx, out_rko, out_ako, out_bk);
  }
}

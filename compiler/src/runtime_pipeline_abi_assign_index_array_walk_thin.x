// Thin pure: INDEX chain walk for TYPE_ARRAY resolve (wave441/445).
// wave445: `*out_root =` heal Ubuntu pure-asm CG002.
// wave541 Soft Cap: Ubuntu tip SEGV on raw `*i32` store, and while-body
//   extern calls are dropped. Step helper is always called; stop/advance
//   branches on parameters; out cell is pipe_store_i32_le (not `*out=`).
//   stamp w541 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;

/**
 * One INDEX-chain step. Stores the next cursor at cell[0].
 * go/n/cur are parameters so both arms stay in the tip object.
 * @param arena *u8 — AST arena
 * @param cur i32 — current expr ref
 * @param n i32 — steps already taken; n>=8 stops
 * @param go i32 — 0 means a previous step already stopped
 * @param cell *u8 — 4-byte slot for the next cursor; null is not checked
 * @return i32 — 1 if this step advanced, else 0
 * PLATFORM: SHARED freestanding. Caller must wrap use in unsafe.
 */
function w541_walk_step(arena: *u8, cur: i32, n: i32, go: i32, cell: *u8): i32 {
  unsafe {
    // Stopped already: keep the cursor, do not walk further.
    if (go == 0) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    // Bound matches the old while (chain_n < 8).
    if (n >= 8) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    if (cur <= 0) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    // INDEX kind ordinal is 47. Call stays in the parameter arm.
    if (pipeline_expr_kind_ord_at(arena, cur) != 47) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    pipe_store_i32_le(cell, 0, pipeline_expr_index_base_ref(arena, cur));
    return 1;
  }
}

/**
 * Walk INDEX chain from left_ref; write root through out_root; return chain_n.
 * @param arena *u8 — AST arena
 * @param left_ref i32 — start expr ref
 * @param out_root *i32 — receives the root expr ref (via pipe_store, not *i32)
 * @return i32 — chain_n (>=0, at most 8)
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_index_array_walk_elf_c(arena: *u8, left_ref: i32, out_root: *i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let n: i32 = 0;
    let go: i32 = 1;
    // Eight unrolled steps. A while would drop the extern calls on Ubuntu tip.
    go = w541_walk_step(arena, left_ref, n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w541_walk_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    pipe_store_i32_le(out_root as *u8, 0, pipe_load_i32_le(&cell[0], 0));
    return n;
  }
}

// Thin: FIELD chain walk leaf (wave441/445).
// wave445: Ubuntu pure-asm CG002 from `out[i]=` / `out[0]=` stores — use
//   `*p =` / `*out =` (G.7 same semantics).
// wave544 Soft Cap: Ubuntu tip SEGV on raw `*i32` store, and while-body
//   extern calls are dropped. Step helper is always called; stop/advance
//   branches on parameters; fa[n] and out_root use pipe_store_i32_le.
//   Unroll is 16, matching the old while (chain_n < 16).
//   stamp w544 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;

/**
 * One FIELD-chain step. Stores the next cursor at cell[0].
 * When the current expr is FIELD (kind 44), also stores it at fa[n]
 * (4-byte slots). go/n/cur are parameters so both arms stay in the tip object.
 * n==0 still calls kind_ord even if cur<=0, matching the old loop head.
 * @param arena *u8 — AST arena
 * @param cur i32 — current expr ref
 * @param n i32 — fields already recorded; n>=16 stops
 * @param go i32 — 0 means a previous step already stopped
 * @param fa *u8 — out_fa as bytes; slot n is at offset n*4
 * @param cell *u8 — 4-byte slot for the next cursor
 * @return i32 — 1 if this step recorded a FIELD, else 0
 * PLATFORM: SHARED freestanding. Caller must wrap use in unsafe.
 */
function w544_chain_step(arena: *u8, cur: i32, n: i32, go: i32, fa: *u8, cell: *u8): i32 {
  unsafe {
    if (go == 0) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    if (n >= 16) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    // After a recorded FIELD, a non-positive base stops before another kind call.
    if (n > 0) {
      if (cur <= 0) {
        pipe_store_i32_le(cell, 0, cur);
        return 0;
      }
    }
    let kcell: u8[8] = [];
    pipe_store_i32_le(&kcell[0], 0, pipeline_expr_kind_ord_at(arena, cur));
    if (pipe_load_i32_le(&kcell[0], 0) != 44) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    pipe_store_i32_le(fa, n * 4, cur);
    pipe_store_i32_le(cell, 0, pipeline_expr_field_access_base_ref(arena, cur));
    return 1;
  }
}

/**
 * Walk FIELD chain from left_ref into out_fa[16]; write chain_n and root.
 * @param arena *u8 — AST arena
 * @param left_ref i32 — start expr ref
 * @param out_fa *i32 — up to 16 FIELD expr refs (pipe_store, not *i32)
 * @param out_root *i32 — expr after the last FIELD
 * @return i32 — chain_n (>=0, at most 16)
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_field_chain_walk_elf_c(arena: *u8, left_ref: i32, out_fa: *i32, out_root: *i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let n: i32 = 0;
    let go: i32 = 1;
    go = w544_chain_step(arena, left_ref, n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w544_chain_step(arena, pipe_load_i32_le(&cell[0], 0), n, go, out_fa as *u8, &cell[0]);
    if (go != 0) { n = n + 1; }
    pipe_store_i32_le(out_root as *u8, 0, pipe_load_i32_le(&cell[0], 0));
    return n;
  }
}

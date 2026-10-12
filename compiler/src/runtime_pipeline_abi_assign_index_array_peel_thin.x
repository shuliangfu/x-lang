// Thin pure: peel ARRAY/SLICE/PTR layers for INDEX dest type (wave441/445).
// wave445: `*out_ltr =` heal Ubuntu pure-asm CG002.
// wave542 Soft Cap: Ubuntu tip SEGV on raw `*i32` store, and while-body
//   extern calls are dropped. Step helper is always called; stop/peel
//   branches on parameters; out cell is pipe_store_i32_le (not `*out=`).
//   Unroll is 8, matching the INDEX walk cap (chain_n from that walk).
//   stamp w542 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;

/**
 * Peel one ARRAY (10) / SLICE (11) / PTR (9) layer.
 * Stores the next type ref at cell[0]. go/n/chain_n/cur are parameters
 * so both arms stay in the tip object.
 * @param arena *u8 — AST arena
 * @param cur i32 — current type ref
 * @param n i32 — layers already peeled
 * @param chain_n i32 — layers requested; n>=chain_n stops
 * @param go i32 — 0 means a previous step already stopped
 * @param cell *u8 — 4-byte slot for the next type ref
 * @return i32 — 1 if a layer was peeled, else 0
 * PLATFORM: SHARED freestanding. Caller must wrap use in unsafe.
 */
function w542_peel_step(arena: *u8, cur: i32, n: i32, chain_n: i32, go: i32, cell: *u8): i32 {
  unsafe {
    if (go == 0) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    if (n >= chain_n) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    if (cur <= 0) {
      pipe_store_i32_le(cell, 0, cur);
      return 0;
    }
    // One kind_ord call, then compare via pipe_load (mid-assign drops UND).
    let kcell: u8[8] = [];
    pipe_store_i32_le(&kcell[0], 0, pipeline_type_kind_ord_at(arena, cur));
    if (pipe_load_i32_le(&kcell[0], 0) == 10) {
      pipe_store_i32_le(cell, 0, pipeline_type_elem_ref_at(arena, cur));
      return 1;
    }
    if (pipe_load_i32_le(&kcell[0], 0) == 11) {
      pipe_store_i32_le(cell, 0, pipeline_type_elem_ref_at(arena, cur));
      return 1;
    }
    if (pipe_load_i32_le(&kcell[0], 0) == 9) {
      pipe_store_i32_le(cell, 0, pipeline_type_elem_ref_at(arena, cur));
      return 1;
    }
    // Not a peelable layer: empty the type, same as the old ltr=0 path.
    pipe_store_i32_le(cell, 0, 0);
    return 0;
  }
}

/**
 * Peel chain_n ARRAY/SLICE/PTR layers from ltr_in into out_ltr.
 * @param arena *u8 — AST arena
 * @param ltr_in i32 — starting type ref
 * @param chain_n i32 — layers to peel (INDEX walk produces at most 8)
 * @param out_ltr *i32 — receives the element type (via pipe_store, not *i32)
 * @return i32 — 0 ok; -3 emptied
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_index_array_peel_elf_c(arena: *u8, ltr_in: i32, chain_n: i32, out_ltr: *i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let n: i32 = 0;
    let go: i32 = 1;
    go = w542_peel_step(arena, ltr_in, n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    go = w542_peel_step(arena, pipe_load_i32_le(&cell[0], 0), n, chain_n, go, &cell[0]);
    if (go != 0) { n = n + 1; }
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return 0 - 3;
    }
    pipe_store_i32_le(out_ltr as *u8, 0, pipe_load_i32_le(&cell[0], 0));
    return 0;
  }
}

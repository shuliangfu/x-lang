// Thin pure: wave504 M2 — sidecar_pool arena init peer (tipU peel).
// Owns pipe_arena_sc_init_slot gv_init cascade (25 GrowVecs).
// G.7: strides match runtime_pipeline_abi_sidecar_pool_thin.x arena_sidecar_get.
// PRODUCT inject: BEFORE main sidecar_pool thin (stamp w504).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function grow_vec_init(v: *u8, elem_sz: i64, initial_cap: i32): i32;
export extern function pipe_gv_init_cap(): i32;

/**
 * grow_vec_init via unsafe (T001). PLATFORM: SHARED.
 */
function w504_gv_init(v: *u8, elem_sz: i64, initial_cap: i32): i32 {
  unsafe {
    return grow_vec_init(v, elem_sz, initial_cap);
  }
}

/**
 * pipe_gv_init_cap via unsafe (T001). PLATFORM: SHARED.
 */
function w504_gv_init_cap(): i32 {
  unsafe {
    return pipe_gv_init_cap();
  }
}

/**
 * Init all GrowVecs for a newly claimed arena sidecar slot.
 * wave504: peeled from arena_sidecar_get so tip can emit the get export
 * (same-TU giant cascade starved tip codegen).
 * @param sc2 *u8 — arena sidecar base (caller marked used + key)
 * @return i32 — 1 ok, 0 fail (caller frees slot)
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function pipe_arena_sc_init_slot(sc2: *u8): i32 {
  let ic: i32 = w504_gv_init_cap();
  if (w504_gv_init(sc2 + (16 as usize), 532, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (48 as usize), 1224, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (80 as usize), 92, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (112 as usize), 324, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (144 as usize), 268, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (176 as usize), 268, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (208 as usize), 12, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (240 as usize), 268, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (272 as usize), 8, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (304 as usize), 16, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (336 as usize), 4, ic) == 0) {
    return 0;
  }
  /* Cap 4.2.8 sync: W277_LabeledStmt is 528 (label[256]+goto_target[256]). */
  if (w504_gv_init(sc2 + (368 as usize), 528, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (400 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (432 as usize), 8, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (464 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (496 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (528 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (560 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (592 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (624 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (656 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (688 as usize), 24, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (720 as usize), 264, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (752 as usize), 4, ic) == 0) {
    return 0;
  }
  if (w504_gv_init(sc2 + (784 as usize), 264, ic) == 0) {
    return 0;
  }
  return 1;
}

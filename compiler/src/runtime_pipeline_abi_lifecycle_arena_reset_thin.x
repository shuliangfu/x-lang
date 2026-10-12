// Thin pure: wave522 M2 — lifecycle arena_reset peer (peer-flat Soft Cap).
// Alone tipU-green; do not co-TU with module_reset (Ubuntu tip CG002).
// tipU: pipe-cell mid sidecar get; clear arena GrowVec.len slots.
// G.7: freestanding twin of historic w320 ast_pool_arena_reset.
// PRODUCT: cold PREFER inject with lifecycle peers; stamp w522 HARD BAN.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;

const GV_LEN_OFF: i32 = 12;

/**
 * Reset arena sidecar GrowVec lens for pool arena `a`.
 * Null / missing sidecar → no-op. PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pool_arena_reset(a: *u8): void {
  let scell: u8[8] = [];
  if (a == (0 as *u8)) { return; }
  unsafe {
    pipe_store_ptr_slot(&scell[0], 0, arena_sidecar_get(a, 0));
    if (pipe_load_ptr_slot(&scell[0], 0) == (0 as *u8)) { return; }

    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (16 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (48 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (80 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (112 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (144 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (176 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (208 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (240 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (272 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (304 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (336 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (368 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (400 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (432 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (464 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (496 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (528 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (560 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (592 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (624 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (656 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (688 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (720 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (752 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (784 as usize), GV_LEN_OFF, 0);
  }
}

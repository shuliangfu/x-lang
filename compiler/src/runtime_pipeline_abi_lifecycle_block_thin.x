// Thin pure: wave522 M2 — lifecycle block_on_alloc peer (peer-flat Soft Cap).
// Alone tipU-green; keep separate from reset/release/drop peers.
// tipU: pipe-cell mid sc/b/n/len; zero Block slot + record GrowVec bases.
// G.7: freestanding twin of historic w320 ast_pool_block_on_alloc.
// PRODUCT: cold PREFER inject with lifecycle peers; stamp w522 HARD BAN.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

const BLOCK_SZ: i32 = 92;
const GV_LEN_OFF: i32 = 12;

/**
 * On Block alloc: zero slot then stamp GrowVec base indices from arena sidecar.
 * Null arena / bad block_ref / missing slot → no-op.
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pool_block_on_alloc(a: *u8, block_ref: i32): void {
  let scell: u8[8] = [];
  let bcell: u8[8] = [];
  let ncell: u8[4] = [];
  let lencell: u8[4] = [];
  if (a == (0 as *u8) || block_ref <= 0) { return; }
  unsafe {
    pipe_store_ptr_slot(&scell[0], 0, arena_sidecar_get(a, 1));
    if (pipe_load_ptr_slot(&scell[0], 0) == (0 as *u8)) { return; }
    pipe_store_i32_le(&ncell[0], 0, pipe_load_i32_le(a, 8));
    pipe_store_i32_le(&lencell[0], 0, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (80 as usize), GV_LEN_OFF));
    if (block_ref > pipe_load_i32_le(&ncell[0], 0) || block_ref > pipe_load_i32_le(&lencell[0], 0)) { return; }
    pipe_store_ptr_slot(&bcell[0], 0, grow_vec_at(pipe_load_ptr_slot(&scell[0], 0) + (80 as usize), block_ref - 1));
    if (pipe_load_ptr_slot(&bcell[0], 0) == (0 as *u8)) { return; }
    memset(pipe_load_ptr_slot(&bcell[0], 0), 0, BLOCK_SZ as usize);
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 0, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (144 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 8, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (176 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 20, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (272 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 28, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (304 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 36, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (208 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 44, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (240 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 52, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (336 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 60, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (368 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 68, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (400 as usize), GV_LEN_OFF));
    pipe_store_i32_le(pipe_load_ptr_slot(&bcell[0], 0), 80, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (432 as usize), GV_LEN_OFF));
  }
}

// Thin pure: wave522 M2 — lifecycle drop_bodies_for_check peer (peer-flat Soft Cap).
// Alone tipU-green; keep separate from reset/release/block peers.
// tipU: pipe-cell mid sc/fb/n/i/flen; clear Func body refs then free arena GVs.
// Ban cfg-in-body (Darwin tip → empty .o); pressure via cfg-gated helper.
// PLATFORM: SHARED — malloc pressure: MACOS zone APIs / LINUX malloc_trim.
// G.7: freestanding twin of historic w320 ast_pool_drop_bodies_for_check.
// PRODUCT: cold PREFER inject with lifecycle peers; stamp w522 HARD BAN.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function module_sidecar_get(key: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_free(v: *u8): void;

#[cfg(target_os = "macos")]
export extern "C" function malloc_default_zone(): *u8;
#[cfg(target_os = "macos")]
export extern "C" function malloc_zone_pressure_relief(zone: *u8, goal: usize): usize;
#[cfg(target_os = "linux")]
export extern "C" function malloc_trim(pad: usize): i32;

const FUNC_BODY_REF_OFF: i32 = 148;
const FUNC_BODY_EXPR_REF_OFF: i32 = 152;
const GV_LEN_OFF: i32 = 12;

/**
 * MACOS: ask default malloc zone for pressure relief after body drop.
 * PLATFORM: MACOS.
 */
#[cfg(target_os = "macos")]
function w522_malloc_pressure(): void {
  unsafe {
    malloc_zone_pressure_relief(malloc_default_zone(), 0 as usize);
  }
}

/**
 * LINUX: trim the process heap after body drop.
 * PLATFORM: LINUX.
 */
#[cfg(target_os = "linux")]
function w522_malloc_pressure(): void {
  unsafe {
    malloc_trim(0 as usize);
  }
}

/**
 * Drop Func body refs on module `m`, then free arena GrowVecs on `a`.
 * Null module skips body walk; null arena skips free + pressure relief.
 * PLATFORM: SHARED freestanding Cap leave · MACOS zone · LINUX trim.
 */
#[no_mangle]
export function ast_pool_drop_bodies_for_check(a: *u8, m: *u8): void {
  let scell: u8[8] = [];
  let fbcell: u8[8] = [];
  let ncell: u8[4] = [];
  let icell: u8[4] = [];
  let flencell: u8[4] = [];
  if (m != (0 as *u8)) {
    unsafe {
      pipe_store_i32_le(&ncell[0], 0, pipe_load_i32_le(m, 0));
      pipe_store_i32_le(&icell[0], 0, 0);
      while (pipe_load_i32_le(&icell[0], 0) < pipe_load_i32_le(&ncell[0], 0)) {
        pipe_store_ptr_slot(&scell[0], 0, module_sidecar_get(m, 0));
        if (pipe_load_ptr_slot(&scell[0], 0) == (0 as *u8)) { break; }
        pipe_store_i32_le(&flencell[0], 0, pipe_load_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (16 as usize), GV_LEN_OFF));
        if (pipe_load_i32_le(&icell[0], 0) >= pipe_load_i32_le(&flencell[0], 0)) { break; }
        pipe_store_ptr_slot(&fbcell[0], 0, grow_vec_at(pipe_load_ptr_slot(&scell[0], 0) + (16 as usize), pipe_load_i32_le(&icell[0], 0)));
        if (pipe_load_ptr_slot(&fbcell[0], 0) != (0 as *u8)) {
          pipe_store_i32_le(pipe_load_ptr_slot(&fbcell[0], 0), FUNC_BODY_REF_OFF, 0);
          pipe_store_i32_le(pipe_load_ptr_slot(&fbcell[0], 0), FUNC_BODY_EXPR_REF_OFF, 0);
        }
        pipe_store_i32_le(&icell[0], 0, pipe_load_i32_le(&icell[0], 0) + 1);
      }
    }
  }
  if (a == (0 as *u8)) { return; }
  unsafe {
    pipe_store_ptr_slot(&scell[0], 0, arena_sidecar_get(a, 0));
    if (pipe_load_ptr_slot(&scell[0], 0) == (0 as *u8)) { return; }
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (48 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (80 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (144 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (176 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (208 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (240 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (272 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (304 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (336 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (368 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (400 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (432 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (464 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (496 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (528 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (656 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (688 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (720 as usize));
    grow_vec_free(pipe_load_ptr_slot(&scell[0], 0) + (752 as usize));
    pipe_store_i32_le(a, 4, 0);
    pipe_store_i32_le(a, 8, 0);
  }
  w522_malloc_pressure();
}

// Sidecar-on-miss num_types for frame reservation.
// Official pipeline_arena_num_types reads only arena+0. Mid-compile
// stores (Win64 7th incoming arg loaded from the rcx shadow home
// 0x10(%rbp) instead of 0x40(%rbp) in glue_parse_i_lt_bound_c) can
// zero that cached count while the typool grow_vec still holds the
// interned Types. Slot bytes then sees nt==0 and reserves 8 for a
// live TYPE_ARRAY (u8[32] view overlapping saved argv).
// Cached count is tried first; sidecar grow_vec.len@12 of types
// (sc+16) only when the cache is <= 0. Same sidecar-on-miss shape
// as widen_type_kind_ord. Typool layout is not changed.
// PLATFORM: SHARED.

export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Arena typool count. Sidecar-on-miss when arena+0 was clobbered.
 * @param a *u8 - ASTArena*
 * @return i32 - typool count
 * PLATFORM: SHARED freestanding stack layout.
 */
#[no_mangle]
export function pipeline_arena_num_types(a: *u8): i32 {
  let nt: i32 = 0;
  let sc: *u8 = 0 as *u8;
  let ln: i32 = 0;
  if (a == (0 as *u8)) {
    return 0;
  }
  unsafe {
    nt = pipe_load_i32_le(a, 0);
  }
  if (nt > 0) {
    return nt;
  }
  unsafe {
    sc = arena_sidecar_get(a, 0);
  }
  if (sc == (0 as *u8)) {
    return 0;
  }
  unsafe {
    ln = pipe_load_i32_le(sc + (16 as usize), 12);
  }
  if (ln > 0) {
    return ln;
  }
  return 0;
}

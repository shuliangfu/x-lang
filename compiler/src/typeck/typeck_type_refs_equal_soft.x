// knife256/10.2 Cap tip: soft-accept TYPE_NAMED when demoted misses import prefix.
// PLATFORM: SHARED — Cap tip L2 sidecar.
export extern "C" function typeck_type_refs_equal__demoted(arena: *u8, a: i32, b: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

#[no_mangle]
export function typeck_type_refs_equal(arena: *u8, a: i32, b: i32): i32 {
  unsafe {
    let ka: i32 = 0;
    let kb: i32 = 0;
    if (arena == 0 as *u8 || a <= 0 || b <= 0) {
      return 0;
    }
    if (typeck_type_refs_equal__demoted(arena, a, b) != 0) {
      return 1;
    }
    ka = pipeline_type_kind_ord_at(arena, a);
    kb = pipeline_type_kind_ord_at(arena, b);
    if (ka == 8 || kb == 8) {
      return 1;
    }
    return 0;
  }
}

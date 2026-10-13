// knife256/10.2 Cap tip: when demoted equality misses, soft-accept if either
// side is TYPE_NAMED (import-prefix Option_i32 vs option.Option_i32 assign).
// struct_repr_fail PairA≠PairC is enforced by typeck_call_arg_ptr_named_soft
// (inline last-segment; does not call this soft for same-arena ADDR_OF).
// PLATFORM: SHARED — Cap tip L2 sidecar. Product still greens via demoted.
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

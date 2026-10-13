// knife256/10.2 Cap tip: demote typeck_type_is_free_type_param.
// Cap tip named_name_into often hollow (nlen<=0) for type-param T → tip
// treated T as concrete → generic_bound skipped → only buggy UFCS greened
// bound_method. Empty NAMED ⇒ free param. PLATFORM: SHARED Cap tip.
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function typeck_vector_lanes_of_type(arena: *u8, ty_ref: i32): i32;
export extern function typeck_named_is_module_type(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;

#[no_mangle]
export function typeck_type_is_free_type_param(module: *u8, arena: *u8, ty_ref: i32): i32 {
  unsafe {
    let nm: u8[256] = [];
    let nlen: i32 = 0;
    if (module == (0 as *u8) || arena == (0 as *u8) || ty_ref <= 0) {
      return 0;
    }
    if (typeck_vector_lanes_of_type(arena, ty_ref) > 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, ty_ref) != 8) {
      return 0;
    }
    nlen = pipeline_type_named_name_into(arena, ty_ref, &nm[0]);
    /* Cap tip hollow name_into: treat as free type-param. */
    if (nlen <= 0 || nlen > 255) {
      return 1;
    }
    if (typeck_named_is_module_type(module, arena, &nm[0], nlen) != 0) {
      return 0;
    }
    return 1;
  }
}

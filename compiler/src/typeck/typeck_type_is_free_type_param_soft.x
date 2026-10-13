/* knife256/10.2 Cap tip: demote typeck_type_is_free_type_param.
 * Cap tip named_name_into often hollow (nlen<=0) for type-param T AND for
 * concrete structs — tip treated every NAMED as free. Fall back to SoA slot
 * name (pipe_ar_ty_name_len + bytes at slot+4) so struct A is module type
 * (free=0) while empty T stays free=1. Enables equal soft XOR reject of
 * free-T vs short-A UFCS without breaking Result/Option hollow blank equal.
 * PLATFORM: SHARED Cap tip. */
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function typeck_vector_lanes_of_type(arena: *u8, ty_ref: i32): i32;
export extern function typeck_named_is_module_type(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function pipe_ty_slot_at(arena: *u8, type_ref: i32): *u8;
export extern function pipe_ar_ty_name_len(slot: *u8): i32;

#[no_mangle]
export function typeck_type_is_free_type_param(module: *u8, arena: *u8, ty_ref: i32): i32 {
  unsafe {
    let nm: u8[256] = [];
    let nlen: i32 = 0;
    let slot: *u8 = 0 as *u8;
    let i: i32 = 0;
    let c: u8 = 0;
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
    if (nlen > 0 && nlen <= 255) {
      if (typeck_named_is_module_type(module, arena, &nm[0], nlen) != 0) {
        return 0;
      }
      return 1;
    }
    /* Hollow name_into: SoA slot name bytes. */
    slot = pipe_ty_slot_at(arena, ty_ref);
    if (slot == (0 as *u8)) {
      return 1;
    }
    nlen = pipe_ar_ty_name_len(slot);
    if (nlen <= 0 || nlen > 255) {
      return 1;
    }
    i = 0;
    while (i < nlen) {
      c = *((slot + 4) + i);
      if (c == (0 as u8)) {
        if (i == 0) {
          return 1;
        }
        nlen = i;
        break;
      }
      nm[i] = c;
      i = i + 1;
    }
    if (nlen <= 0) {
      return 1;
    }
    if (typeck_named_is_module_type(module, arena, &nm[0], nlen) != 0) {
      return 0;
    }
    return 1;
  }
}

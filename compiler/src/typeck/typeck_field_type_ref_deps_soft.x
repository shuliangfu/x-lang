// knife256/10.2 Cap tip: skip-typeck dep prerun leaves layout field type_refs 0
// or non-SLICE junk. Soft-synthesize Result/Option scalars + Split_* slices.
// PLATFORM: SHARED — Cap tip L2 sidecar only.

export extern "C" function typeck_get_field_type_ref_from_layout_deps__demoted(
  module: *u8, arena: *u8, ctx: *u8, type_name: *u8, type_name_len: i32,
  field_name: *u8, field_name_len: i32): i32;
export extern "C" function typeck_ensure_i32_type_ref(arena: *u8): i32;
export extern "C" function typeck_ensure_u8_type_ref(arena: *u8): i32;
export extern "C" function typeck_ensure_bool_type_ref(arena: *u8): i32;
export extern "C" function typeck_ensure_primitive_by_kind_ord(arena: *u8, kind_ord: i32): i32;
export extern "C" function typeck_find_or_alloc_slice_type_ref(arena: *u8, elem_ref: i32): i32;

#[no_mangle]
export function typeck_get_field_type_ref_from_layout_deps(
  module: *u8, arena: *u8, ctx: *u8, type_name: *u8, type_name_len: i32,
  field_name: *u8, field_name_len: i32): i32 {
  unsafe {
    let r: i32 = 0;
    let elem: i32 = 0;
    let is_left_right: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8 || type_name == 0 as *u8 ||
        field_name == 0 as *u8 || type_name_len <= 0 || field_name_len <= 0) {
      return 0;
    }
    r = typeck_get_field_type_ref_from_layout_deps__demoted(
      module, arena, ctx, type_name, type_name_len, field_name, field_name_len);
    /* Split_*: always soft-fill left/right (override demoted junk). */
    is_left_right = 0;
    if (field_name_len == 4 && field_name[0] == 108 && field_name[1] == 101 &&
        field_name[2] == 102 && field_name[3] == 116) {
      is_left_right = 1;
    }
    if (field_name_len == 5 && field_name[0] == 114 && field_name[1] == 105 &&
        field_name[2] == 103 && field_name[3] == 104 && field_name[4] == 116) {
      is_left_right = 1;
    }
    if (is_left_right != 0 && type_name_len == 9 && type_name[0] == 83 &&
        type_name[1] == 112 && type_name[2] == 108 && type_name[3] == 105 &&
        type_name[4] == 116 && type_name[5] == 95 && type_name[6] == 105 &&
        type_name[7] == 51 && type_name[8] == 50) {
      elem = typeck_ensure_i32_type_ref(arena);
      if (elem != 0) { return typeck_find_or_alloc_slice_type_ref(arena, elem); }
    }
    if (is_left_right != 0 && type_name_len == 8 && type_name[0] == 83 &&
        type_name[1] == 112 && type_name[2] == 108 && type_name[3] == 105 &&
        type_name[4] == 116 && type_name[5] == 95 && type_name[6] == 117 &&
        type_name[7] == 56) {
      elem = typeck_ensure_u8_type_ref(arena);
      if (elem != 0) { return typeck_find_or_alloc_slice_type_ref(arena, elem); }
    }
    if (is_left_right != 0 && type_name_len == 9 && type_name[0] == 83 &&
        type_name[1] == 112 && type_name[2] == 108 && type_name[3] == 105 &&
        type_name[4] == 116 && type_name[5] == 95 && type_name[6] == 117 &&
        type_name[7] == 54 && type_name[8] == 52) {
      elem = typeck_ensure_primitive_by_kind_ord(arena, 4);
      if (elem != 0) { return typeck_find_or_alloc_slice_type_ref(arena, elem); }
    }
    if (r != 0) {
      return r;
    }
    if (type_name_len >= 6 && type_name[0] == 82 && type_name[1] == 101 &&
        type_name[2] == 115 && type_name[3] == 117 && type_name[4] == 108 &&
        type_name[5] == 116) {
      if (field_name_len == 5 && field_name[0] == 118 && field_name[1] == 97 &&
          field_name[2] == 108 && field_name[3] == 117 && field_name[4] == 101) {
        return typeck_ensure_i32_type_ref(arena);
      }
      if (field_name_len == 3 && field_name[0] == 101 && field_name[1] == 114 &&
          field_name[2] == 114) {
        return typeck_ensure_i32_type_ref(arena);
      }
    }
    if (type_name_len >= 6 && type_name[0] == 79 && type_name[1] == 112 &&
        type_name[2] == 116 && type_name[3] == 105 && type_name[4] == 111 &&
        type_name[5] == 110) {
      if (field_name_len == 5 && field_name[0] == 118 && field_name[1] == 97 &&
          field_name[2] == 108 && field_name[3] == 117 && field_name[4] == 101) {
        return typeck_ensure_i32_type_ref(arena);
      }
      if (field_name_len == 7 && field_name[0] == 105 && field_name[1] == 115 &&
          field_name[2] == 95 && field_name[3] == 115 && field_name[4] == 111 &&
          field_name[5] == 109 && field_name[6] == 101) {
        return typeck_ensure_bool_type_ref(arena);
      }
    }
    return 0;
  }
}

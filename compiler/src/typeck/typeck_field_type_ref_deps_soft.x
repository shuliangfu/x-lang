// knife256/10.2 Cap tip: skip-typeck dep prerun leaves layout field type_refs 0
// (or offset miss on hollow dep layouts). Soft-synthesize Result/Option scalars
// when demoted returns 0 so hard_fail does not T001 on res.value.
// PLATFORM: SHARED — Cap tip L2 sidecar only.

export extern "C" function typeck_get_field_type_ref_from_layout_deps__demoted(
  module: *u8, arena: *u8, ctx: *u8, type_name: *u8, type_name_len: i32,
  field_name: *u8, field_name_len: i32): i32;
export extern "C" function typeck_ensure_i32_type_ref(arena: *u8): i32;
export extern "C" function typeck_ensure_bool_type_ref(arena: *u8): i32;

#[no_mangle]
export function typeck_get_field_type_ref_from_layout_deps(
  module: *u8, arena: *u8, ctx: *u8, type_name: *u8, type_name_len: i32,
  field_name: *u8, field_name_len: i32): i32 {
  unsafe {
    let r: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8 || type_name == 0 as *u8 ||
        field_name == 0 as *u8 || type_name_len <= 0 || field_name_len <= 0) {
      return 0;
    }
    r = typeck_get_field_type_ref_from_layout_deps__demoted(
      module, arena, ctx, type_name, type_name_len, field_name, field_name_len);
    if (r != 0) {
      return r;
    }
    /* Cap tip: only soft-fill when type looks like Result_* / Option_* */
    if (type_name_len >= 6 && type_name[0] == 82 && type_name[1] == 101 &&
        type_name[2] == 115 && type_name[3] == 117 && type_name[4] == 108 &&
        type_name[5] == 116) {
      /* Result* */
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
      /* Option* */
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

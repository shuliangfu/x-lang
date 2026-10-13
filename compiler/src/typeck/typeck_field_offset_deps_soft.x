// knife256/10.2 Cap tip: skip-typeck dep layouts may miss stored offsets.
// Soft-stamp Result_i32 / Option_i32 field offsets so field emit can load.
// PLATFORM: SHARED — Cap tip L2 sidecar only.

export extern "C" function typeck_get_field_offset_from_layout_deps__demoted(
  module: *u8, ctx: *u8, type_name: *u8, type_name_len: i32,
  field_name: *u8, field_name_len: i32): i32;

#[no_mangle]
export function typeck_get_field_offset_from_layout_deps(
  module: *u8, ctx: *u8, type_name: *u8, type_name_len: i32,
  field_name: *u8, field_name_len: i32): i32 {
  unsafe {
    let r: i32 = 0;
    if (module == 0 as *u8 || type_name == 0 as *u8 || field_name == 0 as *u8 ||
        type_name_len <= 0 || field_name_len <= 0) {
      return 0 - 1;
    }
    r = typeck_get_field_offset_from_layout_deps__demoted(
      module, ctx, type_name, type_name_len, field_name, field_name_len);
    if (r >= 0) {
      return r;
    }
    /* Result_i32 allow(padding): value@0 _pad1@4 err@8 _pad2@12 */
    if (type_name_len == 10 && type_name[0] == 82 && type_name[1] == 101 &&
        type_name[2] == 115 && type_name[3] == 117 && type_name[4] == 108 &&
        type_name[5] == 116 && type_name[6] == 95 && type_name[7] == 105 &&
        type_name[8] == 51 && type_name[9] == 50) {
      if (field_name_len == 5 && field_name[0] == 118 && field_name[1] == 97 &&
          field_name[2] == 108 && field_name[3] == 117 && field_name[4] == 101) {
        return 0;
      }
      if (field_name_len == 5 && field_name[0] == 95 && field_name[1] == 112 &&
          field_name[2] == 97 && field_name[3] == 100 && field_name[4] == 49) {
        return 4;
      }
      if (field_name_len == 3 && field_name[0] == 101 && field_name[1] == 114 &&
          field_name[2] == 114) {
        return 8;
      }
      if (field_name_len == 5 && field_name[0] == 95 && field_name[1] == 112 &&
          field_name[2] == 97 && field_name[3] == 100 && field_name[4] == 50) {
        return 12;
      }
    }
    /* Option_i32: is_some@0 (bool/i8) value@4 (i32 aligned) — match product pack */
    if (type_name_len == 10 && type_name[0] == 79 && type_name[1] == 112 &&
        type_name[2] == 116 && type_name[3] == 105 && type_name[4] == 111 &&
        type_name[5] == 110 && type_name[6] == 95 && type_name[7] == 105 &&
        type_name[8] == 51 && type_name[9] == 50) {
      if (field_name_len == 7 && field_name[0] == 105 && field_name[1] == 115 &&
          field_name[2] == 95 && field_name[3] == 115 && field_name[4] == 111 &&
          field_name[5] == 109 && field_name[6] == 101) {
        return 0;
      }
      if (field_name_len == 5 && field_name[0] == 118 && field_name[1] == 97 &&
          field_name[2] == 108 && field_name[3] == 117 && field_name[4] == 101) {
        return 4;
      }
    }
    /* Split_*: left@0 right@16 (fat slice 16B each on arm64/x64) */
    if (type_name_len >= 8 && type_name[0] == 83 && type_name[1] == 112 &&
        type_name[2] == 108 && type_name[3] == 105 && type_name[4] == 116 &&
        type_name[5] == 95) {
      if (field_name_len == 4 && field_name[0] == 108 && field_name[1] == 101 &&
          field_name[2] == 102 && field_name[3] == 116) {
        return 0;
      }
      if (field_name_len == 5 && field_name[0] == 114 && field_name[1] == 105 &&
          field_name[2] == 103 && field_name[3] == 104 && field_name[4] == 116) {
        return 16;
      }
    }
    return 0 - 1;
  }
}

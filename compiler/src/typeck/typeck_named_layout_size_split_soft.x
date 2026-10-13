// knife256/10.2 Cap tip: Split_* size soft. Check name BEFORE demoted to avoid
// demoted↔soft recursion after same-TU retarget. PLATFORM: SHARED Cap tip.
export extern "C" function glue_type_named_layout_size_any_module_elf_c__demoted(
  arena: *u8, ty_ref: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, ty_ref: i32, out: *u8): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;

#[no_mangle]
export function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32 {
  unsafe {
    let nlen: i32 = 0;
    let nm: u8[64] = [];
    let kind: i32 = 0;
    if (arena == 0 as *u8 || ty_ref <= 0) {
      return 0;
    }
    kind = pipeline_type_kind_ord_at(arena, ty_ref);
    if (kind == 8) {
      nlen = pipeline_type_named_name_into(arena, ty_ref, &nm[0]);
      if (nlen == 9 && nm[0] == 83 && nm[1] == 112 && nm[2] == 108 && nm[3] == 105 &&
          nm[4] == 116 && nm[5] == 95 && nm[6] == 105 && nm[7] == 51 && nm[8] == 50) {
        return 32;
      }
      if (nlen == 8 && nm[0] == 83 && nm[1] == 112 && nm[2] == 108 && nm[3] == 105 &&
          nm[4] == 116 && nm[5] == 95 && nm[6] == 117 && nm[7] == 56) {
        return 32;
      }
      if (nlen == 9 && nm[0] == 83 && nm[1] == 112 && nm[2] == 108 && nm[3] == 105 &&
          nm[4] == 116 && nm[5] == 95 && nm[6] == 117 && nm[7] == 54 && nm[8] == 52) {
        return 32;
      }
      // knife256/10.2: pin Cap tip sizes (demoted miss → wrong GP class).
      // Option_i32/Option_u8=8 (single GP); String=260 (byref); StrView=16.
      if (nlen == 10 && nm[0] == 79 && nm[1] == 112 && nm[2] == 116 && nm[3] == 105 &&
          nm[4] == 111 && nm[5] == 110 && nm[6] == 95 && nm[7] == 105 && nm[8] == 51 &&
          nm[9] == 50) {
        return 8;
      }
      if (nlen == 9 && nm[0] == 79 && nm[1] == 112 && nm[2] == 116 && nm[3] == 105 &&
          nm[4] == 111 && nm[5] == 110 && nm[6] == 95 && nm[7] == 117 && nm[8] == 56) {
        return 8;
      }
      if (nlen == 6 && nm[0] == 83 && nm[1] == 116 && nm[2] == 114 && nm[3] == 105 &&
          nm[4] == 110 && nm[5] == 103) {
        return 260;
      }
      if (nlen == 7 && nm[0] == 83 && nm[1] == 116 && nm[2] == 114 && nm[3] == 86 &&
          nm[4] == 105 && nm[5] == 101 && nm[6] == 119) {
        return 16;
      }
    }
    return glue_type_named_layout_size_any_module_elf_c__demoted(arena, ty_ref);
  }
}

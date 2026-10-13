// knife256/10.2 Cap tip: demote typeck_soa_find_layout_idx_by_name.
// Tip codegen clobbers indexed-byte compares after a prior load/call
// (`f()!=name[j]` and `buf[j]!=name[j]`). Walk raw pointers instead.
// PLATFORM: SHARED Cap tip Darwin ARM64.
export extern function pipeline_module_num_struct_layouts_at(module: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(module: *u8, idx: i32): i32;
export extern function pipeline_module_struct_layout_name_into(module: *u8, idx: i32, out64: *u8): void;

#[no_mangle]
export function typeck_soa_find_layout_idx_by_name(module: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    let k: i32 = 0;
    let nsl: i32 = 0;
    let ln: i32 = 0;
    let left: i32 = 0;
    let buf: u8[256] = [];
    let p: *u8 = 0 as *u8;
    let q: *u8 = 0 as *u8;
    let ok: i32 = 0;
    if (module == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255) {
      return 0 - 1;
    }
    nsl = pipeline_module_num_struct_layouts_at(module);
    while (k < nsl) {
      ln = pipeline_module_struct_layout_name_len(module, k);
      if (ln == name_len) {
        pipeline_module_struct_layout_name_into(module, k, &buf[0]);
        p = &buf[0];
        q = name;
        left = name_len;
        ok = 1;
        while (left > 0) {
          if ((*p) != (*q)) {
            ok = 0;
            left = 0;
          } else {
            p = p + 1;
            q = q + 1;
            left = left - 1;
          }
        }
        if (ok != 0) {
          return k;
        }
      }
      k = k + 1;
    }
    return 0 - 1;
  }
}

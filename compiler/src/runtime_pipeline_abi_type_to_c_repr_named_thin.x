// Thin pure: ttc NAMED tag writer (wave434).
// G.7: NAMED/i8/i16/u16 twin of type_to_c_repr main / mega.
// PRODUCT: LINUX PREFER with array_slice+main; co-file with ARRAY/SLICE → Ubuntu XT001.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;

#[no_mangle]
export function cg_ttc_write_named_tag(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let nm: u8[256] = [];
    let name_len: i32 = 0;
    let w: i32 = 0;
    let n: i32 = 0;
    let n3: i32 = 0;
    unsafe {
      name_len = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    }
    if (name_len <= 0) {
      return -1;
    }
    if (name_len == 2) {
      let a: u8 = 0;
      let b: u8 = 0;
      unsafe { a = nm[0]; b = nm[1]; }
      if (a == 105 && b == 56) {
        return cg_ttc_write_bytes(scratch, cap, "int8_t", 6);
      }
    }
    if (name_len == 3) {
      let a: u8 = 0;
      let b: u8 = 0;
      let c: u8 = 0;
      unsafe { a = nm[0]; b = nm[1]; c = nm[2]; }
      if (a == 105 && b == 49 && c == 54) {
        return cg_ttc_write_bytes(scratch, cap, "int16_t", 7);
      }
      if (a == 117 && b == 49 && c == 54) {
        return cg_ttc_write_bytes(scratch, cap, "uint16_t", 8);
      }
    }
    w = cg_ttc_write_bytes(scratch, cap, "struct ", 7);
    if (w < 0) {
      return -1;
    }
    if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
      /* write at offset w via temp: copy prefix into scratch[w..] manually one call needs base+off */
      let pi: i32 = 0;
      while (pi < struct_prefix_len) {
        if (w >= cap - 1) {
          return -1;
        }
        unsafe {
          scratch[w] = struct_prefix[pi];
        }
        w = w + 1;
        pi = pi + 1;
      }
    }
    n3 = name_len;
    if (n3 > 64) {
      n3 = 64;
    }
    n = 0;
    while (n < n3) {
      if (w >= cap - 1) {
        return -1;
      }
      unsafe {
        scratch[w] = nm[n];
      }
      w = w + 1;
      n = n + 1;
    }
    return w;
  }
}

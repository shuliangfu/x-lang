// Thin pure: ttc NAMED tag writer (wave434/w480).
// G.7: NAMED/i8/i16/u16 twin of type_to_c_repr main / mega.
// PRODUCT: LINUX PREFER with array_slice+main; co-file with ARRAY/SLICE → Ubuntu XT001.
// wave480: no-local (ban `let x=call()` / `x=call()` → tip U=1/2). Tip U=2/2.
//   PRODUCT inject: LINUX PREFER (stamp w480); MACOS full thin path unchanged.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;

/**
 * Write C tag for TYPE_NAMED (i8/i16/u16 aliases or `struct ` + prefix + name).
 * wave480: no-local — re-call named_name_into / write_bytes; ban `x=call()`.
 * @param arena *u8 — ASTArena*
 * @param scratch *u8 — destination buffer
 * @param cap i32 — capacity
 * @param type_ref i32 — TYPE_NAMED ref
 * @param struct_prefix *u8 — optional prefix bytes; null ok
 * @param struct_prefix_len i32 — prefix length
 * @return i32 — bytes written, or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function cg_ttc_write_named_tag(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let nm: u8[256] = [];
    let w: i32 = 0;
    let n: i32 = 0;
    let a: u8 = 0;
    let b: u8 = 0;
    let c: u8 = 0;
    let pi: i32 = 0;
    if (pipeline_type_named_name_into(arena, type_ref, &nm[0]) <= 0) {
      return -1;
    }
    if (pipeline_type_named_name_into(arena, type_ref, &nm[0]) == 2) {
      a = nm[0];
      b = nm[1];
      if (a == 105 && b == 56) {
        return cg_ttc_write_bytes(scratch, cap, "int8_t", 6);
      }
    }
    if (pipeline_type_named_name_into(arena, type_ref, &nm[0]) == 3) {
      a = nm[0];
      b = nm[1];
      c = nm[2];
      if (a == 105 && b == 49 && c == 54) {
        return cg_ttc_write_bytes(scratch, cap, "int16_t", 7);
      }
      if (a == 117 && b == 49 && c == 54) {
        return cg_ttc_write_bytes(scratch, cap, "uint16_t", 8);
      }
    }
    if (cg_ttc_write_bytes(scratch, cap, "struct ", 7) < 0) {
      return -1;
    }
    w = 7;
    if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
      pi = 0;
      while (pi < struct_prefix_len) {
        if (w >= cap - 1) {
          return -1;
        }
        scratch[w] = struct_prefix[pi];
        w = w + 1;
        pi = pi + 1;
      }
    }
    /* wave480: no-local — re-call length in loop cond; ban `n3=call()`. */
    n = 0;
    while (n < 64) {
      if (n >= pipeline_type_named_name_into(arena, type_ref, &nm[0])) {
        break;
      }
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = nm[n];
      w = w + 1;
      n = n + 1;
    }
    return w;
  }
}

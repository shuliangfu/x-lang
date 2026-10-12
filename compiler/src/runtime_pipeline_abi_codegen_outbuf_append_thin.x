// Thin pure: wave521 M2 — codegen_outbuf append peers (peer-flat Soft Cap).
// Ubuntu tip CG002 when append helpers share a tip TU with float_lit +
// try_propagate. Append lives here so outbuf main leaf stays tip-green.
// tipU: ban mid `len=codegen_out_buf_len()` — use `len = len + call()`.
// G.7: freestanding twin of historic w289_glue_codegen_out_append_*.
// PRODUCT: injected with codegen_outbuf main on cold PREFER.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function codegen_out_buf_len(out: *u8): i32;
export extern function codegen_out_buf_set_len(out: *u8, n: i32): void;

const W289_OUTBUF_CAP: i32 = 9437184;

/* Single-byte scratch for cstr walk (ban stack u8[1] mid-path). */
let g_w521_one: u8[1] = [];

/**
 * Append n bytes from p into out starting at current len. Returns 0 / -1.
 * tipU: `len = len + codegen_out_buf_len(out)` (ban mid `len=call()`).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function w521_codegen_out_append_bytes(out: *u8, p: *u8, n: i32): i32 {
  let i: i32 = 0;
  let len: i32 = 0;
  if (out == (0 as *u8) || p == (0 as *u8) || n < 0) {
    return 0 - 1;
  }
  unsafe {
    if (codegen_out_buf_len(out) < 0) {
      return 0 - 1;
    }
    len = 0;
    len = len + codegen_out_buf_len(out);
  }
  while (i < n) {
    if (len >= W289_OUTBUF_CAP - 1) {
      return 0 - 1;
    }
    out[len] = p[i];
    len = len + 1;
    i = i + 1;
  }
  unsafe {
    codegen_out_buf_set_len(out, len);
  }
  return 0;
}

/**
 * Append a NUL-terminated C string into out. Null s → 0. Returns 0 / -1.
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function w521_codegen_out_append_cstr(out: *u8, s: *u8): i32 {
  if (s == (0 as *u8)) {
    return 0;
  }
  while (s[0] != 0) {
    g_w521_one[0] = s[0];
    if (w521_codegen_out_append_bytes(out, &g_w521_one[0], 1) != 0) {
      return 0 - 1;
    }
    s = s + 1;
  }
  return 0;
}

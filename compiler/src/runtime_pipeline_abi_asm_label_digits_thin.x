// Thin pure: wave520 M2 — asm_label digit peers (peer-flat Soft Cap).
// Ubuntu tip CG002 when while-digit helpers + emit_next + format_label_id
// share one tip TU; digits live here so emit/format leaves stay tip-green.
// G.7: freestanding twin of historic w288_glue_format_{u32,i32}_to_buf
// (no snprintf). PRODUCT: injected with emit/format peers on cold PREFER.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

/**
 * Write unsigned decimal digits of val into buf[off..]. Returns bytes written or -1.
 * Digits go into the caller's buf reversed, then reverse in-place in that slice.
 * PLATFORM: SHARED — freestanding twin of w288_glue_format_u32_to_buf.
 */
#[no_mangle]
export function w520_format_u32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let t: i32 = val;
  let dig: i32 = 0;
  let a: u8 = 0;
  if (buf == (0 as *u8) || max <= 0 || off < 0) {
    return 0 - 1;
  }
  if (t < 0) {
    t = 0;
  }
  if (t == 0) {
    if (max < 1) {
      return 0 - 1;
    }
    buf[off] = 48;
    return 1;
  }
  while (t > 0) {
    if (n >= max) {
      return 0 - 1;
    }
    dig = t % 10;
    buf[off + n] = (48 + dig) as u8;
    n = n + 1;
    t = t / 10;
  }
  i = 0;
  while (i < n / 2) {
    a = buf[off + i];
    buf[off + i] = buf[off + n - 1 - i];
    buf[off + n - 1 - i] = a;
    i = i + 1;
  }
  return n;
}

/**
 * Write signed decimal digits of val into buf[off..]. Returns bytes written or -1.
 * PLATFORM: SHARED — freestanding twin of w288_glue_format_i32_to_buf.
 */
#[no_mangle]
export function w520_format_i32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  let start: i32 = off;
  let v: i32 = val;
  let n: i32 = 0;
  if (buf == (0 as *u8) || max <= 0 || off < 0) {
    return 0 - 1;
  }
  if (v < 0) {
    if (max < 2) {
      return 0 - 1;
    }
    buf[off] = 45;
    start = off + 1;
    if (v == (0 - 2147483647 - 1)) {
      v = 2147483647;
    } else {
      v = 0 - v;
    }
    n = w520_format_u32_to_buf(buf, start, max - 1, v);
    if (n < 0) {
      return 0 - 1;
    }
    return n + 1;
  }
  return w520_format_u32_to_buf(buf, off, max, v);
}

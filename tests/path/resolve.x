// See implementation.
const path = import("std.path");

/** Internal function `bytes_eq`.
 * Implements `bytes_eq`.
 * @param out *u8
 * @param len i32
 * @param a u8
 * @param b u8
 * @param c u8
 * @param d u8
 * @param e u8
 * @param f u8
 * @param g u8
 * @param h u8
 * @return i32
 */
function bytes_eq(out: *u8, len: i32, a: u8, b: u8, c: u8, d: u8, e: u8, f: u8, g: u8, h: u8): i32 {
  if (len != 8) { return 0; }
  if (out[0] != a || out[1] != b || out[2] != c || out[3] != d) { return 0; }
  if (out[4] != e || out[5] != f || out[6] != g || out[7] != h) { return 0; }
  return 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let base: u8[15] = [
    47, 102, 111, 111, 47, 98, 97, 114, 47, 98, 97, 122, 46, 116, 120
  ];
  let rel: u8[6] = [46, 46, 47, 113, 117, 120];
  let abs_ref: u8[9] = [47, 97, 98, 115, 47, 112, 97, 116, 104];
  let out: u8[32] = [];
  let n: i32 = 0;

  n = path.resolve(&out[0], 32, &base[0], 15, &rel[0], 6);
  if (n != 8) { return 1; }
  if (bytes_eq(&out[0], n, 47, 102, 111, 111, 47, 113, 117, 120) == 0) {
    return 2;
  }

  n = path.resolve(&out[0], 32, &base[0], 15, &abs_ref[0], 9);
  if (n != 9) { return 3; }
  if (out[0] != 47 || out[8] != 104) { return 4; }

  return 0;
}

/**
 * See implementation.
 */
const path = import("std.path");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let inp: u8[7] = [47, 47, 97, 47, 47, 47, 98];
  let out: u8[16] = [];
  let n: i32 = path.clean(&inp[0], 7, &out[0], 16);
  if (n != 4) { return 1; }
  if (out[0] != 47 || out[1] != 97 || out[2] != 47 || out[3] != 98) { return 2; }
  return 0;
}

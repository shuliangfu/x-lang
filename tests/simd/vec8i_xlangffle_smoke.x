// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: Vec8i = [0, 1, 2, 3, 4, 5, 6, 7];
  let m: i32[8] = [3, 2, 1, 0, 7, 6, 5, 4];
  let r: Vec8i = simd.shuffle(v, m);
  let _unused: Vec8i = r - r;
  return 0;
}

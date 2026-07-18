// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let mask: Vec8i = [1, 0, 1, 0, 0, 1, 0, 1];
  let a: Vec8i = [10, 10, 10, 10, 10, 10, 10, 10];
  let b: Vec8i = [1, 1, 1, 1, 1, 1, 1, 1];
  let r: Vec8i = simd.select(mask, a, b);
  let _unused: Vec8i = r - r;
  return 0;
}

// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let mask: Vec4f = [1.0, 0.0, 1.0, 0.0];
  let a: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let b: Vec4f = [0.5, 0.5, 0.5, 0.5];
  let r: Vec4f = simd.select(mask, a, b);
  let _unused: Vec4f = r - r;
  return 0;
}

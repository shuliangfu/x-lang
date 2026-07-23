// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let m: i32[4] = [3, 2, 1, 0];
  let r: Vec4f = simd.shuffle(v, m);
  let _unused: Vec4f = r - r;
  return 0;
}

// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let c: Vec4f = [0.5, 0.5, 0.5, 0.5];
  let f: Vec4f = simd.fma(a, b, c);
  if (f[0] != 2.0 || f[3] != 5.0) {
    return 1;
  }
  return 0;
}

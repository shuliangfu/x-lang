// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let vi: Vec8i = simd.splat(1);
  let vj: Vec8i = simd.splat(2);
  let vk: Vec8i = simd.add(vi, vj);
  let vf: Vec4f = simd.splat(1.0);
  let vg: Vec4f = simd.splat(2.0);
  let vh: Vec4f = simd.add(vf, vg);
  let _unused: Vec8i = vk - vk;
  let _unused2: Vec4f = vh - vh;
  return simd.placeholder();
}

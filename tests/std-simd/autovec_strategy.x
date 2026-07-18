// See implementation.
//
// See implementation.
const simd = import("std.simd");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let hw: i32 = simd.hw_available();
  let path: i32 = simd.recommend_path();
  if (hw != 0 && path != 1) {
    return 1;
  }
  if (hw == 0 && path != 0) {
    return 2;
  }
  if (path != 0 && path != 1) {
    return 3;
  }
  return 0;
}

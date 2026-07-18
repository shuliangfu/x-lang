// See implementation.
const vec = import("std.vec");

/** Internal function `early`.
 * Implements `early`.
 * @param flag i32
 * @return i32
 */
function early(flag: i32): i32 {
  let v: owned(Vec_u8) = vec.new();
  if (flag != 0) {
    return 42;
  }
  return vec.len(v);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (early(1) != 42) {
    return 1;
  }
  if (early(0) != 0) {
    return 2;
  }
  return 0;
}

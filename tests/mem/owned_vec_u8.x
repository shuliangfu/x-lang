// See implementation.
const vec = import("std.vec");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: owned(Vec_u8) = vec.new();
  return vec.len(v);
}

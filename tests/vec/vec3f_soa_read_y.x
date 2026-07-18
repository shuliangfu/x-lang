// See implementation.
const vec = import("std.vec");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: Vec3f_soa = vec.vec3f_soa_new();
  if (vec.vec3f_soa_reserve_one(&v) != 0) { return 100; }
  let x: f32 = v.col_y[0];
  return 0;
}

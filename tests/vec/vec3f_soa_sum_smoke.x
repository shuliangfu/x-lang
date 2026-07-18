// See implementation.
const vec = import("std.vec");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: Vec3f_soa = vec.vec3f_soa_new();
  if (vec.vec3f_soa_push(&v, 1.0, 0.0, 0.0) != 0) { return 11; }
  if (vec.vec3f_soa_push(&v, 2.0, 0.0, 0.0) != 0) { return 12; }
  if (vec.vec3f_soa_push(&v, 3.0, 0.0, 0.0) != 0) { return 13; }
  let x: f32 = vec.vec3f_soa_sum_x(&v);
  vec.vec3f_soa_deinit(&v);
  return x as i32;
}

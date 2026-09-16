/**
 * Cookbook: sole Vec3f_aos new+deinit (no push/reserve/sum).
 * Labi matcher is exact: Vec_* deinit needles do not cover
 * std_vec_vec3f_aos_deinit. Empty deinit must succeed.
 */
const vec = import("std.vec");

/**
 * Program entry: construct empty Vec3f_aos and deinit.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let v: Vec3f_aos = vec.vec3f_aos_new();
  vec.vec3f_aos_deinit(&v);
  return 0;
}

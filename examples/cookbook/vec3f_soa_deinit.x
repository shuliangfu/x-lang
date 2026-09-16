/**
 * Cookbook: sole Vec3f_soa new+deinit (no push/reserve/sum).
 * Labi matcher is exact: Vec_* deinit needles do not cover
 * std_vec_vec3f_soa_deinit. Empty deinit must succeed.
 */
const vec = import("std.vec");

/**
 * Program entry: construct empty Vec3f_soa and deinit.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let v: Vec3f_soa = vec.vec3f_soa_new();
  vec.vec3f_soa_deinit(&v);
  return 0;
}

/**
 * Cookbook: sole Vec3f_soa new+push (no deinit/reserve/sum).
 * Labi matcher is exact: Vec_* push/length needles do not cover
 * std_vec_vec3f_soa_push. Omitting deinit keeps the UNDEF unique.
 */
const vec = import("std.vec");

/**
 * Program entry: push one SOA triple and check length.
 * @return i32 — 0 on success; 1 if push fails; 2 if length is not 1
 */
function main(): i32 {
  let v: Vec3f_soa = vec.vec3f_soa_new();
  if (vec.vec3f_soa_push(&v, 1.0, 0.0, 0.0) != 0) { return 1; }
  if (v.length != 1) { return 2; }
  return 0;
}

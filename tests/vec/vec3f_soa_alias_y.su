const vec = import("std.vec");

function main(): i32 {
  let v: Vec3f_soa = vec.vec3f_soa_new();
  if (vec.vec3f_soa_reserve_one(&v) != 0) { return 100; }
  v.col_y = v.col_x;
  let x: f32 = v.col_y[0];
  return 0;
}

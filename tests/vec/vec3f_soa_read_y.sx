// 诊断：reserve 后 col_y[0] 读（col_x/col_z 正常，col_y 曾 SIGSEGV）
const vec = import("std.vec");

function main(): i32 {
  let v: Vec3f_soa = vec.vec3f_soa_new();
  if (vec.vec3f_soa_reserve_one(&v) != 0) { return 100; }
  let x: f32 = v.col_y[0];
  return 0;
}

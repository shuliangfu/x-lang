/**
 * Cookbook VEC-02：Vec_u16 push/get（STD-161）。
 */
const vec = import("std.vec");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: Vec_u16 = vec.new();
  if (vec.push(&v, 1000 as u16) != 0) { return 1; }
  if (vec.push(&v, 2000 as u16) != 0) { return 2; }
  if (vec.length(v) != 2) { return 3; }
  if (vec.get(v, 1) != 2000 as u16) { return 4; }
  vec.deinit(&v);
  return 0;
}

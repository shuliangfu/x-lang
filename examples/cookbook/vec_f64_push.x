/**
 * Cookbook: Vec_f64 push/get.
 * Non-integer payload: first-wins push_Vec_i32 cannot round-trip 1.5.
 */
const vec = import("std.vec");

/**
 * Program entry: push two f64 values and read them back.
 * @return i32 — 0 on success; 1..5 on push/length/get mismatch
 */
function main(): i32 {
  let v: Vec_f64 = vec.new();
  if (vec.push(&v, 1.5) != 0) { return 1; }
  if (vec.push(&v, 2.25) != 0) { return 2; }
  if (vec.length(v) != 2) { return 3; }
  if (vec.get(v, 0) != 1.5) { return 4; }
  if (vec.get(v, 1) != 2.25) { return 5; }
  vec.deinit(&v);
  return 0;
}

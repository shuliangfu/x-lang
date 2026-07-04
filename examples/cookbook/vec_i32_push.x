/**
 * Cookbook VEC-01：Vec_i32 push/pop/append_slice 基本路径（STD-014）。
 */
const vec = import("std.vec");

function main(): i32 {
  let v: Vec_i32 = vec.new();
  if (vec.push(&v, 10) != 0) { return 1; }
  if (vec.push(&v, 20) != 0) { return 2; }
  if (vec.len(v) != 2) { return 3; }
  if (vec.pop(&v) != 20) { return 4; }
  let tail: i32[2] = [30, 40];
  if (vec.extend(&v, &tail[0], 2) != 0) { return 5; }
  vec.deinit(&v);
  return 0;
}

/**
 * Cookbook: Vec_u64 push/get.
 * Two distinct values: i32-stride first-wins stores 4-byte slots so get(0)
 * as u64 would not equal 1 (little-endian 1|(2<<32)).
 */
const vec = import("std.vec");

/**
 * Program entry: push two u64 values and read them back.
 * @return i32 — 0 on success; 1..5 on push/length/get mismatch
 */
function main(): i32 {
  let v: Vec_u64 = vec.new();
  if (vec.push(&v, 1 as u64) != 0) { return 1; }
  if (vec.push(&v, 2 as u64) != 0) { return 2; }
  if (vec.length(v) != 2) { return 3; }
  if (vec.get(v, 0) != 1 as u64) { return 4; }
  if (vec.get(v, 1) != 2 as u64) { return 5; }
  vec.deinit(&v);
  return 0;
}

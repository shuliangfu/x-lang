/**
 * Cookbook: sole Vec_f64 new+deinit (no length/push/from_slice/extend).
 * Labi matcher is exact: deinit_Vec_i32/u16 needles do not cover f64.
 * This is the leftover BLD001 after the push-u64 leaf.
 */
const vec = import("std.vec");

/**
 * Program entry: construct empty Vec_f64 and deinit.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let v: Vec_f64 = vec.new();
  vec.deinit(&v);
  return 0;
}

/**
 * Cookbook: sole Vec_u64 new+length (no deinit/push/from_slice/extend).
 * Labi matcher is exact: length_Vec_i32/u16 needles do not cover u64.
 * Empty length must be 0. Omitting deinit keeps the UNDEF unique.
 */
const vec = import("std.vec");

/**
 * Program entry: construct empty Vec_u64 and check length.
 * @return i32 — 0 on success; 1 if length is not 0
 */
function main(): i32 {
  let v: Vec_u64 = vec.new();
  if (vec.length(v) != 0) { return 1; }
  return 0;
}

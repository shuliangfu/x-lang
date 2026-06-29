/**
 * Cookbook SET-01：Set_u64 insert/contains/remove 基本路径（STD-015）。
 */
const set = import("std.set");

function main(): i32 {
  let su: Set_u64 = set.new(0);
  if (set.with_capacity(&su, 4) != 0) { return 1; }
  if (set.insert(&su, 1000 as u64) != 0) { return 2; }
  if (set.contains_key(su, 1000 as u64) != 1) { return 3; }
  if (set.remove(&su, 1000 as u64) != 1) { return 4; }
  set.deinit(&su);
  return 0;
}

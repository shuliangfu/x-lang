// tests/sort/main.x — std.sort 回归：sort_i32、sort_u8。
const sort = import("std.sort");
const debug = import("core.debug");

function main(): i32 {
  let a: i32[4] = [3, 1, 4, 2];
  sort.sort(&a[0], 4);
  debug.assert_eq_i32(a[0], 1);
  debug.assert_eq_i32(a[1], 2);
  debug.assert_eq_i32(a[2], 3);
  debug.assert_eq_i32(a[3], 4);
  let b: u8[3] = [200, 100, 150];
  sort.sort(&b[0], 3);
  let b0: u32 = b[0];
  let b1: u32 = b[1];
  let b2: u32 = b[2];
  debug.assert_eq_u32(b0, 100);
  debug.assert_eq_u32(b1, 150);
  debug.assert_eq_u32(b2, 200);
  return 0;
}

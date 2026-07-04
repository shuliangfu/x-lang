// STD-060：稳定升序 i32 烟测
const sort = import("std.sort");
const debug = import("core.debug");

function main(): i32 {
  let a: i32[4] = [3, 1, 4, 2];
  sort.stable(&a[0], 4);
  debug.assert_eq_i32(a[0], 1);
  debug.assert_eq_i32(a[1], 2);
  debug.assert_eq_i32(a[2], 3);
  debug.assert_eq_i32(a[3], 4);
  return 0;
}

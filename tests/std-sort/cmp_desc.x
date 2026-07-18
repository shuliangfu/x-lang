// See implementation.
const sort = import("std.sort");
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32[4] = [3, 1, 4, 2];
  let cmp_fn: usize = sort.cmp_desc_fn();
  sort.cmp(&a[0], 4, cmp_fn);
  debug.assert_eq_i32(a[0], 4);
  debug.assert_eq_i32(a[1], 3);
  debug.assert_eq_i32(a[2], 2);
  debug.assert_eq_i32(a[3], 1);
  return 0;
}

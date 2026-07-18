// See implementation.
//
// See implementation.
// See implementation.
const async_mod = import("std.async");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  async_mod.scheduler_reset();
  let n: i64 = async_mod.coop_pingpong(1000);
  if (n != 2000) {
    return 1;
  }
  return 0;
}

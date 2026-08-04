// See implementation.
const async_mod = import("std.async");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let total: i64 = async_mod.coop_pingpong_jmp(1000);
  if (total != 2000) {
    return 1;
  }
  return 0;
}

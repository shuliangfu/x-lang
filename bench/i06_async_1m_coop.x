// See implementation.
// See implementation.
const async_mod = import("std.async");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let rounds: i64 = 1000000;
  let a: i64 = async_mod.coop_pingpong(rounds);
  if (a != 2000000) { return 1; }
  let b: i64 = async_mod.coop_pingpong_jmp(rounds);
  if (b != 2000000) { return 2; }
  return 0;
}

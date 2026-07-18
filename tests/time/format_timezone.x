// See implementation.
// See implementation.
const time = import("std.time");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let off: i32 = 0;
  off = time.wall_local_offset_min();
  if (off < -840 || off > 840) { return 3; }
  return 0;
}

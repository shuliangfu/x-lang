// See implementation.
// See implementation.
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[16] = [72, 105, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  io.write(&buf[0], 3, 0);
  if (io.stdin() != 0) { return 2; }
  if (io.stdout() != 1) { return 3; }
  return 0;
}

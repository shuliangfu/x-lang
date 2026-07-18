/**
 * See implementation.
 */
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[8] = [];
  let _r: i32 = io.read_fd(0, &buf[0], 8);
  let _w: i32 = io.write_fd(1, &buf[0], 0);
  return 0;
}

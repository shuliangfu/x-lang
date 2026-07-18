// See implementation.
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: u8[]<io_read_ptr> = io.stdin_slice();
  if (s.length <= 0) {
    return 1;
  }
  if (s.data[0] != 65) {
    return 2;
  }
  return 0;
}

// See implementation.
const io = import("std.io");

/** Internal function `slice_len`.
 * Query helper `slice_len`.
 * @param buf u8[]<io_read_ptr>
 * @return i32
 */
function slice_len(buf: u8[]<io_read_ptr>): i32 {
  return buf.length as i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: u8[]<io_read_ptr> = io.stdin_slice();
  if (s.length <= 0) {
    return 1;
  }
  let n: i32 = slice_len(s);
  if (n != s.length as i32) {
    return 2;
  }
  if (s.data[0] != 65) {
    return 3;
  }
  return 0;
}

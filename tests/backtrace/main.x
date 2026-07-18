// See implementation.
// See implementation.

const backtrace = import("std.backtrace");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[64] = [];
  let n: i32 = backtrace.capture(&buf[0], 8);
  if (n <= 0) {
    return 0;
  }
  return 0;
}

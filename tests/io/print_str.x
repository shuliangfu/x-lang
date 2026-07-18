// See implementation.
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[8] = [111, 107, 10, 0, 0, 0, 0, 0];
  let n: i32 = io.print(buf, 3);
  if (n != 3) { return 1; }
  return 0;
}

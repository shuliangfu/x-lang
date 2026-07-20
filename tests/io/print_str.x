// See implementation.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[8] = [111, 107, 10, 0, 0, 0, 0, 0];
  let n: i32 = fmt.println(buf, 3);
  return n;
}

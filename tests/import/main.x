// See implementation.
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 10];
  let n: i32 = io.print(msg, 12);
  return if (n >= 0) { 0 } else { 1 };
}

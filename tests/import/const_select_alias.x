// See implementation.
const fmt = import("std.fmt");
const driver = import("std.io.driver");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 10];
  let n: i32 = fmt.print(msg, 12);
  let buf: Buffer = Buffer { ptr: 0, length: 0, handle: 0 };
  return if (n >= 0 && buf.length == 0) { 0 } else { 1 };
}

// See implementation.
const driver = import("std.io.driver");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: Buffer = Buffer { ptr: 0, length: 0, handle: 0 };
  return if (buf.handle == 0) { 0 } else { 1 };
}

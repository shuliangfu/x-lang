// See implementation.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let msg: *u8 = "Hello World\n";
  let n: i32 = fmt.print(msg, 12);
  return if (n >= 0) { 0 } else { 1 };
}

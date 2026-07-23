// See implementation.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = fmt.println("Hello World", 11);
  return if (a >= 0) { 0 } else { 1 };
}

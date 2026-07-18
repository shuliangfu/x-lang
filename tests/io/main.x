// See implementation.
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = io.print(42);
  return n;
}

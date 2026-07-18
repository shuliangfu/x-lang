// See implementation.
const dbg = import("std.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = dbg.println("debug line");
  let b: i32 = dbg.assert(true);
  return if (a == 0 && b == 0) { 0 } else { 1 };
}

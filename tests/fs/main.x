// See implementation.
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let h: i32 = fs.invalid();
  return if (h != -1) { 1 } else { 0 }
}

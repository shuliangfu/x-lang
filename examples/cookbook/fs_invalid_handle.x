/**
 * See implementation.
 */
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let h: i32 = fs.invalid();
  if (h != -1) { return 1; }
  return 0;
}

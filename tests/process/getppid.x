// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const process = import("std.process");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ppid: i32 = process.getppid();
  if (ppid >= -1) {
    return 0;
  }
  return 0;
}

/**
 * See implementation.
 */
const process = import("std.process");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pid: i32 = process.getpid();
  if (pid <= 0) { return 1; }
  return 0;
}

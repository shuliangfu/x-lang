// See implementation.
//
// See implementation.
// See implementation.
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
  let program: u8[16] = [47, 110, 111, 110, 101, 120, 105, 115, 116, 101, 110, 116, 0, 0, 0, 0];
  let r: i32 = process.exec_simple(&program[0]);
  if (r != -1) {
    return 1;
  }
  return 0;
}

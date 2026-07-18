// See implementation.
//
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
  if (process.args_count() < 1) {
    return 1;
  }
  if (process.arg(0) == 0) {
    return 2;
  }
  // See implementation.
  let path_name: u8[8] = [80, 65, 84, 72, 0, 0, 0, 0];
  let val: *u8 = process.getenv(&path_name[0]);
  // See implementation.
  if (val != 0) {
    return 0;
  }
  return 0;
}

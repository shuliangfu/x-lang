// See implementation.
const dynlib = import("std.dynlib");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let path: u8[4] = [0, 0, 0, 0];
  if (dynlib.open(&path[0]) != 0) {
    return 1;
  }
  return 0;
}

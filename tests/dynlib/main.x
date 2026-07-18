// See implementation.
const dynlib = import("std.dynlib");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let path: u8[4] = [0, 0, 0, 0];
  let lib: *u8 = dynlib.open(&path[0]);
  if (lib != 0) { return 1; }
  return 0;
}

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
  let buf1: u8[128] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0];
  let n1: i32 = process.getcwd(&buf1[0], 128);
  if (n1 <= 0) {
    return 1;
  }
  let dot: u8[4] = [46, 0, 0, 0];
  if (process.chdir(&dot[0]) != 0) {
    return 2;
  }
  let buf2: u8[128] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0];
  let n2: i32 = process.getcwd(&buf2[0], 128);
  if (n2 <= 0) {
    return 3;
  }
  return 0;
}

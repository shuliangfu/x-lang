// See implementation.
const sys = import("std.sys");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 83, 104, 117, 33, 10, 0];
  let n: i32 = sys.write_stdout(&msg[0], 11);
  if (n != 11) {
    return 1;
  }
  return 0;
}

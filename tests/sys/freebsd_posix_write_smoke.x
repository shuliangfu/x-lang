// See implementation.
const sys = import("std.sys");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (sys.freebsd_write_available() != 1) {
    return 1;
  }
  /* "Hello Xlang!\n" — matches platform write-gate EXPECTED (single authority). */
  let msg: u8[14] = [72, 101, 108, 108, 111, 32, 88, 108, 97, 110, 103, 33, 10, 0];
  let n: i32 = sys.freebsd_write_stdout(&msg[0], 13);
  if (n != 13) {
    return 2;
  }
  return 0;
}

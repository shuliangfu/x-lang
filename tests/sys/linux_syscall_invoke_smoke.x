// See implementation.
const sys = import("std.sys");
const linux = import("std.sys.linux");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 1;
  }
  /* See implementation. */
  let z: i32 = linux.linux_syscall_read(0, 0 as *u8, 0);
  if (z != 0) {
    return 2;
  }
  /* "Hello Xlang!\n" — matches platform write-gate EXPECTED (single authority). */
  let msg: u8[14] = [72, 101, 108, 108, 111, 32, 88, 108, 97, 110, 103, 33, 10, 0];
  let n: i32 = sys.os_write_stdout(&msg[0], 13);
  if (n != 13) {
    return 3;
  }
  return 0;
}

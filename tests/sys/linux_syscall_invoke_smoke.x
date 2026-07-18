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
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 83, 104, 117, 33, 10, 0];
  let n: i32 = sys.os_write_stdout(&msg[0], 11);
  if (n != 11) {
    return 3;
  }
  return 0;
}

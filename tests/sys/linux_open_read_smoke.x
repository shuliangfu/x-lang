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
  let path: u8[35] = [
    47, 116, 109, 112, 47, 115, 104, 117, 120, 95, 108, 105, 110, 117, 120, 95,
    111, 112, 101, 110, 95, 114, 101, 97, 100, 95, 103, 97, 116, 101, 46, 116,
    120, 116, 0,
  ];
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = sys.read_file_into(&path[0], &buf[0], 8);
  if (n != 2) {
    return 2;
  }
  if (buf[0] != 79 || buf[1] != 75) {
    return 3;
  }
  return 0;
}

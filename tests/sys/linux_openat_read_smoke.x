// See implementation.
const linux = import("std.sys.linux");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let path: u8[37] = [
    47, 116, 109, 112, 47, 115, 104, 117, 120, 95, 108, 105, 110, 117, 120, 95,
    111, 112, 101, 110, 97, 116, 95, 114, 101, 97, 100, 95, 103, 97, 116, 101,
    46, 116, 120, 116, 0,
  ];
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = linux.linux_read_file_openat(-100, &path[0], &buf[0], 8);
  if (n != 2) {
    return 1;
  }
  if (buf[0] != 65 || buf[1] != 84) {
    return 2;
  }
  return 0;
}

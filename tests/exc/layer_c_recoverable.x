// See implementation.
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let path: u8[36] =
    [116, 101, 115, 116, 115, 47, 101, 120, 99, 47, 46, 110, 111, 95, 115, 117, 99, 104, 95, 102, 115, 95, 112, 97, 116, 104, 95, 120, 120, 120, 0, 0, 0, 0, 0, 0];
  let fd: i32 = fs.open(&path[0]);
  if (fd >= 0) {
    fs.close(fd);
    return 1;
  }
  let err: i32 = fs.last_error();
  if (err == 0) { return 2; }
  return 0;
}

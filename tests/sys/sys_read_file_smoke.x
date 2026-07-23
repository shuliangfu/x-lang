// See implementation.
const sys = import("std.sys");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let path: u8[30] = [47, 116, 109, 112, 47, 120, 108, 97, 110, 103, 95, 114, 101, 97, 100, 95, 102, 105, 108, 101, 95, 103, 97, 116, 101, 46, 116, 120, 116, 0];
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = sys.read_file_into(&path[0], &buf[0], 8);
  if (n != 3) {
    return 1;
  }
  if (buf[0] != 65 || buf[1] != 66 || buf[2] != 67) {
    return 2;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let path: u8[31] =
  [116, 101, 115, 116, 115, 47, 98, 101, 110, 99, 104, 47, 46, 105, 111, 95, 109, 109, 97, 112, 95,
  98, 101, 110, 99, 104, 95, 116, 109, 112, 0];
  let fd: i32 = fs.open(&path[0]);
  if (fd < 0) { return 1; }
  let buf: u8[4096] = [];
  let sum: i32 = 0;
  let rounds: i32 = 0;
  /* See implementation. */
  while (rounds < 4096) {
    let nr: isize = fs.read(fd, &buf[0], 4096);
    if (nr != 4096) {
      fs.close(fd);
      return 2;
    }
    let si: i32 = 0;
    while (si < 4096) {
      sum = sum + (buf[si] as i32);
      si = si + 1;
    }
    rounds = rounds + 1;
  }
  if (fs.close(fd) != 0) { return 3; }
  return sum & 255;
}

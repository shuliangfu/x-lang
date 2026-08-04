// See implementation.
// See implementation.
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let path: u8[32] =
  [116, 101, 115, 116, 115, 47, 98, 101, 110, 99, 104, 47, 46, 105, 111, 95, 119, 114, 105, 116,
  101, 95, 98, 101, 110, 99,
  104, 95, 116, 109, 112, 0];
  let fd: i32 = fs.create(&path[0]);
  if (fd < 0) { return 1; }
  let buf: u8[4096] = [];
  let ci: i32 = 0;
  let sum: i32 = 0;
  while (ci < 4096) {
    let bi: i32 = 0;
    while (bi < 4096) {
      let b: u8 = ((ci + bi) & 255) as u8;
      buf[bi] = b;
      sum = sum + (b as i32);
      bi = bi + 1;
    }
    let nw: isize = fs.write(fd, &buf[0], 4096);
    if (nw != 4096) {
      fs.close(fd);
      return 2;
    }
    ci = ci + 1;
  }
  if (fs.close(fd) != 0) { return 3; }
  return sum & 255;
}

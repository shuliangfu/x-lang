// See implementation.
//
// See implementation.
// See implementation.
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  if (fs.invalid() != -1) { return 1; }
  // See implementation.
  if (fs.chunk_size() < 4096) { return 2; }
  // See implementation.
  let bad: u8[20] = [47, 116, 109, 112, 47, 110, 111, 95, 115, 117, 99, 104, 95, 102, 105, 108, 101, 0, 0, 0];
  if (fs.open(&bad[0]) >= 0) { return 3; }
  // See implementation.
  let path: u8[22] = [47, 116, 109, 112, 47, 115, 104, 117, 95, 102, 115, 95, 98, 111, 117, 110, 100, 97, 114, 121, 0, 0];
  let fd_w: i32 = fs.create(&path[0]);
  if (fd_w < 0) { return 4; }
  // See implementation.
  let payload: u8[4] = [1, 2, 3, 4];
  if (fs.write(fd_w, &payload[0], 4) != 4) { return 5; }
  fs.close(fd_w);
  // See implementation.
  let fd_r: i32 = fs.open(&path[0]);
  if (fd_r < 0) { return 6; }
  // See implementation.
  let buf: u8[4] = [0, 0, 0, 0];
  if (fs.read(fd_r, &buf[0], 4) != 4) { return 7; }
  // See implementation.
  if (buf[0] != 1 || buf[3] != 4) { return 8; }
  // See implementation.
  let buf2: u8[2] = [0, 0];
  if (fs.pread(fd_r, &buf2[0], 2, 1) != 2) { return 9; }
  if (buf2[0] != 2 || buf2[1] != 3) { return 10; }
  fs.close(fd_r);
  // See implementation.
  if (fs.path_readable(&path[0]) != 1) { return 11; }
  return 0;
}

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
  [116,101,115,116,115,47,102,115,47,46,109,109,97,112,95,114,111,46,116,109,112,0,0,0,0,0,0,0,0,0,0
  ,0];
  let fd: i32 = fs.create(&path[0]);
  if (fd < 0) { return 1; }
  let buf: u8[4] = [88, 89, 90, 10];
  let n: isize = fs.write(fd, &buf[0], 4);
  if (fs.sync(fd) != 0) { fs.close(fd); return 2; }
  fs.close(fd);
  if (n != 4) { return 2; }
  let size: usize = 0;
  let ptr: *u8 = fs.mmap_ro(&path[0], &size);
  if (ptr == 0) { return 3; }
  if (size != 4) { return 4; }
  if (ptr[0] != 88) { return 5; }
  if (ptr[1] != 89) { return 6; }
  let r: i32 = fs.munmap(ptr, size);
  if (r != 0) { return 7; }
  return 0;
}

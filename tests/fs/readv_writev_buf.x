// See implementation.
// See implementation.
// See implementation.
const fs = import("std.fs");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[4] = [65, 66, 67, 68];
  let bufs: FsIovecBuf[2] = [
  { ptr: &buf[0], length: 2, handle: 0 },
  { ptr: &buf[2], length: 2, handle: 0 }
  ];
  let bad: i32 = -1;
  let rw: i64 = fs.writev_buf(bad, &bufs[0], 2);
  let rr: i64 = fs.readv_buf(bad, &bufs[0], 1);
  /* i64 vs i32 lit: cast -1 to i64 (strict typeck). */
  if (rw != (-1 as i64) || rr != (-1 as i64)) { return 1; }
  return 0;
}

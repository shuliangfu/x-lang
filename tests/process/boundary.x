// See implementation.
//
// See implementation.
// See implementation.
const process = import("std.process");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  if (process.getpid() <= 0) { return 1; }
  // See implementation.
  if (process.getppid() < 0) { return 2; }
  // See implementation.
  if (process.args_count() < 0) { return 3; }
  // See implementation.
  let a0: *u8 = process.arg(0);
  if (a0 == 0 as *u8) { return 4; }
  // See implementation.
  let rd: i32 = 0;
  let wr: i32 = 0;
  if (process.pipe(&rd, &wr) != 0) { return 5; }
  // See implementation.
  if (rd < 0 || wr < 0) { return 6; }
  // See implementation.
  let buf: u8[128] = [];
  let n: i32 = process.getcwd(&buf[0], 128);
  if (n <= 0) { return 7; }
  // See implementation.
  let cp: *u8 = process.getcwd_ptr();
  if (cp == 0 as *u8) { return 8; }
  if (process.getcwd_cached_len() <= 0) { return 9; }
  // See implementation.
  let path_name: u8[5] = [80, 65, 84, 72, 0];
  let _pv: *u8 = process.getenv(&path_name[0]);
  return 0;
}

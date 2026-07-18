/**
 * See implementation.
 * See implementation.
 */
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p1: *u8 = io.read_stdin_ptr();
  if (p1 == 0 as *u8) {
    return 1;
  }
  if (io.ptr_len() < 2) {
    return 2;
  }
  let g1: u64 = io.ptr_gen();
  if (io.ptr_valid(g1) != 1) {
    return 3;
  }
  if (p1[0] != 65) {
    return 4;
  }
  /* See implementation. */
  let p2: *u8 = io.read_stdin_ptr();
  if (p2 != 0 as *u8 && io.ptr_len() > 0 && p2[0] == 65) {
    return 11;
  }
  if (io.ptr_valid(g1) != 0) {
    return 5;
  }
  let g2: u64 = io.ptr_gen();
  if (io.ptr_valid(g2) != 1) {
    return 6;
  }
  return 0;
}

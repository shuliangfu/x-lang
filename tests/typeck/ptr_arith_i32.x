/** Internal function `write_back`.
 * Write path helper `write_back`.
 * @param out_len *i32
 * @return void
 */
function write_back(out_len: *i32): void {
  unsafe { *out_len = 42; }
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[8] = [1, 2, 3, 4, 0, 0, 0, 0];
  let out: *u8 = &buf[0];
  let n: i32 = 2;
  let p: *u8 = out + n;
  unsafe {
    if (p[0] != 3) {
      return 1;
    }
  }
  let len: i32 = 0;
  write_back(&len);
  if (len != 42) {
    return 2;
  }
  return 0;
}

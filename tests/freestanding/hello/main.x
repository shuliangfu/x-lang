// See implementation.
/* See implementation. */
extern function xlang_sys_write(fd: i32, buf: *u8, len: i32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* "Hello Xlang!\n" — matches run-freestanding-hello EXPECTED (single authority). */
  let msg: u8[14] = [72, 101, 108, 108, 111, 32, 88, 108, 97, 110, 103, 33, 10, 0];
  let n: i32 = unsafe { xlang_sys_write(1, &msg[0], 13) };
  if (n != 13) {
    return 1;
  }
  return 0;
}

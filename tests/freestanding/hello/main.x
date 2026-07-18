// See implementation.
/* See implementation. */
extern function shux_sys_write(fd: i32, buf: *u8, len: i32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 83, 104, 117, 33, 10, 0];
  let n: i32 = unsafe { shux_sys_write(1, &msg[0], 11) };
  if (n != 11) {
    return 1;
  }
  return 0;
}

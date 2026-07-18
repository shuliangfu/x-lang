// See implementation.
extern function read_fd(fd: i32, ptr: *u8, len: usize): i32;

/* See implementation. */
async function read_four(): i32 {
  let buf: u8[4] = [];
  let n: i32 = await unsafe { read_fd(0, buf as *u8, 4) };
  return n;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = run read_four();
  if (n != 4) {
    return 1;
  }
  return 0;
}

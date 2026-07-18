// See implementation.
// See implementation.
extern function read_fd(fd: i32, ptr: *u8, len: usize): i32;

/* See implementation. */
async function read_chunk(fd: i32): i32 {
  let buf: u8[8] = [];
  let n: i32 = await unsafe { read_fd(fd, buf as *u8, 8) };
  return n;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n1: i32 = run read_chunk(3);
  let n2: i32 = run read_chunk(4);
  if (n1 + n2 != 5) {
    return 1;
  }
  return 0;
}
